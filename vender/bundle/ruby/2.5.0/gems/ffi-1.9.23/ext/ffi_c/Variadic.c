/*
 * Copyright (c) 2008-2010 Wayne Meissner
 * Copyright (C) 2009 Andrea Fazzi <andrea.fazzi@alcacoop.it>
 * Copyright (c) 2008-2013, Ruby FFI project contributors
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the Ruby FFI project nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef _MSC_VER
#include <sys/param.h>
#endif
#include <sys/types.h>

#include <stdio.h>
#ifndef _MSC_VER
# include <stdint.h>
# include <stdbool.h>
#else
# include "win32/stdbool.h"
# include "win32/stdint.h"
#endif
#include <ruby.h>

#include <ffi.h>
#include "rbffi.h"
#include "compat.h"

#include "AbstractMemory.h"
#include "Pointer.h"
#include "Types.h"
#include "Type.h"
#include "LastError.h"
#include "MethodHandle.h"
#include "Call.h"
#include "Thread.h"

typedef struct VariadicInvoker_ {
    VALUE rbAddress;
    VALUE rbReturnType;
    VALUE rbEnums;

    Type* returnType;
    ffi_abi abi;
    void* function;
    int paramCount;
    bool blocking;
} VariadicInvoker;


static VALUE variadic_allocate(VALUE klass);
static VALUE variadic_initialize(VALUE self, VALUE rbFunction, VALUE rbParameterTypes,
        VALUE rbReturnType, VALUE options);
static void variadic_mark(VariadicInvoker *);

static VALUE classVariadicInvoker = Qnil;


static VALUE
variadic_allocate(VALUE klass)
{
    VariadicInvoker *invoker;
    VALUE obj = Data_Make_Struct(klass, VariadicInvoker, variadic_mark, -1, invoker);

    invoker->rbAddress = Qnil;
    invoker->rbEnums = Qnil;
    invoker->rbReturnType = Qnil;
    invoker->blocking = false;

    return obj;
}

static void
variadic_mark(VariadicInvoker *invoker)
{
    rb_gc_mark(invoker->rbEnums);
    rb_gc_mark(invoker->rbAddress);
    rb_gc_mark(invoker->rbReturnType);
}

static VALUE
variadic_initialize(VALUE self, VALUE rbFunction, VALUE rbParameterTypes, VALUE rbReturnType, VALUE options)
{
    VariadicInvoker* invoker = NULL;
    VALUE retval = Qnil;
    VALUE convention = Qnil;
    VALUE fixed = Qnil;
#if defined(X86_WIN32)
    VALUE rbConventionStr;
#endif
    int i;

    Check_Type(options, T_HASH);
    convention = rb_hash_aref(options, ID2SYM(rb_intern("convention")));

    Data_Get_Struct(self, VariadicInvoker, invoker);
    invoker->rbEnums = rb_hash_aref(options, ID2SYM(rb_intern("enums")));
    invoker->rbAddress = rbFunction;
    invoker->function = rbffi_AbstractMemory_Cast(rbFunction, rbffi_PointerClass)->address;
    invoker->blocking = RTEST(rb_hash_aref(options, ID2SYM(rb_intern("blocking"))));

#if defined(X86_WIN32)
    rbConventionStr = rb_funcall2(convention, rb_intern("to_s"), 0, NULL);
    invoker->abi = (RTEST(convention) && strcmp(StringValueCStr(rbConventionStr), "stdcall") == 0)
            ? FFI_STDCALL : FFI_DEFAULT_ABI;
#else
    invoker->abi = FFI_DEFAULT_ABI;
#endif

    invoker->rbReturnType = rbffi_Type_Lookup(rbReturnType);
    if (!RTEST(invoker->rbReturnType)) {
        VALUE typeName = rb_funcall2(rbReturnType, rb_intern("inspect"), 0, NULL);
        rb_raise(rb_eTypeError, "Invalid return type (%s)", RSTRING_PTR(typeName));
    }

    Data_Get_Struct(rbReturnType, Type, invoker->returnType);

    invoker->paramCount = -1;

    fixed = rb_ary_new2(RARRAY_LEN(rbParameterTypes) - 1);
    for (i = 0; i < RARRAY_LEN(rbParameterTypes); ++i) {
        VALUE entry = rb_ary_entry(rbParameterTypes, i);
        VALUE rbType = rbffi_Type_Lookup(entry);
        Type* type;

        if (!RTEST(rbType)) {
            VALUE typeName = rb_funcall2(entry, rb_intern("inspect"), 0, NULL);
            rb_raise(rb_eTypeError, "Invalid parameter type (%s)", RSTRING_PTR(typeName));
        }
        Data_Get_Struct(rbType, Type, type);
        if (type->nativeType != NATIVE_VARARGS) {
            rb_ary_push(fixed, entry);
        }
    }
    /*
     * @fixed and @type_map are used by the parameter mangling ruby code
     */
    rb_iv_set(self, "@fixed", fixed);
    rb_iv_set(self, "@type_map", rb_hash_aref(options, ID2SYM(rb_intern("type_map"))));

    return retval;
}

static VALUE
variadic_invoke(VALUE self, VALUE parameterTypes, VALUE parameterValues)
{
    VariadicInvoker* invoker;
    FFIStorage* params;
    void* retval;
    ffi_cif cif;
    void** ffiValues;
    ffi_type** ffiParamTypes;
    ffi_type* ffiReturnType;
    Type** paramTypes;
    VALUE* argv;
    int paramCount = 0, fixedCount = 0, i;
    ffi_status ffiStatus;
    rbffi_frame_t frame = { 0 };

    Check_Type(parameterTypes, T_ARRAY);
    Check_Type(parameterValues, T_ARRAY);

    Data_Get_Struct(self, VariadicInvoker, invoker);
    paramCount = (int) RARRAY_LEN(parameterTypes);
    paramTypes = ALLOCA_N(Type *, paramCount);
    ffiParamTypes = ALLOCA_N(ffi_type *, paramCount);
    params = ALLOCA_N(FFIStorage, paramCount);
    ffiValues = ALLOCA_N(void*, paramCount);
    argv = ALLOCA_N(VALUE, paramCount);
    retval = alloca(MAX(invoker->returnType->ffiType->size, FFI_SIZEOF_ARG));

    for (i = 0; i < paramCount; ++i) {
        VALUE rbType = rb_ary_entry(parameterTypes, i);
        
        if (!rb_obj_is_kind_of(rbType, rbffi_TypeClass)) {
            rb_raise(rb_eTypeError, "wrong type.  Expected (FFI::Type)");
        }
        Data_Get_Struct(rbType, Type, paramTypes[i]);

        switch (paramTypes[i]->nativeType) {
            case NATIVE_INT8:
            case NATIVE_INT16:
            case NATIVE_INT32:
                rbType = rb_const_get(rbffi_TypeClass, rb_intern("INT32"));
                Data_Get_Struct(rbType, Type, paramTypes[i]);
                break;
            case NATIVE_UINT8:
            case NATIVE_UINT16:
            case NATIVE_UINT32:
                rbType = rb_const_get(rbffi_TypeClass, rb_intern("UINT32"));
                Data_Get_Struct(rbType, Type, paramTypes[i]);
                break;
            
            case NATIVE_FLOAT32:
                rbType = rb_const_get(rbffi_TypeClass, rb_intern("DOUBLE"));
                Data_Get_Struct(rbType, Type, paramTypes[i]);
                break;

            default:
                break;
        }
        
        
        ffiParamTypes[i] = paramTypes[i]->ffiType;
        if (ffiParamTypes[i] == NULL) {
            rb_raise(rb_eArgError, "Invalid parameter type #%x", paramTypes[i]->nativeType);
        }
        argv[i] = rb_ary_entry(parameterValues, i);
    }

    ffiReturnType = invoker->returnType->ffiType;
    if (ffiReturnType == NULL) {
        rb_raise(rb_eArgError, "Invalid return type");
    }

    /*Get the number of fixed args from @fixed array*/
    fixedCount = RARRAY_LEN(rb_iv_get(self, "@fixed"));

#ifdef HAVE_FFI_PREP_CIF_VAR
    ffiStatus = ffi_prep_cif_var(&cif, invoker->abi, fixedCount, paramCount, ffiReturnType, ffiParamTypes);
#else
    ffiStatus = ffi_prep_cif(&cif, invoker->abi, paramCount, ffiReturnType, ffiParamTypes);
#endif
    switch (ffiStatus) {
        case FFI_BAD_ABI:
            rb_raise(rb_eArgError, "Invalid ABI specified");
        case FFI_BAD_TYPEDEF:
            rb_raise(rb_eArgError, "Invalid argument type specified");
        case FFI_OK:
            break;
        default:
            rb_raise(rb_eArgError, "Unknown FFI error");
    }

    rbffi_SetupCallParams(paramCount, argv, -1, paramTypes, params,
        ffiValues, NULL, 0, invoker->rbEnums);
    
    rbffi_frame_push(&frame);
#ifdef HAVE_RB_THREAD_CALL_WITHOUT_GVL
    /* In Call.c, blocking: true is supported on older ruby variants
     * without rb_thread_call_without_gvl by allocating on the heap instead
     * of the stack. Since this functionality is being added later,
     * we’re skipping support for old rubies here. */
    if(unlikely(invoker->blocking)) {
        rbffi_blocking_call_t* bc;
        bc = ALLOCA_N(rbffi_blocking_call_t, 1);
        bc->retval = retval;
        bc->function = invoker->function;
        bc->ffiValues = ffiValues;
        bc->params = params;
        bc->frame = &frame;
        bc->cif = cif;

        rb_rescue2(rbffi_do_blocking_call, (VALUE) bc, rbffi_save_frame_exception, (VALUE) &frame, rb_eException, (VALUE) 0);
    } else {
        ffi_call(&cif, FFI_FN(invoker->function), retval, ffiValues);
    }
#else
    ffi_call(&cif, FFI_FN(invoker->function), retval, ffiValues);
#endif
    rbffi_frame_pop(&frame);
    
    rbffi_save_errno();
    
    if (RTEST(frame.exc) && frame.exc != Qnil) {
        rb_exc_raise(frame.exc);
    }

    return rbffi_NativeValue_ToRuby(invoker->returnType, invoker->rbReturnType, retval);
}


void
rbffi_Variadic_Init(VALUE moduleFFI)
{
    classVariadicInvoker = rb_define_class_under(moduleFFI, "VariadicInvoker", rb_cObject);
    rb_global_variable(&classVariadicInvoker);

    rb_define_alloc_func(classVariadicInvoker, variadic_allocate);

    rb_define_method(classVariadicInvoker, "initialize", variadic_initialize, 4);
    rb_define_method(classVariadicInvoker, "invoke", variadic_invoke, 2);
}


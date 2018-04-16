/*
 * Copyright (c) 2010, Wayne Meissner
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright notice
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * * The name of the author or authors may not be used to endorse or promote
 *   products derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef _MSC_VER
# include <sys/param.h>
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
#include <errno.h>
#include <ruby.h>

#include <ffi.h>
#include "rbffi.h"
#include "compat.h"

#include "Pointer.h"
#include "Struct.h"
#include "StructByReference.h"


#define FFI_ALIGN(v, a)  (((((size_t) (v))-1) | ((a)-1))+1)

static VALUE sbr_allocate(VALUE);
static VALUE sbr_initialize(VALUE, VALUE);
static void sbr_mark(StructByReference *);

VALUE rbffi_StructByReferenceClass = Qnil;

static VALUE
sbr_allocate(VALUE klass)
{
    StructByReference* sbr;

    VALUE obj = Data_Make_Struct(klass, StructByReference, sbr_mark, -1, sbr);

    sbr->rbStructClass = Qnil;

    return obj;
}

/*
 * call-seq: initialize(struc_class)
 * @param [Struct] struct_calss
 * @return [self]
 * A new instance of StructByReference.
 */
static VALUE
sbr_initialize(VALUE self, VALUE rbStructClass)
{
    StructByReference* sbr = NULL;
    
    if (!rb_class_inherited_p(rbStructClass, rbffi_StructClass)) {
        rb_raise(rb_eTypeError, "wrong type (expected subclass of FFI::Struct)");
    }

    Data_Get_Struct(self, StructByReference, sbr);
    sbr->rbStructClass = rbStructClass;
    
    return self;
}

static void
sbr_mark(StructByReference *sbr)
{
    rb_gc_mark(sbr->rbStructClass);
}


/*
 * call-seq: struct_class
 * @return [Struct]
 * Get +struct_class+.
 */
static VALUE
sbr_struct_class(VALUE self)
{
    StructByReference* sbr;

    Data_Get_Struct(self, StructByReference, sbr);

    return sbr->rbStructClass;
}

/*
 * call-seq: native_type
 * @return [Class]
 * Always get {FFI::Type}::POINTER.
 */
static VALUE
sbr_native_type(VALUE self)
{
    return rb_const_get(rbffi_TypeClass, rb_intern("POINTER"));
}

/*
 * call-seq: to_native(value, ctx)
 * @param [nil, Struct] value
 * @param [nil] ctx
 * @return [AbstractMemory] Pointer on +value+.
 */
static VALUE
sbr_to_native(VALUE self, VALUE value, VALUE ctx)
{
    StructByReference* sbr;
    Struct* s;

    if (unlikely(value == Qnil)) {
        return rbffi_NullPointerSingleton;
    }

    Data_Get_Struct(self, StructByReference, sbr);
    if (!rb_obj_is_kind_of(value, sbr->rbStructClass)) {
        rb_raise(rb_eTypeError, "wrong argument type %s (expected %s)",
                rb_obj_classname(value),
                RSTRING_PTR(rb_class_name(sbr->rbStructClass)));
    }

    Data_Get_Struct(value, Struct, s);

    return s->rbPointer;
}

/*
 * call-seq: from_native(value, ctx)
 * @param [AbstractMemory] value
 * @param [nil] ctx
 * @return [Struct]
 * Create a struct from content of memory +value+.
 */
static VALUE
sbr_from_native(VALUE self, VALUE value, VALUE ctx)
{
    StructByReference* sbr;

    Data_Get_Struct(self, StructByReference, sbr);

    return rb_class_new_instance(1, &value, sbr->rbStructClass);
}


void
rbffi_StructByReference_Init(VALUE moduleFFI)
{
    /*
     * Document-class: FFI::StructByReference
     * This class includes {FFI::DataConverter} module.
     */
    rbffi_StructByReferenceClass = rb_define_class_under(moduleFFI, "StructByReference", rb_cObject);
    rb_global_variable(&rbffi_StructByReferenceClass);
    rb_include_module(rbffi_StructByReferenceClass, rb_const_get(moduleFFI, rb_intern("DataConverter")));
    
    rb_define_alloc_func(rbffi_StructByReferenceClass, sbr_allocate);
    rb_define_method(rbffi_StructByReferenceClass, "initialize", sbr_initialize, 1);
    rb_define_method(rbffi_StructByReferenceClass, "struct_class", sbr_struct_class, 0);
    rb_define_method(rbffi_StructByReferenceClass, "native_type", sbr_native_type, 0);
    rb_define_method(rbffi_StructByReferenceClass, "to_native", sbr_to_native, 2);
    rb_define_method(rbffi_StructByReferenceClass, "from_native", sbr_from_native, 2);
}


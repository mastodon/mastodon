/*
 * Copyright (c) 2009, 2010 Wayne Meissner
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

#include <ffi.h>
#include "rbffi.h"
#include "compat.h"

#include "Function.h"
#include "Types.h"
#include "Type.h"
#include "LastError.h"
#include "Call.h"
#include "Closure.h"
#include "MethodHandle.h"

#define METHOD_CLOSURE ffi_closure
#define METHOD_PARAMS void**

struct MethodHandle {
    Closure* closure;
};

static ffi_type* methodHandleParamTypes[] = {
    &ffi_type_sint,
    &ffi_type_pointer,
    &ffi_type_ulong,
};

static ffi_cif mh_cif;

static void
attached_method_invoke(ffi_cif* cif, void* mretval, METHOD_PARAMS parameters, void* user_data)
{
    Closure* handle =  (Closure *) user_data;
    FunctionType* fnInfo = (FunctionType *) handle->info;

    int argc = *(int *) parameters[0];
    VALUE* argv = *(VALUE **) parameters[1];

    *(VALUE *) mretval = (*fnInfo->invoke)(argc, argv, handle->function, fnInfo);
}

MethodHandle*
rbffi_MethodHandle_Alloc(FunctionType* fnInfo, void* function)
{
    ffi_status ffiStatus;
    MethodHandle* handle;
    Closure* closure;

    closure = rbffi_Closure_Alloc();
    if (closure == NULL) {
        rb_raise(rb_eNoMemError, "failed to allocate closure from pool");
        return NULL;
    }
    closure->info = fnInfo;
    closure->function = function;

    ffiStatus = ffi_prep_closure_loc(closure->libffi_closure,
        &mh_cif, /* method signature */
        attached_method_invoke,
        closure, /* user_data for attached_method_invoke */
        closure->libffi_trampoline);
    if (ffiStatus != FFI_OK) {
        rb_raise(rb_eRuntimeError, "ffi_prep_closure_loc failed.  status=%#x", ffiStatus);
        return false;
    }

    handle = xcalloc(1, sizeof(*handle));
    handle->closure = closure;

    return handle;
}

void
rbffi_MethodHandle_Free(MethodHandle* handle)
{
    if (handle != NULL) {
        rbffi_Closure_Free(handle->closure);
    }
}

void*
rbffi_MethodHandle_CodeAddress(MethodHandle* handle)
{
    return handle->closure->libffi_trampoline;
}

void
rbffi_MethodHandle_Init(VALUE module)
{
    ffi_status ffiStatus;

    ffiStatus = ffi_prep_cif(&mh_cif, FFI_DEFAULT_ABI, 3, &ffi_type_ulong,
            methodHandleParamTypes);
    if (ffiStatus != FFI_OK) {
        rb_raise(rb_eFatal, "ffi_prep_cif failed.  status=%#x", ffiStatus);
    }
}

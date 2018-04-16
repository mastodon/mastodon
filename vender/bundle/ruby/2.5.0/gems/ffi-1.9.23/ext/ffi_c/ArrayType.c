/*
 * Copyright (c) 2009, Wayne Meissner
 *
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

#include <ruby.h>
#include <ffi.h>
#include "ArrayType.h"

static VALUE array_type_s_allocate(VALUE klass);
static VALUE array_type_initialize(VALUE self, VALUE rbComponentType, VALUE rbLength);
static void array_type_mark(ArrayType *);
static void array_type_free(ArrayType *);

VALUE rbffi_ArrayTypeClass = Qnil;

static VALUE
array_type_s_allocate(VALUE klass)
{
    ArrayType* array;
    VALUE obj;

    obj = Data_Make_Struct(klass, ArrayType, array_type_mark, array_type_free, array);

    array->base.nativeType = NATIVE_ARRAY;
    array->base.ffiType = xcalloc(1, sizeof(*array->base.ffiType));
    array->base.ffiType->type = FFI_TYPE_STRUCT;
    array->base.ffiType->size = 0;
    array->base.ffiType->alignment = 0;
    array->rbComponentType = Qnil;

    return obj;
}

static void
array_type_mark(ArrayType *array)
{
    rb_gc_mark(array->rbComponentType);
}

static void
array_type_free(ArrayType *array)
{
    xfree(array->base.ffiType);
    xfree(array->ffiTypes);
    xfree(array);
}


/*
 * call-seq: initialize(component_type, length)
 * @param [Type] component_type
 * @param [Numeric] length
 * @return [self]
 * A new instance of ArrayType.
 */
static VALUE
array_type_initialize(VALUE self, VALUE rbComponentType, VALUE rbLength)
{
    ArrayType* array;
    int i;

    Data_Get_Struct(self, ArrayType, array);

    array->length = NUM2UINT(rbLength);
    array->rbComponentType = rbComponentType;
    Data_Get_Struct(rbComponentType, Type, array->componentType);
    
    array->ffiTypes = xcalloc(array->length + 1, sizeof(*array->ffiTypes));
    array->base.ffiType->elements = array->ffiTypes;
    array->base.ffiType->size = array->componentType->ffiType->size * array->length;
    array->base.ffiType->alignment = array->componentType->ffiType->alignment;

    for (i = 0; i < array->length; ++i) {
        array->ffiTypes[i] = array->componentType->ffiType;
    }

    return self;
}

/*
 * call-seq: length
 * @return [Numeric]
 * Get array's length
 */
static VALUE
array_type_length(VALUE self)
{
    ArrayType* array;

    Data_Get_Struct(self, ArrayType, array);

    return UINT2NUM(array->length);
}

/*
 * call-seq: element_type
 * @return [Type]
 * Get element type.
 */
static VALUE
array_type_element_type(VALUE self)
{
    ArrayType* array;

    Data_Get_Struct(self, ArrayType, array);

    return array->rbComponentType;
}

void
rbffi_ArrayType_Init(VALUE moduleFFI)
{
    VALUE ffi_Type;

    ffi_Type = rbffi_TypeClass;

    /*
     * Document-class: FFI::ArrayType < FFI::Type
     *
     * This is a typed array. The type is a {NativeType native type}.
     */
    rbffi_ArrayTypeClass = rb_define_class_under(moduleFFI, "ArrayType", ffi_Type);
    /*
     * Document-variable: FFI::ArrayType
     */
    rb_global_variable(&rbffi_ArrayTypeClass);
    /*
     * Document-constant: FFI::Type::Array
     */
    rb_define_const(ffi_Type, "Array", rbffi_ArrayTypeClass);

    rb_define_alloc_func(rbffi_ArrayTypeClass, array_type_s_allocate);
    rb_define_method(rbffi_ArrayTypeClass, "initialize", array_type_initialize, 2);
    rb_define_method(rbffi_ArrayTypeClass, "length", array_type_length, 0);
    rb_define_method(rbffi_ArrayTypeClass, "elem_type", array_type_element_type, 0);
}


/*
 * Copyright (c) 2010, Wayne Meissner
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
#include "rbffi.h"

#include "Type.h"
#include "MappedType.h"


static VALUE mapped_allocate(VALUE);
static VALUE mapped_initialize(VALUE, VALUE);
static void mapped_mark(MappedType *);
static ID id_native_type, id_to_native, id_from_native;

VALUE rbffi_MappedTypeClass = Qnil;

static VALUE
mapped_allocate(VALUE klass)
{
    MappedType* m;

    VALUE obj = Data_Make_Struct(klass, MappedType, mapped_mark, -1, m);

    m->rbConverter = Qnil;
    m->rbType = Qnil;
    m->type = NULL;
    m->base.nativeType = NATIVE_MAPPED;
    m->base.ffiType = &ffi_type_void;
    
    return obj;
}

/*
 * call-seq: initialize(converter)
 * @param [#native_type, #to_native, #from_native] converter +converter+ must respond to
 *  all these methods
 * @return [self]
 */
static VALUE
mapped_initialize(VALUE self, VALUE rbConverter)
{
    MappedType* m = NULL;
    
    if (!rb_respond_to(rbConverter, id_native_type)) {
        rb_raise(rb_eNoMethodError, "native_type method not implemented");
    }

    if (!rb_respond_to(rbConverter, id_to_native)) {
        rb_raise(rb_eNoMethodError, "to_native method not implemented");
    }

    if (!rb_respond_to(rbConverter, id_from_native)) {
        rb_raise(rb_eNoMethodError, "from_native method not implemented");
    }
    
    Data_Get_Struct(self, MappedType, m);
    m->rbType = rb_funcall2(rbConverter, id_native_type, 0, NULL);
    if (!(rb_obj_is_kind_of(m->rbType, rbffi_TypeClass))) {
        rb_raise(rb_eTypeError, "native_type did not return instance of FFI::Type");
    }

    m->rbConverter = rbConverter;
    Data_Get_Struct(m->rbType, Type, m->type);
    m->base.ffiType = m->type->ffiType;
    
    return self;
}

static void
mapped_mark(MappedType* m)
{
    rb_gc_mark(m->rbType);
    rb_gc_mark(m->rbConverter);
}

/*
 * call-seq: mapped_type.native_type
 * @return [Type]
 * Get native type of mapped type.
 */
static VALUE
mapped_native_type(VALUE self)
{
    MappedType*m = NULL;
    Data_Get_Struct(self, MappedType, m);

    return m->rbType;
}

/*
 * call-seq: mapped_type.to_native(*args)
 * @param args depends on {FFI::DataConverter} used to initialize +self+
 */
static VALUE
mapped_to_native(int argc, VALUE* argv, VALUE self)
{
    MappedType*m = NULL;
    
    Data_Get_Struct(self, MappedType, m);
    
    return rb_funcall2(m->rbConverter, id_to_native, argc, argv);
}

/*
 * call-seq: mapped_type.from_native(*args)
 * @param args depends on {FFI::DataConverter} used to initialize +self+
 */
static VALUE
mapped_from_native(int argc, VALUE* argv, VALUE self)
{
    MappedType*m = NULL;
    
    Data_Get_Struct(self, MappedType, m);

    return rb_funcall2(m->rbConverter, id_from_native, argc, argv);
}

void
rbffi_MappedType_Init(VALUE moduleFFI)
{
    /* 
     * Document-class: FFI::Type::Mapped < FFI::Type
     */
    rbffi_MappedTypeClass = rb_define_class_under(rbffi_TypeClass, "Mapped", rbffi_TypeClass);
    
    rb_global_variable(&rbffi_MappedTypeClass);

    id_native_type = rb_intern("native_type");
    id_to_native = rb_intern("to_native");
    id_from_native = rb_intern("from_native");

    rb_define_alloc_func(rbffi_MappedTypeClass, mapped_allocate);
    rb_define_method(rbffi_MappedTypeClass, "initialize", mapped_initialize, 1);
    rb_define_method(rbffi_MappedTypeClass, "type", mapped_native_type, 0);
    rb_define_method(rbffi_MappedTypeClass, "native_type", mapped_native_type, 0);
    rb_define_method(rbffi_MappedTypeClass, "to_native", mapped_to_native, -1);
    rb_define_method(rbffi_MappedTypeClass, "from_native", mapped_from_native, -1);
}


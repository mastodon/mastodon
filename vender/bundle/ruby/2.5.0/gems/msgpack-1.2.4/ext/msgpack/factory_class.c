/*
 * MessagePack for Ruby
 *
 * Copyright (C) 2008-2013 Sadayuki Furuhashi
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#include "factory_class.h"
#include "packer_ext_registry.h"
#include "unpacker_ext_registry.h"
#include "buffer_class.h"
#include "packer_class.h"
#include "unpacker_class.h"

VALUE cMessagePack_Factory;

struct msgpack_factory_t;
typedef struct msgpack_factory_t msgpack_factory_t;

struct msgpack_factory_t {
    msgpack_packer_ext_registry_t pkrg;
    msgpack_unpacker_ext_registry_t ukrg;
    bool has_symbol_ext_type;
};

#define FACTORY(from, name) \
    msgpack_factory_t *name = NULL; \
    Data_Get_Struct(from, msgpack_factory_t, name); \
    if(name == NULL) { \
        rb_raise(rb_eArgError, "NULL found for " # name " when shouldn't be."); \
    }

static void Factory_free(msgpack_factory_t* fc)
{
    if(fc == NULL) {
        return;
    }
    msgpack_packer_ext_registry_destroy(&fc->pkrg);
    msgpack_unpacker_ext_registry_destroy(&fc->ukrg);
    xfree(fc);
}

void Factory_mark(msgpack_factory_t* fc)
{
    msgpack_packer_ext_registry_mark(&fc->pkrg);
    msgpack_unpacker_ext_registry_mark(&fc->ukrg);
}

static VALUE Factory_alloc(VALUE klass)
{
    msgpack_factory_t* fc = ZALLOC_N(msgpack_factory_t, 1);

    VALUE self = Data_Wrap_Struct(klass, Factory_mark, Factory_free, fc);
    return self;
}

static VALUE Factory_initialize(int argc, VALUE* argv, VALUE self)
{
    FACTORY(self, fc);

    msgpack_packer_ext_registry_init(&fc->pkrg);
    msgpack_unpacker_ext_registry_init(&fc->ukrg);

    fc->has_symbol_ext_type = false;

    switch (argc) {
    case 0:
        break;
    default:
        // TODO options is not supported yet
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 0)", argc);
    }

    return Qnil;
}

VALUE MessagePack_Factory_packer(int argc, VALUE* argv, VALUE self)
{
    FACTORY(self, fc);

    VALUE packer = MessagePack_Packer_alloc(cMessagePack_Packer);
    MessagePack_Packer_initialize(argc, argv, packer);

    msgpack_packer_t* pk;
    Data_Get_Struct(packer, msgpack_packer_t, pk);

    msgpack_packer_ext_registry_destroy(&pk->ext_registry);
    msgpack_packer_ext_registry_dup(&fc->pkrg, &pk->ext_registry);
    pk->has_symbol_ext_type = fc->has_symbol_ext_type;

    return packer;
}

VALUE MessagePack_Factory_unpacker(int argc, VALUE* argv, VALUE self)
{
    FACTORY(self, fc);

    VALUE unpacker = MessagePack_Unpacker_alloc(cMessagePack_Unpacker);
    MessagePack_Unpacker_initialize(argc, argv, unpacker);

    msgpack_unpacker_t* uk;
    Data_Get_Struct(unpacker, msgpack_unpacker_t, uk);

    msgpack_unpacker_ext_registry_destroy(&uk->ext_registry);
    msgpack_unpacker_ext_registry_dup(&fc->ukrg, &uk->ext_registry);

    return unpacker;
}

static VALUE Factory_registered_types_internal(VALUE self)
{
    FACTORY(self, fc);

    VALUE uk_mapping = rb_hash_new();
    for(int i=0; i < 256; i++) {
        if(fc->ukrg.array[i] != Qnil) {
            rb_hash_aset(uk_mapping, INT2FIX(i - 128), fc->ukrg.array[i]);
        }
    }
#ifdef HAVE_RB_HASH_DUP
    return rb_ary_new3(2, rb_hash_dup(fc->pkrg.hash), uk_mapping);
#else
    return rb_ary_new3(2, rb_funcall(fc->pkrg.hash, rb_intern("dup"), 0), uk_mapping);
#endif
}

static VALUE Factory_register_type(int argc, VALUE* argv, VALUE self)
{
    FACTORY(self, fc);

    int ext_type;
    VALUE ext_module;
    VALUE options;
    VALUE packer_arg, unpacker_arg;
    VALUE packer_proc, unpacker_proc;

    if (OBJ_FROZEN(self)) {
        rb_raise(rb_eRuntimeError, "can't modify frozen Factory");
    }

    switch (argc) {
    case 2:
        /* register_type(0x7f, Time) */
        packer_arg = ID2SYM(rb_intern("to_msgpack_ext"));
        unpacker_arg = ID2SYM(rb_intern("from_msgpack_ext"));
        break;
    case 3:
        /* register_type(0x7f, Time, packer: proc-like, unapcker: proc-like) */
        options = argv[2];
        if(rb_type(options) != T_HASH) {
            rb_raise(rb_eArgError, "expected Hash but found %s.", rb_obj_classname(options));
        }
        packer_arg = rb_hash_aref(options, ID2SYM(rb_intern("packer")));
        unpacker_arg = rb_hash_aref(options, ID2SYM(rb_intern("unpacker")));
        break;
    default:
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 2..3)", argc);
    }

    ext_type = NUM2INT(argv[0]);
    if(ext_type < -128 || ext_type > 127) {
        rb_raise(rb_eRangeError, "integer %d too big to convert to `signed char'", ext_type);
    }

    ext_module = argv[1];
    if(rb_type(ext_module) != T_MODULE && rb_type(ext_module) != T_CLASS) {
        rb_raise(rb_eArgError, "expected Module/Class but found %s.", rb_obj_classname(ext_module));
    }

    packer_proc = Qnil;
    unpacker_proc = Qnil;

    if(packer_arg != Qnil) {
        packer_proc = rb_funcall(packer_arg, rb_intern("to_proc"), 0);
    }

    if(unpacker_arg != Qnil) {
        if(rb_type(unpacker_arg) == T_SYMBOL || rb_type(unpacker_arg) == T_STRING) {
            unpacker_proc = rb_obj_method(ext_module, unpacker_arg);
        } else {
            unpacker_proc = rb_funcall(unpacker_arg, rb_intern("method"), 1, ID2SYM(rb_intern("call")));
        }
    }

    msgpack_packer_ext_registry_put(&fc->pkrg, ext_module, ext_type, packer_proc, packer_arg);

    if (ext_module == rb_cSymbol) {
        fc->has_symbol_ext_type = true;
    }

    msgpack_unpacker_ext_registry_put(&fc->ukrg, ext_module, ext_type, unpacker_proc, unpacker_arg);

    return Qnil;
}

void MessagePack_Factory_module_init(VALUE mMessagePack)
{
    cMessagePack_Factory = rb_define_class_under(mMessagePack, "Factory", rb_cObject);

    rb_define_alloc_func(cMessagePack_Factory, Factory_alloc);

    rb_define_method(cMessagePack_Factory, "initialize", Factory_initialize, -1);

    rb_define_method(cMessagePack_Factory, "packer", MessagePack_Factory_packer, -1);
    rb_define_method(cMessagePack_Factory, "unpacker", MessagePack_Factory_unpacker, -1);

    rb_define_private_method(cMessagePack_Factory, "registered_types_internal", Factory_registered_types_internal, 0);
    rb_define_method(cMessagePack_Factory, "register_type", Factory_register_type, -1);
}

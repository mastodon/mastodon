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

#include "unpacker.h"
#include "unpacker_class.h"
#include "buffer_class.h"
#include "factory_class.h"

VALUE cMessagePack_Unpacker;

//static VALUE s_unpacker_value;
//static msgpack_unpacker_t* s_unpacker;

static VALUE eUnpackError;
static VALUE eMalformedFormatError;
static VALUE eStackError;
static VALUE eUnexpectedTypeError;
static VALUE eUnknownExtTypeError;
static VALUE mTypeError;  // obsoleted. only for backward compatibility. See #86.

#define UNPACKER(from, name) \
    msgpack_unpacker_t *name = NULL; \
    Data_Get_Struct(from, msgpack_unpacker_t, name); \
    if(name == NULL) { \
        rb_raise(rb_eArgError, "NULL found for " # name " when shouldn't be."); \
    }

static void Unpacker_free(msgpack_unpacker_t* uk)
{
    if(uk == NULL) {
        return;
    }
    msgpack_unpacker_ext_registry_destroy(&uk->ext_registry);
    _msgpack_unpacker_destroy(uk);
    xfree(uk);
}

static void Unpacker_mark(msgpack_unpacker_t* uk)
{
    msgpack_unpacker_mark(uk);
    msgpack_unpacker_ext_registry_mark(&uk->ext_registry);
}

VALUE MessagePack_Unpacker_alloc(VALUE klass)
{
    msgpack_unpacker_t* uk = ZALLOC_N(msgpack_unpacker_t, 1);
    _msgpack_unpacker_init(uk);

    VALUE self = Data_Wrap_Struct(klass, Unpacker_mark, Unpacker_free, uk);
    return self;
}

VALUE MessagePack_Unpacker_initialize(int argc, VALUE* argv, VALUE self)
{
    VALUE io = Qnil;
    VALUE options = Qnil;

    if(argc == 0 || (argc == 1 && argv[0] == Qnil)) {
        /* Qnil */

    } else if(argc == 1) {
        VALUE v = argv[0];
        if(rb_type(v) == T_HASH) {
            options = v;
            if(rb_type(options) != T_HASH) {
                rb_raise(rb_eArgError, "expected Hash but found %s.", rb_obj_classname(options));
            }
        } else {
            io = v;
        }

    } else if(argc == 2) {
        io = argv[0];
        options = argv[1];
        if(rb_type(options) != T_HASH) {
            rb_raise(rb_eArgError, "expected Hash but found %s.", rb_obj_classname(options));
        }

    } else {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 0..2)", argc);
    }

    UNPACKER(self, uk);

    msgpack_unpacker_ext_registry_init(&uk->ext_registry);
    uk->buffer_ref = MessagePack_Buffer_wrap(UNPACKER_BUFFER_(uk), self);

    MessagePack_Buffer_set_options(UNPACKER_BUFFER_(uk), io, options);

    if(options != Qnil) {
        VALUE v;

        v = rb_hash_aref(options, ID2SYM(rb_intern("symbolize_keys")));
        msgpack_unpacker_set_symbolized_keys(uk, RTEST(v));

        v = rb_hash_aref(options, ID2SYM(rb_intern("allow_unknown_ext")));
        msgpack_unpacker_set_allow_unknown_ext(uk, RTEST(v));
    }

    return self;
}

static VALUE Unpacker_symbolized_keys_p(VALUE self)
{
    UNPACKER(self, uk);
    return uk->symbolize_keys ? Qtrue : Qfalse;
}

static VALUE Unpacker_allow_unknown_ext_p(VALUE self)
{
    UNPACKER(self, uk);
    return uk->allow_unknown_ext ? Qtrue : Qfalse;
}

static void raise_unpacker_error(int r)
{
    switch(r) {
    case PRIMITIVE_EOF:
        rb_raise(rb_eEOFError, "end of buffer reached");
    case PRIMITIVE_INVALID_BYTE:
        rb_raise(eMalformedFormatError, "invalid byte");
    case PRIMITIVE_STACK_TOO_DEEP:
        rb_raise(eStackError, "stack level too deep");
    case PRIMITIVE_UNEXPECTED_TYPE:
        rb_raise(eUnexpectedTypeError, "unexpected type");
    case PRIMITIVE_UNEXPECTED_EXT_TYPE:
        rb_raise(eUnknownExtTypeError, "unexpected extension type");
    default:
        rb_raise(eUnpackError, "logically unknown error %d", r);
    }
}

static VALUE Unpacker_buffer(VALUE self)
{
    UNPACKER(self, uk);
    return uk->buffer_ref;
}

static VALUE Unpacker_read(VALUE self)
{
    UNPACKER(self, uk);

    int r = msgpack_unpacker_read(uk, 0);
    if(r < 0) {
        raise_unpacker_error(r);
    }

    return msgpack_unpacker_get_last_object(uk);
}

static VALUE Unpacker_skip(VALUE self)
{
    UNPACKER(self, uk);

    int r = msgpack_unpacker_skip(uk, 0);
    if(r < 0) {
        raise_unpacker_error(r);
    }

    return Qnil;
}

static VALUE Unpacker_skip_nil(VALUE self)
{
    UNPACKER(self, uk);

    int r = msgpack_unpacker_skip_nil(uk);
    if(r < 0) {
        raise_unpacker_error(r);
    }

    if(r) {
        return Qtrue;
    }
    return Qfalse;
}

static VALUE Unpacker_read_array_header(VALUE self)
{
    UNPACKER(self, uk);

    uint32_t size;
    int r = msgpack_unpacker_read_array_header(uk, &size);
    if(r < 0) {
        raise_unpacker_error(r);
    }

    return ULONG2NUM(size);
}

static VALUE Unpacker_read_map_header(VALUE self)
{
    UNPACKER(self, uk);

    uint32_t size;
    int r = msgpack_unpacker_read_map_header(uk, &size);
    if(r < 0) {
        raise_unpacker_error((int)r);
    }

    return ULONG2NUM(size);
}

static VALUE Unpacker_peek_next_type(VALUE self)
{
    UNPACKER(self, uk);

    int r = msgpack_unpacker_peek_next_object_type(uk);
    if(r < 0) {
        raise_unpacker_error(r);
    }

    switch((enum msgpack_unpacker_object_type) r) {
    case TYPE_NIL:
        return rb_intern("nil");
    case TYPE_BOOLEAN:
        return rb_intern("boolean");
    case TYPE_INTEGER:
        return rb_intern("integer");
    case TYPE_FLOAT:
        return rb_intern("float");
    case TYPE_RAW:
        return rb_intern("raw");
    case TYPE_ARRAY:
        return rb_intern("array");
    case TYPE_MAP:
        return rb_intern("map");
    default:
        rb_raise(eUnpackError, "logically unknown type %d", r);
    }
}

static VALUE Unpacker_feed(VALUE self, VALUE data)
{
    UNPACKER(self, uk);

    StringValue(data);

    msgpack_buffer_append_string(UNPACKER_BUFFER_(uk), data);

    return self;
}

static VALUE Unpacker_each_impl(VALUE self)
{
    UNPACKER(self, uk);

    while(true) {
        int r = msgpack_unpacker_read(uk, 0);
        if(r < 0) {
            if(r == PRIMITIVE_EOF) {
                return Qnil;
            }
            raise_unpacker_error(r);
        }
        VALUE v = msgpack_unpacker_get_last_object(uk);
#ifdef JRUBY
        /* TODO JRuby's rb_yield behaves differently from Ruby 1.9.3 or Rubinius. */
        if(rb_type(v) == T_ARRAY) {
            v = rb_ary_new3(1, v);
        }
#endif
        rb_yield(v);
    }
}

static VALUE Unpacker_rescue_EOFError(VALUE self)
{
    UNUSED(self);
    return Qnil;
}

static VALUE Unpacker_each(VALUE self)
{
    UNPACKER(self, uk);

#ifdef RETURN_ENUMERATOR
    RETURN_ENUMERATOR(self, 0, 0);
#endif

    if(msgpack_buffer_has_io(UNPACKER_BUFFER_(uk))) {
        /* rescue EOFError only if io is set */
        return rb_rescue2(Unpacker_each_impl, self,
                Unpacker_rescue_EOFError, self,
                rb_eEOFError, NULL);
    } else {
        return Unpacker_each_impl(self);
    }
}

static VALUE Unpacker_feed_each(VALUE self, VALUE data)
{
#ifdef RETURN_ENUMERATOR
    {
        VALUE argv[] = { data };
        RETURN_ENUMERATOR(self, sizeof(argv) / sizeof(VALUE), argv);
    }
#endif

    // TODO optimize
    Unpacker_feed(self, data);
    return Unpacker_each(self);
}

static VALUE Unpacker_reset(VALUE self)
{
    UNPACKER(self, uk);

    _msgpack_unpacker_reset(uk);

    return Qnil;
}

static VALUE Unpacker_registered_types_internal(VALUE self)
{
    UNPACKER(self, uk);

    VALUE mapping = rb_hash_new();
    for(int i=0; i < 256; i++) {
        if(uk->ext_registry.array[i] != Qnil) {
            rb_hash_aset(mapping, INT2FIX(i - 128), uk->ext_registry.array[i]);
        }
    }

    return mapping;
}

static VALUE Unpacker_register_type(int argc, VALUE* argv, VALUE self)
{
    UNPACKER(self, uk);

    int ext_type;
    VALUE proc;
    VALUE arg;
    VALUE ext_module;

    switch (argc) {
    case 1:
        /* register_type(0x7f) {|data| block... } */
        rb_need_block();
#ifdef HAVE_RB_BLOCK_LAMBDA
        proc = rb_block_lambda();
#else
        /* MRI 1.8 */
        proc = rb_block_proc();
#endif
        arg = proc;
        ext_module = Qnil;
        break;
    case 3:
        /* register_type(0x7f, Time, :from_msgpack_ext) */
        ext_module = argv[1];
        arg = argv[2];
        proc = rb_obj_method(ext_module, arg);
        break;
    default:
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 or 3)", argc);
    }

    ext_type = NUM2INT(argv[0]);
    if(ext_type < -128 || ext_type > 127) {
        rb_raise(rb_eRangeError, "integer %d too big to convert to `signed char'", ext_type);
    }

    msgpack_unpacker_ext_registry_put(&uk->ext_registry, ext_module, ext_type, proc, arg);

    return Qnil;
}

static VALUE Unpacker_full_unpack(VALUE self)
{
    UNPACKER(self, uk);

    /* prefer reference than copying; see MessagePack_Unpacker_module_init */
    msgpack_buffer_set_write_reference_threshold(UNPACKER_BUFFER_(uk), 0);

    int r = msgpack_unpacker_read(uk, 0);
    if(r < 0) {
        raise_unpacker_error(r);
    }

    /* raise if extra bytes follow */
    size_t extra = msgpack_buffer_top_readable_size(UNPACKER_BUFFER_(uk));
    if(extra > 0) {
        rb_raise(eMalformedFormatError, "%zd extra bytes after the deserialized object", extra);
    }

    return msgpack_unpacker_get_last_object(uk);
}

VALUE MessagePack_Unpacker_new(int argc, VALUE* argv)
{
    VALUE self = MessagePack_Unpacker_alloc(cMessagePack_Unpacker);
    MessagePack_Unpacker_initialize(argc, argv, self);
    return self;
}

void MessagePack_Unpacker_module_init(VALUE mMessagePack)
{
    msgpack_unpacker_static_init();
    msgpack_unpacker_ext_registry_static_init();

    mTypeError = rb_define_module_under(mMessagePack, "TypeError");

    cMessagePack_Unpacker = rb_define_class_under(mMessagePack, "Unpacker", rb_cObject);

    eUnpackError = rb_define_class_under(mMessagePack, "UnpackError", rb_eStandardError);

    eMalformedFormatError = rb_define_class_under(mMessagePack, "MalformedFormatError", eUnpackError);

    eStackError = rb_define_class_under(mMessagePack, "StackError", eUnpackError);

    eUnexpectedTypeError = rb_define_class_under(mMessagePack, "UnexpectedTypeError", eUnpackError);
    rb_include_module(eUnexpectedTypeError, mTypeError);

    eUnknownExtTypeError = rb_define_class_under(mMessagePack, "UnknownExtTypeError", eUnpackError);

    rb_define_alloc_func(cMessagePack_Unpacker, MessagePack_Unpacker_alloc);

    rb_define_method(cMessagePack_Unpacker, "initialize", MessagePack_Unpacker_initialize, -1);
    rb_define_method(cMessagePack_Unpacker, "symbolize_keys?", Unpacker_symbolized_keys_p, 0);
    rb_define_method(cMessagePack_Unpacker, "allow_unknown_ext?", Unpacker_allow_unknown_ext_p, 0);
    rb_define_method(cMessagePack_Unpacker, "buffer", Unpacker_buffer, 0);
    rb_define_method(cMessagePack_Unpacker, "read", Unpacker_read, 0);
    rb_define_alias(cMessagePack_Unpacker, "unpack", "read");
    rb_define_method(cMessagePack_Unpacker, "skip", Unpacker_skip, 0);
    rb_define_method(cMessagePack_Unpacker, "skip_nil", Unpacker_skip_nil, 0);
    rb_define_method(cMessagePack_Unpacker, "read_array_header", Unpacker_read_array_header, 0);
    rb_define_method(cMessagePack_Unpacker, "read_map_header", Unpacker_read_map_header, 0);
    //rb_define_method(cMessagePack_Unpacker, "peek_next_type", Unpacker_peek_next_type, 0);  // TODO
    rb_define_method(cMessagePack_Unpacker, "feed", Unpacker_feed, 1);
    rb_define_method(cMessagePack_Unpacker, "each", Unpacker_each, 0);
    rb_define_method(cMessagePack_Unpacker, "feed_each", Unpacker_feed_each, 1);
    rb_define_method(cMessagePack_Unpacker, "reset", Unpacker_reset, 0);

    rb_define_private_method(cMessagePack_Unpacker, "registered_types_internal", Unpacker_registered_types_internal, 0);
    rb_define_method(cMessagePack_Unpacker, "register_type", Unpacker_register_type, -1);

    //s_unpacker_value = MessagePack_Unpacker_alloc(cMessagePack_Unpacker);
    //rb_gc_register_address(&s_unpacker_value);
    //Data_Get_Struct(s_unpacker_value, msgpack_unpacker_t, s_unpacker);
    /* prefer reference than copying */
    //msgpack_buffer_set_write_reference_threshold(UNPACKER_BUFFER_(s_unpacker), 0);

    rb_define_method(cMessagePack_Unpacker, "full_unpack", Unpacker_full_unpack, 0);
}


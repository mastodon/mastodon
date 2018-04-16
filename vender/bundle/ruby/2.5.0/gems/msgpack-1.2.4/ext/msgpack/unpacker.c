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
#include "rmem.h"
#include "extension_value_class.h"

#if !defined(DISABLE_RMEM) && !defined(DISABLE_UNPACKER_STACK_RMEM) && \
        MSGPACK_UNPACKER_STACK_CAPACITY * MSGPACK_UNPACKER_STACK_SIZE <= MSGPACK_RMEM_PAGE_SIZE
#define UNPACKER_STACK_RMEM
#endif

static int RAW_TYPE_STRING = 256;
static int RAW_TYPE_BINARY = 257;

static ID s_call;

#ifdef UNPACKER_STACK_RMEM
static msgpack_rmem_t s_stack_rmem;
#endif

void msgpack_unpacker_static_init()
{
#ifdef UNPACKER_STACK_RMEM
    msgpack_rmem_init(&s_stack_rmem);
#endif

    s_call = rb_intern("call");
}

void msgpack_unpacker_static_destroy()
{
#ifdef UNPACKER_STACK_RMEM
    msgpack_rmem_destroy(&s_stack_rmem);
#endif
}

#define HEAD_BYTE_REQUIRED 0xc1

void _msgpack_unpacker_init(msgpack_unpacker_t* uk)
{
    memset(uk, 0, sizeof(msgpack_unpacker_t));

    msgpack_buffer_init(UNPACKER_BUFFER_(uk));

    uk->head_byte = HEAD_BYTE_REQUIRED;

    uk->last_object = Qnil;
    uk->reading_raw = Qnil;

#ifdef UNPACKER_STACK_RMEM
    uk->stack = msgpack_rmem_alloc(&s_stack_rmem);
    /*memset(uk->stack, 0, MSGPACK_UNPACKER_STACK_CAPACITY);*/
#else
    /*uk->stack = calloc(MSGPACK_UNPACKER_STACK_CAPACITY, sizeof(msgpack_unpacker_stack_t));*/
    uk->stack = xmalloc(MSGPACK_UNPACKER_STACK_CAPACITY * sizeof(msgpack_unpacker_stack_t));
#endif
    uk->stack_capacity = MSGPACK_UNPACKER_STACK_CAPACITY;
}

void _msgpack_unpacker_destroy(msgpack_unpacker_t* uk)
{
#ifdef UNPACKER_STACK_RMEM
    msgpack_rmem_free(&s_stack_rmem, uk->stack);
#else
    xfree(uk->stack);
#endif

    msgpack_buffer_destroy(UNPACKER_BUFFER_(uk));
}

void msgpack_unpacker_mark(msgpack_unpacker_t* uk)
{
    rb_gc_mark(uk->last_object);
    rb_gc_mark(uk->reading_raw);

    msgpack_unpacker_stack_t* s = uk->stack;
    msgpack_unpacker_stack_t* send = uk->stack + uk->stack_depth;
    for(; s < send; s++) {
        rb_gc_mark(s->object);
        rb_gc_mark(s->key);
    }

    /* See MessagePack_Buffer_wrap */
    /* msgpack_buffer_mark(UNPACKER_BUFFER_(uk)); */
    rb_gc_mark(uk->buffer_ref);
}

void _msgpack_unpacker_reset(msgpack_unpacker_t* uk)
{
    msgpack_buffer_clear(UNPACKER_BUFFER_(uk));

    uk->head_byte = HEAD_BYTE_REQUIRED;

    /*memset(uk->stack, 0, sizeof(msgpack_unpacker_t) * uk->stack_depth);*/
    uk->stack_depth = 0;

    uk->last_object = Qnil;
    uk->reading_raw = Qnil;
    uk->reading_raw_remaining = 0;
}


/* head byte functions */
static int read_head_byte(msgpack_unpacker_t* uk)
{
    int r = msgpack_buffer_read_1(UNPACKER_BUFFER_(uk));
    if(r == -1) {
        return PRIMITIVE_EOF;
    }
    return uk->head_byte = r;
}

static inline int get_head_byte(msgpack_unpacker_t* uk)
{
    int b = uk->head_byte;
    if(b == HEAD_BYTE_REQUIRED) {
        b = read_head_byte(uk);
    }
    return b;
}

static inline void reset_head_byte(msgpack_unpacker_t* uk)
{
    uk->head_byte = HEAD_BYTE_REQUIRED;
}

static inline int object_complete(msgpack_unpacker_t* uk, VALUE object)
{
    uk->last_object = object;
    reset_head_byte(uk);
    return PRIMITIVE_OBJECT_COMPLETE;
}

static inline int object_complete_string(msgpack_unpacker_t* uk, VALUE str)
{
#ifdef COMPAT_HAVE_ENCODING
    ENCODING_SET(str, msgpack_rb_encindex_utf8);
#endif
    return object_complete(uk, str);
}

static inline int object_complete_binary(msgpack_unpacker_t* uk, VALUE str)
{
#ifdef COMPAT_HAVE_ENCODING
    ENCODING_SET(str, msgpack_rb_encindex_ascii8bit);
#endif
    return object_complete(uk, str);
}

static inline int object_complete_ext(msgpack_unpacker_t* uk, int ext_type, VALUE str)
{
#ifdef COMPAT_HAVE_ENCODING
    ENCODING_SET(str, msgpack_rb_encindex_ascii8bit);
#endif

    VALUE proc = msgpack_unpacker_ext_registry_lookup(&uk->ext_registry, ext_type);
    if(proc != Qnil) {
        VALUE obj = rb_funcall(proc, s_call, 1, str);
        return object_complete(uk, obj);
    }

    if(uk->allow_unknown_ext) {
        VALUE obj = MessagePack_ExtensionValue_new(ext_type, str);
        return object_complete(uk, obj);
    }

    return PRIMITIVE_UNEXPECTED_EXT_TYPE;
}

/* stack funcs */
static inline msgpack_unpacker_stack_t* _msgpack_unpacker_stack_top(msgpack_unpacker_t* uk)
{
    return &uk->stack[uk->stack_depth-1];
}

static inline int _msgpack_unpacker_stack_push(msgpack_unpacker_t* uk, enum stack_type_t type, size_t count, VALUE object)
{
    reset_head_byte(uk);

    if(uk->stack_capacity - uk->stack_depth <= 0) {
        return PRIMITIVE_STACK_TOO_DEEP;
    }

    msgpack_unpacker_stack_t* next = &uk->stack[uk->stack_depth];
    next->count = count;
    next->type = type;
    next->object = object;
    next->key = Qnil;

    uk->stack_depth++;
    return PRIMITIVE_CONTAINER_START;
}

static inline VALUE msgpack_unpacker_stack_pop(msgpack_unpacker_t* uk)
{
    return --uk->stack_depth;
}

static inline bool msgpack_unpacker_stack_is_empty(msgpack_unpacker_t* uk)
{
    return uk->stack_depth == 0;
}

#ifdef USE_CASE_RANGE

#define SWITCH_RANGE_BEGIN(BYTE)     { switch(BYTE) {
#define SWITCH_RANGE(BYTE, FROM, TO) } case FROM ... TO: {
#define SWITCH_RANGE_DEFAULT         } default: {
#define SWITCH_RANGE_END             } }

#else

#define SWITCH_RANGE_BEGIN(BYTE)     { if(0) {
#define SWITCH_RANGE(BYTE, FROM, TO) } else if(FROM <= (BYTE) && (BYTE) <= TO) {
#define SWITCH_RANGE_DEFAULT         } else {
#define SWITCH_RANGE_END             } }

#endif


#define READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, n) \
    union msgpack_buffer_cast_block_t* cb = msgpack_buffer_read_cast_block(UNPACKER_BUFFER_(uk), n); \
    if(cb == NULL) { \
        return PRIMITIVE_EOF; \
    }

static inline bool is_reading_map_key(msgpack_unpacker_t* uk)
{
    if(uk->stack_depth > 0) {
        msgpack_unpacker_stack_t* top = _msgpack_unpacker_stack_top(uk);
        if(top->type == STACK_TYPE_MAP_KEY) {
            return true;
        }
    }
    return false;
}

static int read_raw_body_cont(msgpack_unpacker_t* uk)
{
    size_t length = uk->reading_raw_remaining;

    if(uk->reading_raw == Qnil) {
        uk->reading_raw = rb_str_buf_new(length);
    }

    do {
        size_t n = msgpack_buffer_read_to_string(UNPACKER_BUFFER_(uk), uk->reading_raw, length);
        if(n == 0) {
            return PRIMITIVE_EOF;
        }
        /* update reading_raw_remaining everytime because
         * msgpack_buffer_read_to_string raises IOError */
        uk->reading_raw_remaining = length = length - n;
    } while(length > 0);

    int ret;
    if(uk->reading_raw_type == RAW_TYPE_STRING) {
        ret = object_complete_string(uk, uk->reading_raw);
    } else if(uk->reading_raw_type == RAW_TYPE_BINARY) {
        ret = object_complete_binary(uk, uk->reading_raw);
    } else {
        ret = object_complete_ext(uk, uk->reading_raw_type, uk->reading_raw);
    }
    uk->reading_raw = Qnil;
    return ret;
}

static inline int read_raw_body_begin(msgpack_unpacker_t* uk, int raw_type)
{
    /* assuming uk->reading_raw == Qnil */

    /* try optimized read */
    size_t length = uk->reading_raw_remaining;
    if(length <= msgpack_buffer_top_readable_size(UNPACKER_BUFFER_(uk))) {
        /* don't use zerocopy for hash keys but get a frozen string directly
         * because rb_hash_aset freezes keys and it causes copying */
        bool will_freeze = is_reading_map_key(uk);
        VALUE string = msgpack_buffer_read_top_as_string(UNPACKER_BUFFER_(uk), length, will_freeze);
        int ret;
        if(raw_type == RAW_TYPE_STRING) {
            ret = object_complete_string(uk, string);
        } else if(raw_type == RAW_TYPE_BINARY) {
            ret = object_complete_binary(uk, string);
        } else {
            ret = object_complete_ext(uk, raw_type, string);
        }
        if(will_freeze) {
            rb_obj_freeze(string);
        }
        uk->reading_raw_remaining = 0;
        return ret;
    }

    uk->reading_raw_type = raw_type;
    return read_raw_body_cont(uk);
}

static int read_primitive(msgpack_unpacker_t* uk)
{
    if(uk->reading_raw_remaining > 0) {
        return read_raw_body_cont(uk);
    }

    int b = get_head_byte(uk);
    if(b < 0) {
        return b;
    }

    SWITCH_RANGE_BEGIN(b)
    SWITCH_RANGE(b, 0x00, 0x7f)  // Positive Fixnum
        return object_complete(uk, INT2NUM(b));

    SWITCH_RANGE(b, 0xe0, 0xff)  // Negative Fixnum
        return object_complete(uk, INT2NUM((int8_t)b));

    SWITCH_RANGE(b, 0xa0, 0xbf)  // FixRaw / fixstr
        int count = b & 0x1f;
        if(count == 0) {
            return object_complete_string(uk, rb_str_buf_new(0));
        }
        /* read_raw_body_begin sets uk->reading_raw */
        uk->reading_raw_remaining = count;
        return read_raw_body_begin(uk, RAW_TYPE_STRING);

    SWITCH_RANGE(b, 0x90, 0x9f)  // FixArray
        int count = b & 0x0f;
        if(count == 0) {
            return object_complete(uk, rb_ary_new());
        }
        return _msgpack_unpacker_stack_push(uk, STACK_TYPE_ARRAY, count, rb_ary_new2(count));

    SWITCH_RANGE(b, 0x80, 0x8f)  // FixMap
        int count = b & 0x0f;
        if(count == 0) {
            return object_complete(uk, rb_hash_new());
        }
        return _msgpack_unpacker_stack_push(uk, STACK_TYPE_MAP_KEY, count*2, rb_hash_new());

    SWITCH_RANGE(b, 0xc0, 0xdf)  // Variable
        switch(b) {
        case 0xc0:  // nil
            return object_complete(uk, Qnil);

        //case 0xc1:  // string

        case 0xc2:  // false
            return object_complete(uk, Qfalse);

        case 0xc3:  // true
            return object_complete(uk, Qtrue);

        case 0xc7: // ext 8
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 2);
                uint8_t length = cb->u8;
                int ext_type = (signed char) cb->buffer[1];
                if(length == 0) {
                    return object_complete_ext(uk, ext_type, rb_str_buf_new(0));
                }
                uk->reading_raw_remaining = length;
                return read_raw_body_begin(uk, ext_type);
            }

        case 0xc8: // ext 16
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 3);
                uint16_t length = _msgpack_be16(cb->u16);
                int ext_type = (signed char) cb->buffer[2];
                if(length == 0) {
                    return object_complete_ext(uk, ext_type, rb_str_buf_new(0));
                }
                uk->reading_raw_remaining = length;
                return read_raw_body_begin(uk, ext_type);
            }

        case 0xc9: // ext 32
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 5);
                uint32_t length = _msgpack_be32(cb->u32);
                int ext_type = (signed char) cb->buffer[4];
                if(length == 0) {
                    return object_complete_ext(uk, ext_type, rb_str_buf_new(0));
                }
                uk->reading_raw_remaining = length;
                return read_raw_body_begin(uk, ext_type);
            }

        case 0xca:  // float
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 4);
                cb->u32 = _msgpack_be_float(cb->u32);
                return object_complete(uk, rb_float_new(cb->f));
            }

        case 0xcb:  // double
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 8);
                cb->u64 = _msgpack_be_double(cb->u64);
                return object_complete(uk, rb_float_new(cb->d));
            }

        case 0xcc:  // unsigned int  8
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 1);
                uint8_t u8 = cb->u8;
                return object_complete(uk, INT2NUM((int)u8));
            }

        case 0xcd:  // unsigned int 16
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 2);
                uint16_t u16 = _msgpack_be16(cb->u16);
                return object_complete(uk, INT2NUM((int)u16));
            }

        case 0xce:  // unsigned int 32
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 4);
                uint32_t u32 = _msgpack_be32(cb->u32);
                return object_complete(uk, ULONG2NUM((unsigned long)u32));
            }

        case 0xcf:  // unsigned int 64
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 8);
                uint64_t u64 = _msgpack_be64(cb->u64);
                return object_complete(uk, rb_ull2inum(u64));
            }

        case 0xd0:  // signed int  8
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 1);
                int8_t i8 = cb->i8;
                return object_complete(uk, INT2NUM((int)i8));
            }

        case 0xd1:  // signed int 16
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 2);
                int16_t i16 = _msgpack_be16(cb->i16);
                return object_complete(uk, INT2NUM((int)i16));
            }

        case 0xd2:  // signed int 32
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 4);
                int32_t i32 = _msgpack_be32(cb->i32);
                return object_complete(uk, LONG2NUM((long)i32));
            }

        case 0xd3:  // signed int 64
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 8);
                int64_t i64 = _msgpack_be64(cb->i64);
                return object_complete(uk, rb_ll2inum(i64));
            }

        case 0xd4:  // fixext 1
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 1);
                int ext_type = cb->i8;
                uk->reading_raw_remaining = 1;
                return read_raw_body_begin(uk, ext_type);
            }

        case 0xd5:  // fixext 2
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 1);
                int ext_type = cb->i8;
                uk->reading_raw_remaining = 2;
                return read_raw_body_begin(uk, ext_type);
            }

        case 0xd6:  // fixext 4
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 1);
                int ext_type = cb->i8;
                uk->reading_raw_remaining = 4;
                return read_raw_body_begin(uk, ext_type);
            }

        case 0xd7:  // fixext 8
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 1);
                int ext_type = cb->i8;
                uk->reading_raw_remaining = 8;
                return read_raw_body_begin(uk, ext_type);
            }

        case 0xd8:  // fixext 16
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 1);
                int ext_type = cb->i8;
                uk->reading_raw_remaining = 16;
                return read_raw_body_begin(uk, ext_type);
            }


        case 0xd9:  // raw 8 / str 8
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 1);
                uint8_t count = cb->u8;
                if(count == 0) {
                    return object_complete_string(uk, rb_str_buf_new(0));
                }
                /* read_raw_body_begin sets uk->reading_raw */
                uk->reading_raw_remaining = count;
                return read_raw_body_begin(uk, RAW_TYPE_STRING);
            }

        case 0xda:  // raw 16 / str 16
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 2);
                uint16_t count = _msgpack_be16(cb->u16);
                if(count == 0) {
                    return object_complete_string(uk, rb_str_buf_new(0));
                }
                /* read_raw_body_begin sets uk->reading_raw */
                uk->reading_raw_remaining = count;
                return read_raw_body_begin(uk, RAW_TYPE_STRING);
            }

        case 0xdb:  // raw 32 / str 32
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 4);
                uint32_t count = _msgpack_be32(cb->u32);
                if(count == 0) {
                    return object_complete_string(uk, rb_str_buf_new(0));
                }
                /* read_raw_body_begin sets uk->reading_raw */
                uk->reading_raw_remaining = count;
                return read_raw_body_begin(uk, RAW_TYPE_STRING);
            }

        case 0xc4:  // bin 8
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 1);
                uint8_t count = cb->u8;
                if(count == 0) {
                    return object_complete_binary(uk, rb_str_buf_new(0));
                }
                /* read_raw_body_begin sets uk->reading_raw */
                uk->reading_raw_remaining = count;
                return read_raw_body_begin(uk, RAW_TYPE_BINARY);
            }

        case 0xc5:  // bin 16
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 2);
                uint16_t count = _msgpack_be16(cb->u16);
                if(count == 0) {
                    return object_complete_binary(uk, rb_str_buf_new(0));
                }
                /* read_raw_body_begin sets uk->reading_raw */
                uk->reading_raw_remaining = count;
                return read_raw_body_begin(uk, RAW_TYPE_BINARY);
            }

        case 0xc6:  // bin 32
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 4);
                uint32_t count = _msgpack_be32(cb->u32);
                if(count == 0) {
                    return object_complete_binary(uk, rb_str_buf_new(0));
                }
                /* read_raw_body_begin sets uk->reading_raw */
                uk->reading_raw_remaining = count;
                return read_raw_body_begin(uk, RAW_TYPE_BINARY);
            }

        case 0xdc:  // array 16
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 2);
                uint16_t count = _msgpack_be16(cb->u16);
                if(count == 0) {
                    return object_complete(uk, rb_ary_new());
                }
                return _msgpack_unpacker_stack_push(uk, STACK_TYPE_ARRAY, count, rb_ary_new2(count));
            }

        case 0xdd:  // array 32
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 4);
                uint32_t count = _msgpack_be32(cb->u32);
                if(count == 0) {
                    return object_complete(uk, rb_ary_new());
                }
                return _msgpack_unpacker_stack_push(uk, STACK_TYPE_ARRAY, count, rb_ary_new2(count));
            }

        case 0xde:  // map 16
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 2);
                uint16_t count = _msgpack_be16(cb->u16);
                if(count == 0) {
                    return object_complete(uk, rb_hash_new());
                }
                return _msgpack_unpacker_stack_push(uk, STACK_TYPE_MAP_KEY, count*2, rb_hash_new());
            }

        case 0xdf:  // map 32
            {
                READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 4);
                uint32_t count = _msgpack_be32(cb->u32);
                if(count == 0) {
                    return object_complete(uk, rb_hash_new());
                }
                return _msgpack_unpacker_stack_push(uk, STACK_TYPE_MAP_KEY, count*2, rb_hash_new());
            }

        default:
            return PRIMITIVE_INVALID_BYTE;
        }

    SWITCH_RANGE_DEFAULT
        return PRIMITIVE_INVALID_BYTE;

    SWITCH_RANGE_END
}

int msgpack_unpacker_read_array_header(msgpack_unpacker_t* uk, uint32_t* result_size)
{
    int b = get_head_byte(uk);
    if(b < 0) {
        return b;
    }

    if(0x90 <= b && b <= 0x9f) {
        *result_size = b & 0x0f;

    } else if(b == 0xdc) {
        /* array 16 */
        READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 2);
        *result_size = _msgpack_be16(cb->u16);

    } else if(b == 0xdd) {
        /* array 32 */
        READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 4);
        *result_size = _msgpack_be32(cb->u32);

    } else {
        return PRIMITIVE_UNEXPECTED_TYPE;
    }

    reset_head_byte(uk);
    return 0;
}

int msgpack_unpacker_read_map_header(msgpack_unpacker_t* uk, uint32_t* result_size)
{
    int b = get_head_byte(uk);
    if(b < 0) {
        return b;
    }

    if(0x80 <= b && b <= 0x8f) {
        *result_size = b & 0x0f;

    } else if(b == 0xde) {
        /* map 16 */
        READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 2);
        *result_size = _msgpack_be16(cb->u16);

    } else if(b == 0xdf) {
        /* map 32 */
        READ_CAST_BLOCK_OR_RETURN_EOF(cb, uk, 4);
        *result_size = _msgpack_be32(cb->u32);

    } else {
        return PRIMITIVE_UNEXPECTED_TYPE;
    }

    reset_head_byte(uk);
    return 0;
}

int msgpack_unpacker_read(msgpack_unpacker_t* uk, size_t target_stack_depth)
{
    while(true) {
        int r = read_primitive(uk);
        if(r < 0) {
            return r;
        }
        if(r == PRIMITIVE_CONTAINER_START) {
            continue;
        }
        /* PRIMITIVE_OBJECT_COMPLETE */

        if(msgpack_unpacker_stack_is_empty(uk)) {
            return PRIMITIVE_OBJECT_COMPLETE;
        }

        container_completed:
        {
            msgpack_unpacker_stack_t* top = _msgpack_unpacker_stack_top(uk);
            switch(top->type) {
            case STACK_TYPE_ARRAY:
                rb_ary_push(top->object, uk->last_object);
                break;
            case STACK_TYPE_MAP_KEY:
                top->key = uk->last_object;
                top->type = STACK_TYPE_MAP_VALUE;
                break;
            case STACK_TYPE_MAP_VALUE:
                if(uk->symbolize_keys && rb_type(top->key) == T_STRING) {
                    /* here uses rb_intern_str instead of rb_intern so that Ruby VM can GC unused symbols */
#ifdef HAVE_RB_STR_INTERN
                    /* rb_str_intern is added since MRI 2.2.0 */
                    rb_hash_aset(top->object, rb_str_intern(top->key), uk->last_object);
#else
#ifndef HAVE_RB_INTERN_STR
                    /* MRI 1.8 doesn't have rb_intern_str or rb_intern2 */
                    rb_hash_aset(top->object, ID2SYM(rb_intern(RSTRING_PTR(top->key))), uk->last_object);
#else
                    rb_hash_aset(top->object, ID2SYM(rb_intern_str(top->key)), uk->last_object);
#endif
#endif
                } else {
                    rb_hash_aset(top->object, top->key, uk->last_object);
                }
                top->type = STACK_TYPE_MAP_KEY;
                break;
            }
            size_t count = --top->count;

            if(count == 0) {
                object_complete(uk, top->object);
                if(msgpack_unpacker_stack_pop(uk) <= target_stack_depth) {
                    return PRIMITIVE_OBJECT_COMPLETE;
                }
                goto container_completed;
            }
        }
    }
}

int msgpack_unpacker_skip(msgpack_unpacker_t* uk, size_t target_stack_depth)
{
    while(true) {
        int r = read_primitive(uk);
        if(r < 0) {
            return r;
        }
        if(r == PRIMITIVE_CONTAINER_START) {
            continue;
        }
        /* PRIMITIVE_OBJECT_COMPLETE */

        if(msgpack_unpacker_stack_is_empty(uk)) {
            return PRIMITIVE_OBJECT_COMPLETE;
        }

        container_completed:
        {
            msgpack_unpacker_stack_t* top = _msgpack_unpacker_stack_top(uk);

            /* this section optimized out */
            // TODO object_complete still creates objects which should be optimized out

            size_t count = --top->count;

            if(count == 0) {
                object_complete(uk, Qnil);
                if(msgpack_unpacker_stack_pop(uk) <= target_stack_depth) {
                    return PRIMITIVE_OBJECT_COMPLETE;
                }
                goto container_completed;
            }
        }
    }
}

int msgpack_unpacker_peek_next_object_type(msgpack_unpacker_t* uk)
{
    int b = get_head_byte(uk);
    if(b < 0) {
        return b;
    }

    SWITCH_RANGE_BEGIN(b)
    SWITCH_RANGE(b, 0x00, 0x7f)  // Positive Fixnum
        return TYPE_INTEGER;

    SWITCH_RANGE(b, 0xe0, 0xff)  // Negative Fixnum
        return TYPE_INTEGER;

    SWITCH_RANGE(b, 0xa0, 0xbf)  // FixRaw
        return TYPE_RAW;

    SWITCH_RANGE(b, 0x90, 0x9f)  // FixArray
        return TYPE_ARRAY;

    SWITCH_RANGE(b, 0x80, 0x8f)  // FixMap
        return TYPE_MAP;

    SWITCH_RANGE(b, 0xc0, 0xdf)  // Variable
        switch(b) {
        case 0xc0:  // nil
            return TYPE_NIL;

        case 0xc2:  // false
        case 0xc3:  // true
            return TYPE_BOOLEAN;

        case 0xca:  // float
        case 0xcb:  // double
            return TYPE_FLOAT;

        case 0xcc:  // unsigned int  8
        case 0xcd:  // unsigned int 16
        case 0xce:  // unsigned int 32
        case 0xcf:  // unsigned int 64
            return TYPE_INTEGER;

        case 0xd0:  // signed int  8
        case 0xd1:  // signed int 16
        case 0xd2:  // signed int 32
        case 0xd3:  // signed int 64
            return TYPE_INTEGER;

        case 0xd9:  // raw 8 / str 8
        case 0xda:  // raw 16 / str 16
        case 0xdb:  // raw 32 / str 32
            return TYPE_RAW;

        case 0xc4:  // bin 8
        case 0xc5:  // bin 16
        case 0xc6:  // bin 32
            return TYPE_RAW;

        case 0xdc:  // array 16
        case 0xdd:  // array 32
            return TYPE_ARRAY;

        case 0xde:  // map 16
        case 0xdf:  // map 32
            return TYPE_MAP;

        default:
            return PRIMITIVE_INVALID_BYTE;
        }

    SWITCH_RANGE_DEFAULT
        return PRIMITIVE_INVALID_BYTE;

    SWITCH_RANGE_END
}

int msgpack_unpacker_skip_nil(msgpack_unpacker_t* uk)
{
    int b = get_head_byte(uk);
    if(b < 0) {
        return b;
    }
    if(b == 0xc0) {
        return 1;
    }
    return 0;
}


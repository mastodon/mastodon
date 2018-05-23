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
#ifndef MSGPACK_RUBY_PACKER_H__
#define MSGPACK_RUBY_PACKER_H__

#include "buffer.h"
#include "packer_ext_registry.h"

#ifndef MSGPACK_PACKER_IO_FLUSH_THRESHOLD_TO_WRITE_STRING_BODY
#define MSGPACK_PACKER_IO_FLUSH_THRESHOLD_TO_WRITE_STRING_BODY (1024)
#endif

struct msgpack_packer_t;
typedef struct msgpack_packer_t msgpack_packer_t;

struct msgpack_packer_t {
    msgpack_buffer_t buffer;

    bool compatibility_mode;
    bool has_symbol_ext_type;

    ID to_msgpack_method;
    VALUE to_msgpack_arg;

    VALUE buffer_ref;

    /* options */
    bool comaptibility_mode;
    msgpack_packer_ext_registry_t ext_registry;
};

#define PACKER_BUFFER_(pk) (&(pk)->buffer)

void msgpack_packer_static_init();

void msgpack_packer_static_destroy();

void msgpack_packer_init(msgpack_packer_t* pk);

void msgpack_packer_destroy(msgpack_packer_t* pk);

void msgpack_packer_mark(msgpack_packer_t* pk);

static inline void msgpack_packer_set_to_msgpack_method(msgpack_packer_t* pk,
        ID to_msgpack_method, VALUE to_msgpack_arg)
{
    pk->to_msgpack_method = to_msgpack_method;
    pk->to_msgpack_arg = to_msgpack_arg;
}

void msgpack_packer_reset(msgpack_packer_t* pk);

static inline void msgpack_packer_set_compat(msgpack_packer_t* pk, bool enable)
{
    pk->compatibility_mode = enable;
}

static inline void msgpack_packer_write_nil(msgpack_packer_t* pk)
{
    msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 1);
    msgpack_buffer_write_1(PACKER_BUFFER_(pk), 0xc0);
}

static inline void msgpack_packer_write_true(msgpack_packer_t* pk)
{
    msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 1);
    msgpack_buffer_write_1(PACKER_BUFFER_(pk), 0xc3);
}

static inline void msgpack_packer_write_false(msgpack_packer_t* pk)
{
    msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 1);
    msgpack_buffer_write_1(PACKER_BUFFER_(pk), 0xc2);
}

static inline void _msgpack_packer_write_fixint(msgpack_packer_t* pk, int8_t v)
{
    msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 1);
    msgpack_buffer_write_1(PACKER_BUFFER_(pk), v);
}

static inline void _msgpack_packer_write_uint8(msgpack_packer_t* pk, uint8_t v)
{
    msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 2);
    msgpack_buffer_write_2(PACKER_BUFFER_(pk), 0xcc, v);
}

static inline void _msgpack_packer_write_uint16(msgpack_packer_t* pk, uint16_t v)
{
    msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 3);
    uint16_t be = _msgpack_be16(v);
    msgpack_buffer_write_byte_and_data(PACKER_BUFFER_(pk), 0xcd, (const void*)&be, 2);
}

static inline void _msgpack_packer_write_uint32(msgpack_packer_t* pk, uint32_t v)
{
    msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 5);
    uint32_t be = _msgpack_be32(v);
    msgpack_buffer_write_byte_and_data(PACKER_BUFFER_(pk), 0xce, (const void*)&be, 4);
}

static inline void _msgpack_packer_write_uint64(msgpack_packer_t* pk, uint64_t v)
{
    msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 9);
    uint64_t be = _msgpack_be64(v);
    msgpack_buffer_write_byte_and_data(PACKER_BUFFER_(pk), 0xcf, (const void*)&be, 8);
}

static inline void _msgpack_packer_write_int8(msgpack_packer_t* pk, int8_t v)
{
    msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 2);
    msgpack_buffer_write_2(PACKER_BUFFER_(pk), 0xd0, v);
}

static inline void _msgpack_packer_write_int16(msgpack_packer_t* pk, int16_t v)
{
    msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 3);
    uint16_t be = _msgpack_be16(v);
    msgpack_buffer_write_byte_and_data(PACKER_BUFFER_(pk), 0xd1, (const void*)&be, 2);
}

static inline void _msgpack_packer_write_int32(msgpack_packer_t* pk, int32_t v)
{
    msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 5);
    uint32_t be = _msgpack_be32(v);
    msgpack_buffer_write_byte_and_data(PACKER_BUFFER_(pk), 0xd2, (const void*)&be, 4);
}

static inline void _msgpack_packer_write_int64(msgpack_packer_t* pk, int64_t v)
{
    msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 9);
    uint64_t be = _msgpack_be64(v);
    msgpack_buffer_write_byte_and_data(PACKER_BUFFER_(pk), 0xd3, (const void*)&be, 8);
}

static inline void _msgpack_packer_write_long32(msgpack_packer_t* pk, long v)
{
    if(v < -0x20L) {
        if(v < -0x8000L) {
            _msgpack_packer_write_int32(pk, (int32_t) v);
        } else if(v < -0x80L) {
            _msgpack_packer_write_int16(pk, (int16_t) v);
        } else {
            _msgpack_packer_write_int8(pk, (int8_t) v);
        }
    } else if(v <= 0x7fL) {
        _msgpack_packer_write_fixint(pk, (int8_t) v);
    } else {
        if(v <= 0xffL) {
            _msgpack_packer_write_uint8(pk, (uint8_t) v);
        } else if(v <= 0xffffL) {
            _msgpack_packer_write_uint16(pk, (uint16_t) v);
        } else {
            _msgpack_packer_write_uint32(pk, (uint32_t) v);
        }
    }
}

static inline void _msgpack_packer_write_long_long64(msgpack_packer_t* pk, long long v)
{
    if(v < -0x20LL) {
        if(v < -0x8000LL) {
            if(v < -0x80000000LL) {
                _msgpack_packer_write_int64(pk, (int64_t) v);
            } else {
                _msgpack_packer_write_int32(pk, (int32_t) v);
            }
        } else {
            if(v < -0x80LL) {
                _msgpack_packer_write_int16(pk, (int16_t) v);
            } else {
                _msgpack_packer_write_int8(pk, (int8_t) v);
            }
        }
    } else if(v <= 0x7fLL) {
        _msgpack_packer_write_fixint(pk, (int8_t) v);
    } else {
        if(v <= 0xffffLL) {
            if(v <= 0xffLL) {
                _msgpack_packer_write_uint8(pk, (uint8_t) v);
            } else {
                _msgpack_packer_write_uint16(pk, (uint16_t) v);
            }
        } else {
            if(v <= 0xffffffffLL) {
                _msgpack_packer_write_uint32(pk, (uint32_t) v);
            } else {
                _msgpack_packer_write_uint64(pk, (uint64_t) v);
            }
        }
    }
}

static inline void msgpack_packer_write_long(msgpack_packer_t* pk, long v)
{
#if defined(SIZEOF_LONG)
#  if SIZEOF_LONG <= 4
    _msgpack_packer_write_long32(pk, v);
#  else
    _msgpack_packer_write_long_long64(pk, v);
#  endif

#elif defined(LONG_MAX)
#  if LONG_MAX <= 0x7fffffffL
    _msgpack_packer_write_long32(pk, v);
#  else
    _msgpack_packer_write_long_long64(pk, v);
#  endif

#else
    if(sizeof(long) <= 4) {
        _msgpack_packer_write_long32(pk, v);
    } else {
        _msgpack_packer_write_long_long64(pk, v);
    }
#endif
}

static inline void msgpack_packer_write_long_long(msgpack_packer_t* pk, long long v)
{
    /* assuming sizeof(long long) == 8 */
    _msgpack_packer_write_long_long64(pk, v);
}

static inline void msgpack_packer_write_u64(msgpack_packer_t* pk, uint64_t v)
{
    if(v <= 0xffULL) {
        if(v <= 0x7fULL) {
            _msgpack_packer_write_fixint(pk, (int8_t) v);
        } else {
            _msgpack_packer_write_uint8(pk, (uint8_t) v);
        }
    } else {
        if(v <= 0xffffULL) {
            _msgpack_packer_write_uint16(pk, (uint16_t) v);
        } else if(v <= 0xffffffffULL) {
            _msgpack_packer_write_uint32(pk, (uint32_t) v);
        } else {
            _msgpack_packer_write_uint64(pk, (uint64_t) v);
        }
    }
}

static inline void msgpack_packer_write_float(msgpack_packer_t* pk, float v)
{
    msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 5);
    union {
        float f;
        uint32_t u32;
        char mem[4];
    } castbuf = { v };
    castbuf.u32 = _msgpack_be_float(castbuf.u32);
    msgpack_buffer_write_byte_and_data(PACKER_BUFFER_(pk), 0xca, castbuf.mem, 4);
}

static inline void msgpack_packer_write_double(msgpack_packer_t* pk, double v)
{
    msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 9);
    union {
        double d;
        uint64_t u64;
        char mem[8];
    } castbuf = { v };
    castbuf.u64 = _msgpack_be_double(castbuf.u64);
    msgpack_buffer_write_byte_and_data(PACKER_BUFFER_(pk), 0xcb, castbuf.mem, 8);
}

static inline void msgpack_packer_write_raw_header(msgpack_packer_t* pk, unsigned int n)
{
    if(n < 32) {
        msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 1);
        unsigned char h = 0xa0 | (uint8_t) n;
        msgpack_buffer_write_1(PACKER_BUFFER_(pk), h);
    } else if(n < 256 && !pk->compatibility_mode) {
        msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 2);
        unsigned char be = (uint8_t) n;
        msgpack_buffer_write_byte_and_data(PACKER_BUFFER_(pk), 0xd9, (const void*)&be, 1);
    } else if(n < 65536) {
        msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 3);
        uint16_t be = _msgpack_be16(n);
        msgpack_buffer_write_byte_and_data(PACKER_BUFFER_(pk), 0xda, (const void*)&be, 2);
    } else {
        msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 5);
        uint32_t be = _msgpack_be32(n);
        msgpack_buffer_write_byte_and_data(PACKER_BUFFER_(pk), 0xdb, (const void*)&be, 4);
    }
}

static inline void msgpack_packer_write_bin_header(msgpack_packer_t* pk, unsigned int n)
{
    if(n < 256) {
        msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 2);
        unsigned char be = (uint8_t) n;
        msgpack_buffer_write_byte_and_data(PACKER_BUFFER_(pk), 0xc4, (const void*)&be, 1);
    } else if(n < 65536) {
        msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 3);
        uint16_t be = _msgpack_be16(n);
        msgpack_buffer_write_byte_and_data(PACKER_BUFFER_(pk), 0xc5, (const void*)&be, 2);
    } else {
        msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 5);
        uint32_t be = _msgpack_be32(n);
        msgpack_buffer_write_byte_and_data(PACKER_BUFFER_(pk), 0xc6, (const void*)&be, 4);
    }
}

static inline void msgpack_packer_write_array_header(msgpack_packer_t* pk, unsigned int n)
{
    if(n < 16) {
        msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 1);
        unsigned char h = 0x90 | (uint8_t) n;
        msgpack_buffer_write_1(PACKER_BUFFER_(pk), h);
    } else if(n < 65536) {
        msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 3);
        uint16_t be = _msgpack_be16(n);
        msgpack_buffer_write_byte_and_data(PACKER_BUFFER_(pk), 0xdc, (const void*)&be, 2);
    } else {
        msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 5);
        uint32_t be = _msgpack_be32(n);
        msgpack_buffer_write_byte_and_data(PACKER_BUFFER_(pk), 0xdd, (const void*)&be, 4);
    }
}

static inline void msgpack_packer_write_map_header(msgpack_packer_t* pk, unsigned int n)
{
    if(n < 16) {
        msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 1);
        unsigned char h = 0x80 | (uint8_t) n;
        msgpack_buffer_write_1(PACKER_BUFFER_(pk), h);
    } else if(n < 65536) {
        msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 3);
        uint16_t be = _msgpack_be16(n);
        msgpack_buffer_write_byte_and_data(PACKER_BUFFER_(pk), 0xde, (const void*)&be, 2);
    } else {
        msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 5);
        uint32_t be = _msgpack_be32(n);
        msgpack_buffer_write_byte_and_data(PACKER_BUFFER_(pk), 0xdf, (const void*)&be, 4);
    }
}

static inline void msgpack_packer_write_ext(msgpack_packer_t* pk, int ext_type, VALUE payload)
{
    unsigned long len = RSTRING_LEN(payload);
    switch (len) {
    case 1:
        msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 2);
        msgpack_buffer_write_2(PACKER_BUFFER_(pk), 0xd4, ext_type);
        break;
    case 2:
        msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 2);
        msgpack_buffer_write_2(PACKER_BUFFER_(pk), 0xd5, ext_type);
        break;
    case 4:
        msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 2);
        msgpack_buffer_write_2(PACKER_BUFFER_(pk), 0xd6, ext_type);
        break;
    case 8:
        msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 2);
        msgpack_buffer_write_2(PACKER_BUFFER_(pk), 0xd7, ext_type);
        break;
    case 16:
        msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 2);
        msgpack_buffer_write_2(PACKER_BUFFER_(pk), 0xd8, ext_type);
        break;
    default:
        if(len < 256) {
            msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 3);
            msgpack_buffer_write_2(PACKER_BUFFER_(pk), 0xc7, len);
            msgpack_buffer_write_1(PACKER_BUFFER_(pk), ext_type);
        } else if(len < 65536) {
            msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 4);
            uint16_t be = _msgpack_be16(len);
            msgpack_buffer_write_byte_and_data(PACKER_BUFFER_(pk), 0xc8, (const void*)&be, 2);
            msgpack_buffer_write_1(PACKER_BUFFER_(pk), ext_type);
        } else {
            msgpack_buffer_ensure_writable(PACKER_BUFFER_(pk), 6);
            uint32_t be = _msgpack_be32(len);
            msgpack_buffer_write_byte_and_data(PACKER_BUFFER_(pk), 0xc9, (const void*)&be, 4);
            msgpack_buffer_write_1(PACKER_BUFFER_(pk), ext_type);
        }
    }
    msgpack_buffer_append_string(PACKER_BUFFER_(pk), payload);
}

#ifdef COMPAT_HAVE_ENCODING
static inline bool msgpack_packer_is_binary(VALUE v, int encindex)
{
    return encindex == msgpack_rb_encindex_ascii8bit;
}

static inline bool msgpack_packer_is_utf8_compat_string(VALUE v, int encindex)
{
    return encindex == msgpack_rb_encindex_utf8
        || encindex == msgpack_rb_encindex_usascii
#ifdef ENC_CODERANGE_ASCIIONLY
        /* Because ENC_CODERANGE_ASCIIONLY does not scan string, it may return ENC_CODERANGE_UNKNOWN unlike */
        /* rb_enc_str_asciionly_p. It is always faster than rb_str_encode if it is available. */
        /* Very old Rubinius (< v1.3.1) doesn't have ENC_CODERANGE_ASCIIONLY. */
        || (rb_enc_asciicompat(rb_enc_from_index(encindex)) && ENC_CODERANGE_ASCIIONLY(v))
#endif
        ;
}
#endif

static inline void msgpack_packer_write_string_value(msgpack_packer_t* pk, VALUE v)
{
    /* actual return type of RSTRING_LEN is long */
    unsigned long len = RSTRING_LEN(v);
    if(len > 0xffffffffUL) {
        // TODO rb_eArgError?
        rb_raise(rb_eArgError, "size of string is too long to pack: %lu bytes should be <= %lu", len, 0xffffffffUL);
    }

#ifdef COMPAT_HAVE_ENCODING
    int encindex = ENCODING_GET(v);
    if(msgpack_packer_is_binary(v, encindex) && !pk->compatibility_mode) {
        /* write ASCII-8BIT string using Binary type */
        msgpack_packer_write_bin_header(pk, (unsigned int)len);
        msgpack_buffer_append_string(PACKER_BUFFER_(pk), v);
    } else {
        /* write UTF-8, US-ASCII, or 7bit-safe ascii-compatible string using String type directly */
        /* in compatibility mode, packer packs String values as is */
        if(!pk->compatibility_mode && !msgpack_packer_is_utf8_compat_string(v, encindex)) {
            /* transcode other strings to UTF-8 and write using String type */
            VALUE enc = rb_enc_from_encoding(rb_utf8_encoding()); /* rb_enc_from_encoding_index is not extern */
            v = rb_str_encode(v, enc, 0, Qnil);
            len = RSTRING_LEN(v);
        }
        msgpack_packer_write_raw_header(pk, (unsigned int)len);
        msgpack_buffer_append_string(PACKER_BUFFER_(pk), v);
    }
#else
    msgpack_packer_write_raw_header(pk, (unsigned int)len);
    msgpack_buffer_append_string(PACKER_BUFFER_(pk), v);
#endif
}

static inline void msgpack_packer_write_symbol_string_value(msgpack_packer_t* pk, VALUE v)
{
#ifdef HAVE_RB_SYM2STR
    /* rb_sym2str is added since MRI 2.2.0 */
    msgpack_packer_write_string_value(pk, rb_sym2str(v));
#else
    VALUE str = rb_id2str(SYM2ID(v));
    if (!str) {
       rb_raise(rb_eRuntimeError, "could not convert a symbol to string");
    }
    msgpack_packer_write_string_value(pk, str);
#endif
}

void msgpack_packer_write_other_value(msgpack_packer_t* pk, VALUE v);

static inline void msgpack_packer_write_symbol_value(msgpack_packer_t* pk, VALUE v)
{
    if (pk->has_symbol_ext_type) {
        msgpack_packer_write_other_value(pk, v);
    } else {
        msgpack_packer_write_symbol_string_value(pk, v);
    }
}

static inline void msgpack_packer_write_fixnum_value(msgpack_packer_t* pk, VALUE v)
{
#ifdef JRUBY
    msgpack_packer_write_long(pk, FIXNUM_P(v) ? FIX2LONG(v) : rb_num2ll(v));
#else
    msgpack_packer_write_long(pk, FIX2LONG(v));
#endif
}

static inline void msgpack_packer_write_bignum_value(msgpack_packer_t* pk, VALUE v)
{
    if(RBIGNUM_POSITIVE_P(v)) {
        msgpack_packer_write_u64(pk, rb_big2ull(v));
    } else {
        msgpack_packer_write_long_long(pk, rb_big2ll(v));
    }
}

static inline void msgpack_packer_write_float_value(msgpack_packer_t* pk, VALUE v)
{
    msgpack_packer_write_double(pk, rb_num2dbl(v));
}

void msgpack_packer_write_array_value(msgpack_packer_t* pk, VALUE v);

void msgpack_packer_write_hash_value(msgpack_packer_t* pk, VALUE v);

void msgpack_packer_write_value(msgpack_packer_t* pk, VALUE v);


#endif


/*
 * MessagePack for Ruby
 *
 * Copyright (C) 2008-2015 Sadayuki Furuhashi
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
#ifndef MSGPACK_RUBY_UNPACKER_EXT_REGISTRY_H__
#define MSGPACK_RUBY_UNPACKER_EXT_REGISTRY_H__

#include "compat.h"
#include "ruby.h"

struct msgpack_unpacker_ext_registry_t;
typedef struct msgpack_unpacker_ext_registry_t msgpack_unpacker_ext_registry_t;

struct msgpack_unpacker_ext_registry_t {
    VALUE array[256];
    //int bitmap;
};

void msgpack_unpacker_ext_registry_static_init();

void msgpack_unpacker_ext_registry_static_destroy();

void msgpack_unpacker_ext_registry_init(msgpack_unpacker_ext_registry_t* ukrg);

static inline void msgpack_unpacker_ext_registry_destroy(msgpack_unpacker_ext_registry_t* ukrg)
{ }

void msgpack_unpacker_ext_registry_mark(msgpack_unpacker_ext_registry_t* ukrg);

void msgpack_unpacker_ext_registry_dup(msgpack_unpacker_ext_registry_t* src,
        msgpack_unpacker_ext_registry_t* dst);

VALUE msgpack_unpacker_ext_registry_put(msgpack_unpacker_ext_registry_t* ukrg,
        VALUE ext_module, int ext_type, VALUE proc, VALUE arg);

static inline VALUE msgpack_unpacker_ext_registry_lookup(msgpack_unpacker_ext_registry_t* ukrg,
        int ext_type)
{
    VALUE e = ukrg->array[ext_type + 128];
    if(e == Qnil) {
        return Qnil;
    }
    return rb_ary_entry(e, 1);
}

#endif

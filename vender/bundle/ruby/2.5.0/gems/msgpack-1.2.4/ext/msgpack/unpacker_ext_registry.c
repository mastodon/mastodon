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

#include "unpacker_ext_registry.h"

static ID s_call;
static ID s_dup;

void msgpack_unpacker_ext_registry_static_init()
{
    s_call = rb_intern("call");
    s_dup = rb_intern("dup");
}

void msgpack_unpacker_ext_registry_static_destroy()
{ }

void msgpack_unpacker_ext_registry_init(msgpack_unpacker_ext_registry_t* ukrg)
{
    for(int i=0; i < 256; i++) {
        ukrg->array[i] = Qnil;
    }
}

void msgpack_unpacker_ext_registry_mark(msgpack_unpacker_ext_registry_t* ukrg)
{
    for(int i=0; i < 256; i++) {
        rb_gc_mark(ukrg->array[i]);
    }
}

void msgpack_unpacker_ext_registry_dup(msgpack_unpacker_ext_registry_t* src,
        msgpack_unpacker_ext_registry_t* dst)
{
    for(int i=0; i < 256; i++) {
        dst->array[i] = src->array[i];
    }
}

VALUE msgpack_unpacker_ext_registry_put(msgpack_unpacker_ext_registry_t* ukrg,
        VALUE ext_module, int ext_type, VALUE proc, VALUE arg)
{
    VALUE e = rb_ary_new3(3, ext_module, proc, arg);
    VALUE before = ukrg->array[ext_type + 128];
    ukrg->array[ext_type + 128] = e;
    return before;
}

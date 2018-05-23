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

#include "packer_ext_registry.h"

static ID s_call;

void msgpack_packer_ext_registry_static_init()
{
    s_call = rb_intern("call");
}

void msgpack_packer_ext_registry_static_destroy()
{ }

void msgpack_packer_ext_registry_init(msgpack_packer_ext_registry_t* pkrg)
{
    pkrg->hash = rb_hash_new();
    pkrg->cache = rb_hash_new();
}

void msgpack_packer_ext_registry_mark(msgpack_packer_ext_registry_t* pkrg)
{
    rb_gc_mark(pkrg->hash);
    rb_gc_mark(pkrg->cache);
}

void msgpack_packer_ext_registry_dup(msgpack_packer_ext_registry_t* src,
        msgpack_packer_ext_registry_t* dst)
{
#ifdef HAVE_RB_HASH_DUP
    dst->hash = rb_hash_dup(src->hash);
    dst->cache = rb_hash_dup(src->cache);
#else
    dst->hash = rb_funcall(src->hash, rb_intern("dup"), 0);
    dst->cache = rb_funcall(src->cache, rb_intern("dup"), 0);
#endif
}

#ifndef HAVE_RB_HASH_CLEAR

static int
__rb_hash_clear_clear_i(key, value, dummy)
    VALUE key, value, dummy;
{
    return ST_DELETE;
}

#endif

VALUE msgpack_packer_ext_registry_put(msgpack_packer_ext_registry_t* pkrg,
        VALUE ext_module, int ext_type, VALUE proc, VALUE arg)
{
    VALUE e = rb_ary_new3(3, INT2FIX(ext_type), proc, arg);
    /* clear lookup cache not to miss added type */
#ifdef HAVE_RB_HASH_CLEAR
    rb_hash_clear(pkrg->cache);
#else
    if(FIX2INT(rb_funcall(pkrg->cache, rb_intern("size"), 0)) > 0) {
        rb_hash_foreach(pkrg->cache, __rb_hash_clear_clear_i, 0);
    }
#endif
    return rb_hash_aset(pkrg->hash, ext_module, e);
}

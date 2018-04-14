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

#include "rmem.h"

void msgpack_rmem_init(msgpack_rmem_t* pm)
{
    memset(pm, 0, sizeof(msgpack_rmem_t));
    pm->head.pages = xmalloc(MSGPACK_RMEM_PAGE_SIZE * 32);
    pm->head.mask = 0xffffffff;  /* all bit is 1 = available */
}

void msgpack_rmem_destroy(msgpack_rmem_t* pm)
{
    msgpack_rmem_chunk_t* c = pm->array_first;
    msgpack_rmem_chunk_t* cend = pm->array_last;
    for(; c != cend; c++) {
        xfree(c->pages);
    }
    xfree(pm->head.pages);
    xfree(pm->array_first);
}

void* _msgpack_rmem_alloc2(msgpack_rmem_t* pm)
{
    msgpack_rmem_chunk_t* c = pm->array_first;
    msgpack_rmem_chunk_t* last = pm->array_last;
    for(; c != last; c++) {
        if(_msgpack_rmem_chunk_available(c)) {
            void* mem = _msgpack_rmem_chunk_alloc(c);

            /* move to head */
            msgpack_rmem_chunk_t tmp = pm->head;
            pm->head = *c;
            *c = tmp;
            return mem;
        }
    }

    if(c == pm->array_end) {
        size_t capacity = c - pm->array_first;
        size_t length = last - pm->array_first;
        capacity = (capacity == 0) ? 8 : capacity * 2;
        msgpack_rmem_chunk_t* array = xrealloc(pm->array_first, capacity * sizeof(msgpack_rmem_chunk_t));
        pm->array_first = array;
        pm->array_last = array + length;
        pm->array_end = array + capacity;
    }

    /* allocate new chunk */
    c = pm->array_last++;

    /* move to head */
    msgpack_rmem_chunk_t tmp = pm->head;
    pm->head = *c;
    *c = tmp;

    pm->head.mask = 0xffffffff & (~1);  /* "& (~1)" means first chunk is already allocated */
    pm->head.pages = xmalloc(MSGPACK_RMEM_PAGE_SIZE * 32);

    return pm->head.pages;
}

void _msgpack_rmem_chunk_free(msgpack_rmem_t* pm, msgpack_rmem_chunk_t* c)
{
    if(pm->array_first->mask == 0xffffffff) {
        /* free and move to last */
        pm->array_last--;
        xfree(c->pages);
        *c = *pm->array_last;
        return;
    }

    /* move to first */
    msgpack_rmem_chunk_t tmp = *pm->array_first;
    *pm->array_first = *c;
    *c = tmp;
}


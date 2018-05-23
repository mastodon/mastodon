/* hash.c
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *  - Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 
 *  - Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 
 *  - Neither the name of Peter Ohler nor the names of its contributors may be
 *    used to endorse or promote products derived from this software without
 *    specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "hash.h"
#include <stdint.h>

#define HASH_MASK	0x000003FF
#define  HASH_SLOT_CNT	1024

typedef struct _KeyVal {
    struct _KeyVal	*next;
    const char		*key;
    size_t		len;
    VALUE		val;
} *KeyVal;

struct _Hash {
    struct _KeyVal	slots[HASH_SLOT_CNT];
};

struct _Hash	class_hash;
struct _Hash	intern_hash;

// almost the Murmur hash algorithm
#define M 0x5bd1e995
#define C1 0xCC9E2D51
#define C2 0x1B873593
#define N  0xE6546B64

static uint32_t
hash_calc(const uint8_t *key, size_t len) {
    const uint8_t	*end = key + len;
    const uint8_t	*endless = key + (len / 4 * 4);
    uint32_t		h = (uint32_t)len;
    uint32_t		k;

    while (key < endless) {
	k = (uint32_t)*key++;
	k |= (uint32_t)*key++ << 8;
	k |= (uint32_t)*key++ << 16;
	k |= (uint32_t)*key++ << 24;

        k *= M;
        k ^= k >> 24;
        h *= M;
        h ^= k * M;
    }
    if (1 < end - key) {
	uint16_t	k16 = (uint16_t)*key++;

	k16 |= (uint16_t)*key++ << 8;
	h ^= k16 << 8;
    }
    if (key < end) {
	h ^= *key;
    }
    h *= M;
    h ^= h >> 13;
    h *= M;
    h ^= h >> 15;
    
    return h;
}

void
oj_hash_init() {
    memset(class_hash.slots, 0, sizeof(class_hash.slots));
    memset(intern_hash.slots, 0, sizeof(intern_hash.slots));
}

// if slotp is 0 then just lookup
static VALUE
hash_get(Hash hash, const char *key, size_t len, VALUE **slotp, VALUE def_value) {
    uint32_t	h = hash_calc((const uint8_t*)key, len) & HASH_MASK;
    KeyVal	bucket = hash->slots + h;

    if (0 != bucket->key) {
	KeyVal	b;

	for (b = bucket; 0 != b; b = b->next) {
	    if (len == b->len && 0 == strncmp(b->key, key, len)) {
		*slotp = &b->val;
		return b->val;
	    }
	    bucket = b;
	}
    }
    if (0 != slotp) {
	if (0 != bucket->key) {
	    KeyVal	b = ALLOC(struct _KeyVal);
	
	    b->next = 0;
	    bucket->next = b;
	    bucket = b;
	}
	bucket->key = oj_strndup(key, len);
	bucket->len = len;
	bucket->val = def_value;
	*slotp = &bucket->val;
    }
    return def_value;
}

void
oj_hash_print() {
    int		i;
    KeyVal	b;

    for (i = 0; i < HASH_SLOT_CNT; i++) {
	printf("%4d:", i);
	for (b = class_hash.slots + i; 0 != b && 0 != b->key; b = b->next) {
	    printf(" %s", b->key);
	}
	printf("\n");
    }
}

VALUE
oj_class_hash_get(const char *key, size_t len, VALUE **slotp) {
    return hash_get(&class_hash, key, len, slotp, Qnil);
}

ID
oj_attr_hash_get(const char *key, size_t len, ID **slotp) {
    return (ID)hash_get(&intern_hash, key, len, (VALUE**)slotp, 0);
}

char*
oj_strndup(const char *s, size_t len) {
    char	*d = ALLOC_N(char, len + 1);
    
    memcpy(d, s, len);
    d[len] = '\0';

    return d;
}

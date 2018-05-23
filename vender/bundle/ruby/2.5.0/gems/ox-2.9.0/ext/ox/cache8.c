/* cache8.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

#include "ruby.h"
#include "cache8.h"

#define BITS		4
#define MASK		0x000000000000000FULL
#define SLOT_CNT	16
#define DEPTH		16

typedef union {
    struct _Cache8	*child;
    slot_t		value;
} Bucket;

struct _Cache8 {
    Bucket	buckets[SLOT_CNT];
};

static void	cache8_delete(Cache8 cache, int depth);
//static void	slot_print(Cache8 cache, sid_t key, unsigned int depth);

void
ox_cache8_new(Cache8 *cache) {
    Bucket	*b;
    int		i;
    
    *cache = ALLOC(struct _Cache8);
    for (i = SLOT_CNT, b = (*cache)->buckets; 0 < i; i--, b++) {
	b->value = 0;
    }
}

void
ox_cache8_delete(Cache8 cache) {
    cache8_delete(cache, 0);
}

static void
cache8_delete(Cache8 cache, int depth) {
    Bucket		*b;
    unsigned int	i;

    for (i = 0, b = cache->buckets; i < SLOT_CNT; i++, b++) {
	if (0 != b->child) {
	    if (DEPTH - 1 != depth) {
		cache8_delete(b->child, depth + 1);
	    }
	}
    }
    xfree(cache);
}

slot_t
ox_cache8_get(Cache8 cache, sid_t key, slot_t **slot) {
    Bucket	*b;
    int		i;
    sid_t	k8 = (sid_t)key;
    sid_t	k;
    
    for (i = 64 - BITS; 0 < i; i -= BITS) {
	k = (k8 >> i) & MASK;
	b = cache->buckets + k;
	if (0 == b->child) {
	    ox_cache8_new(&b->child);
	}
	cache = b->child;
    }
    *slot = &(cache->buckets + (k8 & MASK))->value;

    return **slot;
}

#if 0
void
ox_cache8_print(Cache8 cache) {
    //printf("-------------------------------------------\n");
    slot_print(cache, 0, 0);
}

static void
slot_print(Cache8 c, sid_t key, unsigned int depth) {
    Bucket		*b;
    unsigned int	i;
    sid_t		k8 = (sid_t)key;
    sid_t		k;

    for (i = 0, b = c->buckets; i < SLOT_CNT; i++, b++) {
	if (0 != b->child) {
	    k = (k8 << BITS) | i;
	    //printf("*** key: 0x%016llx  depth: %u  i: %u\n", k, depth, i);
	    if (DEPTH - 1 == depth) {
		printf("0x%016llx: %4llu\n", (unsigned long long)k, (unsigned long long)b->value);
	    } else {
		slot_print(b->child, k, depth + 1);
	    }
	}
    }
}
#endif

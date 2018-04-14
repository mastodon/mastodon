/* cache.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#ifndef __OX_CACHE_H__
#define __OX_CACHE_H__

#include "ruby.h"

typedef struct _Cache   *Cache;

extern void     ox_cache_new(Cache *cache);

extern VALUE    ox_cache_get(Cache cache, const char *key, VALUE **slot, const char **keyp);

extern void     ox_cache_print(Cache cache);

#endif /* __OX_CACHE_H__ */

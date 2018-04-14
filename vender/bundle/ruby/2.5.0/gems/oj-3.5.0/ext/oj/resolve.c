/* resolve.c
 * Copyright (c) 2012, Peter Ohler
 * All rights reserved.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#if USE_PTHREAD_MUTEX
#include <pthread.h>
#endif

#include "oj.h"
#include "err.h"
#include "parse.h"
#include "hash.h"

inline static VALUE
resolve_classname(VALUE mod, const char *classname, int auto_define) {
    VALUE	clas;
    ID		ci = rb_intern(classname);

    if (rb_const_defined_at(mod, ci)) {
	clas = rb_const_get_at(mod, ci);
    } else if (auto_define) {
	clas = rb_define_class_under(mod, classname, oj_bag_class);
    } else {
	clas = Qundef;
    }
    return clas;
}

static VALUE
resolve_classpath(ParseInfo pi, const char *name, size_t len, int auto_define, VALUE error_class) {
    char	class_name[1024];
    VALUE	clas;
    char	*end = class_name + sizeof(class_name) - 1;
    char	*s;
    const char	*n = name;

    clas = rb_cObject;
    for (s = class_name; 0 < len; n++, len--) {
	if (':' == *n) {
	    *s = '\0';
	    n++;
	    len--;
	    if (':' != *n) {
		return Qundef;
	    }
	    if (Qundef == (clas = resolve_classname(clas, class_name, auto_define))) {
		return Qundef;
	    }
	    s = class_name;
	} else if (end <= s) {
	    return Qundef;
	} else {
	    *s++ = *n;
	}
    }
    *s = '\0';
    if (Qundef == (clas = resolve_classname(clas, class_name, auto_define))) {
	oj_set_error_at(pi, error_class, __FILE__, __LINE__, "class %s is not defined", name);
	if (Qnil != error_class) {
	    pi->err_class = error_class;
	}
    }
    return clas;
}

VALUE
oj_name2class(ParseInfo pi, const char *name, size_t len, int auto_define, VALUE error_class) {
    VALUE	clas;
    VALUE	*slot;

    if (No == pi->options.class_cache) {
	return resolve_classpath(pi, name, len, auto_define, error_class);
    }
#if USE_PTHREAD_MUTEX
    pthread_mutex_lock(&oj_cache_mutex);
#elif USE_RB_MUTEX
    rb_mutex_lock(oj_cache_mutex);
#endif
    if (Qnil == (clas = oj_class_hash_get(name, len, &slot))) {
	if (Qundef != (clas = resolve_classpath(pi, name, len, auto_define, error_class))) {
	    *slot = clas;
	}
    }
#if USE_PTHREAD_MUTEX
    pthread_mutex_unlock(&oj_cache_mutex);
#elif USE_RB_MUTEX
    rb_mutex_unlock(oj_cache_mutex);
#endif
    return clas;
}

VALUE
oj_name2struct(ParseInfo pi, VALUE nameVal, VALUE error_class) {
    size_t	len = RSTRING_LEN(nameVal);
    const char	*str = StringValuePtr(nameVal);

    return resolve_classpath(pi, str, len, 0, error_class);
}

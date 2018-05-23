/* circarray.c
 * Copyright (c) 2012, Peter Ohler
 * All rights reserved.
 */

#include "circarray.h"

CircArray
oj_circ_array_new() {
    CircArray	ca;
    
    if (0 == (ca = ALLOC(struct _CircArray))) {
	rb_raise(rb_eNoMemError, "not enough memory\n");
    }
    ca->objs = ca->obj_array;
    ca->size = sizeof(ca->obj_array) / sizeof(VALUE);
    ca->cnt = 0;
    
    return ca;
}

void
oj_circ_array_free(CircArray ca) {
    if (ca->objs != ca->obj_array) {
	xfree(ca->objs);
    }
    xfree(ca);
}

void
oj_circ_array_set(CircArray ca, VALUE obj, unsigned long id) {
    if (0 < id && 0 != ca) {
	unsigned long	i;

	if (ca->size < id) {
	    unsigned long	cnt = id + 512;

	    if (ca->objs == ca->obj_array) {
		if (0 == (ca->objs = ALLOC_N(VALUE, cnt))) {
		    rb_raise(rb_eNoMemError, "not enough memory\n");
		}
		memcpy(ca->objs, ca->obj_array, sizeof(VALUE) * ca->cnt);
	    } else { 
		REALLOC_N(ca->objs, VALUE, cnt);
	    }
	    ca->size = cnt;
	}
	id--;
	for (i = ca->cnt; i < id; i++) {
	    ca->objs[i] = Qnil;
	}
	ca->objs[id] = obj;
	if (ca->cnt <= id) {
	    ca->cnt = id + 1;
	}
    }
}

VALUE
oj_circ_array_get(CircArray ca, unsigned long id) {
    VALUE	obj = Qnil;

    if (id <= ca->cnt && 0 != ca) {
	obj = ca->objs[id - 1];
    }
    return obj;
}


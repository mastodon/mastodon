/* hash_load.c
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#include <stdbool.h>
#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

#include "ruby.h"
#include "ox.h"

// The approach taken for the hash and has_no_attrs parsing is to push just
// the key on to the stack and then decide what to do on the way up/out.

static VALUE
create_top(PInfo pi) {
    volatile VALUE       top = rb_hash_new();;

    helper_stack_push(&pi->helpers, 0, top, HashCode);
    pi->obj = top;

    return top;
}

static void
add_text(PInfo pi, char *text, int closed) {
    Helper		parent = helper_stack_peek(&pi->helpers);
    volatile VALUE	s = rb_str_new2(text);
    volatile VALUE	a;

#if HAS_ENCODING_SUPPORT
    if (0 != pi->options->rb_enc) {
        rb_enc_associate(s, pi->options->rb_enc);
    }
#elif HAS_PRIVATE_ENCODING
    if (Qnil != pi->options->rb_enc) {
	rb_funcall(s, ox_force_encoding_id, 1, pi->options->rb_enc);
    }
#endif
    switch (parent->type) {
    case NoCode:
	parent->obj = s;
	parent->type = StringCode;
	break;
    case ArrayCode:
	rb_ary_push(parent->obj, s);
	break;
    default:
	a = rb_ary_new();
	rb_ary_push(a, parent->obj);
	rb_ary_push(a, s);
	parent->obj = a;
	parent->type = ArrayCode;
	break;
    }
}

static void
add_element(PInfo pi, const char *ename, Attr attrs, int hasChildren) {
    if (helper_stack_empty(&pi->helpers)) {
	create_top(pi);
    }
    if (NULL != attrs && NULL != attrs->name) {
	volatile VALUE	h = rb_hash_new();
        volatile VALUE	key;
	volatile VALUE	val;
	volatile VALUE	a;
	
        for (; 0 != attrs->name; attrs++) {
	    if (Yes == pi->options->sym_keys) {
		key = rb_id2sym(rb_intern(attrs->name));
	    } else {
		key = rb_str_new2(attrs->name);
	    }
	    val = rb_str_new2(attrs->value);
#if HAS_ENCODING_SUPPORT
	    if (0 != pi->options->rb_enc) {
		rb_enc_associate(val, pi->options->rb_enc);
	    }
#elif HAS_PRIVATE_ENCODING
	    if (Qnil != pi->options->rb_enc) {
		rb_funcall(val, ox_force_encoding_id, 1, pi->options->rb_enc);
	    }
#endif
	    rb_hash_aset(h, key, val);
	}
	a = rb_ary_new();
	rb_ary_push(a, h);
	rb_obj_taint(a); // flag indicating it is a unit, kind of a hack but it works
	helper_stack_push(&pi->helpers, rb_intern(ename), a, ArrayCode);
    } else {
	helper_stack_push(&pi->helpers, rb_intern(ename), Qnil, NoCode);
    }
}

static void
add_element_no_attrs(PInfo pi, const char *ename, Attr attrs, int hasChildren) {
    if (helper_stack_empty(&pi->helpers)) {
	create_top(pi);
    }
    helper_stack_push(&pi->helpers, rb_intern(ename), Qnil, NoCode);
}

static int
untaint_hash_cb(VALUE key, VALUE value, VALUE x) {
    if (Qtrue == rb_obj_tainted(value)) {
	rb_obj_untaint(value);
    }
    return ST_CONTINUE;
}

static void
end_element_core(PInfo pi, const char *ename, bool check_taint) {
    Helper		e = helper_stack_pop(&pi->helpers);
    Helper		parent = helper_stack_peek(&pi->helpers);
    volatile VALUE	pobj = parent->obj;
    volatile VALUE	found = Qundef;
    volatile VALUE	key;
    volatile VALUE	a;

    if (NoCode == e->type) {
	e->obj = Qnil;
    }
    if (Yes == pi->options->sym_keys) {
	key = rb_id2sym(e->var);
    } else {
	key = rb_id2str(e->var);
    }
    // Make sure the parent is a Hash. If not set then make a Hash. If an
    // Array or non-Hash then append to array or create and append.
    switch (parent->type) {
    case NoCode:
	pobj = rb_hash_new();
	parent->obj = pobj;
	parent->type = HashCode;
	break;
    case ArrayCode:
	pobj = rb_hash_new();
	rb_ary_push(parent->obj, pobj);
	break;
    case HashCode:
	found = rb_hash_lookup2(parent->obj, key, Qundef);
	break;
    default:
	a = rb_ary_new();
	rb_ary_push(a, parent->obj);
	pobj = rb_hash_new();
	rb_ary_push(a, pobj);
	parent->obj = a;
	parent->type = ArrayCode;
	break;
    }
    if (Qundef == found) {
	rb_hash_aset(pobj, key, e->obj);
    } else if (RUBY_T_ARRAY == rb_type(found)) {
	if (check_taint && Qtrue == rb_obj_tainted(found)) {
	    rb_obj_untaint(found);
	    a = rb_ary_new();
	    rb_ary_push(a, found);
	    rb_ary_push(a, e->obj);
	    rb_hash_aset(pobj, key, a);
	} else {
	    rb_ary_push(found, e->obj);
	}
    } else { // something there other than an array
	if (check_taint && Qtrue == rb_obj_tainted(e->obj)) {
	    rb_obj_untaint(e->obj);
	}
	a = rb_ary_new();
	rb_ary_push(a, found);
	rb_ary_push(a, e->obj);
	rb_hash_aset(pobj, key, a);
    }
    if (check_taint && RUBY_T_HASH == rb_type(e->obj)) {
	rb_hash_foreach(e->obj, untaint_hash_cb, Qnil);
    }
}

static void
end_element(PInfo pi, const char *ename) {
    end_element_core(pi, ename, true);
}

static void
end_element_no_attrs(PInfo pi, const char *ename) {
    end_element_core(pi, ename, false);
}

static void
finish(PInfo pi) {
    if (Qnil != pi->obj && RUBY_T_HASH == rb_type(pi->obj)) {
	rb_hash_foreach(pi->obj, untaint_hash_cb, Qnil);
    }
}

struct _ParseCallbacks   _ox_hash_callbacks = {
    NULL,
    NULL,
    NULL,
    NULL,
    add_text,
    add_element,
    end_element,
    finish,
};

ParseCallbacks   ox_hash_callbacks = &_ox_hash_callbacks;

struct _ParseCallbacks   _ox_hash_no_attrs_callbacks = {
    NULL,
    NULL,
    NULL,
    NULL,
    add_text,
    add_element_no_attrs,
    end_element_no_attrs,
    NULL,
};

ParseCallbacks   ox_hash_no_attrs_callbacks = &_ox_hash_no_attrs_callbacks;

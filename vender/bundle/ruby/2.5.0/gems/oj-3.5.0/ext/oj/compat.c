/* compat.c
 * Copyright (c) 2012, Peter Ohler
 * All rights reserved.
 */

#include <stdio.h>

#include "oj.h"
#include "err.h"
#include "parse.h"
#include "resolve.h"
#include "hash.h"
#include "encode.h"
#include "trace.h"

static void
hash_set_cstr(ParseInfo pi, Val kval, const char *str, size_t len, const char *orig) {
    const char		*key = kval->key;
    int			klen = kval->klen;
    Val			parent = stack_peek(&pi->stack);
    volatile VALUE	rkey = kval->key_val;

    if (Qundef == rkey &&
	Yes == pi->options.create_ok &&
	NULL != pi->options.create_id &&
	*pi->options.create_id == *key &&
	(int)pi->options.create_id_len == klen &&
	0 == strncmp(pi->options.create_id, key, klen)) {

	parent->classname = oj_strndup(str, len);
	parent->clen = len;
    } else {
	volatile VALUE	rstr = rb_str_new(str, len);

	if (Qundef == rkey) {
	    rkey = rb_str_new(key, klen);
	    rstr = oj_encode(rstr);
	    rkey = oj_encode(rkey);
	    if (Yes == pi->options.sym_key) {
		rkey = rb_str_intern(rkey);
	    }
	}
	if (Yes == pi->options.create_ok && NULL != pi->options.str_rx.head) {
	    VALUE	clas = oj_rxclass_match(&pi->options.str_rx, str, (int)len);

	    if (Qnil != clas) {
		rstr = rb_funcall(clas, oj_json_create_id, 1, rstr);
	    }
	}
	if (rb_cHash != rb_obj_class(parent->val)) {
	    // The rb_hash_set would still work but the unit tests for the
	    // json gem require the less efficient []= method be called to set
	    // values. Even using the store method to set the values will fail
	    // the unit tests.
	    rb_funcall(parent->val, rb_intern("[]="), 2, rkey, rstr);
	} else {
	    rb_hash_aset(parent->val, rkey, rstr);
	}
	if (Yes == pi->options.trace) {
	    oj_trace_parse_call("set_string", pi, __FILE__, __LINE__, rstr);
	}
    }
}

static VALUE
start_hash(ParseInfo pi) {
    volatile VALUE	h;
    
    if (Qnil != pi->options.hash_class) {
	h = rb_class_new_instance(0, NULL, pi->options.hash_class);
    } else {
	h = rb_hash_new();
    }
    if (Yes == pi->options.trace) {
	oj_trace_parse_in("start_hash", pi, __FILE__, __LINE__);
    }
    return h;
}

static void
end_hash(struct _ParseInfo *pi) {
    Val	parent = stack_peek(&pi->stack);

    if (0 != parent->classname) {
	volatile VALUE	clas;

	clas = oj_name2class(pi, parent->classname, parent->clen, 0, rb_eArgError);
	if (Qundef != clas) { // else an error
	    ID	creatable = rb_intern("json_creatable?");
	    
	    if (!rb_respond_to(clas, creatable) || Qtrue == rb_funcall(clas, creatable, 0)) {
		parent->val = rb_funcall(clas, oj_json_create_id, 1, parent->val);
	    }
	}
	if (0 != parent->classname) {
	    xfree((char*)parent->classname);
	    parent->classname = 0;
	}
    }
    if (Yes == pi->options.trace) {
	oj_trace_parse_hash_end(pi, __FILE__, __LINE__);
    }
}

static VALUE
calc_hash_key(ParseInfo pi, Val parent) {
    volatile VALUE	rkey = parent->key_val;

    if (Qundef == rkey) {
	rkey = rb_str_new(parent->key, parent->klen);
    }
    rkey = oj_encode(rkey);
    if (Yes == pi->options.sym_key) {
	rkey = rb_str_intern(rkey);
    }
    return rkey;
}

static void
add_cstr(ParseInfo pi, const char *str, size_t len, const char *orig) {
    volatile VALUE	rstr = rb_str_new(str, len);

    rstr = oj_encode(rstr);
    if (Yes == pi->options.create_ok && NULL != pi->options.str_rx.head) {
	VALUE	clas = oj_rxclass_match(&pi->options.str_rx, str, (int)len);

	if (Qnil != clas) {
	    pi->stack.head->val = rb_funcall(clas, oj_json_create_id, 1, rstr);
	    return;
	}
    }
    pi->stack.head->val = rstr;
    if (Yes == pi->options.trace) {
	oj_trace_parse_call("add_string", pi, __FILE__, __LINE__, rstr);
    }
}

static void
add_num(ParseInfo pi, NumInfo ni) {
    pi->stack.head->val = oj_num_as_value(ni);
    if (Yes == pi->options.trace) {
	oj_trace_parse_call("add_number", pi, __FILE__, __LINE__, pi->stack.head->val);
    }
}

static void
hash_set_num(struct _ParseInfo *pi, Val parent, NumInfo ni) {
    volatile VALUE	rval = oj_num_as_value(ni);
    
    if (!oj_use_hash_alt && rb_cHash != rb_obj_class(parent->val)) {
	// The rb_hash_set would still work but the unit tests for the
	// json gem require the less efficient []= method be called to set
	// values. Even using the store method to set the values will fail
	// the unit tests.
	rb_funcall(stack_peek(&pi->stack)->val, rb_intern("[]="), 2, calc_hash_key(pi, parent), rval);
    } else {
	rb_hash_aset(stack_peek(&pi->stack)->val, calc_hash_key(pi, parent), rval);
    }
    if (Yes == pi->options.trace) {
	oj_trace_parse_call("set_number", pi, __FILE__, __LINE__, rval);
    }
}

static void
hash_set_value(ParseInfo pi, Val parent, VALUE value) {
    if (rb_cHash != rb_obj_class(parent->val)) {
	// The rb_hash_set would still work but the unit tests for the
	// json gem require the less efficient []= method be called to set
	// values. Even using the store method to set the values will fail
	// the unit tests.
	rb_funcall(stack_peek(&pi->stack)->val, rb_intern("[]="), 2, calc_hash_key(pi, parent), value);
    } else {
	rb_hash_aset(stack_peek(&pi->stack)->val, calc_hash_key(pi, parent), value);
    }
    if (Yes == pi->options.trace) {
	oj_trace_parse_call("set_value", pi, __FILE__, __LINE__, value);
    }
}

static VALUE
start_array(ParseInfo pi) {
    if (Qnil != pi->options.array_class) {
	return rb_class_new_instance(0, NULL, pi->options.array_class);
    }
    if (Yes == pi->options.trace) {
	oj_trace_parse_in("start_array", pi, __FILE__, __LINE__);
    }
    return rb_ary_new();
}

static void
array_append_num(ParseInfo pi, NumInfo ni) {
    Val			parent = stack_peek(&pi->stack);
    volatile VALUE	rval = oj_num_as_value(ni);
    
    if (!oj_use_array_alt && rb_cArray != rb_obj_class(parent->val)) {
	// The rb_ary_push would still work but the unit tests for the json
	// gem require the less efficient << method be called to push the
	// values.
	rb_funcall(parent->val, rb_intern("<<"), 1, rval);
    } else {
	rb_ary_push(parent->val, rval);
    }
    if (Yes == pi->options.trace) {
	oj_trace_parse_call("append_number", pi, __FILE__, __LINE__, rval);
    }
}

static void
array_append_cstr(ParseInfo pi, const char *str, size_t len, const char *orig) {
    volatile VALUE	rstr = rb_str_new(str, len);

    rstr = oj_encode(rstr);
    if (Yes == pi->options.create_ok && NULL != pi->options.str_rx.head) {
	VALUE	clas = oj_rxclass_match(&pi->options.str_rx, str, (int)len);

	if (Qnil != clas) {
	    rb_ary_push(stack_peek(&pi->stack)->val, rb_funcall(clas, oj_json_create_id, 1, rstr));
	    return;
	}
    }
    rb_ary_push(stack_peek(&pi->stack)->val, rstr);
    if (Yes == pi->options.trace) {
	oj_trace_parse_call("append_string", pi, __FILE__, __LINE__, rstr);
    }
}

void
oj_set_compat_callbacks(ParseInfo pi) {
    oj_set_strict_callbacks(pi);
    pi->start_hash = start_hash;
    pi->end_hash = end_hash;
    pi->hash_set_cstr = hash_set_cstr;
    pi->hash_set_num = hash_set_num;
    pi->hash_set_value = hash_set_value;
    pi->add_num = add_num;
    pi->add_cstr = add_cstr;
    pi->array_append_cstr = array_append_cstr;
    pi->start_array = start_array;
    pi->array_append_num = array_append_num;
}

VALUE
oj_compat_parse(int argc, VALUE *argv, VALUE self) {
    struct _ParseInfo	pi;

    parse_info_init(&pi);
    pi.options = oj_default_options;
    pi.handler = Qnil;
    pi.err_class = Qnil;
    pi.max_depth = 0;
    pi.options.allow_nan = Yes;
    pi.options.nilnil = Yes;
    pi.options.empty_string = No;
    oj_set_compat_callbacks(&pi);

    if (T_STRING == rb_type(*argv)) {
	return oj_pi_parse(argc, argv, &pi, 0, 0, false);
    } else {
	return oj_pi_sparse(argc, argv, &pi, 0);
    }
}

VALUE
oj_compat_load(int argc, VALUE *argv, VALUE self) {
    struct _ParseInfo	pi;

    parse_info_init(&pi);
    pi.options = oj_default_options;
    pi.handler = Qnil;
    pi.err_class = Qnil;
    pi.max_depth = 0;
    pi.options.allow_nan = Yes;
    pi.options.nilnil = Yes;
    pi.options.empty_string = Yes;
    oj_set_compat_callbacks(&pi);
    
    if (T_STRING == rb_type(*argv)) {
	return oj_pi_parse(argc, argv, &pi, 0, 0, false);
    } else {
	return oj_pi_sparse(argc, argv, &pi, 0);
    }
}

VALUE
oj_compat_parse_cstr(int argc, VALUE *argv, char *json, size_t len) {
    struct _ParseInfo	pi;

    parse_info_init(&pi);
    pi.options = oj_default_options;
    pi.handler = Qnil;
    pi.err_class = Qnil;
    pi.max_depth = 0;
    pi.options.allow_nan = Yes;
    pi.options.nilnil = Yes;
    oj_set_compat_callbacks(&pi);

    return oj_pi_parse(argc, argv, &pi, json, len, false);
}

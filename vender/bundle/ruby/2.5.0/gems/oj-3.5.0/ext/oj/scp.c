/* scp.c
 * Copyright (c) 2012, Peter Ohler
 * All rights reserved.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <sys/types.h>
#include <unistd.h>

#include "oj.h"
#include "parse.h"
#include "encode.h"

static VALUE
noop_start(ParseInfo pi) {
    return Qnil;
}

static void
noop_end(ParseInfo pi) {
}

static void
noop_add_value(ParseInfo pi, VALUE val) {
}

static void
noop_add_cstr(ParseInfo pi, const char *str, size_t len, const char *orig) {
}

static void
noop_add_num(ParseInfo pi, NumInfo ni) {
}

static VALUE
noop_hash_key(struct _ParseInfo *pi, const char *key, size_t klen) {
    return Qundef;
}

static void
noop_hash_set_cstr(ParseInfo pi, Val kval, const char *str, size_t len, const char *orig) {
}

static void
noop_hash_set_num(ParseInfo pi, Val kval, NumInfo ni) {
}

static void
noop_hash_set_value(ParseInfo pi, Val kval, VALUE value) {
}

static void
noop_array_append_cstr(ParseInfo pi, const char *str, size_t len, const char *orig) {
}

static void
noop_array_append_num(ParseInfo pi, NumInfo ni) {
}

static void
noop_array_append_value(ParseInfo pi, VALUE value) {
}

static void
add_value(ParseInfo pi, VALUE val) {
    rb_funcall(pi->handler, oj_add_value_id, 1, val);
}

static void
add_cstr(ParseInfo pi, const char *str, size_t len, const char *orig) {
    volatile VALUE	rstr = rb_str_new(str, len);

    rstr = oj_encode(rstr);
    rb_funcall(pi->handler, oj_add_value_id, 1, rstr);
}

static void
add_num(ParseInfo pi, NumInfo ni) {
    rb_funcall(pi->handler, oj_add_value_id, 1, oj_num_as_value(ni));
}

static VALUE
start_hash(ParseInfo pi) {
    return rb_funcall(pi->handler, oj_hash_start_id, 0);
}

static void
end_hash(ParseInfo pi) {
    rb_funcall(pi->handler, oj_hash_end_id, 0);
}

static VALUE
start_array(ParseInfo pi) {
    return rb_funcall(pi->handler, oj_array_start_id, 0);
}

static void
end_array(ParseInfo pi) {
    rb_funcall(pi->handler, oj_array_end_id, 0);
}

static VALUE
calc_hash_key(ParseInfo pi, Val kval) {
    volatile VALUE	rkey = kval->key_val;

    if (Qundef == rkey) {
	rkey = rb_str_new(kval->key, kval->klen);
	rkey = oj_encode(rkey);
	if (Yes == pi->options.sym_key) {
	    rkey = rb_str_intern(rkey);
	}
    }
    return rkey;
}

static VALUE
hash_key(struct _ParseInfo *pi, const char *key, size_t klen) {
    return rb_funcall(pi->handler, oj_hash_key_id, 1, rb_str_new(key, klen));
}

static void
hash_set_cstr(ParseInfo pi, Val kval, const char *str, size_t len, const char *orig) {
    volatile VALUE	rstr = rb_str_new(str, len);

    rstr = oj_encode(rstr);
    rb_funcall(pi->handler, oj_hash_set_id, 3, stack_peek(&pi->stack)->val, calc_hash_key(pi, kval), rstr);
}

static void
hash_set_num(ParseInfo pi, Val kval, NumInfo ni) {
    rb_funcall(pi->handler, oj_hash_set_id, 3, stack_peek(&pi->stack)->val, calc_hash_key(pi, kval), oj_num_as_value(ni));
}

static void
hash_set_value(ParseInfo pi, Val kval, VALUE value) {
    rb_funcall(pi->handler, oj_hash_set_id, 3, stack_peek(&pi->stack)->val, calc_hash_key(pi, kval), value);
}

static void
array_append_cstr(ParseInfo pi, const char *str, size_t len, const char *orig) {
    volatile VALUE	rstr = rb_str_new(str, len);

    rstr = oj_encode(rstr);
    rb_funcall(pi->handler, oj_array_append_id, 2, stack_peek(&pi->stack)->val, rstr);
}

static void
array_append_num(ParseInfo pi, NumInfo ni) {
    rb_funcall(pi->handler, oj_array_append_id, 2, stack_peek(&pi->stack)->val, oj_num_as_value(ni));
}

static void
array_append_value(ParseInfo pi, VALUE value) {
    rb_funcall(pi->handler, oj_array_append_id, 2, stack_peek(&pi->stack)->val, value);
}

VALUE
oj_sc_parse(int argc, VALUE *argv, VALUE self) {
    struct _ParseInfo	pi;
    VALUE		input = argv[1];

    parse_info_init(&pi);
    pi.err_class = Qnil;
    pi.max_depth = 0;
    pi.options = oj_default_options;
    if (3 == argc) {
	oj_parse_options(argv[2], &pi.options);
    }
    if (rb_block_given_p()) {
	pi.proc = Qnil;
    } else {
	pi.proc = Qundef;
    }
    pi.handler = *argv;

    pi.start_hash = rb_respond_to(pi.handler, oj_hash_start_id) ? start_hash : noop_start;
    pi.end_hash = rb_respond_to(pi.handler, oj_hash_end_id) ? end_hash : noop_end;
    pi.hash_key = rb_respond_to(pi.handler, oj_hash_key_id) ? hash_key : noop_hash_key;
    pi.start_array = rb_respond_to(pi.handler, oj_array_start_id) ? start_array : noop_start;
    pi.end_array = rb_respond_to(pi.handler, oj_array_end_id) ? end_array : noop_end;
    if (rb_respond_to(pi.handler, oj_hash_set_id)) {
	pi.hash_set_value = hash_set_value;
	pi.hash_set_cstr = hash_set_cstr;
	pi.hash_set_num = hash_set_num;
	pi.expect_value = 1;
    } else {
	pi.hash_set_value = noop_hash_set_value;
	pi.hash_set_cstr = noop_hash_set_cstr;
	pi.hash_set_num = noop_hash_set_num;
	pi.expect_value = 0;
    }
    if (rb_respond_to(pi.handler, oj_array_append_id)) {
	pi.array_append_value = array_append_value;
	pi.array_append_cstr = array_append_cstr;
	pi.array_append_num = array_append_num;
	pi.expect_value = 1;
    } else {
	pi.array_append_value = noop_array_append_value;
	pi.array_append_cstr = noop_array_append_cstr;
	pi.array_append_num = noop_array_append_num;
	pi.expect_value = 0;
    }
    if (rb_respond_to(pi.handler, oj_add_value_id)) {
	pi.add_cstr = add_cstr;
	pi.add_num = add_num;
	pi.add_value = add_value;
	pi.expect_value = 1;
    } else {
	pi.add_cstr = noop_add_cstr;
	pi.add_num = noop_add_num;
	pi.add_value = noop_add_value;
	pi.expect_value = 0;
    }
    pi.has_callbacks = true;

    if (T_STRING == rb_type(input)) {
	return oj_pi_parse(argc - 1, argv + 1, &pi, 0, 0, 1);
    } else {
	return oj_pi_sparse(argc - 1, argv + 1, &pi, 0);
    }
}

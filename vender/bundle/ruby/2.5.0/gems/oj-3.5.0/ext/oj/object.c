/* object.c
 * Copyright (c) 2012, Peter Ohler
 * All rights reserved.
 */

#include <stdio.h>
#include <time.h>

#include "oj.h"
#include "err.h"
#include "parse.h"
#include "resolve.h"
#include "hash.h"
#include "odd.h"
#include "encode.h"
#include "trace.h"

inline static long
read_long(const char *str, size_t len) {
    long	n = 0;

    for (; 0 < len; str++, len--) {
	if ('0' <= *str && *str <= '9') {
	    n = n * 10 + (*str - '0');
	} else {
	    return -1;
	}
    }
    return n;
}

static VALUE
calc_hash_key(ParseInfo pi, Val kval, char k1) {
    volatile VALUE	rkey;

    if (':' == k1) {
	rkey = rb_str_new(kval->key + 1, kval->klen - 1);
	rkey = oj_encode(rkey);
	rkey = rb_funcall(rkey, oj_to_sym_id, 0);
    } else {
	rkey = rb_str_new(kval->key, kval->klen);
	rkey = oj_encode(rkey);
	if (Yes == pi->options.sym_key) {
	    rkey = rb_str_intern(rkey);
	}
    }
    return rkey;
}

static VALUE
str_to_value(ParseInfo pi, const char *str, size_t len, const char *orig) {
    volatile VALUE	rstr = Qnil;

    if (':' == *orig && 0 < len) {
	rstr = rb_str_new(str + 1, len - 1);
	rstr = oj_encode(rstr);
	rstr = rb_funcall(rstr, oj_to_sym_id, 0);
    } else if (pi->circ_array && 3 <= len && '^' == *orig && 'r' == orig[1]) {
	long	i = read_long(str + 2, len - 2);

	if (0 > i) {
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "not a valid ID number");
	    return Qnil;
	}
	rstr = oj_circ_array_get(pi->circ_array, i);
    } else {
	rstr = rb_str_new(str, len);
	rstr = oj_encode(rstr);
    }
    return rstr;
}

#if (RUBY_VERSION_MAJOR == 1 && RUBY_VERSION_MINOR == 8)
static VALUE
oj_parse_xml_time(const char *str, int len) {
    return rb_funcall(rb_cTime, oj_parse_id, 1, rb_str_new(str, len));
}
#else
// The much faster approach (4x faster)
static int
parse_num(const char *str, const char *end, int cnt) {
    int		n = 0;
    char	c;
    int		i;

    for (i = cnt; 0 < i; i--, str++) {
	c = *str;
	if (end <= str || c < '0' || '9' < c) {
	    return -1;
	}
	n = n * 10 + (c - '0');
    }
    return n;
}

VALUE
oj_parse_xml_time(const char *str, int len) {
    VALUE	args[8];
    const char	*end = str + len;
    int		n;

    // year
    if (0 > (n = parse_num(str, end, 4))) {
	return Qnil;
    }
    str += 4;
    args[0] = LONG2NUM(n);
    if ('-' != *str++) {
	return Qnil;
    }
    // month
    if (0 > (n = parse_num(str, end, 2))) {
	return Qnil;
    }
    str += 2;
    args[1] = LONG2NUM(n);
    if ('-' != *str++) {
	return Qnil;
    }
    // day
    if (0 > (n = parse_num(str, end, 2))) {
	return Qnil;
    }
    str += 2;
    args[2] = LONG2NUM(n);
    if ('T' != *str++) {
	return Qnil;
    }
    // hour
    if (0 > (n = parse_num(str, end, 2))) {
	return Qnil;
    }
    str += 2;
    args[3] = LONG2NUM(n);
    if (':' != *str++) {
	return Qnil;
    }
    // minute
    if (0 > (n = parse_num(str, end, 2))) {
	return Qnil;
    }
    str += 2;
    args[4] = LONG2NUM(n);
    if (':' != *str++) {
	return Qnil;
    }
    // second
    if (0 > (n = parse_num(str, end, 2))) {
	return Qnil;
    }
    str += 2;
    if (str == end) {
	args[5] = LONG2NUM(n);
	args[6] = LONG2NUM(0);
    } else {
	char	c = *str++;

	if ('.' == c) {
	    long long	nsec = 0;

	    for (; str < end; str++) {
		c = *str;
		if (c < '0' || '9' < c) {
		    str++;
		    break;
		}
		nsec = nsec * 10 + (c - '0');
	    }
	    args[5] = rb_float_new((double)n + ((double)nsec + 0.5) / 1000000000.0);
	} else {
	    args[5] = rb_ll2inum(n);
	}
	if (end < str) {
	    args[6] = LONG2NUM(0);
	} else {
	    if ('Z' == c) {
		return rb_funcall2(rb_cTime, oj_utc_id, 6, args);
	    } else if ('+' == c) {
		int	hr = parse_num(str, end, 2);
		int	min;

		str += 2;
		if (0 > hr || ':' != *str++) {
		    return Qnil;
		}
		min = parse_num(str, end, 2);
		if (0 > min) {
		    return Qnil;
		}
		args[6] = LONG2NUM(hr * 3600 + min * 60);
	    } else if ('-' == c) {
		int	hr = parse_num(str, end, 2);
		int	min;

		str += 2;
		if (0 > hr || ':' != *str++) {
		    return Qnil;
		}
		min = parse_num(str, end, 2);
		if (0 > min) {
		    return Qnil;
		}
		args[6] = LONG2NUM(-(hr * 3600 + min * 60));
	    } else {
		args[6] = LONG2NUM(0);
	    }
	}
    }
    return rb_funcall2(rb_cTime, oj_new_id, 7, args);
}
#endif

static int
hat_cstr(ParseInfo pi, Val parent, Val kval, const char *str, size_t len) {
    const char	*key = kval->key;
    int		klen = kval->klen;

    if (2 == klen) {
	switch (key[1]) {
	case 'o': // object
	    {	// name2class sets an error if the class is not found or created
		VALUE	clas = oj_name2class(pi, str, len, Yes == pi->options.auto_define, rb_eArgError);

		if (Qundef != clas) {
		    parent->val = rb_obj_alloc(clas);
		}
	    }
	    break;
	case 'O': // odd object
	    {
		Odd	odd = oj_get_oddc(str, len);

		if (0 == odd) {
		    return 0;
		}
		parent->val = odd->clas;
		parent->odd_args = oj_odd_alloc_args(odd);
	    }
	    break;
	case 'm':
	    parent->val = rb_str_new(str + 1, len - 1);
	    parent->val = oj_encode(parent->val);
	    parent->val = rb_funcall(parent->val, oj_to_sym_id, 0);
	    break;
	case 's':
	    parent->val = rb_str_new(str, len);
	    parent->val = oj_encode(parent->val);
	    break;
	case 'c': // class
	    {
		VALUE	clas = oj_name2class(pi, str, len, Yes == pi->options.auto_define, rb_eArgError);

		if (Qundef == clas) {
		    return 0;
		} else {
		    parent->val = clas;
		}
	    }
	    break;
	case 't': // time
	    parent->val = oj_parse_xml_time(str, (int)len);
	    break;
	default:
	    return 0;
	    break;
	}
	return 1; // handled
    }
    return 0;
}

static int
hat_num(ParseInfo pi, Val parent, Val kval, NumInfo ni) {
    if (2 == kval->klen) {
	switch (kval->key[1]) {
	case 't': // time as a float
	    {
		int64_t	nsec = ni->num * 1000000000LL / ni->div;

		if (ni->neg) {
		    ni->i = -ni->i;
		    if (0 < nsec) {
			ni->i--;
			nsec = 1000000000LL - nsec;
		    }
		}
		if (86400 == ni->exp) { // UTC time
		    parent->val = rb_time_nano_new(ni->i, (long)nsec);
		    // Since the ruby C routines alway create local time, the
		    // offset and then a conversion to UTC keeps makes the time
		    // match the expected value.
		    parent->val = rb_funcall2(parent->val, oj_utc_id, 0, 0);
		} else if (ni->hasExp) {
		    time_t	t = (time_t)(ni->i + ni->exp);
		    struct tm	*st = gmtime(&t);
		    VALUE	args[8];

		    // Windows does not support dates before 1970 so ignore
		    // the zone and do the best we can.
		    if (NULL == st) {
			parent->val = rb_time_nano_new(ni->i, (long)nsec);
		    } else {
			args[0] = LONG2NUM((long)(1900 + st->tm_year));
			args[1] = LONG2NUM(1 + st->tm_mon);
			args[2] = LONG2NUM(st->tm_mday);
			args[3] = LONG2NUM(st->tm_hour);
			args[4] = LONG2NUM(st->tm_min);
			args[5] = rb_float_new((double)st->tm_sec + ((double)nsec + 0.5) / 1000000000.0);
			args[6] = LONG2NUM(ni->exp);
			parent->val = rb_funcall2(rb_cTime, oj_new_id, 7, args);
		    }
		} else {
		    parent->val = rb_time_nano_new(ni->i, (long)nsec);
		}
	    }
	    break;
	case 'i': // circular index
	    if (!ni->infinity && !ni->neg && 1 == ni->div && 0 == ni->exp && 0 != pi->circ_array) { // fixnum
		if (Qnil == parent->val) {
		    parent->val = rb_hash_new();
		}
		oj_circ_array_set(pi->circ_array, parent->val, ni->i);
	    } else {
		return 0;
	    }
	    break;
	default:
	    return 0;
	    break;
	}
	return 1; // handled
    }
    return 0;
}

static int
hat_value(ParseInfo pi, Val parent, const char *key, size_t klen, volatile VALUE value) {
    if (T_ARRAY == rb_type(value)) {
	int	len = (int)RARRAY_LEN(value);

	if (2 == klen && 'u' == key[1]) {
            volatile VALUE	sc;
	    volatile VALUE	e1;
	    int			slen;

	    if (0 == len) {
		oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "Invalid struct data");
		return 1;
	    }
	    e1 = *RARRAY_PTR(value);
	    // check for anonymous Struct
	    if (T_ARRAY == rb_type(e1)) {
		VALUE		args[1024];
		volatile VALUE	rstr;
		int		i, cnt = (int)RARRAY_LEN(e1);

		for (i = 0; i < cnt; i++) {
		    rstr = rb_ary_entry(e1, i);
		    args[i] = rb_funcall(rstr, oj_to_sym_id, 0);
		}
		sc = rb_funcall2(rb_cStruct, oj_new_id, cnt, args);
	    } else {
		// If struct is not defined then we let this fail and raise an exception.
		sc = oj_name2struct(pi, *RARRAY_PTR(value), rb_eArgError);
	    }
            // Create a properly initialized struct instance without calling the initialize method.
            parent->val = rb_obj_alloc(sc);
            // If the JSON array has more entries than the struct class allows, we record an error.
#ifdef RSTRUCT_LEN
#if RSTRUCT_LEN_RETURNS_INTEGER_OBJECT
	    slen = (int)NUM2LONG(RSTRUCT_LEN(parent->val));
#else // RSTRUCT_LEN_RETURNS_INTEGER_OBJECT
	    slen = (int)RSTRUCT_LEN(parent->val);
#endif // RSTRUCT_LEN_RETURNS_INTEGER_OBJECT
#else
	    slen = FIX2INT(rb_funcall2(parent->val, oj_length_id, 0, 0));
#endif
            // MRI >= 1.9
            if (len - 1 > slen) {
		oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "Invalid struct data");
            } else {
		int	i;

		for (i = 0; i < len - 1; i++) {
		    rb_struct_aset(parent->val, INT2FIX(i), RARRAY_PTR(value)[i + 1]);
		}
            }
	    return 1;
	} else if (3 <= klen && '#' == key[1]) {
	    volatile VALUE	*a;

	    if (2 != len) {
		oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "invalid hash pair");
		return 1;
	    }
	    parent->val = rb_hash_new();
	    a = RARRAY_PTR(value);
	    rb_hash_aset(parent->val, *a, a[1]);

	    return 1;
	}
    }
    return 0;
}

static void
copy_ivars(VALUE target, VALUE src) {
    volatile VALUE	vars = rb_funcall(src, oj_instance_variables_id, 0);
    volatile VALUE	*np = RARRAY_PTR(vars);
    ID			vid;
    int			i, cnt = (int)RARRAY_LEN(vars);
    const char		*attr;

    for (i = cnt; 0 < i; i--, np++) {
	vid = rb_to_id(*np);
	attr = rb_id2name(vid);
	if ('@' == *attr) {
	    rb_ivar_set(target, vid, rb_ivar_get(src, vid));
	}
    }
}

void
oj_set_obj_ivar(Val parent, Val kval, VALUE value) {
    const char	*key = kval->key;
    int		klen = kval->klen;
    ID		var_id;
    ID		*slot;

    if ('~' == *key && Qtrue == rb_obj_is_kind_of(parent->val, rb_eException)) {
	if (5 == klen && 0 == strncmp("~mesg", key, klen)) {
	    VALUE		args[1];
	    volatile VALUE	prev = parent->val;

	    args[0] = value;
	    parent->val = rb_class_new_instance(1, args, rb_class_of(parent->val));
	    copy_ivars(parent->val, prev);
	} else if (3 == klen && 0 == strncmp("~bt", key, klen)) {
	    rb_funcall(parent->val, rb_intern("set_backtrace"), 1, value);
	}
    }
#if USE_PTHREAD_MUTEX
    pthread_mutex_lock(&oj_cache_mutex);
#elif USE_RB_MUTEX
    rb_mutex_lock(oj_cache_mutex);
#endif
    if (0 == (var_id = oj_attr_hash_get(key, klen, &slot))) {
	char	attr[256];

	if ((int)sizeof(attr) <= klen + 2) {
	    char	*buf = ALLOC_N(char, klen + 2);

	    if ('~' == *key) {
		strncpy(buf, key + 1, klen - 1);
		buf[klen - 1] = '\0';
	    } else {
		*buf = '@';
		strncpy(buf + 1, key, klen);
		buf[klen + 1] = '\0';
	    }
	    var_id = rb_intern(buf);
	    xfree(buf);
	} else {
	    if ('~' == *key) {
		strncpy(attr, key + 1, klen - 1);
		attr[klen - 1] = '\0';
	    } else {
		*attr = '@';
		strncpy(attr + 1, key, klen);
		attr[klen + 1] = '\0';
	    }
	    var_id = rb_intern(attr);
	}
	*slot = var_id;
    }
#if USE_PTHREAD_MUTEX
    pthread_mutex_unlock(&oj_cache_mutex);
#elif USE_RB_MUTEX
    rb_mutex_unlock(oj_cache_mutex);
#endif
    rb_ivar_set(parent->val, var_id, value);
}

static void
hash_set_cstr(ParseInfo pi, Val kval, const char *str, size_t len, const char *orig) {
    const char		*key = kval->key;
    int			klen = kval->klen;
    Val			parent = stack_peek(&pi->stack);
    volatile VALUE	rval = Qnil;

 WHICH_TYPE:
    switch (rb_type(parent->val)) {
    case T_NIL:
	parent->odd_args = 0; // make sure it is 0 in case not odd
	if ('^' != *key || !hat_cstr(pi, parent, kval, str, len)) {
	    parent->val = rb_hash_new();
	    goto WHICH_TYPE;
	}
	break;
    case T_HASH:
	rb_hash_aset(parent->val, calc_hash_key(pi, kval, parent->k1), str_to_value(pi, str, len, orig));
	break;
    case T_STRING:
	rval = str_to_value(pi, str, len, orig);
	if (4 == klen && 's' == *key && 'e' == key[1] && 'l' == key[2] && 'f' == key[3]) {
	    rb_funcall(parent->val, oj_replace_id, 1, rval);
	} else {
	    oj_set_obj_ivar(parent, kval, rval);
	}
	break;
    case T_OBJECT:
	rval = str_to_value(pi, str, len, orig);
	oj_set_obj_ivar(parent, kval, rval);
	break;
    case T_CLASS:
	if (0 == parent->odd_args) {
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "%s is not an odd class", rb_class2name(rb_obj_class(parent->val)));
	    return;
	} else {
	    rval = str_to_value(pi, str, len, orig);
	    if (0 != oj_odd_set_arg(parent->odd_args, kval->key, kval->klen, rval)) {
		char	buf[256];

		if ((int)sizeof(buf) - 1 <= klen) {
		    klen = sizeof(buf) - 2;
		}
		memcpy(buf, key, klen);
		buf[klen] = '\0';
		oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "%s is not an attribute of %s", buf, rb_class2name(rb_obj_class(parent->val)));
	    }
	}
	break;
    default:
	oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "can not add attributes to a %s", rb_class2name(rb_obj_class(parent->val)));
	return;
    }
    if (Yes == pi->options.trace) {
	oj_trace_parse_call("set_string", pi, __FILE__, __LINE__, rval);
    }
}

static void
hash_set_num(ParseInfo pi, Val kval, NumInfo ni) {
    const char		*key = kval->key;
    int			klen = kval->klen;
    Val			parent = stack_peek(&pi->stack);
    volatile VALUE	rval = Qnil;

 WHICH_TYPE:
    switch (rb_type(parent->val)) {
    case T_NIL:
	parent->odd_args = 0; // make sure it is 0 in case not odd
	if ('^' != *key || !hat_num(pi, parent, kval, ni)) {
	    parent->val = rb_hash_new();
	    goto WHICH_TYPE;
	}
	break;
    case T_HASH:
	rval = oj_num_as_value(ni);
	rb_hash_aset(parent->val, calc_hash_key(pi, kval, parent->k1), rval);
	break;
    case T_OBJECT:
	if (2 == klen && '^' == *key && 'i' == key[1] &&
	    !ni->infinity && !ni->neg && 1 == ni->div && 0 == ni->exp && 0 != pi->circ_array) { // fixnum
	    oj_circ_array_set(pi->circ_array, parent->val, ni->i);
	} else {
	    rval = oj_num_as_value(ni);
	    oj_set_obj_ivar(parent, kval, rval);
	}
	break;
    case T_CLASS:
	if (0 == parent->odd_args) {
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "%s is not an odd class", rb_class2name(rb_obj_class(parent->val)));
	    return;
	} else {
	    rval = oj_num_as_value(ni);
	    if (0 != oj_odd_set_arg(parent->odd_args, key, klen, rval)) {
		char	buf[256];

		if ((int)sizeof(buf) - 1 <= klen) {
		    klen = sizeof(buf) - 2;
		}
		memcpy(buf, key, klen);
		buf[klen] = '\0';
		oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "%s is not an attribute of %s", buf, rb_class2name(rb_obj_class(parent->val)));
	    }
	}
	break;
    default:
	oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "can not add attributes to a %s", rb_class2name(rb_obj_class(parent->val)));
	return;
    }
    if (Yes == pi->options.trace) {
	oj_trace_parse_call("add_number", pi, __FILE__, __LINE__, rval);
    }
}

static void
hash_set_value(ParseInfo pi, Val kval, VALUE value) {
    const char	*key = kval->key;
    int		klen = kval->klen;
    Val		parent = stack_peek(&pi->stack);

 WHICH_TYPE:
    switch (rb_type(parent->val)) {
    case T_NIL:
	parent->odd_args = 0; // make sure it is 0 in case not odd
	if ('^' != *key || !hat_value(pi, parent, key, klen, value)) {
	    parent->val = rb_hash_new();
	    goto WHICH_TYPE;
	}
	break;
    case T_HASH:
	if (rb_cHash != rb_obj_class(parent->val)) {
	    if (4 == klen && 's' == *key && 'e' == key[1] && 'l' == key[2] && 'f' == key[3]) {
		rb_funcall(parent->val, oj_replace_id, 1, value);
	    } else {
		oj_set_obj_ivar(parent, kval, value);
	    }
	} else {
	    if (3 <= klen && '^' == *key && '#' == key[1] && T_ARRAY == rb_type(value)) {
		long		len = RARRAY_LEN(value);
		volatile VALUE	*a = RARRAY_PTR(value);

		if (2 != len) {
		    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "invalid hash pair");
		    return;
		}
		rb_hash_aset(parent->val, *a, a[1]);
	    } else {
		rb_hash_aset(parent->val, calc_hash_key(pi, kval, parent->k1), value);
	    }
	}
	break;
    case T_ARRAY:
	if (4 == klen && 's' == *key && 'e' == key[1] && 'l' == key[2] && 'f' == key[3]) {
	    rb_funcall(parent->val, oj_replace_id, 1, value);
	} else {
	    oj_set_obj_ivar(parent, kval, value);
	}
	break;
    case T_STRING: // for subclassed strings
    case T_OBJECT:
	oj_set_obj_ivar(parent, kval, value);
	break;
    case T_MODULE:
    case T_CLASS:
	if (0 == parent->odd_args) {
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "%s is not an odd class", rb_class2name(rb_obj_class(parent->val)));
	    return;
	} else if (0 !=	oj_odd_set_arg(parent->odd_args, key, klen, value)) {
	    char	buf[256];

	    if ((int)sizeof(buf) - 1 <= klen) {
		klen = sizeof(buf) - 2;
	    }
	    memcpy(buf, key, klen);
	    buf[klen] = '\0';
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "%s is not an attribute of %s", buf, rb_class2name(rb_obj_class(parent->val)));
	}
	break;
    default:
	oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "can not add attributes to a %s", rb_class2name(rb_obj_class(parent->val)));
	return;
    }
    if (Yes == pi->options.trace) {
	oj_trace_parse_call("add_value", pi, __FILE__, __LINE__, value);
    }
}

static VALUE
start_hash(ParseInfo pi) {
    if (Yes == pi->options.trace) {
	oj_trace_parse_in("start_hash", pi, __FILE__, __LINE__);
    }
    return Qnil;
}

static void
end_hash(struct _ParseInfo *pi) {
    Val	parent = stack_peek(&pi->stack);

    if (Qnil == parent->val) {
	parent->val = rb_hash_new();
    } else if (0 != parent->odd_args) {
	OddArgs	oa = parent->odd_args;

	parent->val = rb_funcall2(oa->odd->create_obj, oa->odd->create_op, oa->odd->attr_cnt, oa->args);
	oj_odd_free(oa);
	parent->odd_args = 0;
    }
    if (Yes == pi->options.trace) {
	oj_trace_parse_hash_end(pi, __FILE__, __LINE__);
    }
}

static void
array_append_cstr(ParseInfo pi, const char *str, size_t len, const char *orig) {
    volatile VALUE	rval = Qnil;
    
    if (3 <= len && 0 != pi->circ_array) {
	if ('i' == str[1]) {
	    long	i = read_long(str + 2, len - 2);

	    if (0 < i) {
		oj_circ_array_set(pi->circ_array, stack_peek(&pi->stack)->val, i);
		return;
	    }
	} else if ('r' == str[1]) {
	    long	i = read_long(str + 2, len - 2);

	    if (0 < i) {
		rb_ary_push(stack_peek(&pi->stack)->val, oj_circ_array_get(pi->circ_array, i));
		return;
	    }

	}
    }
    rval = str_to_value(pi, str, len, orig);
    rb_ary_push(stack_peek(&pi->stack)->val, rval);
    if (Yes == pi->options.trace) {
	oj_trace_parse_call("append_string", pi, __FILE__, __LINE__, rval);
    }
}

static void
array_append_num(ParseInfo pi, NumInfo ni) {
    volatile VALUE	rval = oj_num_as_value(ni);
    
    rb_ary_push(stack_peek(&pi->stack)->val, rval);
    if (Yes == pi->options.trace) {
	oj_trace_parse_call("append_number", pi, __FILE__, __LINE__, rval);
    }
}

static void
add_cstr(ParseInfo pi, const char *str, size_t len, const char *orig) {
    pi->stack.head->val = str_to_value(pi, str, len, orig);
    if (Yes == pi->options.trace) {
	oj_trace_parse_call("add_string", pi, __FILE__, __LINE__, pi->stack.head->val);
    }
}

static void
add_num(ParseInfo pi, NumInfo ni) {
    pi->stack.head->val = oj_num_as_value(ni);
    if (Yes == pi->options.trace) {
	oj_trace_parse_call("add_num", pi, __FILE__, __LINE__, pi->stack.head->val);
    }
}

void
oj_set_object_callbacks(ParseInfo pi) {
    oj_set_strict_callbacks(pi);
    pi->end_hash = end_hash;
    pi->start_hash = start_hash;
    pi->hash_set_cstr = hash_set_cstr;
    pi->hash_set_num = hash_set_num;
    pi->hash_set_value = hash_set_value;
    pi->add_cstr = add_cstr;
    pi->add_num = add_num;
    pi->array_append_cstr = array_append_cstr;
    pi->array_append_num = array_append_num;
}

VALUE
oj_object_parse(int argc, VALUE *argv, VALUE self) {
    struct _ParseInfo	pi;

    parse_info_init(&pi);
    pi.options = oj_default_options;
    pi.handler = Qnil;
    pi.err_class = Qnil;
    oj_set_object_callbacks(&pi);

    if (T_STRING == rb_type(*argv)) {
	return oj_pi_parse(argc, argv, &pi, 0, 0, 1);
    } else {
	return oj_pi_sparse(argc, argv, &pi, 0);
    }
}

VALUE
oj_object_parse_cstr(int argc, VALUE *argv, char *json, size_t len) {
    struct _ParseInfo	pi;

    parse_info_init(&pi);
    pi.options = oj_default_options;
    pi.handler = Qnil;
    pi.err_class = Qnil;
    oj_set_strict_callbacks(&pi);
    pi.end_hash = end_hash;
    pi.start_hash = start_hash;
    pi.hash_set_cstr = hash_set_cstr;
    pi.hash_set_num = hash_set_num;
    pi.hash_set_value = hash_set_value;
    pi.add_cstr = add_cstr;
    pi.add_num = add_num;
    pi.array_append_cstr = array_append_cstr;
    pi.array_append_num = array_append_num;

    return oj_pi_parse(argc, argv, &pi, json, len, 1);
}

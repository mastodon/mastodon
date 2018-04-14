/* custom.c
 * Copyright (c) 2012, 2017, Peter Ohler
 * All rights reserved.
 */

#include <stdio.h>

#include "code.h"
#include "dump.h"
#include "encode.h"
#include "err.h"
#include "hash.h"
#include "odd.h"
#include "oj.h"
#include "parse.h"
#include "resolve.h"
#include "trace.h"

extern void	oj_set_obj_ivar(Val parent, Val kval, VALUE value);
extern VALUE	oj_parse_xml_time(const char *str, int len); // from object.c

static void
dump_obj_str(VALUE obj, int depth, Out out) {
    struct _Attr	attrs[] = {
	{ "s", 1, Qnil },
	{ NULL, 0, Qnil },
    };
    attrs->value = rb_funcall(obj, oj_to_s_id, 0);

    oj_code_attrs(obj, attrs, depth, out, Yes == out->opts->create_ok);
}


static void
bigdecimal_dump(VALUE obj, int depth, Out out) {
    volatile VALUE	rstr = rb_funcall(obj, oj_to_s_id, 0);
    const char		*str = rb_string_value_ptr((VALUE*)&rstr);
    int			len = (int)RSTRING_LEN(rstr);

    if (0 == strcasecmp("Infinity", str)) {
	str = oj_nan_str(obj, out->opts->dump_opts.nan_dump, out->opts->mode, true, &len);
	oj_dump_raw(str, len, out);
    } else if (0 == strcasecmp("-Infinity", str)) {
	str = oj_nan_str(obj, out->opts->dump_opts.nan_dump, out->opts->mode, false, &len);
	oj_dump_raw(str, len, out);
    } else if (No == out->opts->bigdec_as_num) {
	oj_dump_cstr(str, len, 0, 0, out);
    } else {
	oj_dump_raw(str, len, out);
    }
}

static ID	real_id = 0;
static ID	imag_id = 0;

static void
complex_dump(VALUE obj, int depth, Out out) {
    struct _Attr	attrs[] = {
	{ "real", 4, Qnil },
	{ "imag", 4, Qnil },
	{ NULL, 0, Qnil },
    };
    if (0 == real_id) {
	real_id = rb_intern("real");
	imag_id = rb_intern("imag");
    }
    attrs[0].value = rb_funcall(obj, real_id, 0);
    attrs[1].value = rb_funcall(obj, imag_id, 0);

    oj_code_attrs(obj, attrs, depth, out, Yes == out->opts->create_ok);
}

static VALUE
complex_load(VALUE clas, VALUE args) {
    if (0 == real_id) {
	real_id = rb_intern("real");
	imag_id = rb_intern("imag");
    }
    return rb_complex_new(rb_hash_aref(args, rb_id2str(real_id)), rb_hash_aref(args, rb_id2str(imag_id)));
}

static void
date_dump(VALUE obj, int depth, Out out) {
    struct _Attr	attrs[] = {
	{ "s", 1, Qnil },
	{ NULL, 0, Qnil },
    };
    attrs->value = rb_funcall(obj, rb_intern("iso8601"), 0);

    oj_code_attrs(obj, attrs, depth, out, Yes == out->opts->create_ok);
}

static VALUE
date_load(VALUE clas, VALUE args) {
    volatile VALUE	v;
    
    if (Qnil != (v = rb_hash_aref(args, rb_str_new2("s")))) {
	return rb_funcall(oj_date_class, rb_intern("parse"), 1, v);
    }
    return Qnil;
}

static VALUE
datetime_load(VALUE clas, VALUE args) {
    volatile VALUE	v;
    
    if (Qnil != (v = rb_hash_aref(args, rb_str_new2("s")))) {
	return rb_funcall(oj_datetime_class, rb_intern("parse"), 1, v);
    }
    return Qnil;
}

static ID	table_id = 0;

static void
openstruct_dump(VALUE obj, int depth, Out out) {
    struct _Attr	attrs[] = {
	{ "table", 5, Qnil },
	{ NULL, 0, Qnil },
    };
    if (0 == table_id) {
	table_id = rb_intern("table");
    }
    attrs->value = rb_funcall(obj, table_id, 0);

    oj_code_attrs(obj, attrs, depth, out, Yes == out->opts->create_ok);
}

static VALUE
openstruct_load(VALUE clas, VALUE args) {
    if (0 == table_id) {
	table_id = rb_intern("table");
    }
    return rb_funcall(clas, oj_new_id, 1, rb_hash_aref(args, rb_id2str(table_id)));
}

static void
range_dump(VALUE obj, int depth, Out out) {
    struct _Attr	attrs[] = {
	{ "begin", 5, Qnil },
	{ "end", 3, Qnil },
	{ "exclude", 7, Qnil },
	{ NULL, 0, Qnil },
    };
    attrs[0].value = rb_funcall(obj, oj_begin_id, 0);
    attrs[1].value = rb_funcall(obj, oj_end_id, 0);
    attrs[2].value = rb_funcall(obj, oj_exclude_end_id, 0);

    oj_code_attrs(obj, attrs, depth, out, Yes == out->opts->create_ok);
}

static VALUE
range_load(VALUE clas, VALUE args) {
    VALUE	nargs[3];
    
    nargs[0] = rb_hash_aref(args, rb_id2str(oj_begin_id));
    nargs[1] = rb_hash_aref(args, rb_id2str(oj_end_id));
    nargs[2] = rb_hash_aref(args, rb_id2str(oj_exclude_end_id));

    return rb_class_new_instance(3, nargs, rb_cRange);
}

static ID	numerator_id = 0;
static ID	denominator_id = 0;

static void
rational_dump(VALUE obj, int depth, Out out) {
    struct _Attr	attrs[] = {
	{ "numerator", 9, Qnil },
	{ "denominator", 11, Qnil },
	{ NULL, 0, Qnil },
    };
    if (0 == numerator_id) {
	numerator_id = rb_intern("numerator");
	denominator_id = rb_intern("denominator");
    }
    attrs[0].value = rb_funcall(obj, numerator_id, 0);
    attrs[1].value = rb_funcall(obj, denominator_id, 0);

    oj_code_attrs(obj, attrs, depth, out, Yes == out->opts->create_ok);
}

static VALUE
rational_load(VALUE clas, VALUE args) {
    if (0 == numerator_id) {
	numerator_id = rb_intern("numerator");
	denominator_id = rb_intern("denominator");
    }
    return rb_rational_new(rb_hash_aref(args, rb_id2str(numerator_id)),
			   rb_hash_aref(args, rb_id2str(denominator_id)));
}

static VALUE
regexp_load(VALUE clas, VALUE args) {
    volatile VALUE	v;
    
    if (Qnil != (v = rb_hash_aref(args, rb_str_new2("s")))) {
	return rb_funcall(rb_cRegexp, oj_new_id, 1, v);
    }
    return Qnil;
}

static void
time_dump(VALUE obj, int depth, Out out) {
    if (Yes == out->opts->create_ok) {
	struct _Attr	attrs[] = {
	    { "time", 4, Qundef, 0, Qundef },
	    { NULL, 0, Qnil },
	};
	attrs->time = obj;

	oj_code_attrs(obj, attrs, depth, out, true);
    } else {
	switch (out->opts->time_format) {
	case RubyTime:	oj_dump_ruby_time(obj, out);	break;
	case XmlTime:	oj_dump_xml_time(obj, out);	break;
	case UnixZTime:	oj_dump_time(obj, out, true);	break;
	case UnixTime:
	default:	oj_dump_time(obj, out, false);	break;
	}
    }
}

static VALUE
time_load(VALUE clas, VALUE args) {
    // Value should have already been replaced in one of the hash_set_xxx
    // functions.
    return args;
}

static struct _Code	codes[] = {
    { "BigDecimal", Qnil, bigdecimal_dump, NULL, true },
    { "Complex", Qnil, complex_dump, complex_load, true },
    { "Date", Qnil, date_dump, date_load, true },
    { "DateTime", Qnil, date_dump, datetime_load, true },
    { "OpenStruct", Qnil, openstruct_dump, openstruct_load, true },
    { "Range", Qnil, range_dump, range_load, true },
    { "Rational", Qnil, rational_dump, rational_load, true },
    { "Regexp", Qnil, dump_obj_str, regexp_load, true },
    { "Time", Qnil, time_dump, time_load, true },
    { NULL, Qundef, NULL, NULL, false },
};

static int
hash_cb(VALUE key, VALUE value, Out out) {
    int	depth = out->depth;

    if (oj_dump_ignore(out->opts, value)) {
	return ST_CONTINUE;
    }
    if (out->omit_nil && Qnil == value) {
	return ST_CONTINUE;
    }
    if (!out->opts->dump_opts.use) {
	assure_size(out, depth * out->indent + 1);
	fill_indent(out, depth);
    } else {
	assure_size(out, depth * out->opts->dump_opts.indent_size + out->opts->dump_opts.hash_size + 1);
	if (0 < out->opts->dump_opts.hash_size) {
	    strcpy(out->cur, out->opts->dump_opts.hash_nl);
	    out->cur += out->opts->dump_opts.hash_size;
	}
	if (0 < out->opts->dump_opts.indent_size) {
	    int	i;

	    for (i = depth; 0 < i; i--) {
		strcpy(out->cur, out->opts->dump_opts.indent_str);
		out->cur += out->opts->dump_opts.indent_size;
	    }
	}
    }
    switch (rb_type(key)) {
    case T_STRING:
	oj_dump_str(key, 0, out, false);
	break;
    case T_SYMBOL:
	oj_dump_sym(key, 0, out, false);
	break;
    default:
	oj_dump_str(rb_funcall(key, oj_to_s_id, 0), 0, out, false);
	break;
    }
    if (!out->opts->dump_opts.use) {
	*out->cur++ = ':';
    } else {
	assure_size(out, out->opts->dump_opts.before_size + out->opts->dump_opts.after_size + 2);
	if (0 < out->opts->dump_opts.before_size) {
	    strcpy(out->cur, out->opts->dump_opts.before_sep);
	    out->cur += out->opts->dump_opts.before_size;
	}
	*out->cur++ = ':';
	if (0 < out->opts->dump_opts.after_size) {
	    strcpy(out->cur, out->opts->dump_opts.after_sep);
	    out->cur += out->opts->dump_opts.after_size;
	}
    }
    oj_dump_custom_val(value, depth, out, true);
    out->depth = depth;
    *out->cur++ = ',';

    return ST_CONTINUE;
}

static void
dump_hash(VALUE obj, int depth, Out out, bool as_ok) {
    int		cnt;
    long	id = oj_check_circular(obj, out);

    if (0 > id) {
	oj_dump_nil(Qnil, depth, out, false);
	return;
    }
    cnt = (int)RHASH_SIZE(obj);
    assure_size(out, 2);
    if (0 == cnt) {
	*out->cur++ = '{';
	*out->cur++ = '}';
    } else {
	*out->cur++ = '{';
	out->depth = depth + 1;
	rb_hash_foreach(obj, hash_cb, (VALUE)out);
	if (',' == *(out->cur - 1)) {
	    out->cur--; // backup to overwrite last comma
	}
	if (!out->opts->dump_opts.use) {
	    assure_size(out, depth * out->indent + 2);
	    fill_indent(out, depth);
	} else {
	    assure_size(out, depth * out->opts->dump_opts.indent_size + out->opts->dump_opts.hash_size + 1);
	    if (0 < out->opts->dump_opts.hash_size) {
		strcpy(out->cur, out->opts->dump_opts.hash_nl);
		out->cur += out->opts->dump_opts.hash_size;
	    }
	    if (0 < out->opts->dump_opts.indent_size) {
		int	i;

		for (i = depth; 0 < i; i--) {
		    strcpy(out->cur, out->opts->dump_opts.indent_str);
		    out->cur += out->opts->dump_opts.indent_size;
		}
	    }
	}
	*out->cur++ = '}';
    }
    *out->cur = '\0';
}

static void
dump_odd(VALUE obj, Odd odd, VALUE clas, int depth, Out out) {
    ID			*idp;
    AttrGetFunc		*fp;
    volatile VALUE	v;
    const char		*name;
    size_t		size;
    int			d2 = depth + 1;

    assure_size(out, 2);
    *out->cur++ = '{';
    if (NULL != out->opts->create_id && Yes == out->opts->create_ok) {
	const char	*classname = rb_class2name(clas);
	int		clen = (int)strlen(classname);
	size_t		sep_len = out->opts->dump_opts.before_size + out->opts->dump_opts.after_size + 2;

	size = d2 * out->indent + 10 + clen + out->opts->create_id_len + sep_len;
	assure_size(out, size);
	fill_indent(out, d2);
	*out->cur++ = '"';
	memcpy(out->cur, out->opts->create_id, out->opts->create_id_len);
	out->cur += out->opts->create_id_len;
	*out->cur++ = '"';
	if (0 < out->opts->dump_opts.before_size) {
	    strcpy(out->cur, out->opts->dump_opts.before_sep);
	    out->cur += out->opts->dump_opts.before_size;
	}
	*out->cur++ = ':';
	if (0 < out->opts->dump_opts.after_size) {
	    strcpy(out->cur, out->opts->dump_opts.after_sep);
	    out->cur += out->opts->dump_opts.after_size;
	}
	*out->cur++ = '"';
	memcpy(out->cur, classname, clen);
	out->cur += clen;
	*out->cur++ = '"';
	*out->cur++ = ',';
    }
    if (odd->raw) {
	v = rb_funcall(obj, *odd->attrs, 0);
	if (Qundef == v || T_STRING != rb_type(v)) {
	    rb_raise(rb_eEncodingError, "Invalid type for raw JSON.\n");
	} else {	    
	    const char	*s = rb_string_value_ptr((VALUE*)&v);
	    int		len = (int)RSTRING_LEN(v);
	    const char	*name = rb_id2name(*odd->attrs);
	    size_t	nlen = strlen(name);

	    size = len + d2 * out->indent + nlen + 10;
	    assure_size(out, size);
	    fill_indent(out, d2);
	    *out->cur++ = '"';
	    memcpy(out->cur, name, nlen);
	    out->cur += nlen;
	    *out->cur++ = '"';
	    *out->cur++ = ':';
	    memcpy(out->cur, s, len);
	    out->cur += len;
	    *out->cur = '\0';
	}
    } else {
	size = d2 * out->indent + 1;
	for (idp = odd->attrs, fp = odd->attrFuncs; 0 != *idp; idp++, fp++) {
	    size_t	nlen;

	    assure_size(out, size);
	    name = rb_id2name(*idp);
	    nlen = strlen(name);
	    if (0 != *fp) {
		v = (*fp)(obj);
	    } else if (0 == strchr(name, '.')) {
		v = rb_funcall(obj, *idp, 0);
	    } else {
		char	nbuf[256];
		char	*n2 = nbuf;
		char	*n;
		char	*end;
		ID	i;
	    
		if (sizeof(nbuf) <= nlen) {
		    n2 = strdup(name);
		} else {
		    strcpy(n2, name);
		}
		n = n2;
		v = obj;
		while (0 != (end = strchr(n, '.'))) {
		    *end = '\0';
		    i = rb_intern(n);
		    v = rb_funcall(v, i, 0);
		    n = end + 1;
		}
		i = rb_intern(n);
		v = rb_funcall(v, i, 0);
		if (nbuf != n2) {
		    free(n2);
		}
	    }
	    fill_indent(out, d2);
	    oj_dump_cstr(name, nlen, 0, 0, out);
	    *out->cur++ = ':';
	    oj_dump_custom_val(v, d2, out, true);
	    assure_size(out, 2);
	    *out->cur++ = ',';
	}
	out->cur--;
    }
    *out->cur++ = '}';
    *out->cur = '\0';
}

// Return class if still needs dumping.
static VALUE
dump_common(VALUE obj, int depth, Out out) {
    if (Yes == out->opts->to_json && rb_respond_to(obj, oj_to_json_id)) {
	volatile VALUE	rs;
	const char	*s;
	int		len;

#if HAS_METHOD_ARITY
	if (0 == rb_obj_method_arity(obj, oj_to_json_id)) {
	    rs = rb_funcall(obj, oj_to_json_id, 0);
	} else {
	    rs = rb_funcall2(obj, oj_to_json_id, out->argc, out->argv);
	}
#else
	rs = rb_funcall2(obj, oj_to_json_id, out->argc, out->argv);
#endif
	s = rb_string_value_ptr((VALUE*)&rs);
	len = (int)RSTRING_LEN(rs);

	assure_size(out, len + 1);
	memcpy(out->cur, s, len);
	out->cur += len;
	*out->cur = '\0';
    } else if (Yes == out->opts->as_json && rb_respond_to(obj, oj_as_json_id)) {
	volatile VALUE	aj;

	// Some classes elect to not take an options argument so check the arity
	// of as_json.
#if HAS_METHOD_ARITY
	if (0 == rb_obj_method_arity(obj, oj_as_json_id)) {
	    aj = rb_funcall(obj, oj_as_json_id, 0);
	} else {
	    aj = rb_funcall2(obj, oj_as_json_id, out->argc, out->argv);
	}
#else
	aj = rb_funcall2(obj, oj_as_json_id, out->argc, out->argv);
#endif
	// Catch the obvious brain damaged recursive dumping.
	if (aj == obj) {
	    volatile VALUE	rstr = rb_funcall(obj, oj_to_s_id, 0);

	    oj_dump_cstr(rb_string_value_ptr((VALUE*)&rstr), RSTRING_LEN(rstr), false, false, out);
	} else {
	    oj_dump_custom_val(aj, depth, out, true);
	}
    } else if (Yes == out->opts->to_hash && rb_respond_to(obj, oj_to_hash_id)) {
	volatile VALUE	h = rb_funcall(obj, oj_to_hash_id, 0);

	if (T_HASH != rb_type(h)) {
	    // It seems that ActiveRecord implemented to_hash so that it returns
	    // an Array and not a Hash. To get around that any value returned
	    // will be dumped.

	    //rb_raise(rb_eTypeError, "%s.to_hash() did not return a Hash.\n", rb_class2name(rb_obj_class(obj)));
	    oj_dump_custom_val(h, depth, out, false);
	} else {
	    dump_hash(h, depth, out, true);
	}
    } else if (!oj_code_dump(codes, obj, depth, out)) {
	VALUE	clas = rb_obj_class(obj);
	Odd	odd = oj_get_odd(clas);

	if (NULL == odd) {
	    return clas;
	}
	dump_odd(obj, odd, clas, depth + 1, out);
    }
    return Qnil;
}

static int
dump_attr_cb(ID key, VALUE value, Out out) {
    int		depth = out->depth;
    size_t	size;
    const char	*attr;

    if (oj_dump_ignore(out->opts, value)) {
	return ST_CONTINUE;
    }
    if (out->omit_nil && Qnil == value) {
	return ST_CONTINUE;
    }
    size = depth * out->indent + 1;
    attr = rb_id2name(key);
    // Some exceptions such as NoMethodError have an invisible attribute where
    // the key name is NULL. Not an empty string but NULL.
    if (NULL == attr) {
	attr = "";
    }
#if HAS_EXCEPTION_MAGIC
    if (0 == strcmp("bt", attr) || 0 == strcmp("mesg", attr)) {
	return ST_CONTINUE;
    }
#endif
    assure_size(out, size);
    fill_indent(out, depth);
    if ('@' == *attr) {
	attr++;
	oj_dump_cstr(attr, strlen(attr), 0, 0, out);
    } else {
	char	buf[32];

	*buf = '~';
	strncpy(buf + 1, attr, sizeof(buf) - 2);
	buf[sizeof(buf) - 1] = '\0';
	oj_dump_cstr(buf, strlen(buf), 0, 0, out);
    }
    *out->cur++ = ':';
    oj_dump_custom_val(value, depth, out, true);
    out->depth = depth;
    *out->cur++ = ',';
    
    return ST_CONTINUE;
}

static void
dump_obj_attrs(VALUE obj, VALUE clas, slot_t id, int depth, Out out) {
    size_t	size = 0;
    int		d2 = depth + 1;
    int		cnt;
    bool	class_written = false;

    assure_size(out, 2);
    *out->cur++ = '{';
    if (Qundef != clas && NULL != out->opts->create_id && Yes == out->opts->create_ok) {
	size_t		sep_len = out->opts->dump_opts.before_size + out->opts->dump_opts.after_size + 2;
	const char	*classname = rb_obj_classname(obj);
	size_t		len = strlen(classname);

	size = d2 * out->indent + 10 + len + out->opts->create_id_len + sep_len;
	assure_size(out, size);
	fill_indent(out, d2);
	*out->cur++ = '"';
	memcpy(out->cur, out->opts->create_id, out->opts->create_id_len);
	out->cur += out->opts->create_id_len;
	*out->cur++ = '"';
	if (0 < out->opts->dump_opts.before_size) {
	    strcpy(out->cur, out->opts->dump_opts.before_sep);
	    out->cur += out->opts->dump_opts.before_size;
	}
	*out->cur++ = ':';
	if (0 < out->opts->dump_opts.after_size) {
	    strcpy(out->cur, out->opts->dump_opts.after_sep);
	    out->cur += out->opts->dump_opts.after_size;
	}
	*out->cur++ = '"';
	memcpy(out->cur, classname, len);
	out->cur += len;
	*out->cur++ = '"';
	class_written = true;
    }
    cnt = (int)rb_ivar_count(obj);
    if (class_written) {
	*out->cur++ = ',';
    }
    if (0 == cnt && Qundef == clas) {
	// Might be something special like an Enumerable.
	if (Qtrue == rb_obj_is_kind_of(obj, oj_enumerable_class)) {
	    out->cur--;
	    oj_dump_custom_val(rb_funcall(obj, rb_intern("entries"), 0), depth, out, false);
	    return;
	}
    }
    out->depth = depth + 1;
    rb_ivar_foreach(obj, dump_attr_cb, (VALUE)out);
    if (',' == *(out->cur - 1)) {
	out->cur--; // backup to overwrite last comma
    }
#if HAS_EXCEPTION_MAGIC
    if (rb_obj_is_kind_of(obj, rb_eException)) {
	volatile VALUE	rv;

	if (',' != *(out->cur - 1)) {
	    *out->cur++ = ',';
	}
	// message
	assure_size(out, 2);
	fill_indent(out, d2);
	oj_dump_cstr("~mesg", 5, 0, 0, out);
	*out->cur++ = ':';
	rv = rb_funcall2(obj, rb_intern("message"), 0, 0);
	oj_dump_custom_val(rv, d2, out, true);
	assure_size(out, size + 2);
	*out->cur++ = ',';
	// backtrace
	fill_indent(out, d2);
	oj_dump_cstr("~bt", 3, 0, 0, out);
	*out->cur++ = ':';
	rv = rb_funcall2(obj, rb_intern("backtrace"), 0, 0);
	oj_dump_custom_val(rv, d2, out, true);
	assure_size(out, 2);
    }
#endif
    out->depth = depth;

    fill_indent(out, depth);
    *out->cur++ = '}';
    *out->cur = '\0';
}

static void
dump_obj(VALUE obj, int depth, Out out, bool as_ok) {
    long	id = oj_check_circular(obj, out);
    VALUE	clas;

    if (0 > id) {
	oj_dump_nil(Qnil, depth, out, false);
    } else if (Qnil != (clas = dump_common(obj, depth, out))) {
	dump_obj_attrs(obj, clas, 0, depth, out);
    }
    *out->cur = '\0';
}

static void
dump_array(VALUE a, int depth, Out out, bool as_ok) {
    size_t	size;
    int		i, cnt;
    int		d2 = depth + 1;
    long	id = oj_check_circular(a, out);

    if (0 > id) {
	oj_dump_nil(Qnil, depth, out, false);
	return;
    }
    cnt = (int)RARRAY_LEN(a);
    *out->cur++ = '[';
    assure_size(out, 2);
    if (0 == cnt) {
	*out->cur++ = ']';
    } else {
	if (out->opts->dump_opts.use) {
	    size = d2 * out->opts->dump_opts.indent_size + out->opts->dump_opts.array_size + 1;
	} else {
	    size = d2 * out->indent + 2;
	}
	cnt--;
	for (i = 0; i <= cnt; i++) {
	    assure_size(out, size);
	    if (out->opts->dump_opts.use) {
		if (0 < out->opts->dump_opts.array_size) {
		    strcpy(out->cur, out->opts->dump_opts.array_nl);
		    out->cur += out->opts->dump_opts.array_size;
		}
		if (0 < out->opts->dump_opts.indent_size) {
		    int	i;
		    for (i = d2; 0 < i; i--) {
			strcpy(out->cur, out->opts->dump_opts.indent_str);
			out->cur += out->opts->dump_opts.indent_size;
		    }
		}
	    } else {
		fill_indent(out, d2);
	    }
	    oj_dump_custom_val(rb_ary_entry(a, i), d2, out, true);
	    if (i < cnt) {
		*out->cur++ = ',';
	    }
	}
	size = depth * out->indent + 1;
	assure_size(out, size);
	if (out->opts->dump_opts.use) {
	    if (0 < out->opts->dump_opts.array_size) {
		strcpy(out->cur, out->opts->dump_opts.array_nl);
		out->cur += out->opts->dump_opts.array_size;
	    }
	    if (0 < out->opts->dump_opts.indent_size) {
		int	i;

		for (i = depth; 0 < i; i--) {
		    strcpy(out->cur, out->opts->dump_opts.indent_str);
		    out->cur += out->opts->dump_opts.indent_size;
		}
	    }
	} else {
	    fill_indent(out, depth);
	}
	*out->cur++ = ']';
    }
    *out->cur = '\0';
}

static void
dump_struct(VALUE obj, int depth, Out out, bool as_ok) {
    long	id = oj_check_circular(obj, out);
    VALUE	clas;
    
    if (0 > id) {
	oj_dump_nil(Qnil, depth, out, false);
    } else if (Qnil != (clas = dump_common(obj, depth, out))) {
	VALUE		ma = Qnil;
	VALUE		v;
	char		num_id[32];
	int		i;
	int		d2 = depth + 1;
	int		d3 = d2 + 1;
	size_t		size = d2 * out->indent + d3 * out->indent + 3;
	const char	*name;
	int		cnt;
	size_t		len;	

	assure_size(out, size);
	if (clas == rb_cRange) {
	    *out->cur++ = '"';
	    oj_dump_custom_val(rb_funcall(obj, oj_begin_id, 0), d3, out, false);
	    assure_size(out, 3);
	    *out->cur++ = '.';
	    *out->cur++ = '.';
	    if (Qtrue == rb_funcall(obj, oj_exclude_end_id, 0)) {
		*out->cur++ = '.';
	    }
	    oj_dump_custom_val(rb_funcall(obj, oj_end_id, 0), d3, out, false);
	    *out->cur++ = '"';

	    return;
	}
	*out->cur++ = '{';
	fill_indent(out, d2);
	size = d3 * out->indent + 2;
#if HAS_STRUCT_MEMBERS
	ma = rb_struct_s_members(clas);
#endif

#ifdef RSTRUCT_LEN
#if RSTRUCT_LEN_RETURNS_INTEGER_OBJECT
	cnt = (int)NUM2LONG(RSTRUCT_LEN(obj));
#else // RSTRUCT_LEN_RETURNS_INTEGER_OBJECT
	cnt = (int)RSTRUCT_LEN(obj);
#endif // RSTRUCT_LEN_RETURNS_INTEGER_OBJECT
#else
	// This is a bit risky as a struct in C ruby is not the same as a Struct
	// class in interpreted Ruby so length() may not be defined.
	cnt = FIX2INT(rb_funcall2(obj, oj_length_id, 0, 0));
#endif
	for (i = 0; i < cnt; i++) {
#ifdef RSTRUCT_LEN
	    v = RSTRUCT_GET(obj, i);
#else
	    v = rb_struct_aref(obj, INT2FIX(i));
#endif
	    if (ma != Qnil) {
		name = rb_id2name(SYM2ID(rb_ary_entry(ma, i)));
		len = strlen(name);
	    } else {
		len = snprintf(num_id, sizeof(num_id), "%d", i);
		name = num_id;
	    }
	    assure_size(out, size + len + 3);
	    fill_indent(out, d3);
	    *out->cur++ = '"';
	    memcpy(out->cur, name, len);
	    out->cur += len;
	    *out->cur++ = '"';
	    *out->cur++ = ':';
	    oj_dump_custom_val(v, d3, out, true);
	    *out->cur++ = ',';
	}
	out->cur--;
	*out->cur++ = '}';
	*out->cur = '\0';
    }
}

static void
dump_data(VALUE obj, int depth, Out out, bool as_ok) {
    long	id = oj_check_circular(obj, out);
    VALUE	clas;

    if (0 > id) {
	oj_dump_nil(Qnil, depth, out, false);
    } else if (Qnil != (clas = dump_common(obj, depth, out))) {
	dump_obj_attrs(obj, clas, id, depth, out);
    }
}

static void
dump_regexp(VALUE obj, int depth, Out out, bool as_ok) {
    dump_obj_str(obj, depth, out);
}

static void
dump_complex(VALUE obj, int depth, Out out, bool as_ok) {
    complex_dump(obj, depth, out);
}

static void
dump_rational(VALUE obj, int depth, Out out, bool as_ok) {
    rational_dump(obj, depth, out);
}

static DumpFunc	custom_funcs[] = {
    NULL,	 	// RUBY_T_NONE     = 0x00,
    dump_obj,		// RUBY_T_OBJECT   = 0x01,
    oj_dump_class, 	// RUBY_T_CLASS    = 0x02,
    oj_dump_class,	// RUBY_T_MODULE   = 0x03,
    oj_dump_float, 	// RUBY_T_FLOAT    = 0x04,
    oj_dump_str, 	// RUBY_T_STRING   = 0x05,
    dump_regexp,	// RUBY_T_REGEXP   = 0x06,
    dump_array,		// RUBY_T_ARRAY    = 0x07,
    dump_hash,	 	// RUBY_T_HASH     = 0x08,
    dump_struct,	// RUBY_T_STRUCT   = 0x09,
    oj_dump_bignum,	// RUBY_T_BIGNUM   = 0x0a,
    NULL, 		// RUBY_T_FILE     = 0x0b,
    dump_data,		// RUBY_T_DATA     = 0x0c,
    NULL, 		// RUBY_T_MATCH    = 0x0d,
    dump_complex, 	// RUBY_T_COMPLEX  = 0x0e,
    dump_rational, 	// RUBY_T_RATIONAL = 0x0f,
    NULL, 		// 0x10
    oj_dump_nil, 	// RUBY_T_NIL      = 0x11,
    oj_dump_true, 	// RUBY_T_TRUE     = 0x12,
    oj_dump_false,	// RUBY_T_FALSE    = 0x13,
    oj_dump_sym,	// RUBY_T_SYMBOL   = 0x14,
    oj_dump_fixnum,	// RUBY_T_FIXNUM   = 0x15,
};

void
oj_dump_custom_val(VALUE obj, int depth, Out out, bool as_ok) {
    int	type = rb_type(obj);

    if (Yes == out->opts->trace) {
	oj_trace("dump", obj, __FILE__, __LINE__, depth, TraceIn);
    }
    if (MAX_DEPTH < depth) {
	rb_raise(rb_eNoMemError, "Too deeply nested.\n");
    }
    if (0 < type && type <= RUBY_T_FIXNUM) {
	DumpFunc	f = custom_funcs[type];

	if (NULL != f) {
	    f(obj, depth, out, true);
	    if (Yes == out->opts->trace) {
		oj_trace("dump", obj, __FILE__, __LINE__, depth, TraceOut);
	    }
	    return;
	}
    }
    oj_dump_nil(Qnil, depth, out, false);
    if (Yes == out->opts->trace) {
	oj_trace("dump", Qnil, __FILE__, __LINE__, depth, TraceOut);
    }
}

///// load functions /////

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

	parent->clas = oj_name2class(pi, str, len, false, rb_eArgError);
	if (2 == klen && '^' == *key && 'o' == key[1]) {
	    if (Qundef != parent->clas) {
		if (!oj_code_has(codes, parent->clas, false)) {
		    parent->val = rb_obj_alloc(parent->clas);
		}
	    }
	}
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
	switch (rb_type(parent->val)) {
	case T_OBJECT:
	    oj_set_obj_ivar(parent, kval, rstr);
	    break;
	case T_HASH:
	    if (4 == parent->klen && NULL != parent->key && rb_cTime == parent->clas && 0 == strncmp("time", parent->key, 4)) {
		if (Qnil == (parent->val = oj_parse_xml_time(str, (int)len))) {
		    parent->val = rb_funcall(rb_cTime, rb_intern("parse"), 1, rb_str_new(str, len));
		}
	    } else {
		rb_hash_aset(parent->val, rkey, rstr);
	    }
	    break;
	default:
	    break;
	}
	if (Yes == pi->options.trace) {
	    oj_trace_parse_call("set_string", pi, __FILE__, __LINE__, rstr);
	}
    }
}

static void
end_hash(struct _ParseInfo *pi) {
    Val	parent = stack_peek(&pi->stack);

    if (Qundef != parent->clas && parent->clas != rb_obj_class(parent->val)) {
	volatile VALUE	obj = oj_code_load(codes, parent->clas, parent->val);

	if (Qnil != obj) {
	    parent->val = obj;
	} else {
	    parent->val = rb_funcall(parent->clas, oj_json_create_id, 1, parent->val);
	}
	parent->clas = Qundef;
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
hash_set_num(struct _ParseInfo *pi, Val kval, NumInfo ni) {
    Val			parent = stack_peek(&pi->stack);
    volatile VALUE	rval = oj_num_as_value(ni);

    switch (rb_type(parent->val)) {
    case T_OBJECT:
	oj_set_obj_ivar(parent, kval, rval);
	break;
    case T_HASH:
	if (4 == parent->klen && NULL != parent->key && rb_cTime == parent->clas && 0 == strncmp("time", parent->key, 4)) {
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

		args[0] = LONG2NUM(1900 + st->tm_year);
		args[1] = LONG2NUM(1 + st->tm_mon);
		args[2] = LONG2NUM(st->tm_mday);
		args[3] = LONG2NUM(st->tm_hour);
		args[4] = LONG2NUM(st->tm_min);
		args[5] = rb_float_new((double)st->tm_sec + ((double)nsec + 0.5) / 1000000000.0);
		args[6] = LONG2NUM(ni->exp);
		parent->val = rb_funcall2(rb_cTime, oj_new_id, 7, args);
	    } else {
		parent->val = rb_time_nano_new(ni->i, (long)nsec);
	    }
	    rval = parent->val;
	} else {
	    rb_hash_aset(parent->val, calc_hash_key(pi, kval), rval);
	}
	break;
    default:
	break;
    }
    if (Yes == pi->options.trace) {
	oj_trace_parse_call("set_string", pi, __FILE__, __LINE__, rval);
    }
}

static void
hash_set_value(ParseInfo pi, Val kval, VALUE value) {
    Val	parent = stack_peek(&pi->stack);

    switch (rb_type(parent->val)) {
    case T_OBJECT:
	oj_set_obj_ivar(parent, kval, value);
	break;
    case T_HASH:
	rb_hash_aset(parent->val, calc_hash_key(pi, kval), value);
	break;
    default:
	break;
    }
    if (Yes == pi->options.trace) {
	oj_trace_parse_call("set_value", pi, __FILE__, __LINE__, value);
    }
}

static void
array_append_num(ParseInfo pi, NumInfo ni) {
    Val			parent = stack_peek(&pi->stack);
    volatile VALUE	rval = oj_num_as_value(ni);
    
    rb_ary_push(parent->val, rval);
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
oj_set_custom_callbacks(ParseInfo pi) {
    oj_set_compat_callbacks(pi);
    pi->hash_set_cstr = hash_set_cstr;
    pi->end_hash = end_hash;
    pi->hash_set_num = hash_set_num;
    pi->hash_set_value = hash_set_value;
    pi->array_append_cstr = array_append_cstr;
    pi->array_append_num = array_append_num;
}

VALUE
oj_custom_parse(int argc, VALUE *argv, VALUE self) {
    struct _ParseInfo	pi;

    parse_info_init(&pi);
    pi.options = oj_default_options;
    pi.handler = Qnil;
    pi.err_class = Qnil;
    pi.max_depth = 0;
    pi.options.allow_nan = Yes;
    pi.options.nilnil = Yes;
    oj_set_custom_callbacks(&pi);

    if (T_STRING == rb_type(*argv)) {
	return oj_pi_parse(argc, argv, &pi, 0, 0, false);
    } else {
	return oj_pi_sparse(argc, argv, &pi, 0);
    }
}

VALUE
oj_custom_parse_cstr(int argc, VALUE *argv, char *json, size_t len) {
    struct _ParseInfo	pi;

    parse_info_init(&pi);
    pi.options = oj_default_options;
    pi.handler = Qnil;
    pi.err_class = Qnil;
    pi.max_depth = 0;
    pi.options.allow_nan = Yes;
    pi.options.nilnil = Yes;
    oj_set_custom_callbacks(&pi);
    pi.end_hash = end_hash;

    return oj_pi_parse(argc, argv, &pi, json, len, false);
}

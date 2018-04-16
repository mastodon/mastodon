/* dump_object.c
 * Copyright (c) 2012, 2017, Peter Ohler
 * All rights reserved.
 */

#include "dump.h"
#include "odd.h"
#include "trace.h"

static const char	hex_chars[17] = "0123456789abcdef";

static void	dump_obj_attrs(VALUE obj, VALUE clas, slot_t id, int depth, Out out);

static void
dump_time(VALUE obj, Out out) {
    switch (out->opts->time_format) {
    case RubyTime:
    case XmlTime:	oj_dump_xml_time(obj, out);	break;
    case UnixZTime:	oj_dump_time(obj, out, 1);	break;
    case UnixTime:
    default:		oj_dump_time(obj, out, 0);	break;
    }
}

static void
dump_data(VALUE obj, int depth, Out out, bool as_ok) {
    VALUE	clas = rb_obj_class(obj);

    if (rb_cTime == clas) {
	assure_size(out, 6);
	*out->cur++ = '{';
	*out->cur++ = '"';
	*out->cur++ = '^';
	*out->cur++ = 't';
	*out->cur++ = '"';
	*out->cur++ = ':';
	dump_time(obj, out);
	*out->cur++ = '}';
	*out->cur = '\0';
    } else {
	if (oj_bigdecimal_class == clas) {
	    volatile VALUE	rstr = rb_funcall(obj, oj_to_s_id, 0);
	    const char		*str = rb_string_value_ptr((VALUE*)&rstr);
	    int			len = (int)RSTRING_LEN(rstr);

	    if (No != out->opts->bigdec_as_num) {
		oj_dump_raw(str, len, out);
	    } else if (0 == strcasecmp("Infinity", str)) {
		str = oj_nan_str(obj, out->opts->dump_opts.nan_dump, out->opts->mode, true, &len);
		oj_dump_raw(str, len, out);
	    } else if (0 == strcasecmp("-Infinity", str)) {
		str = oj_nan_str(obj, out->opts->dump_opts.nan_dump, out->opts->mode, false, &len);
		oj_dump_raw(str, len, out);
	    } else {
		oj_dump_cstr(str, len, 0, 0, out);
	    }
	} else {
	    long	id = oj_check_circular(obj, out);
	    
	    if (0 <= id) {
		dump_obj_attrs(obj, clas, id, depth, out);
	    }
	}
    }
}

static void
dump_obj(VALUE obj, int depth, Out out, bool as_ok) {
    VALUE	clas = rb_obj_class(obj);

    if (oj_bigdecimal_class == clas) {
	volatile VALUE	rstr = rb_funcall(obj, oj_to_s_id, 0);
	const char	*str = rb_string_value_ptr((VALUE*)&rstr);
	int		len = (int)RSTRING_LEN(rstr);
	    
	if (0 == strcasecmp("Infinity", str)) {
	    str = oj_nan_str(obj, out->opts->dump_opts.nan_dump, out->opts->mode, true, &len);
	    oj_dump_raw(str, len, out);
	} else if (0 == strcasecmp("-Infinity", str)) {
	    str = oj_nan_str(obj, out->opts->dump_opts.nan_dump, out->opts->mode, false, &len);
	    oj_dump_raw(str, len, out);
	} else {
	    oj_dump_raw(str, len, out);
	}
    } else {
	long	id = oj_check_circular(obj, out);

	if (0 <= id) {
	    dump_obj_attrs(obj, clas, id, depth, out);
	}
    }
}

static void
dump_class(VALUE obj, int depth, Out out, bool as_ok) {
    const char	*s = rb_class2name(obj);
    size_t	len = strlen(s);

    assure_size(out, 6);
    *out->cur++ = '{';
    *out->cur++ = '"';
    *out->cur++ = '^';
    *out->cur++ = 'c';
    *out->cur++ = '"';
    *out->cur++ = ':';
    oj_dump_cstr(s, len, 0, 0, out);
    *out->cur++ = '}';
    *out->cur = '\0';
}

static void
dump_array_class(VALUE a, VALUE clas, int depth, Out out) {
    size_t	size;
    int		i, cnt;
    int		d2 = depth + 1;
    long	id = oj_check_circular(a, out);

    if (id < 0) {
	return;
    }
    if (Qundef != clas && rb_cArray != clas && ObjectMode == out->opts->mode) {
	dump_obj_attrs(a, clas, 0, depth, out);
	return;
    }
    cnt = (int)RARRAY_LEN(a);
    *out->cur++ = '[';
    if (0 < id) {
	assure_size(out, d2 * out->indent + 16);
	fill_indent(out, d2);
	*out->cur++ = '"';
	*out->cur++ = '^';
	*out->cur++ = 'i';
	dump_ulong(id, out);
	*out->cur++ = '"';
    }
    size = 2;
    assure_size(out, 2);
    if (0 == cnt) {
	*out->cur++ = ']';
    } else {
	if (0 < id) {
	    *out->cur++ = ',';
	}
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
	    oj_dump_obj_val(rb_ary_entry(a, i), d2, out);
	    if (i < cnt) {
		*out->cur++ = ',';
	    }
	}
	size = depth * out->indent + 1;
	assure_size(out, size);
	if (out->opts->dump_opts.use) {
	    //printf("*** d2: %u  indent: %u '%s'\n", d2, out->opts->dump_opts->indent_size, out->opts->dump_opts->indent);
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
dump_array(VALUE obj, int depth, Out out, bool as_ok) {
    dump_array_class(obj, rb_obj_class(obj), depth, out);
}

static void
dump_str_class(VALUE obj, VALUE clas, int depth, Out out) {
    if (Qundef != clas && rb_cString != clas) {
	dump_obj_attrs(obj, clas, 0, depth, out);
    } else {
	const char	*s = rb_string_value_ptr((VALUE*)&obj);
	size_t		len = RSTRING_LEN(obj);
	char		s1 = s[1];

	oj_dump_cstr(s, len, 0, (':' == *s || ('^' == *s && ('r' == s1 || 'i' == s1))), out);
    }
}

static void
dump_str(VALUE obj, int depth, Out out, bool as_ok) {
    dump_str_class(obj, rb_obj_class(obj), depth, out);
}

static void
dump_sym(VALUE obj, int depth, Out out, bool as_ok) {
    const char	*sym = rb_id2name(SYM2ID(obj));
    
    oj_dump_cstr(sym, strlen(sym), 1, 0, out);
}

static int
hash_cb(VALUE key, VALUE value, Out out) {
    int		depth = out->depth;
    long	size = depth * out->indent + 1;

    if (oj_dump_ignore(out->opts, value)) {
	return ST_CONTINUE;
    }
    if (out->omit_nil && Qnil == value) {
	return ST_CONTINUE;
    }
    assure_size(out, size);
    fill_indent(out, depth);
    if (rb_type(key) == T_STRING) {
	dump_str_class(key, Qundef, depth, out);
	*out->cur++ = ':';
	oj_dump_obj_val(value, depth, out);
    } else if (rb_type(key) == T_SYMBOL) {
	dump_sym(key, 0, out, false);
	*out->cur++ = ':';
	oj_dump_obj_val(value, depth, out);
    } else {
	int	d2 = depth + 1;
	long	s2 = size + out->indent + 1;
	int	i;
	int	started = 0;
	uint8_t	b;

	assure_size(out, s2 + 15);
	*out->cur++ = '"';
	*out->cur++ = '^';
	*out->cur++ = '#';
	out->hash_cnt++;
	for (i = 28; 0 <= i; i -= 4) {
	    b = (uint8_t)((out->hash_cnt >> i) & 0x0000000F);
	    if ('\0' != b) {
		started = 1;
	    }
	    if (started) {
		*out->cur++ = hex_chars[b];
	    }
	}
	*out->cur++ = '"';
	*out->cur++ = ':';
	*out->cur++ = '[';
	fill_indent(out, d2);
	oj_dump_obj_val(key, d2, out);
	assure_size(out, s2);
	*out->cur++ = ',';
	fill_indent(out, d2);
	oj_dump_obj_val(value, d2, out);
	assure_size(out, size);
	fill_indent(out, depth);
	*out->cur++ = ']';
    }
    out->depth = depth;
    *out->cur++ = ',';
    
    return ST_CONTINUE;
}

static void
dump_hash_class(VALUE obj, VALUE clas, int depth, Out out) {
    int		cnt;
    size_t	size;

    if (Qundef != clas && rb_cHash != clas) {
	dump_obj_attrs(obj, clas, 0, depth, out);
	return;
    }
    cnt = (int)RHASH_SIZE(obj);
    size = depth * out->indent + 2;
    assure_size(out, 2);
    if (0 == cnt) {
	*out->cur++ = '{';
	*out->cur++ = '}';
    } else {
	long	id = oj_check_circular(obj, out);

	if (0 > id) {
	    return;
	}
	*out->cur++ = '{';
	if (0 < id) {
	    assure_size(out, size + 16);
	    fill_indent(out, depth + 1);
	    *out->cur++ = '"';
	    *out->cur++ = '^';
	    *out->cur++ = 'i';
	    *out->cur++ = '"';
	    *out->cur++ = ':';
	    dump_ulong(id, out);
	    *out->cur++ = ',';
	}
	out->depth = depth + 1;
	rb_hash_foreach(obj, hash_cb, (VALUE)out);
	if (',' == *(out->cur - 1)) {
	    out->cur--; // backup to overwrite last comma
	}
	if (!out->opts->dump_opts.use) {
	    assure_size(out, size);
	    fill_indent(out, depth);
	} else {
	    size = depth * out->opts->dump_opts.indent_size + out->opts->dump_opts.hash_size + 1;
	    assure_size(out, size);
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

#if HAS_IVAR_HELPERS
static int
dump_attr_cb(ID key, VALUE value, Out out) {
    int		depth = out->depth;
    size_t	size = depth * out->indent + 1;
    const char	*attr = rb_id2name(key);

    if (oj_dump_ignore(out->opts, value)) {
	return ST_CONTINUE;
    }
    if (out->omit_nil && Qnil == value) {
	return ST_CONTINUE;
    }
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
    oj_dump_obj_val(value, depth, out);
    out->depth = depth;
    *out->cur++ = ',';
    
    return ST_CONTINUE;
}
#endif

static void
dump_hash(VALUE obj, int depth, Out out, bool as_ok) {
    dump_hash_class(obj, rb_obj_class(obj), depth, out);
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
    if (Qundef != clas) {
	const char	*class_name = rb_class2name(clas);
	int		clen = (int)strlen(class_name);

	size = d2 * out->indent + clen + 10;
	assure_size(out, size);
	fill_indent(out, d2);
	*out->cur++ = '"';
	*out->cur++ = '^';
	*out->cur++ = 'O';
	*out->cur++ = '"';
	*out->cur++ = ':';
	oj_dump_cstr(class_name, clen, 0, 0, out);
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
	    oj_dump_obj_val(v, d2, out);
	    assure_size(out, 2);
	    *out->cur++ = ',';
	}
	out->cur--;
    }
    *out->cur++ = '}';
    *out->cur = '\0';
}

static void
dump_obj_attrs(VALUE obj, VALUE clas, slot_t id, int depth, Out out) {
    size_t	size = 0;
    int		d2 = depth + 1;
    int		type = rb_type(obj);
    Odd		odd;

    if (0 != (odd = oj_get_odd(clas))) {
	dump_odd(obj, odd, clas, depth + 1, out);
	return;
    }
    assure_size(out, 2);
    *out->cur++ = '{';
    if (Qundef != clas) {
	const char	*class_name = rb_class2name(clas);
	int		clen = (int)strlen(class_name);

	assure_size(out, d2 * out->indent + clen + 10);
	fill_indent(out, d2);
	*out->cur++ = '"';
	*out->cur++ = '^';
	*out->cur++ = 'o';
	*out->cur++ = '"';
	*out->cur++ = ':';
	oj_dump_cstr(class_name, clen, 0, 0, out);
    }
    if (0 < id) {
	assure_size(out, d2 * out->indent + 16);
	*out->cur++ = ',';
	fill_indent(out, d2);
	*out->cur++ = '"';
	*out->cur++ = '^';
	*out->cur++ = 'i';
	*out->cur++ = '"';
	*out->cur++ = ':';
	dump_ulong(id, out);
    }
    switch (type) {
    case T_STRING:
	assure_size(out, d2 * out->indent + 14);
	*out->cur++ = ',';
	fill_indent(out, d2);
	*out->cur++ = '"';
	*out->cur++ = 's';
	*out->cur++ = 'e';
	*out->cur++ = 'l';
	*out->cur++ = 'f';
	*out->cur++ = '"';
	*out->cur++ = ':';
	oj_dump_cstr(rb_string_value_ptr((VALUE*)&obj), RSTRING_LEN(obj), 0, 0, out);
	break;
    case T_ARRAY:
	assure_size(out, d2 * out->indent + 14);
	*out->cur++ = ',';
	fill_indent(out, d2);
	*out->cur++ = '"';
	*out->cur++ = 's';
	*out->cur++ = 'e';
	*out->cur++ = 'l';
	*out->cur++ = 'f';
	*out->cur++ = '"';
	*out->cur++ = ':';
	dump_array_class(obj, Qundef, depth + 1, out);
	break;
    case T_HASH:
	assure_size(out, d2 * out->indent + 14);
	*out->cur++ = ',';
	fill_indent(out, d2);
	*out->cur++ = '"';
	*out->cur++ = 's';
	*out->cur++ = 'e';
	*out->cur++ = 'l';
	*out->cur++ = 'f';
	*out->cur++ = '"';
	*out->cur++ = ':';
	dump_hash_class(obj, Qundef, depth + 1, out);
	break;
    default:
	break;
    }
    {
	int	cnt;
#if HAS_IVAR_HELPERS
	cnt = (int)rb_ivar_count(obj);
#else
	volatile VALUE	vars = rb_funcall2(obj, oj_instance_variables_id, 0, 0);
	VALUE		*np = RARRAY_PTR(vars);
	ID		vid;
	const char	*attr;
	int		i;
	int		first = 1;

	cnt = (int)RARRAY_LEN(vars);
#endif
	if (Qundef != clas && 0 < cnt) {
	    *out->cur++ = ',';
	}
	if (0 == cnt && Qundef == clas) {
	    // Might be something special like an Enumerable.
	    if (Qtrue == rb_obj_is_kind_of(obj, oj_enumerable_class)) {
		out->cur--;
		oj_dump_obj_val(rb_funcall(obj, rb_intern("entries"), 0), depth, out);
		return;
	    }
	}
	out->depth = depth + 1;
#if HAS_IVAR_HELPERS
	rb_ivar_foreach(obj, dump_attr_cb, (VALUE)out);
	if (',' == *(out->cur - 1)) {
	    out->cur--; // backup to overwrite last comma
	}
#else
	size = d2 * out->indent + 1;
	for (i = cnt; 0 < i; i--, np++) {
	    VALUE	value;
	    
	    vid = rb_to_id(*np);
	    attr = rb_id2name(vid);
	    value = rb_ivar_get(obj, vid);

	    if (oj_dump_ignore(out->opts, value)) {
		continue;
	    }
	    if (out->omit_nil && Qnil == value) {
		continue;
	    }
	    if (first) {
		first = 0;
	    } else {
		*out->cur++ = ',';
	    }
	    assure_size(out, size);
	    fill_indent(out, d2);
	    if ('@' == *attr) {
		attr++;
		oj_dump_cstr(attr, strlen(attr), 0, 0, out);
	    } else {
		char	buf[32];

		*buf = '~';
		strncpy(buf + 1, attr, sizeof(buf) - 2);
		buf[sizeof(buf) - 1] = '\0';
		oj_dump_cstr(buf, strlen(attr) + 1, 0, 0, out);
	    }
	    *out->cur++ = ':';
	    oj_dump_obj_val(value, d2, out);
	    assure_size(out, 2);
	}
#endif
#if HAS_EXCEPTION_MAGIC
	if (rb_obj_is_kind_of(obj, rb_eException)) {
	    volatile VALUE	rv;

	    if (',' != *(out->cur - 1)) {
		*out->cur++ = ',';
	    }
	    // message
	    assure_size(out, size);
	    fill_indent(out, d2);
	    oj_dump_cstr("~mesg", 5, 0, 0, out);
	    *out->cur++ = ':';
	    rv = rb_funcall2(obj, rb_intern("message"), 0, 0);
	    oj_dump_obj_val(rv, d2, out);
	    assure_size(out, 2);
	    *out->cur++ = ',';
	    // backtrace
	    assure_size(out, size);
	    fill_indent(out, d2);
	    oj_dump_cstr("~bt", 3, 0, 0, out);
	    *out->cur++ = ':';
	    rv = rb_funcall2(obj, rb_intern("backtrace"), 0, 0);
	    oj_dump_obj_val(rv, d2, out);
	    assure_size(out, 2);
	}
#endif
	out->depth = depth;
    }
    fill_indent(out, depth);
    *out->cur++ = '}';
    *out->cur = '\0';
}

static void
dump_regexp(VALUE obj, int depth, Out out, bool as_ok) {
    dump_obj_attrs(obj, rb_obj_class(obj), 0, depth, out);
}

static void
dump_struct(VALUE obj, int depth, Out out, bool as_ok) {
    VALUE	clas = rb_obj_class(obj);
    const char	*class_name = rb_class2name(clas);
    int		i;
    int		d2 = depth + 1;
    int		d3 = d2 + 1;
    size_t	len = strlen(class_name);
    size_t	size = d2 * out->indent + d3 * out->indent + 10 + len;

    assure_size(out, size);
    *out->cur++ = '{';
    fill_indent(out, d2);
    *out->cur++ = '"';
    *out->cur++ = '^';
    *out->cur++ = 'u';
    *out->cur++ = '"';
    *out->cur++ = ':';
    *out->cur++ = '[';
#if HAS_STRUCT_MEMBERS
    if ('#' == *class_name) {
	VALUE		ma = rb_struct_s_members(clas);
	const char	*name;
	int		cnt = (int)RARRAY_LEN(ma);

	*out->cur++ = '[';
	for (i = 0; i < cnt; i++) {
	    name = rb_id2name(SYM2ID(rb_ary_entry(ma, i)));
	    len = strlen(name);
	    size = len + 3;
	    assure_size(out, size);
	    if (0 < i) {
		*out->cur++ = ',';
	    }
	    *out->cur++ = '"';
	    memcpy(out->cur, name, len);
	    out->cur += len;
	    *out->cur++ = '"';
	}
	*out->cur++ = ']';
    } else {
#else
    if (true) {
#endif
	fill_indent(out, d3);
	*out->cur++ = '"';
	memcpy(out->cur, class_name, len);
	out->cur += len;
	*out->cur++ = '"';
    }
    *out->cur++ = ',';
    size = d3 * out->indent + 2;
#ifdef RSTRUCT_LEN
    {
	VALUE	v;
	int	cnt;
#if RSTRUCT_LEN_RETURNS_INTEGER_OBJECT
	cnt = (int)NUM2LONG(RSTRUCT_LEN(obj));
#else // RSTRUCT_LEN_RETURNS_INTEGER_OBJECT
	cnt = (int)RSTRUCT_LEN(obj);
#endif // RSTRUCT_LEN_RETURNS_INTEGER_OBJECT
	
	for (i = 0; i < cnt; i++) {
	    v = RSTRUCT_GET(obj, i);
	    if (oj_dump_ignore(out->opts, v)) {
		v = Qnil;
	    }
	    assure_size(out, size);
	    fill_indent(out, d3);
	    oj_dump_obj_val(v, d3, out);
	    *out->cur++ = ',';
	}
    }
#else
    {
	// This is a bit risky as a struct in C ruby is not the same as a Struct
	// class in interpreted Ruby so length() may not be defined.
	int	slen = FIX2INT(rb_funcall2(obj, oj_length_id, 0, 0));

	for (i = 0; i < slen; i++) {
	    assure_size(out, size);
	    fill_indent(out, d3);
	    if (oj_dump_ignore(out->opts, v)) {
		v = Qnil;
	    }
	    oj_dump_obj_val(rb_struct_aref(obj, INT2FIX(i)), d3, out, 0, 0, true);
	    *out->cur++ = ',';
	}
    }
#endif
    out->cur--;
    *out->cur++ = ']';
    *out->cur++ = '}';
    *out->cur = '\0';
}

static void
dump_complex(VALUE obj, int depth, Out out, bool as_ok) {
    dump_obj_attrs(obj, rb_obj_class(obj), 0, depth, out);
}

static void
dump_rational(VALUE obj, int depth, Out out, bool as_ok) {
    dump_obj_attrs(obj, rb_obj_class(obj), 0, depth, out);
}

static DumpFunc	obj_funcs[] = {
    NULL,	 	// RUBY_T_NONE   = 0x00,
    dump_obj,		// RUBY_T_OBJECT = 0x01,
    dump_class, 	// RUBY_T_CLASS  = 0x02,
    dump_class,		// RUBY_T_MODULE = 0x03,
    oj_dump_float, 	// RUBY_T_FLOAT  = 0x04,
    dump_str,	 	// RUBY_T_STRING = 0x05,
    dump_regexp,	// RUBY_T_REGEXP = 0x06,
    dump_array,		// RUBY_T_ARRAY  = 0x07,
    dump_hash,	 	// RUBY_T_HASH   = 0x08,
    dump_struct,	// RUBY_T_STRUCT = 0x09,
    oj_dump_bignum,	// RUBY_T_BIGNUM = 0x0a,
    NULL, 		// RUBY_T_FILE   = 0x0b,
    dump_data,		// RUBY_T_DATA   = 0x0c,
    NULL, 		// RUBY_T_MATCH  = 0x0d,
    dump_complex, 	// RUBY_T_COMPLEX  = 0x0e,
    dump_rational, 	// RUBY_T_RATIONAL = 0x0f,
    NULL, 		// 0x10
    oj_dump_nil, 	// RUBY_T_NIL    = 0x11,
    oj_dump_true, 	// RUBY_T_TRUE   = 0x12,
    oj_dump_false,	// RUBY_T_FALSE  = 0x13,
    dump_sym,		// RUBY_T_SYMBOL = 0x14,
    oj_dump_fixnum,	// RUBY_T_FIXNUM = 0x15,
};

void
oj_dump_obj_val(VALUE obj, int depth, Out out) {
    int	type = rb_type(obj);
    
    if (Yes == out->opts->trace) {
	oj_trace("dump", obj, __FILE__, __LINE__, depth, TraceIn);
    }
    if (MAX_DEPTH < depth) {
	rb_raise(rb_eNoMemError, "Too deeply nested.\n");
    }
    if (0 < type && type <= RUBY_T_FIXNUM) {
	DumpFunc	f = obj_funcs[type];

	if (NULL != f) {
	    f(obj, depth, out, false);
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

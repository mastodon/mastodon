/* dump_strict.c
 * Copyright (c) 2012, 2017, Peter Ohler
 * All rights reserved.
 */

#include <stdlib.h>
#include <time.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <unistd.h>
#include <errno.h>

#include "dump.h"
#include "trace.h"

#if !HAS_ENCODING_SUPPORT || defined(RUBINIUS_RUBY)
#define rb_eEncodingError	rb_eException
#endif

// Workaround in case INFINITY is not defined in math.h or if the OS is CentOS
#define OJ_INFINITY (1.0/0.0)

// Extra padding at end of buffer.
#define BUFFER_EXTRA 10

typedef unsigned long	ulong;

static const char	inf_val[] = INF_VAL;
static const char	ninf_val[] = NINF_VAL;
static const char	nan_val[] = NAN_VAL;

static void
raise_strict(VALUE obj) {
    rb_raise(rb_eTypeError, "Failed to dump %s Object to JSON in strict mode.\n", rb_class2name(rb_obj_class(obj)));
}

// Removed dependencies on math due to problems with CentOS 5.4.
static void
dump_float(VALUE obj, int depth, Out out, bool as_ok) {
    char	buf[64];
    char	*b;
    double	d = rb_num2dbl(obj);
    int		cnt = 0;

    if (0.0 == d) {
	b = buf;
	*b++ = '0';
	*b++ = '.';
	*b++ = '0';
	*b++ = '\0';
	cnt = 3;
    } else {
	NanDump	nd = out->opts->dump_opts.nan_dump;
	    
	if (AutoNan == nd) {
	    nd = RaiseNan;
	}
	if (OJ_INFINITY == d) {
	    switch (nd) {
	    case RaiseNan:
	    case WordNan:
		raise_strict(obj);
		break;
	    case NullNan:
		strcpy(buf, "null");
		cnt = 4;
		break;
	    case HugeNan:
	    default:
		strcpy(buf, inf_val);
		cnt = sizeof(inf_val) - 1;
		break;
	    }
	} else if (-OJ_INFINITY == d) {
	    switch (nd) {
	    case RaiseNan:
	    case WordNan:
		raise_strict(obj);
		break;
	    case NullNan:
		strcpy(buf, "null");
		cnt = 4;
		break;
	    case HugeNan:
	    default:
		strcpy(buf, ninf_val);
		cnt = sizeof(ninf_val) - 1;
		break;
	    }
	} else if (isnan(d)) {
	    switch (nd) {
	    case RaiseNan:
	    case WordNan:
		raise_strict(obj);
		break;
	    case NullNan:
		strcpy(buf, "null");
		cnt = 4;
		break;
	    case HugeNan:
	    default:
		strcpy(buf, nan_val);
		cnt = sizeof(nan_val) - 1;
		break;
	    }
	} else if (d == (double)(long long int)d) {
	    cnt = snprintf(buf, sizeof(buf), "%.1f", d);
	} else if (0 == out->opts->float_prec) {
	    volatile VALUE	rstr = rb_funcall(obj, oj_to_s_id, 0);

	    cnt = (int)RSTRING_LEN(rstr);
	    if ((int)sizeof(buf) <= cnt) {
		cnt = sizeof(buf) - 1;
	    }
	    strncpy(buf, rb_string_value_ptr((VALUE*)&rstr), cnt);
	    buf[cnt] = '\0';
	} else {
	    cnt = oj_dump_float_printf(buf, sizeof(buf), obj, d, out->opts->float_fmt);
	}
    }
    assure_size(out, cnt);
    for (b = buf; '\0' != *b; b++) {
	*out->cur++ = *b;
    }
    *out->cur = '\0';
}

static void
dump_array(VALUE a, int depth, Out out, bool as_ok) {
    size_t	size;
    int		i, cnt;
    int		d2 = depth + 1;

    if (Yes == out->opts->circular) {
	if (0 > oj_check_circular(a, out)) {
	    oj_dump_nil(Qnil, 0, out, false);
	    return;
	}
    }
    cnt = (int)RARRAY_LEN(a);
    *out->cur++ = '[';
    size = 2;
    assure_size(out, size);
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
	    if (NullMode == out->opts->mode) {
		oj_dump_null_val(rb_ary_entry(a, i), d2, out);
	    } else {
		oj_dump_strict_val(rb_ary_entry(a, i), d2, out);
	    }
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

static int
hash_cb(VALUE key, VALUE value, Out out) {
    int		depth = out->depth;
    long	size;
    int		rtype = rb_type(key);
    
    if (rtype != T_STRING && rtype != T_SYMBOL) {
	rb_raise(rb_eTypeError, "In :strict and :null mode all Hash keys must be Strings or Symbols, not %s.\n", rb_class2name(rb_obj_class(key)));
    }
    if (out->omit_nil && Qnil == value) {
	return ST_CONTINUE;
    }
    if (!out->opts->dump_opts.use) {
	size = depth * out->indent + 1;
	assure_size(out, size);
	fill_indent(out, depth);
	if (rtype == T_STRING) {
	    oj_dump_str(key, 0, out, false);
	} else {
	    oj_dump_sym(key, 0, out, false);
	}
	*out->cur++ = ':';
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
	if (rtype == T_STRING) {
	    oj_dump_str(key, 0, out, false);
	} else {
	    oj_dump_sym(key, 0, out, false);
	}
	size = out->opts->dump_opts.before_size + out->opts->dump_opts.after_size + 2;
	assure_size(out, size);
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
    if (NullMode == out->opts->mode) {
	oj_dump_null_val(value, depth, out);
    } else {
	oj_dump_strict_val(value, depth, out);
    }
    out->depth = depth;
    *out->cur++ = ',';

    return ST_CONTINUE;
}

static void
dump_hash(VALUE obj, int depth, Out out, bool as_ok) {
    int		cnt;
    size_t	size;

    if (Yes == out->opts->circular) {
	if (0 > oj_check_circular(obj, out)) {
	    oj_dump_nil(Qnil, 0, out, false);
	    return;
	}
    }
    cnt = (int)RHASH_SIZE(obj);
    size = depth * out->indent + 2;
    assure_size(out, 2);
    *out->cur++ = '{';
    if (0 == cnt) {
	*out->cur++ = '}';
    } else {
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

static void
dump_data_strict(VALUE obj, int depth, Out out, bool as_ok) {
    VALUE	clas = rb_obj_class(obj);

    if (oj_bigdecimal_class == clas) {
	volatile VALUE	rstr = rb_funcall(obj, oj_to_s_id, 0);

	oj_dump_raw(rb_string_value_ptr((VALUE*)&rstr), RSTRING_LEN(rstr), out);
    } else {
	raise_strict(obj);
    }
}

static void
dump_data_null(VALUE obj, int depth, Out out, bool as_ok) {
    VALUE	clas = rb_obj_class(obj);

    if (oj_bigdecimal_class == clas) {
	volatile VALUE	rstr = rb_funcall(obj, oj_to_s_id, 0);

	oj_dump_raw(rb_string_value_ptr((VALUE*)&rstr), RSTRING_LEN(rstr), out);
    } else {
	oj_dump_nil(Qnil, depth, out, false);
    }
}

static DumpFunc	strict_funcs[] = {
    NULL,	 	// RUBY_T_NONE   = 0x00,
    dump_data_strict,	// RUBY_T_OBJECT = 0x01,
    NULL, 		// RUBY_T_CLASS  = 0x02,
    NULL, 		// RUBY_T_MODULE = 0x03,
    dump_float, 	// RUBY_T_FLOAT  = 0x04,
    oj_dump_str, 	// RUBY_T_STRING = 0x05,
    NULL, 		// RUBY_T_REGEXP = 0x06,
    dump_array,		// RUBY_T_ARRAY  = 0x07,
    dump_hash,	 	// RUBY_T_HASH   = 0x08,
    NULL, 		// RUBY_T_STRUCT = 0x09,
    oj_dump_bignum,	// RUBY_T_BIGNUM = 0x0a,
    NULL, 		// RUBY_T_FILE   = 0x0b,
    dump_data_strict,	// RUBY_T_DATA   = 0x0c,
    NULL, 		// RUBY_T_MATCH  = 0x0d,
    NULL, 		// RUBY_T_COMPLEX  = 0x0e,
    NULL, 		// RUBY_T_RATIONAL = 0x0f,
    NULL, 		// 0x10
    oj_dump_nil, 	// RUBY_T_NIL    = 0x11,
    oj_dump_true, 	// RUBY_T_TRUE   = 0x12,
    oj_dump_false,	// RUBY_T_FALSE  = 0x13,
    oj_dump_sym,	// RUBY_T_SYMBOL = 0x14,
    oj_dump_fixnum,	// RUBY_T_FIXNUM = 0x15,
};

void
oj_dump_strict_val(VALUE obj, int depth, Out out) {
    int	type = rb_type(obj);
    
    if (Yes == out->opts->trace) {
	oj_trace("dump", obj, __FILE__, __LINE__, depth, TraceIn);
    }
    if (MAX_DEPTH < depth) {
	rb_raise(rb_eNoMemError, "Too deeply nested.\n");
    }
    if (0 < type && type <= RUBY_T_FIXNUM) {
	DumpFunc	f = strict_funcs[type];

	if (NULL != f) {
	    f(obj, depth, out, false);
	    if (Yes == out->opts->trace) {
		oj_trace("dump", obj, __FILE__, __LINE__, depth, TraceOut);
	    }
	    return;
	}
    }
    raise_strict(obj);
}

static DumpFunc	null_funcs[] = {
    NULL,	 	// RUBY_T_NONE   = 0x00,
    dump_data_null,	// RUBY_T_OBJECT = 0x01,
    NULL, 		// RUBY_T_CLASS  = 0x02,
    NULL, 		// RUBY_T_MODULE = 0x03,
    dump_float, 	// RUBY_T_FLOAT  = 0x04,
    oj_dump_str, 	// RUBY_T_STRING = 0x05,
    NULL, 		// RUBY_T_REGEXP = 0x06,
    dump_array,		// RUBY_T_ARRAY  = 0x07,
    dump_hash,	 	// RUBY_T_HASH   = 0x08,
    NULL, 		// RUBY_T_STRUCT = 0x09,
    oj_dump_bignum,	// RUBY_T_BIGNUM = 0x0a,
    NULL, 		// RUBY_T_FILE   = 0x0b,
    dump_data_null,	// RUBY_T_DATA   = 0x0c,
    NULL, 		// RUBY_T_MATCH  = 0x0d,
    NULL, 		// RUBY_T_COMPLEX  = 0x0e,
    NULL, 		// RUBY_T_RATIONAL = 0x0f,
    NULL, 		// 0x10
    oj_dump_nil, 	// RUBY_T_NIL    = 0x11,
    oj_dump_true, 	// RUBY_T_TRUE   = 0x12,
    oj_dump_false,	// RUBY_T_FALSE  = 0x13,
    oj_dump_sym,	// RUBY_T_SYMBOL = 0x14,
    oj_dump_fixnum,	// RUBY_T_FIXNUM = 0x15,
};

void
oj_dump_null_val(VALUE obj, int depth, Out out) {
    int	type = rb_type(obj);
    
    if (Yes == out->opts->trace) {
	oj_trace("dump", obj, __FILE__, __LINE__, depth, TraceOut);
    }
    if (MAX_DEPTH < depth) {
	rb_raise(rb_eNoMemError, "Too deeply nested.\n");
    }
    if (0 < type && type <= RUBY_T_FIXNUM) {
	DumpFunc	f = null_funcs[type];

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

/* rails.c
 * Copyright (c) 2017, Peter Ohler
 * All rights reserved.
 */

#include "rails.h"
#include "encode.h"
#include "code.h"
#include "encode.h"
#include "trace.h"

#define OJ_INFINITY (1.0/0.0)

// TBD keep static array of strings and functions to help with rails optimization
typedef struct _Encoder {
    struct _ROptTable	ropts;
    struct _Options	opts;
    VALUE		arg;
} *Encoder;

bool	oj_rails_hash_opt = false;
bool	oj_rails_array_opt = false;
bool	oj_rails_float_opt = false;

extern void	oj_mimic_json_methods(VALUE json);

static void	dump_rails_val(VALUE obj, int depth, Out out, bool as_ok);

extern VALUE	Oj;

static struct _ROptTable	ropts = { 0, 0, NULL };

static VALUE	encoder_class = Qnil;
static bool	escape_html = true;
static bool	xml_time = true;

static ROpt	create_opt(ROptTable rot, VALUE clas);

ROpt
oj_rails_get_opt(ROptTable rot, VALUE clas) {
    if (NULL == rot) {
	rot = &ropts;
    }
    if (0 < rot->len) {
	int	lo = 0;
	int	hi = rot->len - 1;
	int	mid;
	VALUE	v;

	if (clas < rot->table->clas || rot->table[hi].clas < clas) {
	    return NULL;
	}
	if (rot->table[lo].clas == clas) {
	    return rot->table;
	}
	if (rot->table[hi].clas == clas) {
	    return &rot->table[hi];
	}
	while (2 <= hi - lo) {
	    mid = (hi + lo) / 2;
	    v = rot->table[mid].clas;
	    if (v == clas) {
		return &rot->table[mid];
	    }
	    if (v < clas) {
		lo = mid;
	    } else {
		hi = mid;
	    }
	}
    }
    return NULL;
}

static ROptTable
copy_opts(ROptTable src, ROptTable dest) {
    dest->len = src->len;
    dest->alen = src->alen;
    if (NULL == src->table) {
	dest->table = NULL;
    } else {
	dest->table = ALLOC_N(struct _ROpt, dest->alen);
	memcpy(dest->table, src->table, sizeof(struct _ROpt) * dest->alen);
    }
    return NULL;
}

static int
dump_attr_cb(ID key, VALUE value, Out out) {
    int		depth = out->depth;
    size_t	size = depth * out->indent + 1;
    const char	*attr = rb_id2name(key);

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
    dump_rails_val(value, depth, out, true);
    out->depth = depth;
    *out->cur++ = ',';
    
    return ST_CONTINUE;
}

static void
dump_obj_attrs(VALUE obj, int depth, Out out, bool as_ok) {
    assure_size(out, 2);
    *out->cur++ = '{';
    out->depth = depth + 1;
    rb_ivar_foreach(obj, dump_attr_cb, (VALUE)out);
    if (',' == *(out->cur - 1)) {
	out->cur--; // backup to overwrite last comma
    }
    out->depth = depth;
    fill_indent(out, depth);
    *out->cur++ = '}';
    *out->cur = '\0';
}

static void
dump_struct(VALUE obj, int depth, Out out, bool as_ok) {
    int			d3 = depth + 2;
    size_t		size = d3 * out->indent + 2;
    size_t		sep_len = out->opts->dump_opts.before_size + out->opts->dump_opts.after_size + 2;
    volatile VALUE	ma;
    volatile VALUE	v;
    int			cnt;
    int			i;
    int			len;
    const char		*name;

#ifdef RSTRUCT_LEN
#if RSTRUCT_LEN_RETURNS_INTEGER_OBJECT
    cnt = (int)NUM2LONG(RSTRUCT_LEN(obj));
#else // RSTRUCT_LEN_RETURNS_INTEGER_OBJECT
    cnt = (int)RSTRUCT_LEN(obj);
#endif // RSTRUCT_LEN_RETURNS_INTEGER_OBJECT
#else
    // This is a bit risky as a struct in C ruby is not the same as a Struct
    // class in interpreted Ruby so length() may not be defined.
    cnt = FIX2INT(rb_funcall(obj, oj_length_id, 0));
#endif
    ma = rb_struct_s_members(rb_obj_class(obj));
    assure_size(out, 2);
    *out->cur++ = '{';
    for (i = 0; i < cnt; i++) {
	name = rb_id2name(SYM2ID(rb_ary_entry(ma, i)));
	len = (int)strlen(name);
	assure_size(out, size + sep_len + 6);
	if (0 < i) {
	    *out->cur++ = ',';
	}
	fill_indent(out, d3);
	*out->cur++ = '"';
	memcpy(out->cur, name, len);
	out->cur += len;
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
#ifdef RSTRUCT_LEN
	v = RSTRUCT_GET(obj, i);
#else
	v = rb_struct_aref(obj, INT2FIX(i));
#endif
	dump_rails_val(v, d3, out, true);
    }
    fill_indent(out, depth);
    *out->cur++ = '}';
    *out->cur = '\0';
}

static ID	to_a_id = 0;

static void
dump_enumerable(VALUE obj, int depth, Out out, bool as_ok) {
    if (0 == to_a_id) {
	to_a_id = rb_intern("to_a");
    }
    dump_rails_val(rb_funcall(obj, to_a_id, 0), depth, out, false);
}

static void
dump_bigdecimal(VALUE obj, int depth, Out out, bool as_ok) {
    volatile VALUE	rstr = rb_funcall(obj, oj_to_s_id, 0);
    const char		*str = rb_string_value_ptr((VALUE*)&rstr);

    if ('I' == *str || 'N' == *str || ('-' == *str && 'I' == str[1])) {
	oj_dump_nil(Qnil, depth, out, false);
    } else if (Yes == out->opts->bigdec_as_num) {
	oj_dump_raw(str, RSTRING_LEN(rstr), out);
    } else {
	oj_dump_cstr(str, RSTRING_LEN(rstr), 0, 0, out);
    }
}

static void
dump_sec_nano(VALUE obj, time_t sec, long nsec, Out out) {
    char		buf[64];
    struct tm		*tm;
    long		one = 1000000000;
    long		tzsecs = NUM2LONG(rb_funcall2(obj, oj_utc_offset_id, 0, 0));
    int			tzhour, tzmin;
    char		tzsign = '+';
    int			len;
    
    if (out->end - out->cur <= 36) {
	assure_size(out, 36);
    }
    if (9 > out->opts->sec_prec) {
	int	i;

	// Rails does not round when reducing precision but instead floors,
	for (i = 9 - out->opts->sec_prec; 0 < i; i--) {
	    nsec = nsec / 10;
	    one /= 10;
	}
	if (one <= nsec) {
	    nsec -= one;
	    sec++;
	}
    }
    // 2012-01-05T23:58:07.123456000+09:00 or 2012/01/05 23:58:07 +0900
    sec += tzsecs;
    tm = gmtime(&sec);
    if (0 > tzsecs) {
        tzsign = '-';
        tzhour = (int)(tzsecs / -3600);
        tzmin = (int)(tzsecs / -60) - (tzhour * 60);
    } else {
        tzhour = (int)(tzsecs / 3600);
        tzmin = (int)(tzsecs / 60) - (tzhour * 60);
    }
    if (!xml_time) {
	len = sprintf(buf, "%04d/%02d/%02d %02d:%02d:%02d %c%02d%02d",
		      tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday,
		      tm->tm_hour, tm->tm_min, tm->tm_sec, tzsign, tzhour, tzmin);
    } else if (0 == out->opts->sec_prec) {
	if (0 == tzsecs && rb_funcall2(obj, oj_utcq_id, 0, 0)) {
	    len = sprintf(buf, "%04d-%02d-%02dT%02d:%02d:%02dZ",
			  tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday,
			  tm->tm_hour, tm->tm_min, tm->tm_sec);
	} else {
	    len = sprintf(buf, "%04d-%02d-%02dT%02d:%02d:%02d%c%02d:%02d",
			  tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday,
			  tm->tm_hour, tm->tm_min, tm->tm_sec,
			  tzsign, tzhour, tzmin);
	}
    } else if (0 == tzsecs && rb_funcall2(obj, oj_utcq_id, 0, 0)) {
	char	format[64] = "%04d-%02d-%02dT%02d:%02d:%02d.%09ldZ";

	len = 30;
	if (9 > out->opts->sec_prec) {
	    format[32] = '0' + out->opts->sec_prec;
	    len -= 9 - out->opts->sec_prec;
	}
	len = sprintf(buf, format,
		      tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday,
		      tm->tm_hour, tm->tm_min, tm->tm_sec, nsec);
    } else {
	char	format[64] = "%04d-%02d-%02dT%02d:%02d:%02d.%09ld%c%02d:%02d";

	len = 35;
	if (9 > out->opts->sec_prec) {
	    format[32] = '0' + out->opts->sec_prec;
	    len -= 9 - out->opts->sec_prec;
	}
	len = sprintf(buf, format,
		      tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday,
		      tm->tm_hour, tm->tm_min, tm->tm_sec, nsec,
		      tzsign, tzhour, tzmin);
    }
    oj_dump_cstr(buf, len, 0, 0, out);
}

static void
dump_time(VALUE obj, int depth, Out out, bool as_ok) {
#if HAS_RB_TIME_TIMESPEC
    struct timespec	ts = rb_time_timespec(obj);
    time_t		sec = ts.tv_sec;
    long		nsec = ts.tv_nsec;
#else
    time_t		sec = NUM2LONG(rb_funcall2(obj, oj_tv_sec_id, 0, 0));
#if HAS_NANO_TIME
    long long		nsec = rb_num2ll(rb_funcall2(obj, oj_tv_nsec_id, 0, 0));
#else
    long long		nsec = rb_num2ll(rb_funcall2(obj, oj_tv_usec_id, 0, 0)) * 1000;
#endif
#endif
    dump_sec_nano(obj, sec, nsec, out);
}

static void
dump_timewithzone(VALUE obj, int depth, Out out, bool as_ok) {
    time_t	sec = NUM2LONG(rb_funcall2(obj, oj_tv_sec_id, 0, 0));
#if HAS_NANO_TIME
    long long	nsec = rb_num2ll(rb_funcall2(obj, oj_tv_nsec_id, 0, 0));
#else
    long long	nsec = rb_num2ll(rb_funcall2(obj, oj_tv_usec_id, 0, 0)) * 1000;
#endif
    dump_sec_nano(obj, sec, nsec, out);
}

static void
dump_to_s(VALUE obj, int depth, Out out, bool as_ok) {
    volatile VALUE	rstr = rb_funcall(obj, oj_to_s_id, 0);

    oj_dump_cstr(rb_string_value_ptr((VALUE*)&rstr), RSTRING_LEN(rstr), 0, 0, out);
}

static ID	parameters_id = 0;

static void
dump_actioncontroller_parameters(VALUE obj, int depth, Out out, bool as_ok) {
    if (0 == parameters_id) {
	parameters_id = rb_intern("@parameters");
    }
    out->argc = 0;
    dump_rails_val(rb_ivar_get(obj, parameters_id), depth, out, true);
}

typedef struct _NamedFunc {
    const char	*name;
    DumpFunc	func;
} *NamedFunc;

static struct _NamedFunc	dump_map[] = {
    { "ActionController::Parameters", dump_actioncontroller_parameters },
    { "ActiveSupport::TimeWithZone", dump_timewithzone },
    { "BigDecimal", dump_bigdecimal },
    { "Range", dump_to_s },
    { "Regexp", dump_to_s },
    { "Time", dump_time },
    { NULL, NULL },
};

static VALUE	activerecord_base = Qundef;
static ID	attributes_id = 0;

static void
dump_activerecord(VALUE obj, int depth, Out out, bool as_ok) {
    if (0 == attributes_id) {
	attributes_id = rb_intern("@attributes");
    }
    out->argc = 0;
    dump_rails_val(rb_ivar_get(obj, attributes_id), depth, out, true);
}

static ROpt
create_opt(ROptTable rot, VALUE clas) {
    ROpt	ro;
    NamedFunc	nf;
    const char	*classname = rb_class2name(clas);
    int		olen = rot->len;

    rot->len++;
    if (NULL == rot->table) {
	rot->alen = 256;
	rot->table = ALLOC_N(struct _ROpt, rot->alen);
	memset(rot->table, 0, sizeof(struct _ROpt) * rot->alen);
    } else if (rot->alen <= rot->len) {
	rot->alen *= 2;
	REALLOC_N(rot->table, struct _ROpt, rot->alen);
	memset(rot->table + olen, 0, sizeof(struct _ROpt) * olen);
    }
    if (0 == olen) {
	ro = rot->table;
    } else if (rot->table[olen - 1].clas < clas) {
	ro = &rot->table[olen];
    } else {
	int	i;
	
	for (i = 0, ro = rot->table; i < olen; i++, ro++) {
	    if (clas < ro->clas) {
		memmove(ro + 1, ro, sizeof(struct _ROpt) * (olen - i));
		break;
	    }
	}
    }
    ro->clas = clas;
    ro->on = true;
    ro->dump = dump_obj_attrs;
    for (nf = dump_map; NULL != nf->name; nf++) {
	if (0 == strcmp(nf->name, classname)) {
	    ro->dump = nf->func;
	    break;
	}
    }
    if (ro->dump == dump_obj_attrs) {
	if (Qundef == activerecord_base) {
	    // If not defined let an exception be raised.
	    VALUE	ar = rb_const_get_at(rb_cObject, rb_intern("ActiveRecord"));

	    if (Qundef != ar) {
		activerecord_base = rb_const_get_at(ar, rb_intern("Base"));
	    }
	}
	if (Qundef != activerecord_base && Qtrue == rb_class_inherited_p(clas, activerecord_base)) {
	    ro->dump = dump_activerecord;
	} else if (Qtrue == rb_class_inherited_p(clas, rb_cStruct)) { // check before enumerable
	    ro->dump = dump_struct;
	} else if (Qtrue == rb_class_inherited_p(clas, rb_mEnumerable)) {
	    ro->dump = dump_enumerable;
	} else if (Qtrue == rb_class_inherited_p(clas, rb_eException)) {
	    ro->dump = dump_to_s;
	}
    }
    return NULL;
}

static void
encoder_free(void *ptr) {
    if (NULL != ptr) {
	Encoder	e = (Encoder)ptr;

	if (NULL != e->ropts.table) {
	    xfree(e->ropts.table);
	}
	xfree(ptr);
    }
}

static void
encoder_mark(void *ptr) {
    if (NULL != ptr) {
	Encoder	e = (Encoder)ptr;

	if (Qnil != e->arg) {
	    rb_gc_mark(e->arg);
	}
    }
}

/* Document-method: new
 *	call-seq: new(options=nil)
 *
 * Creates a new Encoder.
 * - *options* [_Hash_] formatting options
 */
static VALUE
encoder_new(int argc, VALUE *argv, VALUE self) {
    Encoder	e = ALLOC(struct _Encoder);

    e->opts = oj_default_options;
    e->arg = Qnil;
    copy_opts(&ropts, &e->ropts);
    
    if (1 <= argc && Qnil != *argv) {
	oj_parse_options(*argv, &e->opts);
	e->arg = *argv;
    }
    return Data_Wrap_Struct(encoder_class, encoder_mark, encoder_free, e);
}

static VALUE
resolve_classpath(const char *name) {
    char	class_name[1024];
    VALUE	clas;
    char	*end = class_name + sizeof(class_name) - 1;
    char	*s;
    const char	*n = name;
    ID		cid;

    clas = rb_cObject;
    for (s = class_name; '\0' != *n; n++) {
	if (':' == *n) {
	    *s = '\0';
	    n++;
	    if (':' != *n) {
		return Qnil;
	    }
	    cid = rb_intern(class_name);
	    if (!rb_const_defined_at(clas, cid)) {
		return Qnil;
	    }
	    clas = rb_const_get_at(clas, cid);
	    s = class_name;
	} else if (end <= s) {
	    return Qnil;
	} else {
	    *s++ = *n;
	}
    }
    *s = '\0';
    cid = rb_intern(class_name);
    if (!rb_const_defined_at(clas, cid)) {
	return Qnil;
    }
    clas = rb_const_get_at(clas, cid);

    return clas;
}

static void
optimize(int argc, VALUE *argv, ROptTable rot, bool on) {
    ROpt	ro;

    if (0 == argc) {
	int		i;
	NamedFunc	nf;
	VALUE		clas;
	
	oj_rails_hash_opt = on;
	oj_rails_array_opt = on;
	oj_rails_float_opt = on;

	for (nf = dump_map; NULL != nf->name; nf++) {
	    if (Qnil != (clas = resolve_classpath(nf->name))) {
		if (NULL == oj_rails_get_opt(rot, clas)) {
		    create_opt(rot, clas);
		}
	    }
	}
	for (i = 0; i < rot->len; i++) {
	    rot->table[i].on = on;
	}
    }
    for (; 0 < argc; argc--, argv++) {
	if (rb_cHash == *argv) {
	    oj_rails_hash_opt = on;
	} else if (rb_cArray == *argv) {
	    oj_rails_array_opt = on;
	} else if (rb_cFloat == *argv) {
	    oj_rails_float_opt = on;
	} else if (NULL != (ro = oj_rails_get_opt(rot, *argv)) ||
		   NULL != (ro = create_opt(rot, *argv))) {
	    ro->on = on;
	}
    }
}

/* Document-method optimize
 *	call-seq: optimize(*classes)
 * 
 * Use Oj rails optimized routines to encode the specified classes. This
 * ignores the as_json() method on the class and uses an internal encoding
 * instead. Passing in no classes indicates all should use the optimized
 * version of encoding for all previously optimized classes. Passing in the
 * Object class set a global switch that will then use the optimized behavior
 * for all classes.
 * 
 * - *classes* [_Class_] a list of classes to optimize
 */
static VALUE
encoder_optimize(int argc, VALUE *argv, VALUE self) {
    Encoder	e = (Encoder)DATA_PTR(self);

    optimize(argc, argv, &e->ropts, true);

    return Qnil;
}

/* Document-method: optimize
 *	call-seq: optimize(*classes)
 * 
 * Use Oj rails optimized routines to encode the specified classes. This
 * ignores the as_json() method on the class and uses an internal encoding
 * instead. Passing in no classes indicates all should use the optimized
 * version of encoding for all previously optimized classes. Passing in the
 * Object class set a global switch that will then use the optimized behavior
 * for all classes.
 * 
 * - *classes* [_Class_] a list of classes to optimize
 */
static VALUE
rails_optimize(int argc, VALUE *argv, VALUE self) {
    optimize(argc, argv, &ropts, true);

    return Qnil;
}

/* Document-module: mimic_JSON
 *	call-seq: mimic_JSON()
 *
 * Sets the JSON method to use Oj similar to Oj.mimic_JSON except with the
 * ActiveSupport monkey patches instead of the json gem monkey patches.
 */
VALUE
rails_mimic_json(VALUE self) {
    VALUE	json;
    
    if (rb_const_defined_at(rb_cObject, rb_intern("JSON"))) {
	json = rb_const_get_at(rb_cObject, rb_intern("JSON"));
    } else {
	json = rb_define_module("JSON");
    }
    oj_mimic_json_methods(json);

    return Qnil;
}

/* Document-method: deoptimize
 *	call-seq: deoptimize(*classes)
 * 
 * Turn off Oj rails optimization on the specified classes.
 *
 * - *classes* [_Class_] a list of classes to deoptimize
 */
static VALUE
encoder_deoptimize(int argc, VALUE *argv, VALUE self) {
    Encoder	e = (Encoder)DATA_PTR(self);

    optimize(argc, argv, &e->ropts, false);

    return Qnil;
}

/* Document-method: deoptimize
 *	call-seq: deoptimize(*classes)
 * 
 * Turn off Oj rails optimization on the specified classes.
 *
 * - *classes* [_Class_] a list of classes to deoptimize
 */
static VALUE
rails_deoptimize(int argc, VALUE *argv, VALUE self) {
    optimize(argc, argv, &ropts, false);

    return Qnil;
}

/* Document-method:optimized?
 *	call-seq: optimized?(clas)
 * 
 * - *clas* [_Class_] Class to check
 *
 * @return true if the class is being optimized for rails and false otherwise
 */
static VALUE
encoder_optimized(VALUE self, VALUE clas) {
    Encoder	e = (Encoder)DATA_PTR(self);
    ROpt	ro = oj_rails_get_opt(&e->ropts, clas);

    if (NULL == ro) {
	return Qfalse;
    }
    return (ro->on) ? Qtrue : Qfalse;
}

/* Document-method: optimized?
 *	call-seq: optimized?(clas)
 * 
 * Returns true if the specified Class is being optimized.
 */
static VALUE
rails_optimized(VALUE self, VALUE clas) {
    ROpt	ro = oj_rails_get_opt(&ropts, clas);

    if (NULL == ro) {
	return Qfalse;
    }
    return (ro->on) ? Qtrue : Qfalse;
}

typedef struct _OO {
    Out		out;
    VALUE	obj;
} *OO;

static VALUE
protect_dump(VALUE ov) {
    OO	oo = (OO)ov;

    dump_rails_val(oo->obj, 0, oo->out, true);

    return Qnil;
}

static VALUE
encode(VALUE obj, ROptTable ropts, Options opts, int argc, VALUE *argv) {
    char		buf[4096];
    struct _Out		out;
    struct _Options	copts = *opts;
    volatile VALUE	rstr = Qnil;
    struct _OO		oo;
    int			line = 0;

    oo.out = &out;
    oo.obj = obj;
    copts.str_rx.head = NULL;
    copts.str_rx.tail = NULL;
    copts.mode = RailsMode;
    if (escape_html) {
	copts.escape_mode = JXEsc;
    } else {
	copts.escape_mode = RailsEsc;
    }
    out.buf = buf;
    out.end = buf + sizeof(buf) - 10;
    out.allocated = false;
    out.omit_nil = copts.dump_opts.omit_nil;
    out.caller = 0;
    out.cur = out.buf;
    out.circ_cnt = 0;
    out.opts = &copts;
    out.hash_cnt = 0;
    out.indent = copts.indent;
    out.argc = argc;
    out.argv = argv;
    out.ropts = ropts;
    if (Yes == copts.circular) {
	oj_cache8_new(&out.circ_cache);
    }
    //dump_rails_val(*argv, 0, &out, true);
    rb_protect(protect_dump, (VALUE)&oo, &line);

    if (0 == line) {
	if (0 < out.indent) {
	    switch (*(out.cur - 1)) {
	    case ']':
	    case '}':
		assure_size(&out, 2);
		*out.cur++ = '\n';
	    default:
		break;
	    }
	}
	*out.cur = '\0';

	if (0 == out.buf) {
	    rb_raise(rb_eNoMemError, "Not enough memory.");
	}
	rstr = rb_str_new2(out.buf);
	rstr = oj_encode(rstr);
    }
    if (Yes == copts.circular) {
	oj_cache8_delete(out.circ_cache);
    }
    if (out.allocated) {
	xfree(out.buf);
    }
    if (0 != line) {
	rb_jump_tag(line);
    }
    return rstr;
}

/* Document-method: encode
 *	call-seq: encode(obj)
 * 
 * - *obj* [_Object_] object to encode
 *
 * Returns encoded object as a JSON string.
 */
static VALUE
encoder_encode(VALUE self, VALUE obj) {
    Encoder	e = (Encoder)DATA_PTR(self);

    if (Qnil != e->arg) {
	VALUE	argv[1] = { e->arg };
	
	return encode(obj, &e->ropts, &e->opts, 1, argv);
    }
    return encode(obj, &e->ropts, &e->opts, 0, NULL);
}

/* Document-method: encode
 *	call-seq: encode(obj, opts=nil)
 * 
 * Encode obj as a JSON String.
 * 
 * - *obj* [_Object_|Hash|Array] object to convert to a JSON String
 * - *opts* [_Hash_] options
 *
 * Returns [_String_]
 */
static VALUE
rails_encode(int argc, VALUE *argv, VALUE self) {
    if (1 > argc) {
	rb_raise(rb_eArgError, "wrong number of arguments (0 for 1).");
    }
    if (1 == argc) {
	return encode(*argv, NULL, &oj_default_options, 0, NULL);
    } else {
	return encode(*argv, NULL, &oj_default_options, argc - 1, argv + 1);
    }
}

static VALUE
rails_use_standard_json_time_format(VALUE self, VALUE state) {
    switch (state) {
    case Qtrue:
    case Qfalse:
	break;
    case Qnil:
	state = Qfalse;
	break;
    default:
	state = Qtrue;
	break;
    }
    rb_iv_set(self, "@use_standard_json_time_format", state);
    xml_time = Qtrue == state;

    return state;
}

static VALUE
rails_escape_html_entities_in_json(VALUE self, VALUE state) {
    rb_iv_set(self, "@escape_html_entities_in_json", state);
    escape_html = Qtrue == state;

    return state;
}

static VALUE
rails_time_precision(VALUE self, VALUE prec) {
    rb_iv_set(self, "@time_precision", prec);
    oj_default_options.sec_prec = NUM2INT(prec);

    return prec;
}

/* Document-method: set_encoder
 *	call-seq: set_encoder()
 * 
 * Sets the ActiveSupport.encoder to Oj::Rails::Encoder and wraps some of the
 * formatting globals used by ActiveSupport to allow the use of those globals
 * in the Oj::Rails optimizations.
 */
static VALUE
rails_set_encoder(VALUE self) {
    VALUE	active;
    VALUE	json;
    VALUE	encoding;
    VALUE	pv;
    VALUE	verbose;
    
    if (rb_const_defined_at(rb_cObject, rb_intern("ActiveSupport"))) {
	active = rb_const_get_at(rb_cObject, rb_intern("ActiveSupport"));
    } else {
	rb_raise(rb_eStandardError, "ActiveSupport not loaded.");
    }
    rb_funcall(active, rb_intern("json_encoder="), 1, encoder_class);

    json = rb_const_get_at(active, rb_intern("JSON"));
    encoding = rb_const_get_at(json, rb_intern("Encoding"));

    // rb_undef_method doesn't work for modules or maybe sometimes
    // doesn't. Anyway setting verbose should hide the warning.
    verbose = rb_gv_get("$VERBOSE");
    rb_gv_set("$VERBOSE", Qfalse);
    rb_undef_method(encoding, "use_standard_json_time_format=");
    rb_define_module_function(encoding, "use_standard_json_time_format=", rails_use_standard_json_time_format, 1);

    rb_undef_method(encoding, "escape_html_entities_in_json=");
    rb_define_module_function(encoding, "escape_html_entities_in_json=", rails_escape_html_entities_in_json, 1);

    pv = rb_iv_get(encoding, "@time_precision");
    oj_default_options.sec_prec = NUM2INT(pv);
    rb_undef_method(encoding, "time_precision=");
    rb_define_module_function(encoding, "time_precision=", rails_time_precision, 1);
    rb_gv_set("$VERBOSE", verbose);

    return Qnil;
}

/* Document-method: set_decoder
 *	call-seq: set_decoder()
 *
 * Sets the JSON.parse function to be the Oj::parse function which is json gem
 * compatible.
 */
static VALUE
rails_set_decoder(VALUE self) {
    VALUE	json;
    VALUE	json_error;
    VALUE	verbose;
    
    if (rb_const_defined_at(rb_cObject, rb_intern("JSON"))) {
	json = rb_const_get_at(rb_cObject, rb_intern("JSON"));
    } else {
	json = rb_define_module("JSON");
    }
    if (rb_const_defined_at(json, rb_intern("JSONError"))) {
        json_error = rb_const_get(json, rb_intern("JSONError"));
    } else {
        json_error = rb_define_class_under(json, "JSONError", rb_eStandardError);
    }
    if (rb_const_defined_at(json, rb_intern("ParserError"))) {
        oj_json_parser_error_class = rb_const_get(json, rb_intern("ParserError"));
    } else {
    	oj_json_parser_error_class = rb_define_class_under(json, "ParserError", json_error);
    }
    // rb_undef_method doesn't work for modules or maybe sometimes
    // doesn't. Anyway setting verbose should hide the warning.
    verbose = rb_gv_get("$VERBOSE");
    rb_gv_set("$VERBOSE", Qfalse);
    rb_undef_method(json, "parse");
    rb_define_module_function(json, "parse", oj_mimic_parse, -1);
    rb_gv_set("$VERBOSE", verbose);
    
    return Qnil;
}

/* Document-module: Oj.optimize_rails()
 *
 * Sets the Oj as the Rails encoder and decoder. Oj::Rails.optimize is also
 * called.
 */
VALUE
oj_optimize_rails(VALUE self) {
    rails_set_encoder(self);
    rails_set_decoder(self);
    rails_optimize(0, NULL, self);
    rails_mimic_json(self);

    return Qnil;
}

/* Document-module: Oj::Rails
 * 
 * Module that provides rails and active support compatibility.
 */
/* Document-class: Oj::Rails::Encoder
 *
 * The Oj ActiveSupport compliant encoder.
 */
void
oj_mimic_rails_init() {
    VALUE	rails = rb_define_module_under(Oj, "Rails");
    
    rb_define_module_function(rails, "encode", rails_encode, -1);

    encoder_class = rb_define_class_under(rails, "Encoder", rb_cObject);
    rb_define_module_function(encoder_class, "new", encoder_new, -1);
    rb_define_module_function(rails, "optimize", rails_optimize, -1);
    rb_define_module_function(rails, "deoptimize", rails_deoptimize, -1);
    rb_define_module_function(rails, "optimized?", rails_optimized, 1);
    rb_define_module_function(rails, "mimic_JSON", rails_mimic_json, 0);

    rb_define_module_function(rails, "set_encoder", rails_set_encoder, 0);
    rb_define_module_function(rails, "set_decoder", rails_set_decoder, 0);

    rb_define_method(encoder_class, "encode", encoder_encode, 1);
    rb_define_method(encoder_class, "optimize", encoder_optimize, -1);
    rb_define_method(encoder_class, "deoptimize", encoder_deoptimize, -1);
    rb_define_method(encoder_class, "optimized?", encoder_optimized, 1);
}

static void
dump_as_json(VALUE obj, int depth, Out out, bool as_ok) {
    volatile VALUE	ja;

    // Some classes elect to not take an options argument so check the arity
    // of as_json.
#if HAS_METHOD_ARITY
    if (0 == rb_obj_method_arity(obj, oj_as_json_id)) {
	ja = rb_funcall(obj, oj_as_json_id, 0);
    } else {
	ja = rb_funcall2(obj, oj_as_json_id, out->argc, out->argv);
    }
#else
    ja = rb_funcall2(obj, oj_as_json_id, out->argc, out->argv);
#endif

    out->argc = 0;
    if (ja == obj || !as_ok) {
	// Once as_json is call it should never be called again on the same
	// object with as_ok.
	dump_rails_val(ja, depth, out, false);
    } else {
	int	type = rb_type(ja);

	if (T_HASH == type || T_ARRAY == type) {
	    dump_rails_val(ja, depth, out, true);
	} else {
	    dump_rails_val(ja, depth, out, true);
	}
    }
}

static void
dump_to_hash(VALUE obj, int depth, Out out) {
    dump_rails_val(rb_funcall(obj, oj_to_hash_id, 0), depth, out, true);
}

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
	if (isnan(d) || OJ_INFINITY == d || -OJ_INFINITY == d) {
	    strcpy(buf, "null");
	    cnt = 4;
	} else if (d == (double)(long long int)d) {
	    cnt = snprintf(buf, sizeof(buf), "%.1f", d);
	} else if (oj_rails_float_opt) {
	    cnt = oj_dump_float_printf(buf, sizeof(buf), obj, d, "%0.16g");
	} else {
	    volatile VALUE	rstr = rb_funcall(obj, oj_to_s_id, 0);

	    strcpy(buf, rb_string_value_ptr((VALUE*)&rstr));
	    cnt = (int)RSTRING_LEN(rstr);
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
    //if (!oj_rails_array_opt && as_ok && 0 < out->argc && rb_respond_to(a, oj_as_json_id)) {
    if (as_ok && 0 < out->argc && rb_respond_to(a, oj_as_json_id)) {
	dump_as_json(a, depth, out, false);
	return;
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
	    dump_rails_val(rb_ary_entry(a, i), d2, out, true);
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

static int
hash_cb(VALUE key, VALUE value, Out out) {
    int		depth = out->depth;
    long	size;
    int		rtype = rb_type(key);
    
    if (rtype != T_STRING && rtype != T_SYMBOL) {
	key = rb_funcall(key, oj_to_s_id, 0);
	rtype = rb_type(key);
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
    dump_rails_val(value, depth, out, true);
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
    if ((!oj_rails_hash_opt || 0 < out->argc) && as_ok && rb_respond_to(obj, oj_as_json_id)) {
	dump_as_json(obj, depth, out, false);
	return;
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
dump_obj(VALUE obj, int depth, Out out, bool as_ok) {
    if (oj_code_dump(oj_compat_codes, obj, depth, out)) {
	out->argc = 0;
	return;
    }
    if (as_ok) {
	ROpt	ro;
	
	if (NULL != (ro = oj_rails_get_opt(out->ropts, rb_obj_class(obj))) && ro->on) {
	    ro->dump(obj, depth, out, as_ok);
	} else if (rb_respond_to(obj, oj_as_json_id)) {
	    dump_as_json(obj, depth, out, true);
	} else if (rb_respond_to(obj, oj_to_hash_id)) {
	    dump_to_hash(obj, depth, out);
	} else {
	    oj_dump_obj_to_s(obj, out);
	}
    } else if (rb_respond_to(obj, oj_to_hash_id)) {
	// Always attempt to_hash.
	dump_to_hash(obj, depth, out);
    } else {
	oj_dump_obj_to_s(obj, out);
    }
}

static void
dump_as_string(VALUE obj, int depth, Out out, bool as_ok) {
    if (oj_code_dump(oj_compat_codes, obj, depth, out)) {
	out->argc = 0;
	return;
    }
    oj_dump_obj_to_s(obj, out);
}

static DumpFunc	rails_funcs[] = {
    NULL,	 	// RUBY_T_NONE     = 0x00,
    dump_obj,		// RUBY_T_OBJECT   = 0x01,
    oj_dump_class, 	// RUBY_T_CLASS    = 0x02,
    oj_dump_class,	// RUBY_T_MODULE   = 0x03,
    dump_float, 	// RUBY_T_FLOAT    = 0x04,
    oj_dump_str, 	// RUBY_T_STRING   = 0x05,
    dump_as_string,	// RUBY_T_REGEXP   = 0x06,
    dump_array,		// RUBY_T_ARRAY    = 0x07,
    dump_hash,	 	// RUBY_T_HASH     = 0x08,
    dump_obj,		// RUBY_T_STRUCT   = 0x09,
    oj_dump_bignum,	// RUBY_T_BIGNUM   = 0x0a,
    NULL, 		// RUBY_T_FILE     = 0x0b,
    dump_obj,		// RUBY_T_DATA     = 0x0c,
    NULL, 		// RUBY_T_MATCH    = 0x0d,
    // Rails raises a stack error on Complex and Rational. It also corrupts
    // something which causes a segfault on the next call. Oj will not mimic
    // that behavior.
    dump_as_string, 	// RUBY_T_COMPLEX  = 0x0e,
    dump_as_string, 	// RUBY_T_RATIONAL = 0x0f,
    NULL, 		// 0x10
    oj_dump_nil, 	// RUBY_T_NIL      = 0x11,
    oj_dump_true, 	// RUBY_T_TRUE     = 0x12,
    oj_dump_false,	// RUBY_T_FALSE    = 0x13,
    oj_dump_sym,	// RUBY_T_SYMBOL   = 0x14,
    oj_dump_fixnum,	// RUBY_T_FIXNUM   = 0x15,
};

static void
dump_rails_val(VALUE obj, int depth, Out out, bool as_ok) {
    int	type = rb_type(obj);

    if (Yes == out->opts->trace) {
	oj_trace("dump", obj, __FILE__, __LINE__, depth, TraceIn);
    }
    if (MAX_DEPTH < depth) {
	rb_raise(rb_eNoMemError, "Too deeply nested.\n");
    }
    if (0 < type && type <= RUBY_T_FIXNUM) {
	DumpFunc	f = rails_funcs[type];

	if (NULL != f) {
	    f(obj, depth, out, as_ok);
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

void
oj_dump_rails_val(VALUE obj, int depth, Out out) {
    out->opts->str_rx.head = NULL;
    out->opts->str_rx.tail = NULL;
    if (escape_html) {
	out->opts->escape_mode = JXEsc;
    } else {
	out->opts->escape_mode = RailsEsc;
    }
    dump_rails_val(obj, depth, out, true);
}

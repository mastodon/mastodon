/* obj_load.c
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <time.h>

#include "ruby.h"
#include "base64.h"
#include "ox.h"

static void	instruct(PInfo pi, const char *target, Attr attrs, const char *content);
static void	add_text(PInfo pi, char *text, int closed);
static void	add_element(PInfo pi, const char *ename, Attr attrs, int hasChildren);
static void	end_element(PInfo pi, const char *ename);

static VALUE	parse_time(const char *text, VALUE clas);
static VALUE	parse_xsd_time(const char *text, VALUE clas);
static VALUE	parse_double_time(const char *text, VALUE clas);
static VALUE	parse_regexp(const char *text);

static VALUE		get_var_sym_from_attrs(Attr a, void *encoding);
static VALUE		get_obj_from_attrs(Attr a, PInfo pi, VALUE base_class);
static VALUE		get_class_from_attrs(Attr a, PInfo pi, VALUE base_class);
static VALUE		classname2class(const char *name, PInfo pi, VALUE base_class);
static unsigned long	get_id_from_attrs(PInfo pi, Attr a);
static CircArray	circ_array_new(void);
static void		circ_array_free(CircArray ca);
static void		circ_array_set(CircArray ca, VALUE obj, unsigned long id);
static VALUE		circ_array_get(CircArray ca, unsigned long id);

static void		debug_stack(PInfo pi, const char *comment);
static void		fill_indent(PInfo pi, char *buf, size_t size);


struct _ParseCallbacks	 _ox_obj_callbacks = {
    instruct, /* instruct, */
    0, /* add_doctype, */
    0, /* add_comment, */
    0, /* add_cdata, */
    add_text,
    add_element,
    end_element,
    NULL,
};

ParseCallbacks	 ox_obj_callbacks = &_ox_obj_callbacks;

extern ParseCallbacks	ox_gen_callbacks;


inline static VALUE
str2sym(const char *str, void *encoding) {
    VALUE	sym;
    
#ifdef HAVE_RUBY_ENCODING_H
    if (0 != encoding) {
	VALUE	rstr = rb_str_new2(str);

	rb_enc_associate(rstr, (rb_encoding*)encoding);
	sym = rb_funcall(rstr, ox_to_sym_id, 0);
    } else {
	sym = ID2SYM(rb_intern(str));
    }
#else
    sym = ID2SYM(rb_intern(str));
#endif
    return sym;
}

inline static ID
name2var(const char *name, void *encoding) {
    VALUE	*slot;
    ID		var_id;

    if ('0' <= *name && *name <= '9') {
	var_id = INT2NUM(atoi(name));
    } else if (Qundef == (var_id = ox_cache_get(ox_attr_cache, name, &slot, 0))) {
#ifdef HAVE_RUBY_ENCODING_H
	if (0 != encoding) {
	    volatile VALUE	rstr = rb_str_new2(name);
	    volatile VALUE	sym;
	    
	    rb_enc_associate(rstr, (rb_encoding*)encoding);
	    sym = rb_funcall(rstr, ox_to_sym_id, 0);
	    // Needed for Ruby 2.2 to get around the GC of symbols
	    // created with to_sym which is needed for encoded symbols.
	    rb_ary_push(ox_sym_bank, sym);
	    var_id = SYM2ID(sym);
	} else {
	    var_id = rb_intern(name);
	}
#else
	var_id = rb_intern(name);
#endif
	*slot = var_id;
    }
    return var_id;
}

inline static VALUE
resolve_classname(VALUE mod, const char *class_name, Effort effort, VALUE base_class) {
    VALUE	clas;
    ID		ci = rb_intern(class_name);

    switch (effort) {
    case TolerantEffort:
	if (rb_const_defined_at(mod, ci)) {
	    clas = rb_const_get_at(mod, ci);
	} else {
	    clas = Qundef;
	}
	break;
    case AutoEffort:
	if (rb_const_defined_at(mod, ci)) {
	    clas = rb_const_get_at(mod, ci);
	} else {
	    clas = rb_define_class_under(mod, class_name, base_class);
	}
	break;
    case StrictEffort:
    default:
	/* raise an error if name is not defined */
	clas = rb_const_get_at(mod, ci);
	break;
    }
    return clas;
}

inline static VALUE
classname2obj(const char *name, PInfo pi, VALUE base_class) {
    VALUE   clas = classname2class(name, pi, base_class);
    
    if (Qundef == clas) {
	return Qnil;
    } else {
	return rb_obj_alloc(clas);
    }
}

#if HAS_RSTRUCT
inline static VALUE
structname2obj(const char *name) {
    VALUE	ost;
    const char	*s = name;

    for (; 1; s++) {
	if ('\0' == *s) {
	    s = name;
	    break;
	} else if (':' == *s) {
	    s += 2;
	    break;
	}
    }
    ost = rb_const_get(ox_struct_class, rb_intern(s));
    /* use encoding as the indicator for Ruby 1.8.7 or 1.9.x */
#if HAS_ENCODING_SUPPORT
    return rb_struct_alloc_noinit(ost);
#elif HAS_PRIVATE_ENCODING
    return rb_struct_alloc_noinit(ost);
#else
    return rb_struct_new(ost);
#endif
}
#endif

inline static VALUE
parse_ulong(const char *s, PInfo pi) {
    unsigned long	n = 0;

    for (; '\0' != *s; s++) {
	if ('0' <= *s && *s <= '9') {
	    n = n * 10 + (*s - '0');
	} else {
	    set_error(&pi->err, "Invalid number for a julian day", pi->str, pi->s);
	    return Qundef;
	}
    }
    return ULONG2NUM(n);
}

/* 2010-07-09T10:47:45.895826162+09:00 */
inline static VALUE
parse_time(const char *text, VALUE clas) {
    VALUE	t;

    if (Qnil == (t = parse_double_time(text, clas)) &&
	Qnil == (t = parse_xsd_time(text, clas))) {
	VALUE	    args[1];

	/*printf("**** time parse\n"); */
	*args = rb_str_new2(text);
	t = rb_funcall2(ox_time_class, ox_parse_id, 1, args);
    }
    return t;
}

static VALUE
classname2class(const char *name, PInfo pi, VALUE base_class) {
    VALUE	*slot;
    VALUE	clas;
	    
    if (Qundef == (clas = ox_cache_get(ox_class_cache, name, &slot, 0))) {
	char		class_name[1024];
	char		*s;
	const char	*n = name;

	clas = rb_cObject;
	for (s = class_name; '\0' != *n; n++) {
	    if (':' == *n) {
		*s = '\0';
		n++;
		if (':' != *n) {
		    set_error(&pi->err, "Invalid classname, expected another ':'", pi->str, pi->s);
		    return Qundef;
		}
		if (Qundef == (clas = resolve_classname(clas, class_name, pi->options->effort, base_class))) {
		    return Qundef;
		}
		s = class_name;
	    } else {
		*s++ = *n;
	    }
	}
	*s = '\0';
	if (Qundef != (clas = resolve_classname(clas, class_name, pi->options->effort, base_class))) {
	    *slot = clas;
	}
    }
    return clas;
}

static VALUE
get_var_sym_from_attrs(Attr a, void *encoding) {
    for (; 0 != a->name; a++) {
	if ('a' == *a->name && '\0' == *(a->name + 1)) {
	    return name2var(a->value, encoding);
	}
    }
    return Qundef;
}

static VALUE
get_obj_from_attrs(Attr a, PInfo pi, VALUE base_class) {
    for (; 0 != a->name; a++) {
	if ('c' == *a->name && '\0' == *(a->name + 1)) {
	    return classname2obj(a->value, pi, base_class);
	}
    }
    return Qundef;
}

#if HAS_RSTRUCT
static VALUE
get_struct_from_attrs(Attr a) {
    for (; 0 != a->name; a++) {
	if ('c' == *a->name && '\0' == *(a->name + 1)) {
	    return structname2obj(a->value);
	}
    }
    return Qundef;
}
#endif

static VALUE
get_class_from_attrs(Attr a, PInfo pi, VALUE base_class) {
    for (; 0 != a->name; a++) {
	if ('c' == *a->name && '\0' == *(a->name + 1)) {
	    return classname2class(a->value, pi, base_class);
	}
    }
    return Qundef;
}

static unsigned long
get_id_from_attrs(PInfo pi, Attr a) {
    for (; 0 != a->name; a++) {
	if ('i' == *a->name && '\0' == *(a->name + 1)) {
	    unsigned long	id = 0;
	    const char		*text = a->value;
	    char		c;
	    
	    for (; '\0' != *text; text++) {
		c = *text;
		if ('0' <= c && c <= '9') {
		    id = id * 10 + (c - '0');
		} else {
		    set_error(&pi->err, "bad number format", pi->str, pi->s);
		    return 0;
		}
	    }
	    return id;
	}
    }
    return 0;
}

static CircArray
circ_array_new() {
    CircArray	ca;
    
    ca = ALLOC(struct _CircArray);
    ca->objs = ca->obj_array;
    ca->size = sizeof(ca->obj_array) / sizeof(VALUE);
    ca->cnt = 0;
    
    return ca;
}

static void
circ_array_free(CircArray ca) {
    if (ca->objs != ca->obj_array) {
	xfree(ca->objs);
    }
    xfree(ca);
}

static void
circ_array_set(CircArray ca, VALUE obj, unsigned long id) {
    if (0 < id) {
	unsigned long	i;

	if (ca->size < id) {
	    unsigned long	cnt = id + 512;

	    if (ca->objs == ca->obj_array) {
		ca->objs = ALLOC_N(VALUE, cnt);
		memcpy(ca->objs, ca->obj_array, sizeof(VALUE) * ca->cnt);
	    } else {
		REALLOC_N(ca->objs, VALUE, cnt);
	    }
	    ca->size = cnt;
	}
	id--;
	for (i = ca->cnt; i < id; i++) {
	    ca->objs[i] = Qundef;
	}
	ca->objs[id] = obj;
	if (ca->cnt <= id) {
	    ca->cnt = id + 1;
	}
    }
}

static VALUE
circ_array_get(CircArray ca, unsigned long id) {
    VALUE	obj = Qundef;

    if (id <= ca->cnt) {
	obj = ca->objs[id - 1];
    }
    return obj;
}

static VALUE
parse_regexp(const char *text) {
    const char	*te;
    int		options = 0;
	    
    te = text + strlen(text) - 1;
#if HAS_ONIG
    for (; text < te && '/' != *te; te--) {
	switch (*te) {
	case 'i':	options |= ONIG_OPTION_IGNORECASE;	break;
	case 'm':	options |= ONIG_OPTION_MULTILINE;	break;
	case 'x':	options |= ONIG_OPTION_EXTEND;		break;
	default:						break;
	}
    }
#endif
    return rb_reg_new(text + 1, te - text - 1, options);
}

static void
instruct(PInfo pi, const char *target, Attr attrs, const char *content) {
    if (0 == strcmp("xml", target)) {
#if HAS_ENCODING_SUPPORT
	for (; 0 != attrs->name; attrs++) {
	    if (0 == strcmp("encoding", attrs->name)) {
		pi->options->rb_enc = rb_enc_find(attrs->value);
	    }
	}
#elif HAS_PRIVATE_ENCODING
	for (; 0 != attrs->name; attrs++) {
	    if (0 == strcmp("encoding", attrs->name)) {
		pi->options->rb_enc = rb_str_new2(attrs->value);
	    }
	}
#endif
    }
}

static void
add_text(PInfo pi, char *text, int closed) {
    Helper	h = helper_stack_peek(&pi->helpers);

    if (!closed) {
	set_error(&pi->err, "Text not closed", pi->str, pi->s);
	return;
    }
    if (0 == h) {
	set_error(&pi->err, "Unexpected text", pi->str, pi->s);
	return;
    }
    if (DEBUG <= pi->options->trace) {
	char	indent[128];

	fill_indent(pi, indent, sizeof(indent));
	printf("%s '%s' to type %c\n", indent, text, h->type);
    }
    switch (h->type) {
    case NoCode:
    case StringCode:
	h->obj = rb_str_new2(text);
#if HAS_ENCODING_SUPPORT
	if (0 != pi->options->rb_enc) {
	    rb_enc_associate(h->obj, pi->options->rb_enc);
	}
#elif HAS_PRIVATE_ENCODING
	if (Qnil != pi->options->rb_enc) {
	    rb_funcall(h->obj, ox_force_encoding_id, 1, pi->options->rb_enc);
	}
#endif
	if (0 != pi->circ_array) {
	    circ_array_set(pi->circ_array, h->obj, (unsigned long)pi->id);
	}
	break;
    case FixnumCode:
    {
	long	n = 0;
	char	c;
	int	neg = 0;

	if ('-' == *text) {
	    neg = 1;
	    text++;
	}
	for (; '\0' != *text; text++) {
	    c = *text;
	    if ('0' <= c && c <= '9') {
		n = n * 10 + (c - '0');
	    } else {
		set_error(&pi->err, "bad number format", pi->str, pi->s);
		return;
	    }
	}
	if (neg) {
	    n = -n;
	}
	h->obj = LONG2NUM(n);
	break;
    }
    case FloatCode:
	h->obj = rb_float_new(strtod(text, 0));
	break;
    case SymbolCode:
    {
	VALUE	sym;
	VALUE	*slot;

	if (Qundef == (sym = ox_cache_get(ox_symbol_cache, text, &slot, 0))) {
	    sym = str2sym(text, (void*)pi->options->rb_enc);
	    // Needed for Ruby 2.2 to get around the GC of symbols created with
	    // to_sym which is needed for encoded symbols.
	    rb_ary_push(ox_sym_bank, sym);
	    *slot = sym;
	}
	h->obj = sym;
	break;
    }
    case DateCode:
    {
	VALUE	args[1];

	if (Qundef == (*args = parse_ulong(text, pi))) {
	    return;
	}
	h->obj = rb_funcall2(ox_date_class, ox_jd_id, 1, args);
	break;
    }
    case TimeCode:
	h->obj = parse_time(text, ox_time_class);
	break;
    case String64Code:
    {
	unsigned long	str_size = b64_orig_size(text);
	VALUE		v;
	char		*str = ALLOCA_N(char, str_size + 1);
	
	from_base64(text, (uchar*)str);
	v = rb_str_new(str, str_size);
#if HAS_ENCODING_SUPPORT
	if (0 != pi->options->rb_enc) {
	    rb_enc_associate(v, pi->options->rb_enc);
	}
#elif HAS_PRIVATE_ENCODING
	if (0 != pi->options->rb_enc) {
	    rb_funcall(v, ox_force_encoding_id, 1, pi->options->rb_enc);
	}
#endif
	if (0 != pi->circ_array) {
	    circ_array_set(pi->circ_array, v, (unsigned long)h->obj);
	}
	h->obj = v;
	break;
    }
    case Symbol64Code:
    {
	VALUE		sym;
	VALUE		*slot;
	unsigned long	str_size = b64_orig_size(text);
	char		*str = ALLOCA_N(char, str_size + 1);
	
	from_base64(text, (uchar*)str);
	if (Qundef == (sym = ox_cache_get(ox_symbol_cache, str, &slot, 0))) {
	    sym = str2sym(str, (void*)pi->options->rb_enc);
	    // Needed for Ruby 2.2 to get around the GC of symbols created with
	    // to_sym which is needed for encoded symbols.
	    rb_ary_push(ox_sym_bank, sym);
	    *slot = sym;
	}
	h->obj = sym;
	break;
    }
    case RegexpCode:
	if ('/' == *text) {
	    h->obj = parse_regexp(text);
	} else {
	    unsigned long	str_size = b64_orig_size(text);
	    char		*str = ALLOCA_N(char, str_size + 1);
	
	    from_base64(text, (uchar*)str);
	    h->obj = parse_regexp(str);
	}
	break;
    case BignumCode:
	h->obj = rb_cstr_to_inum(text, 10, 1);
	break;
    case BigDecimalCode:
#if HAS_BIGDECIMAL
	h->obj = rb_funcall(ox_bigdecimal_class, ox_new_id, 1, rb_str_new2(text));
#else
	h->obj = Qnil;
#endif
	break;
    default:
	h->obj = Qnil;
	break;
    }
}

static void
add_element(PInfo pi, const char *ename, Attr attrs, int hasChildren) {
    Attr		a;
    Helper		h;
    unsigned long	id;

    if (TRACE <= pi->options->trace) {
	char	buf[1024];
	char	indent[128];
	char	*s = buf;
	char	*end = buf + sizeof(buf) - 2;

	s += snprintf(s, end - s, " <%s%s", (hasChildren) ? "" : "/", ename);
	for (a = attrs; 0 != a->name; a++) {
	    s += snprintf(s, end - s, " %s=%s", a->name, a->value);
	}
	*s++ = '>';
	*s++ = '\0';
	if (DEBUG <= pi->options->trace) {
	    printf("===== add element stack(%d) =====\n", helper_stack_depth(&pi->helpers));
	    debug_stack(pi, buf);
	} else {
	    fill_indent(pi, indent, sizeof(indent));
	    printf("%s%s\n", indent, buf);
	}
    }
    if (helper_stack_empty(&pi->helpers)) { /* top level object */
	if (0 != (id = get_id_from_attrs(pi, attrs))) {
	    pi->circ_array = circ_array_new();
	}
    }
    if ('\0' != ename[1]) {
	set_error(&pi->err, "Invalid element name", pi->str, pi->s);
	return;
    }
    h = helper_stack_push(&pi->helpers, get_var_sym_from_attrs(attrs, (void*)pi->options->rb_enc), Qundef, *ename);
    switch (h->type) {
    case NilClassCode:
	h->obj = Qnil;
	break;
    case TrueClassCode:
	h->obj = Qtrue;
	break;
    case FalseClassCode:
	h->obj = Qfalse;
	break;
    case StringCode:
	/* h->obj will be replaced by add_text if it is called */
	h->obj = ox_empty_string;
	if (0 != pi->circ_array) {
	    pi->id = get_id_from_attrs(pi, attrs);
	    circ_array_set(pi->circ_array, h->obj, pi->id);
	}
	break;
    case FixnumCode:
    case FloatCode:
    case SymbolCode:
    case Symbol64Code:
    case RegexpCode:
    case BignumCode:
    case BigDecimalCode:
    case ComplexCode:
    case DateCode:
    case TimeCode:
    case RationalCode: /* sub elements read next */
	/* value will be read in the following add_text */
	h->obj = Qundef;
	break;
    case String64Code:
	h->obj = Qundef;
	if (0 != pi->circ_array) {
	    pi->id = get_id_from_attrs(pi, attrs);
	}
	break;
    case ArrayCode:
	h->obj = rb_ary_new();
	if (0 != pi->circ_array) {
	    circ_array_set(pi->circ_array, h->obj, get_id_from_attrs(pi, attrs));
	}
	break;
    case HashCode:
	h->obj = rb_hash_new();
	if (0 != pi->circ_array) {
	    circ_array_set(pi->circ_array, h->obj, get_id_from_attrs(pi, attrs));
	}
	break;
    case RangeCode:
	h->obj = rb_range_new(ox_zero_fixnum, ox_zero_fixnum, Qfalse);
	break;
    case RawCode:
	if (hasChildren) {
	    h->obj = ox_parse(pi->s, ox_gen_callbacks, &pi->s, pi->options, &pi->err);
	    if (0 != pi->circ_array) {
		circ_array_set(pi->circ_array, h->obj, get_id_from_attrs(pi, attrs));
	    }
	} else {
	    h->obj = Qnil;
	}
	break;
    case ExceptionCode:
	if (Qundef == (h->obj = get_obj_from_attrs(attrs, pi, rb_eException))) {
	    return;
	}
	if (0 != pi->circ_array && Qnil != h->obj) {
	    circ_array_set(pi->circ_array, h->obj, get_id_from_attrs(pi, attrs));
	}
	break;
    case ObjectCode:
	if (Qundef == (h->obj = get_obj_from_attrs(attrs, pi, ox_bag_clas))) {
	    return;
	}
	if (0 != pi->circ_array && Qnil != h->obj) {
	    circ_array_set(pi->circ_array, h->obj, get_id_from_attrs(pi, attrs));
	}
	break;
    case StructCode:
#if HAS_RSTRUCT
	h->obj = get_struct_from_attrs(attrs);
	if (0 != pi->circ_array) {
	    circ_array_set(pi->circ_array, h->obj, get_id_from_attrs(pi, attrs));
	}
#else
	set_error(&pi->err, "Ruby structs not supported with this verion of Ruby", pi->str, pi->s);
	return;
#endif
	break;
    case ClassCode:
	if (Qundef == (h->obj = get_class_from_attrs(attrs, pi, ox_bag_clas))) {
	    return;
	}
	break;
    case RefCode:
	h->obj = Qundef;
	if (0 != pi->circ_array) {
	    h->obj = circ_array_get(pi->circ_array, get_id_from_attrs(pi, attrs));
	}
	if (Qundef == h->obj) {
	    set_error(&pi->err, "Invalid circular reference", pi->str, pi->s);
	    return;
	}
	break;
    default:
	set_error(&pi->err, "Invalid element name", pi->str, pi->s);
	return;
	break;
    }
    if (DEBUG <= pi->options->trace) {
	debug_stack(pi, "   -----------");
    }
}

static void
end_element(PInfo pi, const char *ename) {
    if (TRACE <= pi->options->trace) {
	char	indent[128];
	
	if (DEBUG <= pi->options->trace) {
	    char    buf[1024];

	    printf("===== end element stack(%d) =====\n", helper_stack_depth(&pi->helpers));
	    snprintf(buf, sizeof(buf) - 1, "</%s>", ename);
	    debug_stack(pi, buf);
	} else {
	    fill_indent(pi, indent, sizeof(indent));
	    printf("%s</%s>\n", indent, ename);
	}
    }
    if (!helper_stack_empty(&pi->helpers)) {
	Helper	h = helper_stack_pop(&pi->helpers);
	Helper	ph = helper_stack_peek(&pi->helpers);

	if (ox_empty_string == h->obj) {
	    /* special catch for empty strings */
	    h->obj = rb_str_new2("");
	}
	pi->obj = h->obj;
	if (0 != ph) {
	    switch (ph->type) {
	    case ArrayCode:
		rb_ary_push(ph->obj, h->obj);
		break;
	    case ExceptionCode:
	    case ObjectCode:
		if (Qnil != ph->obj) {
		    rb_ivar_set(ph->obj, h->var, h->obj);
		}
		break;
	    case StructCode:
#if HAS_RSTRUCT
		rb_struct_aset(ph->obj, h->var, h->obj);
#else
		set_error(&pi->err, "Ruby structs not supported with this verion of Ruby", pi->str, pi->s);
		return;
#endif
		break;
	    case HashCode:
		// put back h
		helper_stack_push(&pi->helpers, h->var, h->obj, KeyCode);
		break;
	    case RangeCode:
#if HAS_RSTRUCT
		if (ox_beg_id == h->var) {
		    RSTRUCT_SET(ph->obj, 0, h->obj);
		} else if (ox_end_id == h->var) {
		    RSTRUCT_SET(ph->obj, 1, h->obj);
		} else if (ox_excl_id == h->var) {
		    RSTRUCT_SET(ph->obj, 2, h->obj);
		} else {
		    set_error(&pi->err, "Invalid range attribute", pi->str, pi->s);
		    return;
		}
#else
		set_error(&pi->err, "Ruby structs not supported with this verion of Ruby", pi->str, pi->s);
		return;
#endif
		break;
	    case KeyCode:
		{
		    Helper	gh;

		    helper_stack_pop(&pi->helpers);
		    if (NULL == (gh = helper_stack_peek(&pi->helpers))) {
			set_error(&pi->err, "Corrupt parse stack, container is wrong type", pi->str, pi->s);
			return;
		    }
		    rb_hash_aset(gh->obj, ph->obj, h->obj);
		}
		break;
	    case ComplexCode:
#ifdef T_COMPLEX
		if (Qundef == ph->obj) {
		    ph->obj = h->obj;
		} else {
		    ph->obj = rb_complex_new(ph->obj, h->obj);
		}
#else
		set_error(&pi->err, "Complex Objects not implemented in Ruby 1.8.7", pi->str, pi->s);
		return;
#endif
		break;
	    case RationalCode:
#ifdef T_RATIONAL
		if (Qundef == ph->obj) {
		    ph->obj = h->obj;
		} else {
#ifdef RUBINIUS_RUBY
		    ph->obj = rb_Rational(ph->obj, h->obj);
#else
		    ph->obj = rb_rational_new(ph->obj, h->obj);
#endif
		}
#else
		set_error(&pi->err, "Rational Objects not implemented in Ruby 1.8.7", pi->str, pi->s);
		return;
#endif
		break;
	    default:
		set_error(&pi->err, "Corrupt parse stack, container is wrong type", pi->str, pi->s);
		return;
		break;
	    }
	}
    }
    if (0 != pi->circ_array && helper_stack_empty(&pi->helpers)) {
	circ_array_free(pi->circ_array);
	pi->circ_array = 0;
    }
    if (DEBUG <= pi->options->trace) {
	debug_stack(pi, "   ----------");
    }
}

static VALUE
parse_double_time(const char *text, VALUE clas) {
    long	v = 0;
    long	v2 = 0;
    const char	*dot = 0;
    char	c;
    
    for (; '.' != *text; text++) {
	c = *text;
	if (c < '0' || '9' < c) {
	    return Qnil;
	}
	v = 10 * v + (long)(c - '0');
    }
    dot = text++;
    for (; '\0' != *text && text - dot <= 6; text++) {
	c = *text;
	if (c < '0' || '9' < c) {
	    return Qnil;
	}
	v2 = 10 * v2 + (long)(c - '0');
    }
    for (; text - dot <= 9; text++) {
	v2 *= 10;
    }
#if HAS_NANO_TIME
    return rb_time_nano_new(v, v2);
#else
    return rb_time_new(v, v2 / 1000);
#endif
}

typedef struct _Tp {
    int		cnt;
    char	end;
    char	alt;
} *Tp;

static VALUE
parse_xsd_time(const char *text, VALUE clas) {
    long	cargs[10];
    long	*cp = cargs;
    long	v;
    int		i;
    char	c;
    struct _Tp	tpa[10] = { { 4, '-', '-' },
			   { 2, '-', '-' },
			   { 2, 'T', 'T' },
			   { 2, ':', ':' },
			   { 2, ':', ':' },
			   { 2, '.', '.' },
			   { 9, '+', '-' },
			   { 2, ':', ':' },
			   { 2, '\0', '\0' },
			   { 0, '\0', '\0' } };
    Tp		tp = tpa;
    struct tm	tm;

    for (; 0 != tp->cnt; tp++) {
	for (i = tp->cnt, v = 0; 0 < i ; text++, i--) {
	    c = *text;
	    if (c < '0' || '9' < c) {
		if (tp->end == c || tp->alt == c) {
		    break;
		}
		return Qnil;
	    }
	    v = 10 * v + (long)(c - '0');
	}
	c = *text++;
	if (tp->end != c && tp->alt != c) {
	    return Qnil;
	}
	*cp++ = v;
    }
    tm.tm_year = (int)cargs[0] - 1900;
    tm.tm_mon = (int)cargs[1] - 1;
    tm.tm_mday = (int)cargs[2];
    tm.tm_hour = (int)cargs[3];
    tm.tm_min = (int)cargs[4];
    tm.tm_sec = (int)cargs[5];
#if HAS_NANO_TIME
    return rb_time_nano_new(mktime(&tm), cargs[6]);
#else
    return rb_time_new(mktime(&tm), cargs[6] / 1000);
#endif
}

/* debug functions */
static void
fill_indent(PInfo pi, char *buf, size_t size) {
    size_t	cnt;

    if (0 < (cnt = helper_stack_depth(&pi->helpers))) {
	cnt *= 2;
	if (size < cnt + 1) {
	    cnt = size - 1;
	}
	memset(buf, ' ', cnt);
	buf += cnt;
    }
    *buf = '\0';
}

static void
debug_stack(PInfo pi, const char *comment) {
    char	indent[128];
    Helper	h;

    fill_indent(pi, indent, sizeof(indent));
    printf("%s%s\n", indent, comment);
    if (!helper_stack_empty(&pi->helpers)) {
	for (h = pi->helpers.head; h < pi->helpers.tail; h++) {
	    const char	*clas = "---";
	    const char	*key = "---";

	    if (Qundef != h->obj) {
		VALUE	c =  rb_obj_class(h->obj);

		clas = rb_class2name(c);
	    }
	    if (Qundef != h->var) {
		if (HashCode == h->type) {
		    VALUE	v;
		    
		    v = rb_funcall2(h->var, rb_intern("to_s"), 0, 0);
		    key = StringValuePtr(v);
		} else if (ObjectCode == (h - 1)->type || ExceptionCode == (h - 1)->type || RangeCode == (h - 1)->type || StructCode == (h - 1)->type) {
		    key = rb_id2name(h->var);
		} else {
		    printf("%s*** corrupt stack ***\n", indent);
		}
	    }
	    printf("%s [%c] %s : %s\n", indent, h->type, clas, key);
	}
    }
}

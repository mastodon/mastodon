/* dump.c
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#include <stdlib.h>
#include <errno.h>
#include <time.h>
#include <stdio.h>
#include <string.h>

#include "base64.h"
#include "cache8.h"
#include "ox.h"

#define USE_B64	0
#define MAX_DEPTH 1000

typedef unsigned long	ulong;

typedef struct _Str {
    const char	*str;
    size_t	len;
} *Str;

typedef struct _Element {
    struct _Str		clas;
    struct _Str		attr;
    unsigned long	id;
    int			indent; /* < 0 indicates no \n */
    int			closed;
    char		type;
} *Element;

typedef struct _Out {
    void		(*w_start)(struct _Out *out, Element e);
    void		(*w_end)(struct _Out *out, Element e);
    void		(*w_time)(struct _Out *out, VALUE obj);
    char		*buf;
    char		*end;
    char		*cur;
    Cache8		circ_cache;
    unsigned long	circ_cnt;
    int			indent;
    int			depth; /* used by dumpHash */
    Options		opts;
    VALUE		obj;
} *Out;

static void	dump_obj_to_xml(VALUE obj, Options copts, Out out);

static void	dump_first_obj(VALUE obj, Out out);
static void	dump_obj(ID aid, VALUE obj, int depth, Out out);
static void	dump_gen_doc(VALUE obj, int depth, Out out);
static void	dump_gen_element(VALUE obj, int depth, Out out);
static void	dump_gen_instruct(VALUE obj, int depth, Out out);
static int	dump_gen_attr(VALUE key, VALUE value, Out out);
static int	dump_gen_nodes(VALUE obj, int depth, Out out);
static void	dump_gen_val_node(VALUE obj, int depth,
				  const char *pre, size_t plen,
				  const char *suf, size_t slen, Out out);

static void	dump_start(Out out, Element e);
static void	dump_end(Out out, Element e);

static void	grow(Out out, size_t len);

static void	dump_value(Out out, const char *value, size_t size);
static void	dump_str_value(Out out, const char *value, size_t size, const char *table);
static int	dump_var(ID key, VALUE value, Out out);
static void	dump_num(Out out, VALUE obj);
static void	dump_date(Out out, VALUE obj);
static void	dump_time_thin(Out out, VALUE obj);
static void	dump_time_xsd(Out out, VALUE obj);
static int	dump_hash(VALUE key, VALUE value, Out out);

static int	is_xml_friendly(const uchar *str, int len, const char *table);

static const char	hex_chars[17] = "0123456789abcdef";

// The : character is equivalent to 10. Used for replacement characters up to 10
// characters long such as '&#x10FFFF;'.
static const char	xml_friendly_chars[257] = "\
:::::::::11::1::::::::::::::::::\
11611156111111111111111111114141\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111";

static const char	xml_quote_chars[257] = "\
:::::::::11::1::::::::::::::::::\
11611151111111111111111111114141\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111";

static const char	xml_element_chars[257] = "\
:::::::::11::1::::::::::::::::::\
11111151111111111111111111114141\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111";

inline static int
is_xml_friendly(const uchar *str, int len, const char *table) {
    for (; 0 < len; str++, len--) {
	if ('1' != table[*str]) {
	    return 0;
	}
    }
    return 1;
}

inline static size_t
xml_str_len(const uchar *str, size_t len, const char *table) {
    size_t	size = 0;

    for (; 0 < len; str++, len--) {
	size += xml_friendly_chars[*str];
    }
    return size - len * (size_t)'0';
}

inline static void
dump_hex(uchar c, Out out) {
    uchar	d = (c >> 4) & 0x0F;

    *out->cur++ = hex_chars[d];
    d = c & 0x0F;
    *out->cur++ = hex_chars[d];
}

static Type
obj_class_code(VALUE obj) {
    VALUE	clas = rb_obj_class(obj);

    switch (rb_type(obj)) {
    case T_NIL:		   return NilClassCode;
    case T_ARRAY:	   return ArrayCode;
    case T_HASH:	   return HashCode;
    case T_TRUE:	   return TrueClassCode;
    case T_FALSE:	   return FalseClassCode;
    case T_FIXNUM:	   return FixnumCode;
    case T_FLOAT:	   return FloatCode;
    case T_STRING:	   return (is_xml_friendly((uchar*)StringValuePtr(obj), (int)RSTRING_LEN(obj), xml_element_chars)) ? StringCode : String64Code;
    case T_SYMBOL:
    {
	const char	*sym = rb_id2name(SYM2ID(obj));

	return (is_xml_friendly((uchar*)sym, (int)strlen(sym), xml_element_chars)) ? SymbolCode : Symbol64Code;
    }
    case T_DATA:	   return (rb_cTime == clas) ? TimeCode : ((ox_date_class == clas) ? DateCode : 0);
    case T_STRUCT:	   return (rb_cRange == clas) ? RangeCode : StructCode;
    case T_OBJECT:	   return (ox_document_clas == clas || ox_element_clas == clas) ? RawCode : ObjectCode;
    case T_REGEXP:	   return RegexpCode;
    case T_BIGNUM:	   return BignumCode;
#ifdef T_COMPLEX
    case T_COMPLEX:	   return ComplexCode;
#endif
#ifdef T_RATIONAL
    case T_RATIONAL:	   return RationalCode;
#endif
    case T_CLASS:	   return ClassCode;
    default:			return 0;
    }
}

inline static void
fill_indent(Out out, int cnt) {
    if (0 <= cnt) {
	*out->cur++ = '\n';
	if (0 < out->opts->margin_len) {
	    memcpy(out->cur, out->opts->margin, out->opts->margin_len);
	    out->cur += out->opts->margin_len;
	}
	for (; 0 < cnt; cnt--) {
	    *out->cur++ = ' ';
	}
    }
}

inline static void
fill_value(Out out, const char *value, size_t len) {
    if (6 < len) {
	memcpy(out->cur, value, len);
	out->cur += len;
    } else {
	for (; '\0' != *value; value++) {
	    *out->cur++ = *value;
	}
    }
}

inline static void
fill_attr(Out out, char name, const char *value, size_t len) {
    *out->cur++ = ' ';
    *out->cur++ = name;
    *out->cur++ = '=';
    *out->cur++ = '"';
    if (6 < len) {
	memcpy(out->cur, value, len);
	out->cur += len;
    } else {
	for (; '\0' != *value; value++) {
	    *out->cur++ = *value;
	}
    }
    *out->cur++ = '"';
}

inline static const char*
ulong2str(ulong num, char *end) {
    char	*b;

    *end-- = '\0';
    for (b = end; 0 < num || b == end; num /= 10, b--) {
	*b = (num % 10) + '0';
    }
    b++;

    return b;
}

static int
check_circular(Out out, VALUE obj, Element e) {
    slot_t	*slot;
    slot_t	id;
    int		result;
    
    if (0 == (id = ox_cache8_get(out->circ_cache, obj, &slot))) {
	out->circ_cnt++;
	id = out->circ_cnt;
	*slot = id;
	e->id = id;
	result = 0;
    } else {
	e->type = RefCode;  e->clas.len = 0;  e->clas.str = 0;
	e->closed = 1;
	e->id = id;
	out->w_start(out, e);
	result = 1;
    }
    return result;
}

static void
grow(Out out, size_t len) {
    size_t  size = out->end - out->buf;
    long    pos = out->cur - out->buf;
	
    size *= 2;
    if (size <= len * 2 + pos) {
	size += len;
    }
    REALLOC_N(out->buf, char, size + 10); /* 10 extra for terminator character plus extra (paranoid) */
    out->end = out->buf + size;
    out->cur = out->buf + pos;
}

static void
dump_start(Out out, Element e) {
    size_t	size = e->indent + 4 + out->opts->margin_len;

    if (0 < e->attr.len) { /* a="attr" */
	size += e->attr.len + 5;
    }
    if (0 < e->clas.len) { /* c="class" */
	size += e->clas.len + 5;
    }
    if (0 < e->id) { /* i="id" */
	size += 24; /* over estimate, 19 digits */
    }
    if (out->end - out->cur <= (long)size) {
	grow(out, size);
    }
    if (out->buf + out->opts->margin_len < out->cur) {
	fill_indent(out, e->indent);
    }
    *out->cur++ = '<';
    *out->cur++ = e->type;
    if (0 < e->attr.len) {
	fill_attr(out, 'a', e->attr.str, e->attr.len);
    }
    if ((ObjectCode == e->type || ExceptionCode == e->type || StructCode == e->type || ClassCode == e->type) && 0 < e->clas.len) {
	fill_attr(out, 'c', e->clas.str, e->clas.len);
    }
    if (0 < e->id) {
	char		buf[32];
	char		*end = buf + sizeof(buf) - 1;
	const char	*s = ulong2str(e->id, end);
	
	fill_attr(out, 'i', s, end - s);
    }
    if (e->closed) {
	*out->cur++ = '/';
    }
    *out->cur++ = '>';
    *out->cur = '\0';
}

static void
dump_end(Out out, Element e) {
    size_t	size = e->indent + 5 + out->opts->margin_len;

    if (out->end - out->cur <= (long)size) {
	grow(out, size);
    }
    fill_indent(out, e->indent);
    *out->cur++ = '<';
    *out->cur++ = '/';
    *out->cur++ = e->type;
    *out->cur++ = '>';
    *out->cur = '\0';
}

inline static void
dump_value(Out out, const char *value, size_t size) {
    if (out->end - out->cur <= (long)size) {
	grow(out, size);
    }
    if (6 < size) {
	memcpy(out->cur, value, size);
	out->cur += size;
    } else {
	for (; '\0' != *value; value++) {
	    *out->cur++ = *value;
	}
    }
    *out->cur = '\0';
}

inline static void
dump_str_value(Out out, const char *value, size_t size, const char *table) {
    size_t	xsize = xml_str_len((const uchar*)value, size, table);
    
    if (out->end - out->cur <= (long)xsize) {
	grow(out, xsize);
    }
    for (; '\0' != *value; value++) {
	if ('1' == table[(uchar)*value]) {
	    *out->cur++ = *value;
	} else {
	    switch (*value) {
	    case '"':
		*out->cur++ = '&';
		*out->cur++ = 'q';
		*out->cur++ = 'u';
		*out->cur++ = 'o';
		*out->cur++ = 't';
		*out->cur++ = ';';
		break;
	    case '&':
		*out->cur++ = '&';
		*out->cur++ = 'a';
		*out->cur++ = 'm';
		*out->cur++ = 'p';
		*out->cur++ = ';';
		break;
	    case '\'':
		*out->cur++ = '&';
		*out->cur++ = 'a';
		*out->cur++ = 'p';
		*out->cur++ = 'o';
		*out->cur++ = 's';
		*out->cur++ = ';';
		break;
	    case '<':
		*out->cur++ = '&';
		*out->cur++ = 'l';
		*out->cur++ = 't';
		*out->cur++ = ';';
		break;
	    case '>':
		*out->cur++ = '&';
		*out->cur++ = 'g';
		*out->cur++ = 't';
		*out->cur++ = ';';
		break;
	    default:
		// Must be one of the invalid characters.
		if (StrictEffort == out->opts->effort) {
		    rb_raise(rb_eSyntaxError, "'\\#x%02x' is not a valid XML character.", *value);
		}
		if (Yes == out->opts->allow_invalid) {
		    *out->cur++ = '&';
		    *out->cur++ = '#';
		    *out->cur++ = 'x';
		    *out->cur++ = '0';
		    *out->cur++ = '0';
		    dump_hex(*value, out);
		    *out->cur++ = ';';
		} else if ('\0' != *out->opts->inv_repl) {
		    // If the empty string then ignore. The first character of
		    // the replacement is the length.
		    memcpy(out->cur, out->opts->inv_repl + 1, (size_t)*out->opts->inv_repl);
		    out->cur += *out->opts->inv_repl;
		}
		break;
	    }
	}
    }
    *out->cur = '\0';
}

inline static void
dump_num(Out out, VALUE obj) {
    char	buf[32];
    char	*b = buf + sizeof(buf) - 1;
    long	num = NUM2LONG(obj);
    int		neg = 0;

    if (0 > num) {
	neg = 1;
	num = -num;
    }
    *b-- = '\0';
    if (0 < num) {
	for (; 0 < num; num /= 10, b--) {
	    *b = (num % 10) + '0';
	}
	if (neg) {
	    *b = '-';
	} else {
	    b++;
	}
    } else {
	*b = '0';
    }
    if (out->end - out->cur <= (long)(sizeof(buf) - (b - buf))) {
	grow(out, sizeof(buf) - (b - buf));
    }
    for (; '\0' != *b; b++) {
	*out->cur++ = *b;
    }
    *out->cur = '\0';
}

static void
dump_time_thin(Out out, VALUE obj) {
    char		buf[64];
    char		*b = buf + sizeof(buf) - 1;
#if HAS_RB_TIME_TIMESPEC
    struct timespec	ts = rb_time_timespec(obj);
    time_t		sec = ts.tv_sec;
    long		nsec = ts.tv_nsec;
#else
    time_t		sec = NUM2LONG(rb_funcall2(obj, ox_tv_sec_id, 0, 0));
#if HAS_NANO_TIME
    long		nsec = NUM2LONG(rb_funcall2(obj, ox_tv_nsec_id, 0, 0));
#else
    long		nsec = NUM2LONG(rb_funcall2(obj, ox_tv_usec_id, 0, 0)) * 1000;
#endif
#endif
    char		*dot = b - 10;
    long		size;

    *b-- = '\0';
    for (; dot < b; b--, nsec /= 10) {
	*b = '0' + (nsec % 10);
    }
    *b-- = '.';
    for (; 0 < sec; b--, sec /= 10) {
	*b = '0' + (sec % 10);
    }
    b++;
    size = sizeof(buf) - (b - buf) - 1;
    if (out->end - out->cur <= size) {
	grow(out, size);
    }
    memcpy(out->cur, b, size);
    out->cur += size;
}

static void
dump_date(Out out, VALUE obj) {
    char	buf[64];
    char	*b = buf + sizeof(buf) - 1;
    long	jd = NUM2LONG(rb_funcall2(obj, ox_jd_id, 0, 0));
    long	size;

    *b-- = '\0';
    for (; 0 < jd; b--, jd /= 10) {
	*b = '0' + (jd % 10);
    }
    b++;
    if ('\0' == *b) {
	b--;
	*b = '0';
    }
    size = sizeof(buf) - (b - buf) - 1;
    if (out->end - out->cur <= size) {
	grow(out, size);
    }
    memcpy(out->cur, b, size);
    out->cur += size;
}

static void
dump_time_xsd(Out out, VALUE obj) {
    struct tm		*tm;
#if HAS_RB_TIME_TIMESPEC
    struct timespec	ts = rb_time_timespec(obj);
    time_t		sec = ts.tv_sec;
    long		nsec = ts.tv_nsec;
#else
    time_t		sec = NUM2LONG(rb_funcall2(obj, ox_tv_sec_id, 0, 0));
#if HAS_NANO_TIME
    long		nsec = NUM2LONG(rb_funcall2(obj, ox_tv_nsec_id, 0, 0));
#else
    long		nsec = NUM2LONG(rb_funcall2(obj, ox_tv_usec_id, 0, 0)) * 1000;
#endif
#endif
    int			tzhour, tzmin;
    char		tzsign = '+';

    if (out->end - out->cur <= 33) {
	grow(out, 33);
    }
    /* 2010-07-09T10:47:45.895826+09:00 */
    tm = localtime(&sec);
#if HAS_TM_GMTOFF
    if (0 > tm->tm_gmtoff) {
	tzsign = '-';
	tzhour = (int)(tm->tm_gmtoff / -3600);
	tzmin = (int)(tm->tm_gmtoff / -60) - (tzhour * 60);
    } else {
	tzhour = (int)(tm->tm_gmtoff / 3600);
	tzmin = (int)(tm->tm_gmtoff / 60) - (tzhour * 60);
    }
#else
    tzhour = 0;
    tzmin = 0;
#endif
    /* TBD replace with more efficient printer */
    out->cur += sprintf(out->cur, "%04d-%02d-%02dT%02d:%02d:%02d.%06ld%c%02d:%02d",
			tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday,
			tm->tm_hour, tm->tm_min, tm->tm_sec, nsec / 1000,
			tzsign, tzhour, tzmin);
}

static void
dump_first_obj(VALUE obj, Out out) {
    char	buf[128];
    Options	copts = out->opts;
    int		cnt;

    if (Yes == copts->with_xml) {
	if (0 < copts->margin_len) {
	    dump_value(out, copts->margin, copts->margin_len);
	}
	if ('\0' == *copts->encoding) {
	    dump_value(out, "<?xml version=\"1.0\"?>", 21);
	} else {
	    cnt = snprintf(buf, sizeof(buf), "<?xml version=\"1.0\" encoding=\"%s\"?>", copts->encoding);
	    dump_value(out, buf, cnt);
	}
    }
    if (Yes == copts->with_instruct) {
	if (out->buf < out->cur) {
	    dump_value(out, "\n", 1);
	}
	if (0 < copts->margin_len) {
	    dump_value(out, copts->margin, copts->margin_len);
	}
	cnt = snprintf(buf, sizeof(buf), "<?ox version=\"1.0\" mode=\"object\"%s%s?>",
		      (Yes == copts->circular) ? " circular=\"yes\"" : ((No == copts->circular) ? " circular=\"no\"" : ""),
		      (Yes == copts->xsd_date) ? " xsd_date=\"yes\"" : ((No == copts->xsd_date) ? " xsd_date=\"no\"" : ""));
	dump_value(out, buf, cnt);
    }
    if (Yes == copts->with_dtd) {
	if (0 < copts->margin_len) {
	    dump_value(out, copts->margin, copts->margin_len);
	}
	cnt = snprintf(buf, sizeof(buf), "%s<!DOCTYPE %c SYSTEM \"ox.dtd\">", (out->buf < out->cur) ? "\n" : "", obj_class_code(obj));
	dump_value(out, buf, cnt);
    }
    if (0 < copts->margin_len) {
	dump_value(out, copts->margin, copts->margin_len);
    }
    dump_obj(0, obj, 0, out);
}

static void
dump_obj(ID aid, VALUE obj, int depth, Out out) {
    struct _Element	e;
    VALUE		prev_obj = out->obj;
    char		value_buf[64];
    int			cnt;

    if (MAX_DEPTH < depth) {
	rb_raise(rb_eSysStackError, "maximum depth exceeded");
    }
    out->obj = obj;
    if (0 == aid) {
	e.attr.str = 0;
	e.attr.len = 0;
    } else {
	e.attr.str = rb_id2name(aid);
	// Ruby 2.3 started to return NULL for some IDs so check for
	// NULL. Ignore if NULL aid.
	if (NULL == e.attr.str) {
	    return;
	}
	e.attr.len = strlen(e.attr.str);
    }
    e.closed = 0;
    if (0 == depth) {
	e.indent = (0 <= out->indent) ? 0 : -1;
    } else if (0 > out->indent) {
	e.indent = -1;
    } else if (0 == out->indent) {
	e.indent = 0;
    } else {
	e.indent = depth * out->indent;
    }
    e.id = 0;
    e.clas.len = 0;
    e.clas.str = 0;
    switch (rb_type(obj)) {
    case T_NIL:
	e.type = NilClassCode;
	e.closed = 1;
	out->w_start(out, &e);
	break;
    case T_ARRAY:
	if (0 != out->circ_cache && check_circular(out, obj, &e)) {
	    break;
	}
	cnt = (int)RARRAY_LEN(obj);
	e.type = ArrayCode;
	e.closed = (0 >= cnt);
	out->w_start(out, &e);
	if (!e.closed) {
	    const VALUE	*np = RARRAY_PTR(obj);
	    int		i;
	    int		d2 = depth + 1;

	    for (i = cnt; 0 < i; i--, np++) {
		dump_obj(0, *np, d2, out);
	    }
	    out->w_end(out, &e);
	}
	break;
    case T_HASH:
	if (0 != out->circ_cache && check_circular(out, obj, &e)) {
	    break;
	}
	cnt = (int)RHASH_SIZE(obj);
	e.type = HashCode;
	e.closed = (0 >= cnt);
	out->w_start(out, &e);
	if (0 < cnt) {
	    unsigned int	od = out->depth;
	    
	    out->depth = depth + 1;
	    rb_hash_foreach(obj, dump_hash, (VALUE)out);
	    out->depth = od;
	    out->w_end(out, &e);
	}
	break;
    case T_TRUE:
	e.type = TrueClassCode;
	e.closed = 1;
	out->w_start(out, &e);
	break;
    case T_FALSE:
	e.type = FalseClassCode;
	e.closed = 1;
	out->w_start(out, &e);
	break;
    case T_FIXNUM:
	e.type = FixnumCode;
	out->w_start(out, &e);
	dump_num(out, obj);
	e.indent = -1;
	out->w_end(out, &e);
	break;
    case T_FLOAT:
	e.type = FloatCode;
	cnt = snprintf(value_buf, sizeof(value_buf), "%0.16g", rb_num2dbl(obj));
	out->w_start(out, &e);
	dump_value(out, value_buf, cnt);
	e.indent = -1;
	out->w_end(out, &e);
	break;
    case T_STRING:
    {
	const char	*str;

	if (0 != out->circ_cache && check_circular(out, obj, &e)) {
	    break;
	}
	str = StringValuePtr(obj);
	cnt = (int)RSTRING_LEN(obj);
#if USE_B64
	if (is_xml_friendly((uchar*)str, cnt)) {
	    e.type = StringCode;
	    out->w_start(out, &e);
	    dump_str_value(out, str, cnt, '<');
	    e.indent = -1;
	    out->w_end(out, &e);
	} else {
	    ulong	size = b64_size(cnt);
	    char	*b64 = ALLOCA_N(char, size + 1);

	    e.type = String64Code;
	    to_base64((uchar*)str, cnt, b64);
	    out->w_start(out, &e);
	    dump_value(out, b64, size);
	    e.indent = -1;
	    out->w_end(out, &e);
	}
#else
	e.type = StringCode;
	out->w_start(out, &e);
	dump_str_value(out, str, cnt, xml_element_chars);
	e.indent = -1;
	out->w_end(out, &e);
#endif
	break;
    }
    case T_SYMBOL:
    {
	const char	*sym = rb_id2name(SYM2ID(obj));

	cnt = (int)strlen(sym);
#if USE_B64
	if (is_xml_friendly((uchar*)sym, cnt)) {
	    e.type = SymbolCode;
	    out->w_start(out, &e);
	    dump_str_value(out, sym, cnt, '<');
	    e.indent = -1;
	    out->w_end(out, &e);
	} else {
	    ulong	size = b64_size(cnt);
	    char	*b64 = ALLOCA_N(char, size + 1);

	    e.type = Symbol64Code;
	    to_base64((uchar*)sym, cnt, b64);
	    out->w_start(out, &e);
	    dump_value(out, b64, size);
	    e.indent = -1;
	    out->w_end(out, &e);
	}
#else
	e.type = SymbolCode;
	out->w_start(out, &e);
	dump_str_value(out, sym, cnt, xml_element_chars);
	e.indent = -1;
	out->w_end(out, &e);
#endif
	break;
    }
    case T_DATA:
    {
	VALUE	clas;

	clas = rb_obj_class(obj);
	if (rb_cTime == clas) {
	    e.type = TimeCode;
	    out->w_start(out, &e);
	    out->w_time(out, obj);
	    e.indent = -1;
	    out->w_end(out, &e);
	} else {
	    const char	*classname = rb_class2name(clas);

	    if (0 == strcmp("Date", classname)) {
		e.type = DateCode;
		out->w_start(out, &e);
		dump_date(out, obj);
		e.indent = -1;
		out->w_end(out, &e);
	    } else if (0 == strcmp("BigDecimal", classname)) {
		volatile VALUE	rs = rb_funcall(obj, ox_to_s_id, 0);

		e.type = BigDecimalCode;
		out->w_start(out, &e);
		dump_value(out, StringValuePtr(rs), RSTRING_LEN(rs));
		e.indent = -1;
		out->w_end(out, &e);
	    } else {
		if (StrictEffort == out->opts->effort) {
		    rb_raise(rb_eNotImpError, "Failed to dump T_DATA %s\n", classname);
		} else {
		    e.type = NilClassCode;
		    e.closed = 1;
		    out->w_start(out, &e);
		}
	    }
	}
	break;
    }
    case T_STRUCT:
    {
#if HAS_RSTRUCT
	VALUE	clas;

	if (0 != out->circ_cache && check_circular(out, obj, &e)) {
	    break;
	}
	clas = rb_obj_class(obj);
	if (rb_cRange == clas) {
	    VALUE	beg  = RSTRUCT_GET(obj, 0);
	    VALUE	end  = RSTRUCT_GET(obj, 1);
	    VALUE	excl = RSTRUCT_GET(obj, 2);
	    int		d2 = depth + 1;

	    e.type = RangeCode;	 e.clas.len = 5;  e.clas.str = "Range";
	    out->w_start(out, &e);
	    dump_obj(ox_beg_id, beg, d2, out);
	    dump_obj(ox_end_id, end, d2, out);
	    dump_obj(ox_excl_id, excl, d2, out);
	    out->w_end(out, &e);
	} else {
	    char	num_buf[16];
	    int		d2 = depth + 1;
#if UNIFY_FIXNUM_AND_BIGNUM
		long i;
		long cnt = NUM2LONG(rb_struct_size(obj));
#else // UNIFY_FIXNUM_AND_INTEGER
		int   i;
		int   cnt = (int)RSTRUCT_LEN(obj);
#endif // UNIFY_FIXNUM_AND_INTEGER
	    e.type = StructCode;
	    e.clas.str = rb_class2name(clas);
	    e.clas.len = strlen(e.clas.str);
	    out->w_start(out, &e);

	    for (i = 0; i < cnt; i++) {
	        VALUE v = RSTRUCT_GET(obj, i);
	        dump_obj(rb_intern(ulong2str(i, num_buf + sizeof(num_buf) - 1)), v, d2, out);
	    }
	    out->w_end(out, &e);
	}
#else
	e.type = NilClassCode;
	e.closed = 1;
	out->w_start(out, &e);
#endif
	break;
    }
    case T_OBJECT:
    {
	VALUE	clas;

	if (0 != out->circ_cache && check_circular(out, obj, &e)) {
	    break;
	}
	clas = rb_obj_class(obj);
	e.clas.str = rb_class2name(clas);
	e.clas.len = strlen(e.clas.str);
	if (ox_document_clas == clas) {
	    e.type = RawCode;
	    out->w_start(out, &e);
	    dump_gen_doc(obj, depth + 1, out);
	    out->w_end(out, &e);
	} else if (ox_element_clas == clas) {
	    e.type = RawCode;
	    out->w_start(out, &e);
	    dump_gen_element(obj, depth + 1, out);
	    out->w_end(out, &e);
	} else { /* Object */
#if HAS_IVAR_HELPERS
	    e.type = (Qtrue == rb_obj_is_kind_of(obj, rb_eException)) ? ExceptionCode : ObjectCode;
	    cnt = (int)rb_ivar_count(obj);
	    e.closed = (0 >= cnt);
	    out->w_start(out, &e);
	    if (0 < cnt) {
		unsigned int	    od = out->depth;

		out->depth = depth + 1;
		rb_ivar_foreach(obj, dump_var, (VALUE)out);
		out->depth = od;
		out->w_end(out, &e);
	    }
#else
	    volatile VALUE	 vars = rb_obj_instance_variables(obj);
	    //volatile VALUE	   vars = rb_funcall2(obj, rb_intern("instance_variables"), 0, 0);

	    e.type = (Qtrue == rb_obj_is_kind_of(obj, rb_eException)) ? ExceptionCode : ObjectCode;
	    cnt = (int)RARRAY_LEN(vars);
	    e.closed = (0 >= cnt);
	    out->w_start(out, &e);
	    if (0 < cnt) {
		const VALUE	*np = RARRAY_PTR(vars);
		ID		vid;
		unsigned int	od = out->depth;
		int		i;

		out->depth = depth + 1;
		for (i = cnt; 0 < i; i--, np++) {
		    vid = rb_to_id(*np);
		    dump_var(vid, rb_ivar_get(obj, vid), out);
		}
		out->depth = od;
		out->w_end(out, &e);
	    }
#endif
	}
	break;
    }
    case T_REGEXP:
    {
	volatile VALUE	rs = rb_funcall2(obj, ox_inspect_id, 0, 0);
	const char	*s = StringValuePtr(rs);

	cnt = (int)RSTRING_LEN(rs);
	e.type = RegexpCode;
	out->w_start(out, &e);
#if USE_B64
	if (is_xml_friendly((uchar*)s, cnt)) {
	    /*dump_value(out, "/", 1); */
	    dump_str_value(out, s, cnt, '<');
	} else {
	    ulong	size = b64_size(cnt);
	    char	*b64 = ALLOCA_N(char, size + 1);

	    to_base64((uchar*)s, cnt, b64);
	    dump_value(out, b64, size);
	}
#else
	dump_str_value(out, s, cnt, xml_element_chars);
#endif
	e.indent = -1;
	out->w_end(out, &e);
	break;
    }
    case T_BIGNUM:
    {
	volatile VALUE	rs = rb_big2str(obj, 10);
	
	e.type = BignumCode;
	out->w_start(out, &e);
	dump_value(out, StringValuePtr(rs), RSTRING_LEN(rs));
	e.indent = -1;
	out->w_end(out, &e);
	break;
    }
#ifdef T_COMPLEX
    case T_COMPLEX:
	e.type = ComplexCode;
	out->w_start(out, &e);
#ifdef RCOMPLEX
	dump_obj(0, RCOMPLEX(obj)->real, depth + 1, out);
	dump_obj(0, RCOMPLEX(obj)->imag, depth + 1, out);
#else
	dump_obj(0, rb_funcall2(obj, rb_intern("real"), 0, 0), depth + 1, out);
	dump_obj(0, rb_funcall2(obj, rb_intern("imag"), 0, 0), depth + 1, out);
#endif
	out->w_end(out, &e);
	break;
#endif
#ifdef T_RATIONAL
    case T_RATIONAL:
	e.type = RationalCode;
	out->w_start(out, &e);
#ifdef RRATIONAL
	dump_obj(0, RRATIONAL(obj)->num, depth + 1, out);
	dump_obj(0, RRATIONAL(obj)->den, depth + 1, out);
#else
	dump_obj(0, rb_funcall2(obj, rb_intern("numerator"), 0, 0), depth + 1, out);
	dump_obj(0, rb_funcall2(obj, rb_intern("denominator"), 0, 0), depth + 1, out);
#endif
	out->w_end(out, &e);
	break;
#endif
    case T_CLASS:
    {
	e.type = ClassCode;
	e.clas.str = rb_class2name(obj);
	e.clas.len = strlen(e.clas.str);
	e.closed = 1;
	out->w_start(out, &e);
	break;
    }
    default:
	if (StrictEffort == out->opts->effort) {
	    rb_raise(rb_eNotImpError, "Failed to dump %s Object (%02x)\n",
		     rb_obj_classname(obj), rb_type(obj));
	} else {
	    e.type = NilClassCode;
	    e.closed = 1;
	    out->w_start(out, &e);
	}
	break;
    }
    out->obj = prev_obj;
}

static int
dump_var(ID key, VALUE value, Out out) {
    if (T_DATA == rb_type(value) && key == ox_mesg_id) {
	/* There is a secret recipe that keeps Exception mesg attributes as a
	 * T_DATA until it is needed. The safe way around this hack is to call
	 * the message() method and use the returned string as the
	 * message. Not pretty but it solves the most common use of this
	 * hack. If there are others they will have to be handled one at a
	 * time.
	 */
	value = rb_funcall(out->obj, ox_message_id, 0);
    }
    dump_obj(key, value, out->depth, out);

    return ST_CONTINUE;
}

static int
dump_hash(VALUE key, VALUE value, Out out) {
    dump_obj(0, key, out->depth, out);
    dump_obj(0, value, out->depth, out);
    
    return ST_CONTINUE;
}

static void
dump_gen_doc(VALUE obj, int depth, Out out) {
    volatile VALUE	attrs = rb_attr_get(obj, ox_attributes_id);
    volatile VALUE	nodes = rb_attr_get(obj, ox_nodes_id);

    if ('\0' == *out->opts->encoding && Qnil != attrs) {
	volatile VALUE	renc = rb_hash_lookup(attrs, ox_encoding_sym);

	if (Qnil != renc) {
	    const char	*enc = StringValuePtr(renc);

	    strncpy(out->opts->encoding, enc, sizeof(out->opts->encoding) - 1);
	}
    }
    if (Yes == out->opts->with_xml) {
	if (0 < out->opts->margin_len) {
	    dump_value(out, out->opts->margin, out->opts->margin_len);
	}
	dump_value(out, "<?xml", 5);
	if (Qnil != attrs) {
	    rb_hash_foreach(attrs, dump_gen_attr, (VALUE)out);
	}
	dump_value(out, "?>", 2);
    }
    if (Yes == out->opts->with_instruct) {
	if (out->buf < out->cur) {
	    dump_value(out, "\n", 1);
	}
	if (0 < out->opts->margin_len) {
	    dump_value(out, out->opts->margin, out->opts->margin_len);
	}
	dump_value(out, "<?ox version=\"1.0\" mode=\"generic\"?>", 35);
    }
    if (Qnil != nodes) {
	dump_gen_nodes(nodes, depth, out);
    }
}

static void
dump_gen_element(VALUE obj, int depth, Out out) {
    volatile VALUE	rname = rb_attr_get(obj, ox_at_value_id);
    volatile VALUE	attrs = rb_attr_get(obj, ox_attributes_id);
    volatile VALUE	nodes = rb_attr_get(obj, ox_nodes_id);
    const char		*name = StringValuePtr(rname);
    long		nlen = RSTRING_LEN(rname);
    size_t		size;
    int			indent;
    
    if (0 > out->indent) {
	indent = -1;
    } else if (0 == out->indent) {
	indent = 0;
    } else {
	indent = depth * out->indent;
    }
    size = indent + 4 + nlen + out->opts->margin_len;
    if (out->end - out->cur <= (long)size) {
	grow(out, size);
    }
    if (0 == depth && 0 < out->opts->margin_len && 0 < out->indent) {
	memcpy(out->cur, out->opts->margin, out->opts->margin_len);
	out->cur += out->opts->margin_len;
    }
    fill_indent(out, indent);
    *out->cur++ = '<';
    fill_value(out, name, nlen);
    if (Qnil != attrs) {
	rb_hash_foreach(attrs, dump_gen_attr, (VALUE)out);
    }
    if (Qnil != nodes && 0 < RARRAY_LEN(nodes)) {
	int	do_indent;
	
	*out->cur++ = '>';
	do_indent = dump_gen_nodes(nodes, depth, out);
	if (out->end - out->cur <= (long)size) {
	    grow(out, size);
	}
	if (do_indent) {
	    fill_indent(out, indent);
	}
	*out->cur++ = '<';
	*out->cur++ = '/';
	fill_value(out, name, nlen);
    } else {
	*out->cur++ = '/';
    }
    *out->cur++ = '>';
    *out->cur = '\0';
}

static void
dump_gen_instruct(VALUE obj, int depth, Out out) {
    volatile VALUE	rname = rb_attr_get(obj, ox_at_value_id);
    volatile VALUE	attrs = rb_attr_get(obj, ox_attributes_id);
    volatile VALUE	rcontent = rb_attr_get(obj, ox_at_content_id);
    const char		*name = StringValuePtr(rname);
    const char		*content = 0;
    long		nlen = RSTRING_LEN(rname);
    long		clen = 0;
    size_t		size;
    
    if (T_STRING == rb_type(rcontent)) {
	content = StringValuePtr(rcontent);
	clen = RSTRING_LEN(rcontent);
	size = 4 + nlen + clen;
    } else {
	size = 4 + nlen;
    }
    if (out->end - out->cur <= (long)size) {
	grow(out, size);
    }
    *out->cur++ = '<';
    *out->cur++ = '?';
    fill_value(out, name, nlen);
    if (0 != content) {
	fill_value(out, content, clen);
    } else if (Qnil != attrs) {
	rb_hash_foreach(attrs, dump_gen_attr, (VALUE)out);
    }
    *out->cur++ = '?';
    *out->cur++ = '>';
    *out->cur = '\0';
}

static int
dump_gen_nodes(VALUE obj, int depth, Out out) {
    long	cnt = RARRAY_LEN(obj);
    int		indent_needed = 1;
    
    if (0 < cnt) {
	const VALUE	*np = RARRAY_PTR(obj);
	VALUE		clas;
	int		d2 = depth + 1;

	if (MAX_DEPTH < depth) {
	    rb_raise(rb_eSysStackError, "maximum depth exceeded");
	}
	for (; 0 < cnt; cnt--, np++) {
	    clas = rb_obj_class(*np);
	    if (ox_element_clas == clas) {
		dump_gen_element(*np, d2, out);
	    } else if (ox_instruct_clas == clas) {
		dump_gen_instruct(*np, d2, out);
		indent_needed = (1 == cnt) ? 0 : 1;
	    } else if (rb_cString == clas) {
		dump_str_value(out, StringValuePtr(*(VALUE*)np), RSTRING_LEN(*np), xml_element_chars);
		indent_needed = (1 == cnt) ? 0 : 1;
	    } else if (ox_comment_clas == clas) {
		dump_gen_val_node(*np, d2, "<!-- ", 5, " -->", 4, out);
	    } else if (ox_raw_clas == clas) {
		dump_gen_val_node(*np, d2, "", 0, "", 0, out);
	    } else if (ox_cdata_clas == clas) {
		dump_gen_val_node(*np, d2, "<![CDATA[", 9, "]]>", 3, out);
	    } else if (ox_doctype_clas == clas) {
		dump_gen_val_node(*np, d2, "<!DOCTYPE ", 10, " >", 2, out);
	    } else {
		rb_raise(rb_eTypeError, "Unexpected class, %s, while dumping generic XML\n", rb_class2name(clas));
	    }
	}
    }
    return indent_needed;
}

static int
dump_gen_attr(VALUE key, VALUE value, Out out) {
    const char	*ks;
    size_t	klen;
    size_t	size;

#if HAS_PRIVATE_ENCODING
    // There seems to be a bug in jruby for converting symbols to strings and preserving the encoding. This is a work
    // around.
    ks = rb_str_ptr(rb_String(key));
#else
    switch (rb_type(key)) {
    case T_SYMBOL:
	ks = rb_id2name(SYM2ID(key));
	break;
    case T_STRING:
	ks = StringValuePtr(key);
	break;
    default:
	key = rb_String(key);
	ks = StringValuePtr(key);
	break;
    }
#endif
    klen = strlen(ks);
    value = rb_String(value);
    size = 4 + klen + RSTRING_LEN(value);
    if (out->end - out->cur <= (long)size) {
	grow(out, size);
    }
    *out->cur++ = ' ';
    fill_value(out, ks, klen);
    *out->cur++ = '=';
    *out->cur++ = '"';
    dump_str_value(out, StringValuePtr(value), RSTRING_LEN(value), xml_quote_chars);
    *out->cur++ = '"';

    return ST_CONTINUE;
}

static void
dump_gen_val_node(VALUE obj, int depth,
		  const char *pre, size_t plen,
		  const char *suf, size_t slen, Out out) {
    volatile VALUE	v = rb_attr_get(obj, ox_at_value_id);
    const char		*val;
    size_t		vlen;
    size_t		size;
    int			indent;

    if (T_STRING != rb_type(v)) {
	return;
    }
    val = StringValuePtr(v);
    vlen = RSTRING_LEN(v);
    if (0 > out->indent) {
	indent = -1;
    } else if (0 == out->indent) {
	indent = 0;
    } else {
	indent = depth * out->indent;
    }
    size = indent + plen + slen + vlen + out->opts->margin_len;
    if (out->end - out->cur <= (long)size) {
	grow(out, size);
    }
    fill_indent(out, indent);
    fill_value(out, pre, plen);
    fill_value(out, val, vlen);
    fill_value(out, suf, slen);
    *out->cur = '\0';
}

static void
dump_obj_to_xml(VALUE obj, Options copts, Out out) {
    VALUE	clas = rb_obj_class(obj);

    out->w_time = (Yes == copts->xsd_date) ? dump_time_xsd : dump_time_thin;
    out->buf = ALLOC_N(char, 65336);
    out->end = out->buf + 65325; /* 10 less than end plus extra for possible errors */
    out->cur = out->buf;
    out->circ_cache = 0;
    out->circ_cnt = 0;
    out->opts = copts;
    out->obj = obj;
    if (Yes == copts->circular) {
	ox_cache8_new(&out->circ_cache);
    }
    out->indent = copts->indent;

    if (ox_document_clas == clas) {
	dump_gen_doc(obj, -1, out);
    } else if (ox_element_clas == clas) {
	dump_gen_element(obj, 0, out);
    } else {
	out->w_start = dump_start;
	out->w_end = dump_end;
	dump_first_obj(obj, out);
    }
    dump_value(out, "\n", 1);
    if (Yes == copts->circular) {
	ox_cache8_delete(out->circ_cache);
    }
}

char*
ox_write_obj_to_str(VALUE obj, Options copts) {
    struct _Out out;
    
    dump_obj_to_xml(obj, copts, &out);
    return out.buf;
}

void
ox_write_obj_to_file(VALUE obj, const char *path, Options copts) {
    struct _Out out;
    size_t	size;
    FILE	*f;    

    dump_obj_to_xml(obj, copts, &out);
    size = out.cur - out.buf;
    if (0 == (f = fopen(path, "w"))) {
	rb_raise(rb_eIOError, "%s\n", strerror(errno));
    }
    if (size != fwrite(out.buf, 1, size, f)) {
	int err = ferror(f);
	rb_raise(rb_eIOError, "Write failed. [%d:%s]\n", err, strerror(err));
    }
    xfree(out.buf);
    fclose(f);
}

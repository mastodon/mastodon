/* dump.c
 * Copyright (c) 2012, 2017, Peter Ohler
 * All rights reserved.
 */

#include <stdlib.h>
#include <errno.h>
#if !IS_WINDOWS
#include <sys/time.h>
#endif
#include <time.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <unistd.h>
#include <errno.h>

#include "oj.h"
#include "cache8.h"
#include "dump.h"
#include "odd.h"

// Workaround in case INFINITY is not defined in math.h or if the OS is CentOS
#define OJ_INFINITY (1.0/0.0)

#define MAX_DEPTH 1000

static const char	inf_val[] = INF_VAL;
static const char	ninf_val[] = NINF_VAL;
static const char	nan_val[] = NAN_VAL;

typedef unsigned long	ulong;

static size_t	hibit_friendly_size(const uint8_t *str, size_t len);
static size_t	xss_friendly_size(const uint8_t *str, size_t len);
static size_t	ascii_friendly_size(const uint8_t *str, size_t len);

static const char	hex_chars[17] = "0123456789abcdef";

// JSON standard except newlines are no escaped
static char	newline_friendly_chars[256] = "\
66666666221622666666666666666666\
11211111111111111111111111111111\
11111111111111111111111111112111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111";

// JSON standard
static char	hibit_friendly_chars[256] = "\
66666666222622666666666666666666\
11211111111111111111111111111111\
11111111111111111111111111112111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111";

// High bit set characters are always encoded as unicode. Worse case is 3
// bytes per character in the output. That makes this conservative.
static char	ascii_friendly_chars[256] = "\
66666666222622666666666666666666\
11211111111111111111111111111111\
11111111111111111111111111112111\
11111111111111111111111111111116\
33333333333333333333333333333333\
33333333333333333333333333333333\
33333333333333333333333333333333\
33333333333333333333333333333333";

// XSS safe mode
static char	xss_friendly_chars[256] = "\
66666666222622666666666666666666\
11211161111111121111111111116161\
11111111111111111111111111112111\
11111111111111111111111111111116\
33333333333333333333333333333333\
33333333333333333333333333333333\
33333333333333333333333333333333\
33333333333333333333333333333333";

// JSON XSS combo
static char	hixss_friendly_chars[256] = "\
66666666222622666666666666666666\
11211161111111111111111111116161\
11111111111111111111111111112111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11611111111111111111111111111111";

// Rails HTML non-escape
static char	rails_friendly_chars[256] = "\
66666666222622666666666666666666\
11211111111111111111111111111111\
11111111111111111111111111112111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11611111111111111111111111111111";

static void
raise_strict(VALUE obj) {
    rb_raise(rb_eTypeError, "Failed to dump %s Object to JSON in strict mode.", rb_class2name(rb_obj_class(obj)));
}

inline static size_t
newline_friendly_size(const uint8_t *str, size_t len) {
    size_t	size = 0;
    size_t	i = len;

    for (; 0 < i; str++, i--) {
	size += newline_friendly_chars[*str];
    }
    return size - len * (size_t)'0';
}

inline static size_t
hibit_friendly_size(const uint8_t *str, size_t len) {
    size_t	size = 0;
    size_t	i = len;

    for (; 0 < i; str++, i--) {
	size += hibit_friendly_chars[*str];
    }
    return size - len * (size_t)'0';
}

inline static size_t
ascii_friendly_size(const uint8_t *str, size_t len) {
    size_t	size = 0;
    size_t	i = len;

    for (; 0 < i; str++, i--) {
	size += ascii_friendly_chars[*str];
    }
    return size - len * (size_t)'0';
}

inline static size_t
xss_friendly_size(const uint8_t *str, size_t len) {
    size_t	size = 0;
    size_t	i = len;

    for (; 0 < i; str++, i--) {
	size += xss_friendly_chars[*str];
    }
    return size - len * (size_t)'0';
}

inline static size_t
hixss_friendly_size(const uint8_t *str, size_t len) {
    size_t	size = 0;
    size_t	i = len;
    bool	check = false;
    
    for (; 0 < i; str++, i--) {
	size += hixss_friendly_chars[*str];
	if (0 != (0x80 & *str)) {
	    check = true;
	}
    }
    return size - len * (size_t)'0' + check;
}

inline static size_t
rails_friendly_size(const uint8_t *str, size_t len) {
    size_t	size = 0;
    size_t	i = len;

    for (; 0 < i; str++, i--) {
	size += rails_friendly_chars[*str];
    }
    return size - len * (size_t)'0';
}

const char*
oj_nan_str(VALUE obj, int opt, int mode, bool plus, int *lenp) {
    const char	*str = NULL;
    
    if (AutoNan == opt) {
	switch (mode) {
	case CompatMode:	opt = WordNan;	break;
	case StrictMode:	opt = RaiseNan;	break;
	default:				break;
	}
    }
    switch (opt) {
    case RaiseNan:
	raise_strict(obj);
	break;
    case WordNan:
	if (plus) {
	    str = "Infinity";
	    *lenp = 8;
	} else {
	    str = "-Infinity";
	    *lenp = 9;
	}
	break;
    case NullNan:
	str = "null";
	*lenp = 4;
	break;
    case HugeNan:
    default:
	if (plus) {
	    str = inf_val;
	    *lenp = sizeof(inf_val) - 1;
	} else {
	    str = ninf_val;
	    *lenp = sizeof(ninf_val) - 1;
	}
	break;
    }
    return str;
}

inline static void
dump_hex(uint8_t c, Out out) {
    uint8_t	d = (c >> 4) & 0x0F;

    *out->cur++ = hex_chars[d];
    d = c & 0x0F;
    *out->cur++ = hex_chars[d];
}

static const char*
dump_unicode(const char *str, const char *end, Out out) {
    uint32_t	code = 0;
    uint8_t	b = *(uint8_t*)str;
    int		i, cnt;
    
    if (0xC0 == (0xE0 & b)) {
	cnt = 1;
	code = b & 0x0000001F;
    } else if (0xE0 == (0xF0 & b)) {
	cnt = 2;
	code = b & 0x0000000F;
    } else if (0xF0 == (0xF8 & b)) {
	cnt = 3;
	code = b & 0x00000007;
    } else if (0xF8 == (0xFC & b)) {
	cnt = 4;
	code = b & 0x00000003;
    } else if (0xFC == (0xFE & b)) {
	cnt = 5;
	code = b & 0x00000001;
    } else {
	cnt = 0;
	rb_raise(oj_json_generator_error_class, "Invalid Unicode");
    }
    str++;
    for (; 0 < cnt; cnt--, str++) {
	b = *(uint8_t*)str;
	if (end <= str || 0x80 != (0xC0 & b)) {
	    rb_raise(oj_json_generator_error_class, "Invalid Unicode");
	}
	code = (code << 6) | (b & 0x0000003F);
    }
    if (0x0000FFFF < code) {
	uint32_t	c1;

	code -= 0x00010000;
	c1 = ((code >> 10) & 0x000003FF) + 0x0000D800;
	code = (code & 0x000003FF) + 0x0000DC00;
	*out->cur++ = '\\';
	*out->cur++ = 'u';
	for (i = 3; 0 <= i; i--) {
	    *out->cur++ = hex_chars[(uint8_t)(c1 >> (i * 4)) & 0x0F];
	}
    }
    *out->cur++ = '\\';
    *out->cur++ = 'u';
    for (i = 3; 0 <= i; i--) {
	*out->cur++ = hex_chars[(uint8_t)(code >> (i * 4)) & 0x0F];
    }	
    return str - 1;
}

static const char*
check_unicode(const char *str, const char *end) {
    uint8_t	b = *(uint8_t*)str;
    int		cnt;
    
    if (0xC0 == (0xE0 & b)) {
	cnt = 1;
    } else if (0xE0 == (0xF0 & b)) {
	cnt = 2;
    } else if (0xF0 == (0xF8 & b)) {
	cnt = 3;
    } else if (0xF8 == (0xFC & b)) {
	cnt = 4;
    } else if (0xFC == (0xFE & b)) {
	cnt = 5;
    } else {
	rb_raise(oj_json_generator_error_class, "Invalid Unicode");
    }
    str++;
    for (; 0 < cnt; cnt--, str++) {
	b = *(uint8_t*)str;
	if (end <= str || 0x80 != (0xC0 & b)) {
	    rb_raise(oj_json_generator_error_class, "Invalid Unicode");
	}
    }
    return str;
}

// Returns 0 if not using circular references, -1 if no further writing is
// needed (duplicate), and a positive value if the object was added to the
// cache.
long
oj_check_circular(VALUE obj, Out out) {
    slot_t	id = 0;
    slot_t	*slot;

    if (Yes == out->opts->circular) {
	if (0 == (id = oj_cache8_get(out->circ_cache, obj, &slot))) {
	    out->circ_cnt++;
	    id = out->circ_cnt;
	    *slot = id;
	} else {
	    if (ObjectMode == out->opts->mode) {
		assure_size(out, 18);
		*out->cur++ = '"';
		*out->cur++ = '^';
		*out->cur++ = 'r';
		dump_ulong(id, out);
		*out->cur++ = '"';
	    }
	    return -1;
	}
    }
    return (long)id;
}

void
oj_dump_time(VALUE obj, Out out, int withZone) {
    char		buf[64];
    char		*b = buf + sizeof(buf) - 1;
    long		size;
    char		*dot;
    int			neg = 0;
    long		one = 1000000000;
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
    
    *b-- = '\0';
    if (withZone) {
	long	tzsecs = NUM2LONG(rb_funcall2(obj, oj_utc_offset_id, 0, 0));
	int	zneg = (0 > tzsecs);

	if (0 == tzsecs && rb_funcall2(obj, oj_utcq_id, 0, 0)) {
	    tzsecs = 86400;
	}
	if (zneg) {
	    tzsecs = -tzsecs;
	}
	if (0 == tzsecs) {
	    *b-- = '0';
	} else {
	    for (; 0 < tzsecs; b--, tzsecs /= 10) {
		*b = '0' + (tzsecs % 10);
	    }
	    if (zneg) {
		*b-- = '-';
	    }
	}
	*b-- = 'e';
    }
    if (0 > sec) {
	neg = 1;
	sec = -sec;
	if (0 < nsec) {
	    nsec = 1000000000 - nsec;
	    sec--;
	}
    }
    dot = b - 9;
    if (0 < out->opts->sec_prec) {
	if (9 > out->opts->sec_prec) {
	    int	i;

	    for (i = 9 - out->opts->sec_prec; 0 < i; i--) {
		dot++;
		nsec = (nsec + 5) / 10;
		one /= 10;
	    }
	}
	if (one <= nsec) {
	    nsec -= one;
	    sec++;
	}
	for (; dot < b; b--, nsec /= 10) {
	    *b = '0' + (nsec % 10);
	}
	*b-- = '.';
    }
    if (0 == sec) {
	*b-- = '0';
    } else {
	for (; 0 < sec; b--, sec /= 10) {
	    *b = '0' + (sec % 10);
	}
    }
    if (neg) {
	*b-- = '-';
    }
    b++;
    size = sizeof(buf) - (b - buf) - 1;
    assure_size(out, size);
    memcpy(out->cur, b, size);
    out->cur += size;
    *out->cur = '\0';
}

void
oj_dump_ruby_time(VALUE obj, Out out) {
    volatile VALUE	rstr = rb_funcall(obj, oj_to_s_id, 0);

    oj_dump_cstr(rb_string_value_ptr((VALUE*)&rstr), RSTRING_LEN(rstr), 0, 0, out);
}

void
oj_dump_xml_time(VALUE obj, Out out) {
    char		buf[64];
    struct tm		*tm;
    long		one = 1000000000;
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
    long		tzsecs = NUM2LONG(rb_funcall2(obj, oj_utc_offset_id, 0, 0));
    int			tzhour, tzmin;
    char		tzsign = '+';

    assure_size(out, 36);
    if (9 > out->opts->sec_prec) {
	int	i;

	// This is pretty lame but to be compatible with rails and active
	// support rounding is not done but instead a floor is done when
	// second precision is 3 just to be like rails. sigh.
	if (3 == out->opts->sec_prec) {
	    nsec /= 1000000;
	    one = 1000;
	} else {
	    for (i = 9 - out->opts->sec_prec; 0 < i; i--) {
		nsec = (nsec + 5) / 10;
		one /= 10;
	    }
	    if (one <= nsec) {
		nsec -= one;
		sec++;
	    }
	}
    }
    // 2012-01-05T23:58:07.123456000+09:00
    //tm = localtime(&sec);
    sec += tzsecs;
    tm = gmtime(&sec);
#if 1
    if (0 > tzsecs) {
        tzsign = '-';
        tzhour = (int)(tzsecs / -3600);
        tzmin = (int)(tzsecs / -60) - (tzhour * 60);
    } else {
        tzhour = (int)(tzsecs / 3600);
        tzmin = (int)(tzsecs / 60) - (tzhour * 60);
    }
#else
    if (0 > tm->tm_gmtoff) {
        tzsign = '-';
        tzhour = (int)(tm->tm_gmtoff / -3600);
        tzmin = (int)(tm->tm_gmtoff / -60) - (tzhour * 60);
    } else {
        tzhour = (int)(tm->tm_gmtoff / 3600);
        tzmin = (int)(tm->tm_gmtoff / 60) - (tzhour * 60);
    }
#endif
    if (0 == nsec || 0 == out->opts->sec_prec) {
	if (0 == tzsecs && rb_funcall2(obj, oj_utcq_id, 0, 0)) {
	    sprintf(buf, "%04d-%02d-%02dT%02d:%02d:%02dZ",
		    tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday,
		    tm->tm_hour, tm->tm_min, tm->tm_sec);
	    oj_dump_cstr(buf, 20, 0, 0, out);
	} else {
	    sprintf(buf, "%04d-%02d-%02dT%02d:%02d:%02d%c%02d:%02d",
		    tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday,
		    tm->tm_hour, tm->tm_min, tm->tm_sec,
		    tzsign, tzhour, tzmin);
	    oj_dump_cstr(buf, 25, 0, 0, out);
	}
    } else if (0 == tzsecs && rb_funcall2(obj, oj_utcq_id, 0, 0)) {
	char	format[64] = "%04d-%02d-%02dT%02d:%02d:%02d.%09ldZ";
	int	len = 30;

	if (9 > out->opts->sec_prec) {
	    format[32] = '0' + out->opts->sec_prec;
	    len -= 9 - out->opts->sec_prec;
	}
	sprintf(buf, format,
		tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday,
		tm->tm_hour, tm->tm_min, tm->tm_sec, nsec);
	oj_dump_cstr(buf, len, 0, 0, out);
    } else {
	char	format[64] = "%04d-%02d-%02dT%02d:%02d:%02d.%09ld%c%02d:%02d";
	int	len = 35;

	if (9 > out->opts->sec_prec) {
	    format[32] = '0' + out->opts->sec_prec;
	    len -= 9 - out->opts->sec_prec;
	}
	sprintf(buf, format,
		tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday,
		tm->tm_hour, tm->tm_min, tm->tm_sec, nsec,
		tzsign, tzhour, tzmin);
	oj_dump_cstr(buf, len, 0, 0, out);
    }
}

void
oj_dump_obj_to_json(VALUE obj, Options copts, Out out) {
    oj_dump_obj_to_json_using_params(obj, copts, out, 0, 0);
}

void
oj_dump_obj_to_json_using_params(VALUE obj, Options copts, Out out, int argc, VALUE *argv) {
    if (0 == out->buf) {
	out->buf = ALLOC_N(char, 4096);
	out->end = out->buf + 4095 - BUFFER_EXTRA; // 1 less than end plus extra for possible errors
	out->allocated = true;
    }
    out->cur = out->buf;
    out->circ_cnt = 0;
    out->opts = copts;
    out->hash_cnt = 0;
    out->indent = copts->indent;
    out->argc = argc;
    out->argv = argv;
    out->ropts = NULL;
    if (Yes == copts->circular) {
	oj_cache8_new(&out->circ_cache);
    }
    switch (copts->mode) {
    case StrictMode:	oj_dump_strict_val(obj, 0, out);			break;
    case NullMode:	oj_dump_null_val(obj, 0, out);				break;
    case ObjectMode:	oj_dump_obj_val(obj, 0, out);				break;
    case CompatMode:	oj_dump_compat_val(obj, 0, out, Yes == copts->to_json);	break;
    case RailsMode:	oj_dump_rails_val(obj, 0, out);				break;
    case CustomMode:	oj_dump_custom_val(obj, 0, out, true);			break;
    case WabMode:	oj_dump_wab_val(obj, 0, out);				break;
    default:		oj_dump_custom_val(obj, 0, out, true);			break;
    }
    if (0 < out->indent) {
	switch (*(out->cur - 1)) {
	case ']':
	case '}':
	    assure_size(out, 1);
	    *out->cur++ = '\n';
	default:
	    break;
	}
    }
    *out->cur = '\0';
    if (Yes == copts->circular) {
	oj_cache8_delete(out->circ_cache);
    }
}

void
oj_write_obj_to_file(VALUE obj, const char *path, Options copts) {
    char	buf[4096];
    struct _Out out;
    size_t	size;
    FILE	*f;
    int		ok;

    out.buf = buf;
    out.end = buf + sizeof(buf) - BUFFER_EXTRA;
    out.allocated = false;
    out.omit_nil = copts->dump_opts.omit_nil;
    oj_dump_obj_to_json(obj, copts, &out);
    size = out.cur - out.buf;
    if (0 == (f = fopen(path, "w"))) {
	if (out.allocated) {
	    xfree(out.buf);
	}
	rb_raise(rb_eIOError, "%s", strerror(errno));
    }
    ok = (size == fwrite(out.buf, 1, size, f));
    if (out.allocated) {
	xfree(out.buf);
    }
    fclose(f);
    if (!ok) {
	int	err = ferror(f);

	rb_raise(rb_eIOError, "Write failed. [%d:%s]", err, strerror(err));
    }
}

void
oj_write_obj_to_stream(VALUE obj, VALUE stream, Options copts) {
    char	buf[4096];
    struct _Out out;
    ssize_t	size;
    VALUE	clas = rb_obj_class(stream);
#if !IS_WINDOWS
    int		fd;
    VALUE	s;
#endif

    out.buf = buf;
    out.end = buf + sizeof(buf) - BUFFER_EXTRA;
    out.allocated = false;
    out.omit_nil = copts->dump_opts.omit_nil;
    oj_dump_obj_to_json(obj, copts, &out);
    size = out.cur - out.buf;
    if (oj_stringio_class == clas) {
	rb_funcall(stream, oj_write_id, 1, rb_str_new(out.buf, size));
#if !IS_WINDOWS
    } else if (rb_respond_to(stream, oj_fileno_id) &&
	       Qnil != (s = rb_funcall(stream, oj_fileno_id, 0)) &&
	       0 != (fd = FIX2INT(s))) {
	if (size != write(fd, out.buf, size)) {
	    if (out.allocated) {
		xfree(out.buf);
	    }
	    rb_raise(rb_eIOError, "Write failed. [%d:%s]", errno, strerror(errno));
	}
#endif
    } else if (rb_respond_to(stream, oj_write_id)) {
	rb_funcall(stream, oj_write_id, 1, rb_str_new(out.buf, size));
    } else {
	if (out.allocated) {
	    xfree(out.buf);
	}
	rb_raise(rb_eArgError, "to_stream() expected an IO Object.");
    }
    if (out.allocated) {
	xfree(out.buf);
    }
}

void
oj_dump_str(VALUE obj, int depth, Out out, bool as_ok) {
#if HAS_ENCODING_SUPPORT
    rb_encoding	*enc = rb_to_encoding(rb_obj_encoding(obj));

    if (rb_utf8_encoding() != enc) {
	obj = rb_str_conv_enc(obj, enc, rb_utf8_encoding());
    }
#endif
    oj_dump_cstr(rb_string_value_ptr((VALUE*)&obj), RSTRING_LEN(obj), 0, 0, out);
}

void
oj_dump_sym(VALUE obj, int depth, Out out, bool as_ok) {
    const char	*sym = rb_id2name(SYM2ID(obj));

    oj_dump_cstr(sym, strlen(sym), 0, 0, out);
}

static void
debug_raise(const char *orig, size_t cnt, int line) {
    char	buf[1024];
    char	*b = buf;
    const char	*s = orig;
    const char	*s_end = s + cnt;

    if (32 < s_end - s) {
	s_end = s + 32;
    }
    for (; s < s_end; s++) {
	b += sprintf(b, " %02x", *s);
    }
    *b = '\0';
    rb_raise(oj_json_generator_error_class, "Partial character in string. %s @ %d", buf, line);
}

void
oj_dump_cstr(const char *str, size_t cnt, bool is_sym, bool escape1, Out out) {
    size_t	size;
    char	*cmap;
    const char	*orig = str;

    switch (out->opts->escape_mode) {
    case NLEsc:
	cmap = newline_friendly_chars;
	size = newline_friendly_size((uint8_t*)str, cnt);
	break;
    case ASCIIEsc:
	cmap = ascii_friendly_chars;
	size = ascii_friendly_size((uint8_t*)str, cnt);
	break;
    case XSSEsc:
	cmap = xss_friendly_chars;
	size = xss_friendly_size((uint8_t*)str, cnt);
	break;
    case JXEsc:
	cmap = hixss_friendly_chars;
	size = hixss_friendly_size((uint8_t*)str, cnt);
	break;
    case RailsEsc:
	cmap = rails_friendly_chars;
	size = rails_friendly_size((uint8_t*)str, cnt);
	break;
    case JSONEsc:
    default:
	cmap = hibit_friendly_chars;
	size = hibit_friendly_size((uint8_t*)str, cnt);
    }
    assure_size(out, size + BUFFER_EXTRA);
    *out->cur++ = '"';

    if (escape1) {
	*out->cur++ = '\\';
	*out->cur++ = 'u';
	*out->cur++ = '0';
	*out->cur++ = '0';
	dump_hex((uint8_t)*str, out);
	cnt--;
	size--;
	str++;
	is_sym = 0; // just to make sure
    }
    if (cnt == size) {
	if (is_sym) {
	    *out->cur++ = ':';
	}
	for (; '\0' != *str; str++) {
	    *out->cur++ = *str;
	}
	*out->cur++ = '"';
    } else {
	const char	*end = str + cnt;
	const char	*check_start = str;
	
	if (is_sym) {
	    *out->cur++ = ':';
	}
	for (; str < end; str++) {
	    switch (cmap[(uint8_t)*str]) {
	    case '1':
		if (JXEsc == out->opts->escape_mode && check_start <= str) {
		    if (0 != (0x80 & (uint8_t)*str)) {
			if (0xC0 == (0xC0 & (uint8_t)*str)) {
			    check_start = check_unicode(str, end);
			} else {
			    rb_raise(oj_json_generator_error_class, "Invalid Unicode");
			}
		    }
		}
		*out->cur++ = *str;
		break;
	    case '2':
		*out->cur++ = '\\';
		switch (*str) {
		case '\\':	*out->cur++ = '\\';	break;
		case '\b':	*out->cur++ = 'b';	break;
		case '\t':	*out->cur++ = 't';	break;
		case '\n':	*out->cur++ = 'n';	break;
		case '\f':	*out->cur++ = 'f';	break;
		case '\r':	*out->cur++ = 'r';	break;
		default:	*out->cur++ = *str;	break;
		}
		break;
	    case '3': // Unicode
		if (0xe2 == (uint8_t)*str && JXEsc == out->opts->escape_mode && 2 <= end - str) {
		    if (0x80 == (uint8_t)str[1] && (0xa8 == (uint8_t)str[2] || 0xa9 == (uint8_t)str[2])) {
			str = dump_unicode(str, end, out);
		    } else {
			check_start = check_unicode(str, end);
			*out->cur++ = *str;
		    }
		    break;
		}
		str = dump_unicode(str, end, out);
		break;
	    case '6': // control characters
		if (*(uint8_t*)str < 0x80) {
		    *out->cur++ = '\\';
		    *out->cur++ = 'u';
		    *out->cur++ = '0';
		    *out->cur++ = '0';
		    dump_hex((uint8_t)*str, out);
		} else {
		    if (0xe2 == (uint8_t)*str && JXEsc == out->opts->escape_mode && 2 <= end - str) {
			if (0x80 == (uint8_t)str[1] && (0xa8 == (uint8_t)str[2] || 0xa9 == (uint8_t)str[2])) {
			    str = dump_unicode(str, end, out);
			} else {
			    check_start = check_unicode(str, end);
			    *out->cur++ = *str;
			}
			break;
		    }
		    str = dump_unicode(str, end, out);
		}
		break;
	    default:
		break; // ignore, should never happen if the table is correct
	    }
	}
	*out->cur++ = '"'; 
    }
    if (JXEsc == out->opts->escape_mode && 0 < str - orig && 0 != (0x80 & *(str - 1))) {
	uint8_t	c = (uint8_t)*(str - 1);
	int	i;
	int	scnt = (int)(str - orig);
	
	// Last utf-8 characters must be 0x10xxxxxx. The start must be
	// 0x110xxxxx for 2 characters, 0x1110xxxx for 3, and 0x11110xxx for
	// 4.
	if (0 != (0x40 & c)) {
	    debug_raise(orig, cnt, __LINE__);
	}
	for (i = 1; i < (int)scnt && i < 4; i++) {
	    c = str[-1 - i];
	    if (0x80 != (0xC0 & c)) {
		switch (i) {
		case 1:
		    if (0xC0 != (0xE0 & c)) {
			debug_raise(orig, cnt, __LINE__);
		    }
		    break;
		case 2:
		    if (0xE0 != (0xF0 & c)) {
			debug_raise(orig, cnt, __LINE__);
		    }
		    break;
		case 3:
		    if (0xF0 != (0xF8 & c)) {
			debug_raise(orig, cnt, __LINE__);
		    }
		    break;
		default: // can't get here
		    break;
		}
		break;
	    }
	}
	if (i == (int)scnt || 4 <= i) {
	    debug_raise(orig, cnt, __LINE__);
	}
    }
    *out->cur = '\0';
}

void
oj_dump_class(VALUE obj, int depth, Out out, bool as_ok) {
    const char	*s = rb_class2name(obj);

    oj_dump_cstr(s, strlen(s), 0, 0, out);
}

void
oj_dump_obj_to_s(VALUE obj, Out out) {
    volatile VALUE	rstr = rb_funcall(obj, oj_to_s_id, 0);

    oj_dump_cstr(rb_string_value_ptr((VALUE*)&rstr), RSTRING_LEN(rstr), 0, 0, out);
}

void
oj_dump_raw(const char *str, size_t cnt, Out out) {
    assure_size(out, cnt + 10);
    memcpy(out->cur, str, cnt);
    out->cur += cnt;
    *out->cur = '\0';
}

void
oj_grow_out(Out out, size_t len) {
    size_t  size = out->end - out->buf;
    long    pos = out->cur - out->buf;
    char    *buf;
	
    size *= 2;
    if (size <= len * 2 + pos) {
	size += len;
    }
    if (out->allocated) {
	buf = REALLOC_N(out->buf, char, (size + BUFFER_EXTRA));
    } else {
	buf = ALLOC_N(char, (size + BUFFER_EXTRA));
	out->allocated = true;
	memcpy(buf, out->buf, out->end - out->buf + BUFFER_EXTRA);
    }
    if (0 == buf) {
	rb_raise(rb_eNoMemError, "Failed to create string. [%d:%s]", ENOSPC, strerror(ENOSPC));
    }
    out->buf = buf;
    out->end = buf + size;
    out->cur = out->buf + pos;
}

void
oj_dump_nil(VALUE obj, int depth, Out out, bool as_ok) {
    assure_size(out, 4);
    *out->cur++ = 'n';
    *out->cur++ = 'u';
    *out->cur++ = 'l';
    *out->cur++ = 'l';
    *out->cur = '\0';
}

void
oj_dump_true(VALUE obj, int depth, Out out, bool as_ok) {
    assure_size(out, 4);
    *out->cur++ = 't';
    *out->cur++ = 'r';
    *out->cur++ = 'u';
    *out->cur++ = 'e';
    *out->cur = '\0';
}

void
oj_dump_false(VALUE obj, int depth, Out out, bool as_ok) {
    assure_size(out, 5);
    *out->cur++ = 'f';
    *out->cur++ = 'a';
    *out->cur++ = 'l';
    *out->cur++ = 's';
    *out->cur++ = 'e';
    *out->cur = '\0';
}

void
oj_dump_fixnum(VALUE obj, int depth, Out out, bool as_ok) {
    char	buf[32];
    char	*b = buf + sizeof(buf) - 1;
    long long	num = rb_num2ll(obj);
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
    assure_size(out, (sizeof(buf) - (b - buf)));
    for (; '\0' != *b; b++) {
	*out->cur++ = *b;
    }
    *out->cur = '\0';
}

void
oj_dump_bignum(VALUE obj, int depth, Out out, bool as_ok) {
    volatile VALUE	rs = rb_big2str(obj, 10);
    int			cnt = (int)RSTRING_LEN(rs);

    assure_size(out, cnt);
    memcpy(out->cur, rb_string_value_ptr((VALUE*)&rs), cnt);
    out->cur += cnt;
    *out->cur = '\0';
}

// Removed dependencies on math due to problems with CentOS 5.4.
void
oj_dump_float(VALUE obj, int depth, Out out, bool as_ok) {
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
    } else if (OJ_INFINITY == d) {
	if (ObjectMode == out->opts->mode) {
	    strcpy(buf, inf_val);
	    cnt = sizeof(inf_val) - 1;
	} else {
	    NanDump	nd = out->opts->dump_opts.nan_dump;
	    
	    if (AutoNan == nd) {
		switch (out->opts->mode) {
		case CompatMode:	nd = WordNan;	break;
		case StrictMode:	nd = RaiseNan;	break;
		case NullMode:		nd = NullNan;	break;
		case CustomMode:	nd = NullNan;	break;
		default:				break;
		}
	    }
	    switch (nd) {
	    case RaiseNan:
		raise_strict(obj);
		break;
	    case WordNan:
		strcpy(buf, "Infinity");
		cnt = 8;
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
	}
    } else if (-OJ_INFINITY == d) {
	if (ObjectMode == out->opts->mode) {
	    strcpy(buf, ninf_val);
	    cnt = sizeof(ninf_val) - 1;
	} else {
	    NanDump	nd = out->opts->dump_opts.nan_dump;
	    
	    if (AutoNan == nd) {
		switch (out->opts->mode) {
		case CompatMode:	nd = WordNan;	break;
		case StrictMode:	nd = RaiseNan;	break;
		case NullMode:		nd = NullNan;	break;
		default:				break;
		}
	    }
	    switch (nd) {
	    case RaiseNan:
		raise_strict(obj);
		break;
	    case WordNan:
		strcpy(buf, "-Infinity");
		cnt = 9;
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
	}
    } else if (isnan(d)) {
	if (ObjectMode == out->opts->mode) {
	    strcpy(buf, nan_val);
	    cnt = sizeof(ninf_val) - 1;
	} else {
	    NanDump	nd = out->opts->dump_opts.nan_dump;
	    
	    if (AutoNan == nd) {
		switch (out->opts->mode) {
		case ObjectMode:	nd = HugeNan;	break;
		case StrictMode:	nd = RaiseNan;	break;
		case NullMode:		nd = NullNan;	break;
		default:				break;
		}
	    }
	    switch (nd) {
	    case RaiseNan:
		raise_strict(obj);
		break;
	    case WordNan:
		strcpy(buf, "NaN");
		cnt = 3;
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
    assure_size(out, cnt);
    for (b = buf; '\0' != *b; b++) {
	*out->cur++ = *b;
    }
    *out->cur = '\0';
}

int
oj_dump_float_printf(char *buf, size_t blen, VALUE obj, double d, const char *format) {
    int	cnt = snprintf(buf, blen, format, d);

    // Round off issues at 16 significant digits so check for obvious ones of
    // 0001 and 9999.
    if (17 <= cnt && (0 == strcmp("0001", buf + cnt - 4) || 0 == strcmp("9999", buf + cnt - 4))) {
	volatile VALUE	rstr = rb_funcall(obj, oj_to_s_id, 0);

	strcpy(buf, rb_string_value_ptr((VALUE*)&rstr));
	cnt = (int)RSTRING_LEN(rstr);
    }
    return cnt;
}

bool
oj_dump_ignore(Options opts, VALUE obj) {
    if (NULL != opts->ignore && (ObjectMode == opts->mode || CustomMode == opts->mode)) {
	VALUE	*vp = opts->ignore;
	VALUE	clas = rb_obj_class(obj);

	for (; Qnil != *vp; vp++) {
	    if (clas == *vp) {
		return true;
	    }
	}
    }
    return false;
}

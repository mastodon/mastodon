/* saj.c
 * Copyright (c) 2012, Peter Ohler
 * All rights reserved.
 */

#if !IS_WINDOWS
#include <sys/resource.h>  /* for getrlimit() on linux */
#endif
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <sys/types.h>
#include <unistd.h>

// Workaround in case INFINITY is not defined in math.h or if the OS is CentOS
#define OJ_INFINITY (1.0/0.0)

#include "oj.h"
#include "encode.h"

typedef struct _ParseInfo {
    char	*str;		/* buffer being read from */
    char	*s;		/* current position in buffer */
    void	*stack_min;
    VALUE	handler;
    int		has_hash_start;
    int		has_hash_end;
    int		has_array_start;
    int		has_array_end;
    int		has_add_value;
    int		has_error;
} *ParseInfo;

static void	read_next(ParseInfo pi, const char *key);
static void	read_hash(ParseInfo pi, const char *key);
static void	read_array(ParseInfo pi, const char *key);
static void	read_str(ParseInfo pi, const char *key);
static void	read_num(ParseInfo pi, const char *key);
static void	read_true(ParseInfo pi, const char *key);
static void	read_false(ParseInfo pi, const char *key);
static void	read_nil(ParseInfo pi, const char *key);
static void	next_non_white(ParseInfo pi);
static char*	read_quoted_value(ParseInfo pi);
static void	skip_comment(ParseInfo pi);

/* This JSON parser is a single pass, destructive, callback parser. It is a
 * single pass parse since it only make one pass over the characters in the
 * JSON document string. It is destructive because it re-uses the content of
 * the string for values in the callback and places \0 characters at various
 * places to mark the end of tokens and strings. It is a callback parser like
 * a SAX parser because it uses callback when document elements are
 * encountered.
 *
 * Parsing is very tolerant. Lack of headers and even misspelled element
 * endings are passed over without raising an error. A best attempt is made in
 * all cases to parse the string.
 */

inline static void
call_error(const char *msg, ParseInfo pi, const char* file, int line) {
    char	buf[128];
    const char	*s = pi->s;
    int		jline = 1;
    int		col = 1;

    for (; pi->str < s && '\n' != *s; s--) {
	col++;
    }
    for (; pi->str < s; s--) {
	if ('\n' == *s) {
	    jline++;
	}
    }
    sprintf(buf, "%s at line %d, column %d [%s:%d]", msg, jline, col, file, line);
    rb_funcall(pi->handler, oj_error_id, 3, rb_str_new2(buf), LONG2NUM(jline), LONG2NUM(col));
}

inline static void
next_non_white(ParseInfo pi) {
    for (; 1; pi->s++) {
	switch(*pi->s) {
	case ' ':
	case '\t':
	case '\f':
	case '\n':
	case '\r':
	    break;
	case '/':
	    skip_comment(pi);
	    break;
	default:
	    return;
	}
    }
}

inline static void
call_add_value(VALUE handler, VALUE value, const char *key) {
    volatile VALUE	k;

    if (0 == key) {
	k = Qnil;
    } else {
	k = rb_str_new2(key);
	k = oj_encode(k);
    }
    rb_funcall(handler, oj_add_value_id, 2, value, k);
}

inline static void
call_no_value(VALUE handler, ID method, const char *key) {
    volatile VALUE	k;

    if (0 == key) {
	k = Qnil;
    } else {
	k = rb_str_new2(key);
	k = oj_encode(k);
    }
    rb_funcall(handler, method, 1, k);
}

static void
skip_comment(ParseInfo pi) {
    pi->s++; /* skip first / */
    if ('*' == *pi->s) {
	pi->s++;
	for (; '\0' != *pi->s; pi->s++) {
	    if ('*' == *pi->s && '/' == *(pi->s + 1)) {
		pi->s++;
		return;
	    } else if ('\0' == *pi->s) {
		if (pi->has_error) {
		    call_error("comment not terminated", pi, __FILE__, __LINE__);
		} else {
		    raise_error("comment not terminated", pi->str, pi->s);
		}
	    }
	}
    } else if ('/' == *pi->s) {
	for (; 1; pi->s++) {
	    switch (*pi->s) {
	    case '\n':
	    case '\r':
	    case '\f':
	    case '\0':
		return;
	    default:
		break;
	    }
	}
    } else {
	if (pi->has_error) {
	    call_error("invalid comment", pi, __FILE__, __LINE__);
	} else {
	    raise_error("invalid comment", pi->str, pi->s);
	}
    }
}

static void
read_next(ParseInfo pi, const char *key) {
    VALUE	obj;

    if ((void*)&obj < pi->stack_min) {
	rb_raise(rb_eSysStackError, "JSON is too deeply nested");
    }
    next_non_white(pi);	/* skip white space */
    switch (*pi->s) {
    case '{':
	read_hash(pi, key);
	break;
    case '[':
	read_array(pi, key);
	break;
    case '"':
	read_str(pi, key);
	break;
    case '+':
    case '-':
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
	read_num(pi, key);
	break;
    case 'I':
	read_num(pi, key);
	break;
    case 't':
	read_true(pi, key);
	break;
    case 'f':
	read_false(pi, key);
	break;
    case 'n':
	read_nil(pi, key);
	break;
    case '\0':
	return;
    default:
	return;
    }
}

static void
read_hash(ParseInfo pi, const char *key) {
    const char	*ks;
    
    if (pi->has_hash_start) {
	call_no_value(pi->handler, oj_hash_start_id, key);
    }
    pi->s++;
    next_non_white(pi);
    if ('}' == *pi->s) {
	pi->s++;
    } else {
	while (1) {
	    next_non_white(pi);
	    ks = read_quoted_value(pi);
	    next_non_white(pi);
	    if (':' == *pi->s) {
		pi->s++;
	    } else {
		if (pi->has_error) {
		    call_error("invalid format, expected :", pi, __FILE__, __LINE__);
		}
		raise_error("invalid format, expected :", pi->str, pi->s);
	    }
	    read_next(pi, ks);
	    next_non_white(pi);
	    if ('}' == *pi->s) {
		pi->s++;
		break;
	    } else if (',' == *pi->s) {
		pi->s++;
	    } else {
		if (pi->has_error) {
		    call_error("invalid format, expected , or } while in an object", pi, __FILE__, __LINE__);
		}
		raise_error("invalid format, expected , or } while in an object", pi->str, pi->s);
	    }
	}
    }
    if (pi->has_hash_end) {
	call_no_value(pi->handler, oj_hash_end_id, key);
    }
}

static void
read_array(ParseInfo pi, const char *key) {
    if (pi->has_array_start) {
	call_no_value(pi->handler, oj_array_start_id, key);
    }
    pi->s++;
    next_non_white(pi);
    if (']' == *pi->s) {
	pi->s++;
    } else {
	while (1) {
	    read_next(pi, 0);
	    next_non_white(pi);
	    if (',' == *pi->s) {
		pi->s++;
	    } else if (']' == *pi->s) {
		pi->s++;
		break;
	    } else {
		if (pi->has_error) {
		    call_error("invalid format, expected , or ] while in an array", pi, __FILE__, __LINE__);
		}
		raise_error("invalid format, expected , or ] while in an array", pi->str, pi->s);
	    }
	}
    }
    if (pi->has_array_end) {
	call_no_value(pi->handler, oj_array_end_id, key);
    }
}

static void
read_str(ParseInfo pi, const char *key) {
    char	*text;

    text = read_quoted_value(pi);
    if (pi->has_add_value) {
	VALUE	s = rb_str_new2(text);

	s = oj_encode(s);
	call_add_value(pi->handler, s, key);
    }
}

#ifdef RUBINIUS_RUBY
#define NUM_MAX 0x07FFFFFF
#else
#define NUM_MAX (FIXNUM_MAX >> 8)
#endif

static void
read_num(ParseInfo pi, const char *key) {
    char	*start = pi->s;
    int64_t	n = 0;
    long	a = 0;
    long	div = 1;
    long	e = 0;
    int		neg = 0;
    int		eneg = 0;
    int		big = 0;

    if ('-' == *pi->s) {
	pi->s++;
	neg = 1;
    } else if ('+' == *pi->s) {
	pi->s++;
    }
    if ('I' == *pi->s) {
	if (0 != strncmp("Infinity", pi->s, 8)) {
	    if (pi->has_error) {
		call_error("number or other value", pi, __FILE__, __LINE__);
	    }
	    raise_error("number or other value", pi->str, pi->s);
	}
	pi->s += 8;
	if (neg) {
	    if (pi->has_add_value) {
		call_add_value(pi->handler, rb_float_new(-OJ_INFINITY), key);
	    }
	} else {
	    if (pi->has_add_value) {
		call_add_value(pi->handler, rb_float_new(OJ_INFINITY), key);
	    }
	}
	return;
    }
    for (; '0' <= *pi->s && *pi->s <= '9'; pi->s++) {
	if (big) {
	    big++;
	} else {
	    n = n * 10 + (*pi->s - '0');
	    if (NUM_MAX <= n) {
		big = 1;
	    }
	}
    }
    if ('.' == *pi->s) {
	pi->s++;
	for (; '0' <= *pi->s && *pi->s <= '9'; pi->s++) {
	    a = a * 10 + (*pi->s - '0');
	    div *= 10;
	    if (NUM_MAX <= div) {
		big = 1;
	    }
	}
    }
    if ('e' == *pi->s || 'E' == *pi->s) {
	pi->s++;
	if ('-' == *pi->s) {
	    pi->s++;
	    eneg = 1;
	} else if ('+' == *pi->s) {
	    pi->s++;
	}
	for (; '0' <= *pi->s && *pi->s <= '9'; pi->s++) {
	    e = e * 10 + (*pi->s - '0');
	    if (NUM_MAX <= e) {
		big = 1;
	    }
	}
    }
    if (0 == e && 0 == a && 1 == div) {
	if (big) {
	    char	c = *pi->s;
	
	    *pi->s = '\0';
	    if (pi->has_add_value) {
		call_add_value(pi->handler, rb_funcall(rb_cObject, oj_bigdecimal_id, 1, rb_str_new2(start)), key);
	    }
	    *pi->s = c;
	} else {
	    if (neg) {
		n = -n;
	    }
	    if (pi->has_add_value) {
		call_add_value(pi->handler, LONG2NUM(n), key);
	    }
	}
	return;
    } else { /* decimal */
	if (big) {
	    char	c = *pi->s;
	
	    *pi->s = '\0';
	    if (pi->has_add_value) {
		call_add_value(pi->handler, rb_funcall(rb_cObject, oj_bigdecimal_id, 1, rb_str_new2(start)), key);
	    }
	    *pi->s = c;
	} else {
	    double	d = (double)n + (double)a / (double)div;

	    if (neg) {
		d = -d;
	    }
	    if (1 < big) {
		e += big - 1;
	    }
	    if (0 != e) {
		if (eneg) {
		    e = -e;
		}
		d *= pow(10.0, e);
	    }
	    if (pi->has_add_value) {
		call_add_value(pi->handler, rb_float_new(d), key);
	    }
	}
    }
}

static void
read_true(ParseInfo pi, const char *key) {
    pi->s++;
    if ('r' != *pi->s || 'u' != *(pi->s + 1) || 'e' != *(pi->s + 2)) {
	if (pi->has_error) {
	    call_error("invalid format, expected 'true'", pi, __FILE__, __LINE__);
	}
	raise_error("invalid format, expected 'true'", pi->str, pi->s);
    }
    pi->s += 3;
    if (pi->has_add_value) {
	call_add_value(pi->handler, Qtrue, key);
    }
}

static void
read_false(ParseInfo pi, const char *key) {
    pi->s++;
    if ('a' != *pi->s || 'l' != *(pi->s + 1) || 's' != *(pi->s + 2) || 'e' != *(pi->s + 3)) {
	if (pi->has_error) {
	    call_error("invalid format, expected 'false'", pi, __FILE__, __LINE__);
	}
	raise_error("invalid format, expected 'false'", pi->str, pi->s);
    }
    pi->s += 4;
    if (pi->has_add_value) {
	call_add_value(pi->handler, Qfalse, key);
    }
}

static void
read_nil(ParseInfo pi, const char *key) {
    pi->s++;
    if ('u' != *pi->s || 'l' != *(pi->s + 1) || 'l' != *(pi->s + 2)) {
	if (pi->has_error) {
	    call_error("invalid format, expected 'null'", pi, __FILE__, __LINE__);
	}
	raise_error("invalid format, expected 'null'", pi->str, pi->s);
    }
    pi->s += 3;
    if (pi->has_add_value) {
	call_add_value(pi->handler, Qnil, key);
    }
}

static uint32_t
read_hex(ParseInfo pi, char *h) {
    uint32_t	b = 0;
    int		i;

    /* TBD this can be made faster with a table */
    for (i = 0; i < 4; i++, h++) {
	b = b << 4;
	if ('0' <= *h && *h <= '9') {
	    b += *h - '0';
	} else if ('A' <= *h && *h <= 'F') {
	    b += *h - 'A' + 10;
	} else if ('a' <= *h && *h <= 'f') {
	    b += *h - 'a' + 10;
	} else {
	    pi->s = h;
	    if (pi->has_error) {
		call_error("invalid hex character", pi, __FILE__, __LINE__);
	    }
	    raise_error("invalid hex character", pi->str, pi->s);
	}
    }
    return b;
}

static char*
unicode_to_chars(ParseInfo pi, char *t, uint32_t code) {
    if (0x0000007F >= code) {
	*t = (char)code;
    } else if (0x000007FF >= code) {
	*t++ = 0xC0 | (code >> 6);
	*t = 0x80 | (0x3F & code);
    } else if (0x0000FFFF >= code) {
	*t++ = 0xE0 | (code >> 12);
	*t++ = 0x80 | ((code >> 6) & 0x3F);
	*t = 0x80 | (0x3F & code);
    } else if (0x001FFFFF >= code) {
	*t++ = 0xF0 | (code >> 18);
	*t++ = 0x80 | ((code >> 12) & 0x3F);
	*t++ = 0x80 | ((code >> 6) & 0x3F);
	*t = 0x80 | (0x3F & code);
    } else if (0x03FFFFFF >= code) {
	*t++ = 0xF8 | (code >> 24);
	*t++ = 0x80 | ((code >> 18) & 0x3F);
	*t++ = 0x80 | ((code >> 12) & 0x3F);
	*t++ = 0x80 | ((code >> 6) & 0x3F);
	*t = 0x80 | (0x3F & code);
    } else if (0x7FFFFFFF >= code) {
	*t++ = 0xFC | (code >> 30);
	*t++ = 0x80 | ((code >> 24) & 0x3F);
	*t++ = 0x80 | ((code >> 18) & 0x3F);
	*t++ = 0x80 | ((code >> 12) & 0x3F);
	*t++ = 0x80 | ((code >> 6) & 0x3F);
	*t = 0x80 | (0x3F & code);
    } else {
	if (pi->has_error) {
	    call_error("invalid Unicode", pi, __FILE__, __LINE__);
	}
	raise_error("invalid Unicode", pi->str, pi->s);
    }
    return t;
}

/* Assume the value starts immediately and goes until the quote character is
 * reached again. Do not read the character after the terminating quote.
 */
static char*
read_quoted_value(ParseInfo pi) {
    char	*value = 0;
    char	*h = pi->s; /* head */
    char	*t = h;	    /* tail */
    uint32_t	code;
    
    h++;	/* skip quote character */
    t++;
    value = h;
    for (; '"' != *h; h++, t++) {
	if ('\0' == *h) {
	    pi->s = h;
	    raise_error("quoted string not terminated", pi->str, pi->s);
	} else if ('\\' == *h) {
	    h++;
	    switch (*h) {
	    case 'n':	*t = '\n';	break;
	    case 'r':	*t = '\r';	break;
	    case 't':	*t = '\t';	break;
	    case 'f':	*t = '\f';	break;
	    case 'b':	*t = '\b';	break;
	    case '"':	*t = '"';	break;
	    case '/':	*t = '/';	break;
	    case '\\':	*t = '\\';	break;
	    case 'u':
		h++;
		code = read_hex(pi, h);
		h += 3;
		if (0x0000D800 <= code && code <= 0x0000DFFF) {
		    uint32_t	c1 = (code - 0x0000D800) & 0x000003FF;
		    uint32_t	c2;

		    h++;
		    if ('\\' != *h || 'u' != *(h + 1)) {
			pi->s = h;
			if (pi->has_error) {
			    call_error("invalid escaped character", pi, __FILE__, __LINE__);
			}
			raise_error("invalid escaped character", pi->str, pi->s);
		    }
		    h += 2;
		    c2 = read_hex(pi, h);
		    h += 3;
		    c2 = (c2 - 0x0000DC00) & 0x000003FF;
		    code = ((c1 << 10) | c2) + 0x00010000;
		}
		t = unicode_to_chars(pi, t, code);
		break;
	    default:
		pi->s = h;
		if (pi->has_error) {
		    call_error("invalid escaped character", pi, __FILE__, __LINE__);
		}
		raise_error("invalid escaped character", pi->str, pi->s);
		break;
	    }
	} else if (t != h) {
	    *t = *h;
	}
    }
    *t = '\0'; /* terminate value */
    pi->s = h + 1;

    return value;
}

static void
saj_parse(VALUE handler, char *json) {
    volatile VALUE	obj = Qnil;
    struct _ParseInfo	pi;

    if (0 == json) {
	if (pi.has_error) {
	    call_error("Invalid arg, xml string can not be null", &pi, __FILE__, __LINE__);
	}
	raise_error("Invalid arg, xml string can not be null", json, 0);
    }
    /* skip UTF-8 BOM if present */
    if (0xEF == (uint8_t)*json && 0xBB == (uint8_t)json[1] && 0xBF == (uint8_t)json[2]) {
	json += 3;
    }
    /* initialize parse info */
    pi.str = json;
    pi.s = json;
#if IS_WINDOWS
    pi.stack_min = (void*)((char*)&obj - (512 * 1024)); /* assume a 1M stack and give half to ruby */
#else
    {
	struct rlimit	lim;

	if (0 == getrlimit(RLIMIT_STACK, &lim)) {
	    pi.stack_min = (void*)((char*)&obj - (lim.rlim_cur / 4 * 3)); /* let 3/4ths of the stack be used only */
	} else {
	    pi.stack_min = 0; /* indicates not to check stack limit */
	}
    }
#endif
    pi.handler = handler;
    pi.has_hash_start = rb_respond_to(handler, oj_hash_start_id);
    pi.has_hash_end = rb_respond_to(handler, oj_hash_end_id);
    pi.has_array_start = rb_respond_to(handler, oj_array_start_id);
    pi.has_array_end = rb_respond_to(handler, oj_array_end_id);
    pi.has_add_value = rb_respond_to(handler, oj_add_value_id);
    pi.has_error = rb_respond_to(handler, oj_error_id);
    read_next(&pi, 0);
    next_non_white(&pi);
    if ('\0' != *pi.s) {
	if (pi.has_error) {
	    call_error("invalid format, extra characters", &pi, __FILE__, __LINE__);
	} else {
	    raise_error("invalid format, extra characters", pi.str, pi.s);
	}
    }
}

/* call-seq: saj_parse(handler, io)
 *
 * Parses an IO stream or file containing an JSON document. Raises an exception
 * if the JSON is malformed.
 * @param [Oj::Saj] handler Saj (responds to Oj::Saj methods) like handler
 * @param [IO|String] io IO Object to read from
 * @deprecated The sc_parse() method along with the ScHandler is the preferred
 * callback parser. It is slightly faster and handles streams while the
 * saj_parse() methos requires a complete read before parsing.
 * @see sc_parse
 */
VALUE
oj_saj_parse(int argc, VALUE *argv, VALUE self) {
    char	*json = 0;
    size_t	len = 0;
    VALUE	input = argv[1];

    if (argc < 2) {
	rb_raise(rb_eArgError, "Wrong number of arguments to saj_parse.\n");
    }
    if (rb_type(input) == T_STRING) {
	// the json string gets modified so make a copy of it
	len = RSTRING_LEN(input) + 1;
	json = ALLOC_N(char, len);
	strcpy(json, StringValuePtr(input));
    } else {
	VALUE		clas = rb_obj_class(input);
	volatile VALUE	s;
	
	if (oj_stringio_class == clas) {
	    s = rb_funcall2(input, oj_string_id, 0, 0);
	    len = RSTRING_LEN(s) + 1;
	    json = ALLOC_N(char, len);
	    strcpy(json, rb_string_value_cstr((VALUE*)&s));
#if !IS_WINDOWS
	} else if (rb_cFile == clas && 0 == FIX2INT(rb_funcall(input, oj_pos_id, 0))) {
	    int		fd = FIX2INT(rb_funcall(input, oj_fileno_id, 0));
	    ssize_t	cnt;

	    len = lseek(fd, 0, SEEK_END);
	    lseek(fd, 0, SEEK_SET);
	    json = ALLOC_N(char, len + 1);
	    if (0 >= (cnt = read(fd, json, len)) || cnt != (ssize_t)len) {
		rb_raise(rb_eIOError, "failed to read from IO Object.");
	    }
	    json[len] = '\0';
#endif
	} else if (rb_respond_to(input, oj_read_id)) {
	    s = rb_funcall2(input, oj_read_id, 0, 0);
	    len = RSTRING_LEN(s) + 1;
	    json = ALLOC_N(char, len);
	    strcpy(json, rb_string_value_cstr((VALUE*)&s));
	} else {
	    rb_raise(rb_eArgError, "saj_parse() expected a String or IO Object.");
	}
    }
    saj_parse(*argv, json);
    xfree(json);

    return Qnil;
}

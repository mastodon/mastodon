/* parse.c
 * Copyright (c) 2013, Peter Ohler
 * All rights reserved.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <math.h>

#include "oj.h"
#include "encode.h"
#include "parse.h"
#include "buf.h"
#include "val_stack.h"
#include "rxclass.h"

// Workaround in case INFINITY is not defined in math.h or if the OS is CentOS
#define OJ_INFINITY	(1.0/0.0)

//#define EXP_MAX		1023
#define EXP_MAX		100000
#define DEC_MAX		15

static void
next_non_white(ParseInfo pi) {
    for (; 1; pi->cur++) {
	switch(*pi->cur) {
	case ' ':
	case '\t':
	case '\f':
	case '\n':
	case '\r':
	    break;
	default:
	    return;
	}
    }
}

static void
skip_comment(ParseInfo pi) {
    if ('*' == *pi->cur) {
	pi->cur++;
	for (; pi->cur < pi->end; pi->cur++) {
	    if ('*' == *pi->cur && '/' == *(pi->cur + 1)) {
		pi->cur += 2;
		return;
	    } else if (pi->end <= pi->cur) {
		oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "comment not terminated");
		return;
	    }
	}
    } else if ('/' == *pi->cur) {
	for (; 1; pi->cur++) {
	    switch (*pi->cur) {
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
	oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "invalid comment format");
    }
}

static void
add_value(ParseInfo pi, VALUE rval) {
    Val	parent = stack_peek(&pi->stack);

    if (0 == parent) { // simple add
	pi->add_value(pi, rval);
    } else {
	switch (parent->next) {
	case NEXT_ARRAY_NEW:
	case NEXT_ARRAY_ELEMENT:
	    pi->array_append_value(pi, rval);
	    parent->next = NEXT_ARRAY_COMMA;
	    break;
	case NEXT_HASH_VALUE:
	    pi->hash_set_value(pi, parent, rval);
	    if (0 != parent->key && 0 < parent->klen && (parent->key < pi->json || pi->cur < parent->key)) {
		xfree((char*)parent->key);
		parent->key = 0;
	    }
	    parent->next = NEXT_HASH_COMMA;
	    break;
	case NEXT_HASH_NEW:
	case NEXT_HASH_KEY:
	case NEXT_HASH_COMMA:
	case NEXT_NONE:
	case NEXT_ARRAY_COMMA:
	case NEXT_HASH_COLON:
	default:
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "expected %s", oj_stack_next_string(parent->next));
	    break;
	}
    }
}

static void
read_null(ParseInfo pi) {
    if ('u' == *pi->cur++ && 'l' == *pi->cur++ && 'l' == *pi->cur++) {
	add_value(pi, Qnil);
    } else {
	oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "expected null");
    }
}

static void
read_true(ParseInfo pi) {
    if ('r' == *pi->cur++ && 'u' == *pi->cur++ && 'e' == *pi->cur++) {
	add_value(pi, Qtrue);
    } else {
	oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "expected true");
    }
}

static void
read_false(ParseInfo pi) {
    if ('a' == *pi->cur++ && 'l' == *pi->cur++ && 's' == *pi->cur++ && 'e' == *pi->cur++) {
	add_value(pi, Qfalse);
    } else {
	oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "expected false");
    }
}

static uint32_t
read_hex(ParseInfo pi, const char *h) {
    uint32_t	b = 0;
    int		i;

    for (i = 0; i < 4; i++, h++) {
	b = b << 4;
	if ('0' <= *h && *h <= '9') {
	    b += *h - '0';
	} else if ('A' <= *h && *h <= 'F') {
	    b += *h - 'A' + 10;
	} else if ('a' <= *h && *h <= 'f') {
	    b += *h - 'a' + 10;
	} else {
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "invalid hex character");
	    return 0;
	}
    }
    return b;
}

static void
unicode_to_chars(ParseInfo pi, Buf buf, uint32_t code) {
    if (0x0000007F >= code) {
	buf_append(buf, (char)code);
    } else if (0x000007FF >= code) {
	buf_append(buf, 0xC0 | (code >> 6));
	buf_append(buf, 0x80 | (0x3F & code));
    } else if (0x0000FFFF >= code) {
	buf_append(buf, 0xE0 | (code >> 12));
	buf_append(buf, 0x80 | ((code >> 6) & 0x3F));
	buf_append(buf, 0x80 | (0x3F & code));
    } else if (0x001FFFFF >= code) {
	buf_append(buf, 0xF0 | (code >> 18));
	buf_append(buf, 0x80 | ((code >> 12) & 0x3F));
	buf_append(buf, 0x80 | ((code >> 6) & 0x3F));
	buf_append(buf, 0x80 | (0x3F & code));
    } else if (0x03FFFFFF >= code) {
	buf_append(buf, 0xF8 | (code >> 24));
	buf_append(buf, 0x80 | ((code >> 18) & 0x3F));
	buf_append(buf, 0x80 | ((code >> 12) & 0x3F));
	buf_append(buf, 0x80 | ((code >> 6) & 0x3F));
	buf_append(buf, 0x80 | (0x3F & code));
    } else if (0x7FFFFFFF >= code) {
	buf_append(buf, 0xFC | (code >> 30));
	buf_append(buf, 0x80 | ((code >> 24) & 0x3F));
	buf_append(buf, 0x80 | ((code >> 18) & 0x3F));
	buf_append(buf, 0x80 | ((code >> 12) & 0x3F));
	buf_append(buf, 0x80 | ((code >> 6) & 0x3F));
	buf_append(buf, 0x80 | (0x3F & code));
    } else {
	oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "invalid Unicode character");
    }
}

// entered at /
static void
read_escaped_str(ParseInfo pi, const char *start) {
    struct _Buf	buf;
    const char	*s;
    int		cnt = (int)(pi->cur - start);
    uint32_t	code;
    Val		parent = stack_peek(&pi->stack);

    buf_init(&buf);
    if (0 < cnt) {
	buf_append_string(&buf, start, cnt);
    }
    for (s = pi->cur; '"' != *s; s++) {
	if (s >= pi->end) {
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "quoted string not terminated");
	    buf_cleanup(&buf);
	    return;
	} else if ('\\' == *s) {
	    s++;
	    switch (*s) {
	    case 'n':	buf_append(&buf, '\n');	break;
	    case 'r':	buf_append(&buf, '\r');	break;
	    case 't':	buf_append(&buf, '\t');	break;
	    case 'f':	buf_append(&buf, '\f');	break;
	    case 'b':	buf_append(&buf, '\b');	break;
	    case '"':	buf_append(&buf, '"');	break;
	    case '/':	buf_append(&buf, '/');	break;
	    case '\\':	buf_append(&buf, '\\');	break;
	    case '\'':
		// The json gem claims this is not an error despite the
		// ECMA-404 indicating it is not valid.
		if (CompatMode == pi->options.mode) {
		    buf_append(&buf, '\'');
		} else {
		    pi->cur = s;
		    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "invalid escaped character");
		    buf_cleanup(&buf);
		    return;
		}
		break;
	    case 'u':
		s++;
		if (0 == (code = read_hex(pi, s)) && err_has(&pi->err)) {
		    buf_cleanup(&buf);
		    return;
		}
		s += 3;
		if (0x0000D800 <= code && code <= 0x0000DFFF) {
		    uint32_t	c1 = (code - 0x0000D800) & 0x000003FF;
		    uint32_t	c2;

		    s++;
		    if ('\\' != *s || 'u' != *(s + 1)) {
			if (Yes == pi->options.allow_invalid) {
			    s--;
			    unicode_to_chars(pi, &buf, code);
			    break;
			}
			pi->cur = s;
			oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "invalid escaped character");
			buf_cleanup(&buf);
			return;
		    }
		    s += 2;
		    if (0 == (c2 = read_hex(pi, s)) && err_has(&pi->err)) {
			buf_cleanup(&buf);
			return;
		    }
		    s += 3;
		    c2 = (c2 - 0x0000DC00) & 0x000003FF;
		    code = ((c1 << 10) | c2) + 0x00010000;
		}
		unicode_to_chars(pi, &buf, code);
		if (err_has(&pi->err)) {
		    buf_cleanup(&buf);
		    return;
		}
		break;
	    default:
		pi->cur = s;
		oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "invalid escaped character");
		buf_cleanup(&buf);
		return;
	    }
	} else {
	    buf_append(&buf, *s);
	}
    }
    if (0 == parent) {
	pi->add_cstr(pi, buf.head, buf_len(&buf), start);
    } else {
	switch (parent->next) {
	case NEXT_ARRAY_NEW:
	case NEXT_ARRAY_ELEMENT:
	    pi->array_append_cstr(pi, buf.head, buf_len(&buf), start);
	    parent->next = NEXT_ARRAY_COMMA;
	    break;
	case NEXT_HASH_NEW:
	case NEXT_HASH_KEY:
	    if (Qundef == (parent->key_val = pi->hash_key(pi, buf.head, buf_len(&buf)))) {
		parent->key = strdup(buf.head);
		parent->klen = buf_len(&buf);
	    } else {
		parent->key = "";
		parent->klen = 0;
	    }
	    parent->k1 = *start;
	    parent->next = NEXT_HASH_COLON;
	    break;
	case NEXT_HASH_VALUE:
	    pi->hash_set_cstr(pi, parent, buf.head, buf_len(&buf), start);
	    if (0 != parent->key && 0 < parent->klen && (parent->key < pi->json || pi->cur < parent->key)) {
		xfree((char*)parent->key);
		parent->key = 0;
	    }
	    parent->next = NEXT_HASH_COMMA;
	    break;
	case NEXT_HASH_COMMA:
	case NEXT_NONE:
	case NEXT_ARRAY_COMMA:
	case NEXT_HASH_COLON:
	default:
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "expected %s, not a string", oj_stack_next_string(parent->next));
	    break;
	}
    }
    pi->cur = s + 1;
    buf_cleanup(&buf);
}

static void
read_str(ParseInfo pi) {
    const char	*str = pi->cur;
    Val		parent = stack_peek(&pi->stack);

    for (; '"' != *pi->cur; pi->cur++) {
	if (pi->end <= pi->cur) {
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "quoted string not terminated");
	    return;
	} else if ('\0' == *pi->cur) {
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "NULL byte in string");
	    return;
	} else if ('\\' == *pi->cur) {
	    read_escaped_str(pi, str);
	    return;
	}
    }
    if (0 == parent) { // simple add
	pi->add_cstr(pi, str, pi->cur - str, str);
    } else {
	switch (parent->next) {
	case NEXT_ARRAY_NEW:
	case NEXT_ARRAY_ELEMENT:
	    pi->array_append_cstr(pi, str, pi->cur - str, str);
	    parent->next = NEXT_ARRAY_COMMA;
	    break;
	case NEXT_HASH_NEW:
	case NEXT_HASH_KEY:
	    if (Qundef == (parent->key_val = pi->hash_key(pi, str, pi->cur - str))) {
		parent->key = str;
		parent->klen = pi->cur - str;
	    } else {
		parent->key = "";
		parent->klen = 0;
	    }
	    parent->k1 = *str;
	    parent->next = NEXT_HASH_COLON;
	    break;
	case NEXT_HASH_VALUE:
	    pi->hash_set_cstr(pi, parent, str, pi->cur - str, str);
	    if (0 != parent->key && 0 < parent->klen && (parent->key < pi->json || pi->cur < parent->key)) {
		xfree((char*)parent->key);
		parent->key = 0;
	    }
	    parent->next = NEXT_HASH_COMMA;
	    break;
	case NEXT_HASH_COMMA:
	case NEXT_NONE:
	case NEXT_ARRAY_COMMA:
	case NEXT_HASH_COLON:
	default:
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "expected %s, not a string", oj_stack_next_string(parent->next));
	    break;
	}
    }
    pi->cur++; // move past "
}

static void
read_num(ParseInfo pi) {
    struct _NumInfo	ni;
    Val			parent = stack_peek(&pi->stack);

    ni.str = pi->cur;
    ni.i = 0;
    ni.num = 0;
    ni.div = 1;
    ni.di = 0;
    ni.len = 0;
    ni.exp = 0;
    ni.big = 0;
    ni.infinity = 0;
    ni.nan = 0;
    ni.neg = 0;
    ni.hasExp = 0;
    ni.no_big = (FloatDec == pi->options.bigdec_load);

    if ('-' == *pi->cur) {
	pi->cur++;
	ni.neg = 1;
    } else if ('+' == *pi->cur) {
	pi->cur++;
    }
    if ('I' == *pi->cur) {
	if (No == pi->options.allow_nan || 0 != strncmp("Infinity", pi->cur, 8)) {
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "not a number or other value");
	    return;
	}
	pi->cur += 8;
	ni.infinity = 1;
    } else if ('N' == *pi->cur || 'n' == *pi->cur) {
	if ('a' != pi->cur[1] || ('N' != pi->cur[2] && 'n' != pi->cur[2])) {
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "not a number or other value");
	    return;
	}
	pi->cur += 3;
	ni.nan = 1;
    } else {
	int	dec_cnt = 0;
	bool	zero1 = false;
	
	for (; '0' <= *pi->cur && *pi->cur <= '9'; pi->cur++) {
	    if (0 == ni.i && '0' == *pi->cur) {
		zero1 = true;
	    }
	    if (0 < ni.i) {
		dec_cnt++;
	    }
	    if (!ni.big) {
		int	d = (*pi->cur - '0');

		if (0 < d) {
		    if (zero1 && CompatMode == pi->options.mode) {
			oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "not a number");
			return;
		    }
		    zero1 = false;
		}
		ni.i = ni.i * 10 + d;
		if (INT64_MAX <= ni.i || DEC_MAX < dec_cnt) {
		    ni.big = 1;
		}
	    }
	}
	if ('.' == *pi->cur) {
	    pi->cur++;
	    if (*pi->cur < '0' || '9' < *pi->cur) {
		oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "not a number");
		return;
	    }
	    for (; '0' <= *pi->cur && *pi->cur <= '9'; pi->cur++) {
		int	d = (*pi->cur - '0');

		if (0 < ni.num || 0 < ni.i) {
		    dec_cnt++;
		}
		ni.num = ni.num * 10 + d;
		ni.div *= 10;
		ni.di++;
		if (INT64_MAX <= ni.div || DEC_MAX < dec_cnt) {
		    ni.big = 1;
		}
	    }
	}
	if ('e' == *pi->cur || 'E' == *pi->cur) {
	    int	eneg = 0;

	    ni.hasExp = 1;
	    pi->cur++;
	    if ('-' == *pi->cur) {
		pi->cur++;
		eneg = 1;
	    } else if ('+' == *pi->cur) {
		pi->cur++;
	    }
	    for (; '0' <= *pi->cur && *pi->cur <= '9'; pi->cur++) {
		ni.exp = ni.exp * 10 + (*pi->cur - '0');
		if (EXP_MAX <= ni.exp) {
		    ni.big = 1;
		}
	    }
	    if (eneg) {
		ni.exp = -ni.exp;
	    }
	}
	ni.len = pi->cur - ni.str;
    }
    // Check for special reserved values for Infinity and NaN.
    if (ni.big) {
	if (0 == strcasecmp(INF_VAL, ni.str)) {
	    ni.infinity = 1;
	} else if (0 == strcasecmp(NINF_VAL, ni.str)) {
	    ni.infinity = 1;
	    ni.neg = 1;
	} else if (0 == strcasecmp(NAN_VAL, ni.str)) {
	    ni.nan = 1;
	}
    }
    if (BigDec == pi->options.bigdec_load) {
	ni.big = 1;
    }
    if (0 == parent) {
	pi->add_num(pi, &ni);
    } else {
	switch (parent->next) {
	case NEXT_ARRAY_NEW:
	case NEXT_ARRAY_ELEMENT:
	    pi->array_append_num(pi, &ni);
	    parent->next = NEXT_ARRAY_COMMA;
	    break;
	case NEXT_HASH_VALUE:
	    pi->hash_set_num(pi, parent, &ni);
	    if (0 != parent->key && 0 < parent->klen && (parent->key < pi->json || pi->cur < parent->key)) {
		xfree((char*)parent->key);
		parent->key = 0;
	    }
	    parent->next = NEXT_HASH_COMMA;
	    break;
	default:
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "expected %s", oj_stack_next_string(parent->next));
	    break;
	}
    }
}

static void
array_start(ParseInfo pi) {
    volatile VALUE	v = pi->start_array(pi);

    stack_push(&pi->stack, v, NEXT_ARRAY_NEW);
}

static void
array_end(ParseInfo pi) {
    Val	array = stack_pop(&pi->stack);

    if (0 == array) {
	oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "unexpected array close");
    } else if (NEXT_ARRAY_COMMA != array->next && NEXT_ARRAY_NEW != array->next) {
	oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "expected %s, not an array close", oj_stack_next_string(array->next));
    } else {
	pi->end_array(pi);
	add_value(pi, array->val);
    }
}

static void
hash_start(ParseInfo pi) {
    volatile VALUE	v = pi->start_hash(pi);

    stack_push(&pi->stack, v, NEXT_HASH_NEW);
}

static void
hash_end(ParseInfo pi) {
    volatile Val	hash = stack_peek(&pi->stack);

    // leave hash on stack until just before
    if (0 == hash) {
	oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "unexpected hash close");
    } else if (NEXT_HASH_COMMA != hash->next && NEXT_HASH_NEW != hash->next) {
	oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "expected %s, not a hash close", oj_stack_next_string(hash->next));
    } else {
	pi->end_hash(pi);
	stack_pop(&pi->stack);
	add_value(pi, hash->val);
    }
}

static void
comma(ParseInfo pi) {
    Val	parent = stack_peek(&pi->stack);

    if (0 == parent) {
	oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "unexpected comma");
    } else if (NEXT_ARRAY_COMMA == parent->next) {
	parent->next = NEXT_ARRAY_ELEMENT;
    } else if (NEXT_HASH_COMMA == parent->next) {
	parent->next = NEXT_HASH_KEY;
    } else {
	oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "unexpected comma");
    }
}

static void
colon(ParseInfo pi) {
    Val	parent = stack_peek(&pi->stack);

    if (0 != parent && NEXT_HASH_COLON == parent->next) {
	parent->next = NEXT_HASH_VALUE;
    } else {
	oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "unexpected colon");
    }
}

void
oj_parse2(ParseInfo pi) {
    int		first = 1;
    long	start = 0;

    pi->cur = pi->json;
    err_init(&pi->err);
    while (1) {
	if (0 < pi->max_depth && pi->max_depth <= pi->stack.tail - pi->stack.head - 1) {
	    VALUE	err_clas = oj_get_json_err_class("NestingError");
	    
	    oj_set_error_at(pi, err_clas, __FILE__, __LINE__, "Too deeply nested.");
	    pi->err_class = err_clas;
	    return;
	}
	next_non_white(pi);
	if (!first && '\0' != *pi->cur) {
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "unexpected characters after the JSON document");
	}

	// If no tokens are consumed (i.e. empty string), throw a parse error
	// this is the behavior of JSON.parse in both Ruby and JS.
	if (No == pi->options.empty_string && 1 == first && '\0' == *pi->cur) {
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "unexpected character");
	}

	switch (*pi->cur++) {
	case '{':
	    hash_start(pi);
	    break;
	case '}':
	    hash_end(pi);
	    break;
	case ':':
	    colon(pi);
	    break;
	case '[':
	    array_start(pi);
	    break;
	case ']':
	    array_end(pi);
	    break;
	case ',':
	    comma(pi);
	    break;
	case '"':
	    read_str(pi);
	    break;
	    //case '+':
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
	    pi->cur--;
	    read_num(pi);
	    break;
	case 'I':
	case 'N':
	    if (Yes == pi->options.allow_nan) {
		pi->cur--;
		read_num(pi);
	    } else {
		oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "unexpected character");
	    }
	    break;
	case 't':
	    read_true(pi);
	    break;
	case 'f':
	    read_false(pi);
	    break;
	case 'n':
	    if ('u' == *pi->cur) {
		read_null(pi);
	    } else {
		pi->cur--;
		read_num(pi);
	    }
	    break;
	case '/':
	    skip_comment(pi);
	    if (first) {
		continue;
	    }
	    break;
	case '\0':
	    pi->cur--;
	    return;
	default:
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "unexpected character");
	    return;
	}
	if (err_has(&pi->err)) {
	    return;
	}
	if (stack_empty(&pi->stack)) {
	    if (Qundef != pi->proc) {
		VALUE	args[3];
		long	len = (pi->cur - pi->json) - start;

		*args = stack_head_val(&pi->stack);
		args[1] = LONG2NUM(start);
		args[2] = LONG2NUM(len);

		if (Qnil == pi->proc) {
		    rb_yield_values2(3, args);
		} else {
#if HAS_PROC_WITH_BLOCK
		    rb_proc_call_with_block(pi->proc, 3, args, Qnil);
#else
		    rb_raise(rb_eNotImpError,
			     "Calling a Proc with a block not supported in this version. Use func() {|x| } syntax instead.");
#endif
		}
	    } else if (!pi->has_callbacks) {
		first = 0;
	    }
	    start = pi->cur - pi->json;
	}
    }
}

VALUE
oj_num_as_value(NumInfo ni) {
    volatile VALUE	rnum = Qnil;

    if (ni->infinity) {
	if (ni->neg) {
	    rnum = rb_float_new(-OJ_INFINITY);
	} else {
	    rnum = rb_float_new(OJ_INFINITY);
	}
    } else if (ni->nan) {
	rnum = rb_float_new(0.0/0.0);
    } else if (1 == ni->div && 0 == ni->exp) { // fixnum
	if (ni->big) {
	    if (256 > ni->len) {
		char	buf[256];

		memcpy(buf, ni->str, ni->len);
		buf[ni->len] = '\0';
		rnum = rb_cstr_to_inum(buf, 10, 0);
	    } else {
		char	*buf = ALLOC_N(char, ni->len + 1);

		memcpy(buf, ni->str, ni->len);
		buf[ni->len] = '\0';
		rnum = rb_cstr_to_inum(buf, 10, 0);
		xfree(buf);
	    }
	} else {
	    if (ni->neg) {
		rnum = rb_ll2inum(-ni->i);
	    } else {
		rnum = rb_ll2inum(ni->i);
	    }
	}
    } else { // decimal
	if (ni->big) {
	    rnum = rb_funcall(rb_cObject, oj_bigdecimal_id, 1, rb_str_new(ni->str, ni->len));
	    if (ni->no_big) {
		rnum = rb_funcall(rnum, rb_intern("to_f"), 0);
	    }
	} else {
	    // All these machinations are to get rounding to work better.
	    long double	d = (long double)ni->i * (long double)ni->div + (long double)ni->num;
	    int		x = (int)((int64_t)ni->exp - ni->di);

	    // Rounding sometimes cuts off the last digit even if there are only
	    // 15 digits. This attempts to fix those few cases where this
	    // occurs.
	    if ((long double)INT64_MAX > d && (int64_t)d != (ni->i * ni->div + ni->num)) {
		rnum = rb_funcall(rb_cObject, oj_bigdecimal_id, 1, rb_str_new(ni->str, ni->len));
		if (ni->no_big) {
		    rnum = rb_funcall(rnum, rb_intern("to_f"), 0);
		}
	    } else {
		d = roundl(d);
		if (0 < x) {
		    d *= powl(10.0L, x);
		} else if (0 > x) {
		    d /= powl(10.0L, -x);
		}
		if (ni->neg) {
		    d = -d;
		}
		rnum = rb_float_new((double)d);
	    }
	}
    }
    return rnum;
}

void
oj_set_error_at(ParseInfo pi, VALUE err_clas, const char* file, int line, const char *format, ...) {
    va_list	ap;
    char	msg[128];

    va_start(ap, format);
    vsnprintf(msg, sizeof(msg) - 1, format, ap);
    va_end(ap);
    pi->err.clas = err_clas;
    if (0 == pi->json) {
	oj_err_set(&pi->err, err_clas, "%s at line %d, column %d [%s:%d]", msg, pi->rd.line, pi->rd.col, file, line);
    } else {
	_oj_err_set_with_location(&pi->err, err_clas, msg, pi->json, pi->cur - 1, file, line);
    }
}

static VALUE
protect_parse(VALUE pip) {
    oj_parse2((ParseInfo)pip);

    return Qnil;
}

extern int oj_utf8_index;

static void
oj_pi_set_input_str(ParseInfo pi, volatile VALUE *inputp) {
#if HAS_ENCODING_SUPPORT
    rb_encoding	*enc = rb_to_encoding(rb_obj_encoding(*inputp));

    if (rb_utf8_encoding() != enc) {
	*inputp = rb_str_conv_enc(*inputp, enc, rb_utf8_encoding());
    }
#endif
    pi->json = rb_string_value_ptr((VALUE*)inputp);
    pi->end = pi->json + RSTRING_LEN(*inputp);
}

VALUE
oj_pi_parse(int argc, VALUE *argv, ParseInfo pi, char *json, size_t len, int yieldOk) {
    char		*buf = 0;
    volatile VALUE	input;
    volatile VALUE	wrapped_stack;
    volatile VALUE	result = Qnil;
    int			line = 0;
    int			free_json = 0;

    if (argc < 1) {
	rb_raise(rb_eArgError, "Wrong number of arguments to parse.");
    }
    input = argv[0];
    if (2 <= argc) {
	if (T_HASH == rb_type(argv[1])) {
	    oj_parse_options(argv[1], &pi->options);
	} else if (3 <= argc && T_HASH == rb_type(argv[2])) {
	    oj_parse_options(argv[2], &pi->options);
	}
    }
    if (yieldOk && rb_block_given_p()) {
	pi->proc = Qnil;
    } else {
	pi->proc = Qundef;
    }
    if (0 != json) {
	pi->json = json;
	pi->end = json + len;
	free_json = 1;
    } else if (T_STRING == rb_type(input)) {
	if (CompatMode == pi->options.mode) {
	    if (No == pi->options.nilnil && 0 == RSTRING_LEN(input)) {
		rb_raise(oj_json_parser_error_class, "An empty string is not a valid JSON string.");
	    }
	}
	oj_pi_set_input_str(pi, &input);
    } else if (Qnil == input) {
	if (Yes == pi->options.nilnil) {
	    return Qnil;
	} else {
	    rb_raise(rb_eTypeError, "Nil is not a valid JSON source.");
	}
    } else {
	VALUE		clas = rb_obj_class(input);
	volatile VALUE	s;

	if (oj_stringio_class == clas) {
	    s = rb_funcall2(input, oj_string_id, 0, 0);
	    oj_pi_set_input_str(pi, &s);
#if !IS_WINDOWS
	} else if (rb_cFile == clas && 0 == FIX2INT(rb_funcall(input, oj_pos_id, 0))) {
	    int		fd = FIX2INT(rb_funcall(input, oj_fileno_id, 0));
	    ssize_t	cnt;
	    size_t	len = lseek(fd, 0, SEEK_END);

	    lseek(fd, 0, SEEK_SET);
	    buf = ALLOC_N(char, len + 1);
	    pi->json = buf;
	    pi->end = buf + len;
	    if (0 >= (cnt = read(fd, (char*)pi->json, len)) || cnt != (ssize_t)len) {
		if (0 != buf) {
		    xfree(buf);
		}
		rb_raise(rb_eIOError, "failed to read from IO Object.");
	    }
	    ((char*)pi->json)[len] = '\0';
	    /* skip UTF-8 BOM if present */
	    if (0xEF == (uint8_t)*pi->json && 0xBB == (uint8_t)pi->json[1] && 0xBF == (uint8_t)pi->json[2]) {
		pi->cur += 3;
	    }
#endif
	} else if (rb_respond_to(input, oj_read_id)) {
	    // use stream parser instead
	    return oj_pi_sparse(argc, argv, pi, 0);
	} else {
	    rb_raise(rb_eArgError, "parse() expected a String or IO Object.");
}
    }
    if (Yes == pi->options.circular) {
	pi->circ_array = oj_circ_array_new();
    } else {
	pi->circ_array = 0;
    }
    if (No == pi->options.allow_gc) {
	rb_gc_disable();
    }
    // GC can run at any time. When it runs any Object created by C will be
    // freed. We protect against this by wrapping the value stack in a ruby
    // data object and poviding a mark function for ruby objects on the
    // value stack (while it is in scope).
    wrapped_stack = oj_stack_init(&pi->stack);
    rb_protect(protect_parse, (VALUE)pi, &line);
    if (Qundef == pi->stack.head->val && !empty_ok(&pi->options)) {
	if (No == pi->options.nilnil || (CompatMode == pi->options.mode && 0 < pi->cur - pi->json)) {
	    oj_set_error_at(pi, oj_json_parser_error_class, __FILE__, __LINE__, "Empty input");
	}
    }
    result = stack_head_val(&pi->stack);
    DATA_PTR(wrapped_stack) = 0;
    if (No == pi->options.allow_gc) {
	rb_gc_enable();
    }
    if (!err_has(&pi->err)) {
	// If the stack is not empty then the JSON terminated early.
	Val	v;

	if (0 != (v = stack_peek(&pi->stack))) {
	    switch (v->next) {
	    case NEXT_ARRAY_NEW:
	    case NEXT_ARRAY_ELEMENT:
	    case NEXT_ARRAY_COMMA:
		oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "Array not terminated");
		break;
	    case NEXT_HASH_NEW:
	    case NEXT_HASH_KEY:
	    case NEXT_HASH_COLON:
	    case NEXT_HASH_VALUE:
	    case NEXT_HASH_COMMA:
		oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "Hash/Object not terminated");
		break;
	    default:
		oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "not terminated");
	    }
	}
    }
    // proceed with cleanup
    if (0 != pi->circ_array) {
	oj_circ_array_free(pi->circ_array);
    }
    if (0 != buf) {
	xfree(buf);
    } else if (free_json) {
	xfree(json);
    }
    stack_cleanup(&pi->stack);
    if (pi->str_rx.head != oj_default_options.str_rx.head) {
	oj_rxclass_cleanup(&pi->str_rx);
    }
    if (0 != line) {
	rb_jump_tag(line);
    }
    if (err_has(&pi->err)) {
	if (Qnil != pi->err_class) {
	    pi->err.clas = pi->err_class;
	}
	if (CompatMode == pi->options.mode) {
	    // The json gem requires the error message be UTF-8 encoded. In
	    // additional the complete JSON source must be returned. There
	    // does not seem to be a size limit.
	    VALUE	msg = oj_encode(rb_str_new2(pi->err.msg));
	    VALUE	args[1];

	    if (NULL != pi->json) {
		msg = rb_str_append(msg, oj_encode(rb_str_new2(" in '")));
		msg = rb_str_append(msg, oj_encode(rb_str_new2(pi->json)));
	    }
	    args[0] = msg;
	    rb_exc_raise(rb_class_new_instance(1, args, pi->err.clas));
	} else {
	    oj_err_raise(&pi->err);
	}
    }
    if (pi->options.quirks_mode == No) {
	switch (rb_type(result)) {
	case T_NIL:
	case T_TRUE:
	case T_FALSE:
	case T_FIXNUM:
	case T_FLOAT:
	case T_CLASS:
	case T_STRING:
	case T_SYMBOL: {
	    struct _Err	err;

	    if (Qnil == pi->err_class) {
		err.clas = oj_parse_error_class;
	    } else {
		err.clas = pi->err_class;
	    }
	    snprintf(err.msg, sizeof(err.msg), "unexpected non-document value");
	    oj_err_raise(&err);
	    break;
	}
	default:
	    // okay
	    break;
	}
    }
    return result;
}

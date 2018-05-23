/* sparse.c
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
#include "hash.h" // for oj_strndup()
#include "val_stack.h"

// Workaround in case INFINITY is not defined in math.h or if the OS is CentOS
#define OJ_INFINITY	(1.0/0.0)

#ifdef RUBINIUS_RUBY
#define NUM_MAX		0x07FFFFFF
#else
#define NUM_MAX		(FIXNUM_MAX >> 8)
#endif
#define EXP_MAX		100000
#define DEC_MAX		15

static void
skip_comment(ParseInfo pi) {
    char	c = reader_get(&pi->rd);

    if ('*' == c) {
	while ('\0' != (c = reader_get(&pi->rd))) {
	    if ('*' == c) {
		c = reader_get(&pi->rd);
		if ('/' == c) {
		    return;
		}
	    }
	}
    } else if ('/' == c) {
	while ('\0' != (c = reader_get(&pi->rd))) {
	    switch (c) {
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
    if ('\0' == c) {
	oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "comment not terminated");
	return;
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
	    if (parent->kalloc) {
		xfree((char*)parent->key);
	    }
	    parent->key = 0;
	    parent->kalloc = 0;
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
add_num_value(ParseInfo pi, NumInfo ni) {
    Val	parent = stack_peek(&pi->stack);

    if (0 == parent) {
	pi->add_num(pi, ni);
    } else {
	switch (parent->next) {
	case NEXT_ARRAY_NEW:
	case NEXT_ARRAY_ELEMENT:
	    pi->array_append_num(pi, ni);
	    parent->next = NEXT_ARRAY_COMMA;
	    break;
	case NEXT_HASH_VALUE:
	    pi->hash_set_num(pi, parent, ni);
	    if (parent->kalloc) {
		xfree((char*)parent->key);
	    }
	    parent->key = 0;
	    parent->kalloc = 0;
	    parent->next = NEXT_HASH_COMMA;
	    break;
	default:
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "expected %s", oj_stack_next_string(parent->next));
	    break;
	}
    }
}

static void
read_true(ParseInfo pi) {
    if (0 == reader_expect(&pi->rd, "rue")) {
	add_value(pi, Qtrue);
    } else {
	oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "expected true");
    }
}

static void
read_false(ParseInfo pi) {
    if (0 == reader_expect(&pi->rd, "alse")) {
	add_value(pi, Qfalse);
    } else {
	oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "expected false");
    }
}

static uint32_t
read_hex(ParseInfo pi) {
    uint32_t	b = 0;
    int		i;
    char	c;

    for (i = 0; i < 4; i++) {
	c = reader_get(&pi->rd);
	b = b << 4;
	if ('0' <= c && c <= '9') {
	    b += c - '0';
	} else if ('A' <= c && c <= 'F') {
	    b += c - 'A' + 10;
	} else if ('a' <= c && c <= 'f') {
	    b += c - 'a' + 10;
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

// entered at backslash
static void
read_escaped_str(ParseInfo pi) {
    struct _Buf	buf;
    char	c;
    uint32_t	code;
    Val		parent = stack_peek(&pi->stack);

    buf_init(&buf);
    if (pi->rd.str < pi->rd.tail) {
	buf_append_string(&buf, pi->rd.str, pi->rd.tail - pi->rd.str);
    }
    while ('\"' != (c = reader_get(&pi->rd))) {
	if ('\0' == c) {
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "quoted string not terminated");
	    buf_cleanup(&buf);
	    return;
	} else if ('\\' == c) {
	    c = reader_get(&pi->rd);
	    switch (c) {
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
		    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "invalid escaped character");
		    buf_cleanup(&buf);
		    return;
		}
		break;
	    case 'u':
		if (0 == (code = read_hex(pi)) && err_has(&pi->err)) {
		    buf_cleanup(&buf);
		    return;
		}
		if (0x0000D800 <= code && code <= 0x0000DFFF) {
		    uint32_t	c1 = (code - 0x0000D800) & 0x000003FF;
		    uint32_t	c2;
		    char	ch2;

		    c = reader_get(&pi->rd);
		    ch2 = reader_get(&pi->rd);
		    if ('\\' != c || 'u' != ch2) {
			if (Yes == pi->options.allow_invalid) {
			    unicode_to_chars(pi, &buf, code);
			    reader_backup(&pi->rd);
			    reader_backup(&pi->rd);
			    break;
			}
			oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "invalid escaped character");
			buf_cleanup(&buf);
			return;
		    }
		    if (0 == (c2 = read_hex(pi)) && err_has(&pi->err)) {
			buf_cleanup(&buf);
			return;
		    }
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
		oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "invalid escaped character");
		buf_cleanup(&buf);
		return;
	    }
	} else {
	    buf_append(&buf, c);
	}
    }
    if (0 == parent) {
	pi->add_cstr(pi, buf.head, buf_len(&buf), pi->rd.str);
    } else {
	switch (parent->next) {
	case NEXT_ARRAY_NEW:
	case NEXT_ARRAY_ELEMENT:
	    pi->array_append_cstr(pi, buf.head, buf_len(&buf), pi->rd.str);
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
	    parent->k1 = *pi->rd.str;
	    parent->next = NEXT_HASH_COLON;
	    break;
	case NEXT_HASH_VALUE:
	    pi->hash_set_cstr(pi, parent, buf.head, buf_len(&buf), pi->rd.str);
	    if (parent->kalloc) {
		xfree((char*)parent->key);
	    }
	    parent->key = 0;
	    parent->kalloc = 0;
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
    buf_cleanup(&buf);
}

static void
read_str(ParseInfo pi) {
    Val		parent = stack_peek(&pi->stack);
    char	c;

    reader_protect(&pi->rd);
    while ('\"' != (c = reader_get(&pi->rd))) {
	if ('\0' == c) {
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "quoted string not terminated");
	    return;
	} else if ('\\' == c) {
	    reader_backup(&pi->rd);
	    read_escaped_str(pi);
	    reader_release(&pi->rd);
	    return;
	}
    }
    if (0 == parent) { // simple add
	pi->add_cstr(pi, pi->rd.str, pi->rd.tail - pi->rd.str - 1, pi->rd.str);
    } else {
	switch (parent->next) {
	case NEXT_ARRAY_NEW:
	case NEXT_ARRAY_ELEMENT:
	    pi->array_append_cstr(pi, pi->rd.str, pi->rd.tail - pi->rd.str - 1, pi->rd.str);
	    parent->next = NEXT_ARRAY_COMMA;
	    break;
	case NEXT_HASH_NEW:
	case NEXT_HASH_KEY:
	    parent->klen = pi->rd.tail - pi->rd.str - 1;
	    if (sizeof(parent->karray) <= parent->klen) {
		parent->key = oj_strndup(pi->rd.str, parent->klen);
		parent->kalloc = 1;
	    } else {
		memcpy(parent->karray, pi->rd.str, parent->klen);
		parent->karray[parent->klen] = '\0';
		parent->key = parent->karray;
		parent->kalloc = 0;
	    }
	    parent->key_val = pi->hash_key(pi, parent->key, parent->klen);
	    parent->k1 = *pi->rd.str;
	    parent->next = NEXT_HASH_COLON;
	    break;
	case NEXT_HASH_VALUE:
	    pi->hash_set_cstr(pi, parent, pi->rd.str, pi->rd.tail - pi->rd.str - 1, pi->rd.str);
	    if (parent->kalloc) {
		xfree((char*)parent->key);
	    }
	    parent->key = 0;
	    parent->kalloc = 0;
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
    reader_release(&pi->rd);
}

static void
read_num(ParseInfo pi) {
    struct _NumInfo	ni;
    char		c;

    reader_protect(&pi->rd);
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
    c = reader_get(&pi->rd);
    if ('-' == c) {
	c = reader_get(&pi->rd);
	ni.neg = 1;
    } else if ('+' == c) {
	c = reader_get(&pi->rd);
    }
    if ('I' == c) {
	if (No == pi->options.allow_nan) {
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "not a number or other value");
	    return;
	} else if (0 != reader_expect(&pi->rd, "nfinity")) {
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "not a number or other value");
	    return;
	}
	ni.infinity = 1;
    } else {
	int	dec_cnt = 0;
	bool	zero1 = false;

	for (; '0' <= c && c <= '9'; c = reader_get(&pi->rd)) {
	    if (0 == ni.i && '0' == c) {
		zero1 = true;
	    }
	    if (0 < ni.i) {
		dec_cnt++;
	    }
	    if (ni.big) {
		ni.big++;
	    } else {
		int	d = (c - '0');

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
	if ('.' == c) {
	    c = reader_get(&pi->rd);
	    if (c < '0' || '9' < c) {
		oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "not a number");
	    }
	    for (; '0' <= c && c <= '9'; c = reader_get(&pi->rd)) {
		int	d = (c - '0');

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
	if ('e' == c || 'E' == c) {
	    int	eneg = 0;

	    ni.hasExp = 1;
	    c = reader_get(&pi->rd);
	    if ('-' == c) {
		c = reader_get(&pi->rd);
		eneg = 1;
	    } else if ('+' == c) {
		c = reader_get(&pi->rd);
	    }
	    for (; '0' <= c && c <= '9'; c = reader_get(&pi->rd)) {
		ni.exp = ni.exp * 10 + (c - '0');
		if (EXP_MAX <= ni.exp) {
		    ni.big = 1;
		}
	    }
	    if (eneg) {
		ni.exp = -ni.exp;
	    }
	}
	ni.len = pi->rd.tail - pi->rd.str;
	if (0 != c) {
	    reader_backup(&pi->rd);
	}
    }
    ni.str = pi->rd.str;
    ni.len = pi->rd.tail - pi->rd.str;
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
    add_num_value(pi, &ni);
    reader_release(&pi->rd);
}

static void
read_nan(ParseInfo pi) {
    struct _NumInfo	ni;
    char		c;

    ni.str = pi->rd.str;
    ni.i = 0;
    ni.num = 0;
    ni.div = 1;
    ni.di = 0;
    ni.len = 0;
    ni.exp = 0;
    ni.big = 0;
    ni.infinity = 0;
    ni.nan = 1;
    ni.neg = 0;
    ni.no_big = (FloatDec == pi->options.bigdec_load);

    if ('a' != reader_get(&pi->rd) ||
	('N' != (c = reader_get(&pi->rd)) && 'n' != c)) {
	oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "not a number or other value");
	return;
    }
    if (BigDec == pi->options.bigdec_load) {
	ni.big = 1;
    }
    add_num_value(pi, &ni);
}

static void
array_start(ParseInfo pi) {
    VALUE	v = pi->start_array(pi);

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
oj_sparse2(ParseInfo pi) {
    int		first = 1;
    char	c;
    long	start = 0;

    err_init(&pi->err);
    while (1) {
	if (0 < pi->max_depth && pi->max_depth <= pi->stack.tail - pi->stack.head - 1) {
	    VALUE	err_clas = oj_get_json_err_class("NestingError");
	    
	    oj_set_error_at(pi, err_clas, __FILE__, __LINE__, "Too deeply nested.");
	    pi->err_class = err_clas;
	    return;
	}
	c = reader_next_non_white(&pi->rd);
	if (!first && '\0' != c) {
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "unexpected characters after the JSON document");
	}
	switch (c) {
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
	    reader_backup(&pi->rd);
	    read_num(pi);
	    break;
	case 'I':
	    if (Yes == pi->options.allow_nan) {
		reader_backup(&pi->rd);
		read_num(pi);
	    } else {
		oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "unexpected character");
		return;
	    }
	    break;
	case 'N':
	    if (Yes == pi->options.allow_nan) {
		read_nan(pi);
	    } else {
		oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "unexpected character");
		return;
	    }
	    break;
	case 't':
	    read_true(pi);
	    break;
	case 'f':
	    read_false(pi);
	    break;
	case 'n':
	    c = reader_get(&pi->rd);
	    if ('u' == c) {
		if (0 == reader_expect(&pi->rd, "ll")) {
		    add_value(pi, Qnil);
		} else {
		    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "expected null");
		    return;
		}
	    } else if ('a' == c) {
		struct _NumInfo	ni;

		c = reader_get(&pi->rd);
		if ('N' != c && 'n' != c) {
		    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "expected NaN");
		    return;
		}
		ni.str = pi->rd.str;
		ni.i = 0;
		ni.num = 0;
		ni.div = 1;
		ni.di = 0;
		ni.len = 0;
		ni.exp = 0;
		ni.big = 0;
		ni.infinity = 0;
		ni.nan = 1;
		ni.neg = 0;
		ni.no_big = (FloatDec == pi->options.bigdec_load);
		add_num_value(pi, &ni);
	    } else {
		oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "invalid token");
		return;
	    }
	    break;
	case '/':
	    skip_comment(pi);
	    break;
	case '\0':
	    return;
	default:
	    oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "unexpected character '%c' [0x%02x]", c, c);
	    return;
	}
	if (err_has(&pi->err)) {
	    return;
	}
	if (stack_empty(&pi->stack)) {
	    if (Qundef != pi->proc) {
		VALUE	args[3];
		long	len = pi->rd.pos - start;

		*args = stack_head_val(&pi->stack);
		args[1] = LONG2NUM(start);
		args[2] = LONG2NUM(len);

		if (Qnil == pi->proc) {
		    rb_yield_values2(3, args);
		} else {
#if HAS_PROC_WITH_BLOCK
		    rb_proc_call_with_block(pi->proc, 3, args, Qnil);
#else
		    oj_set_error_at(pi, rb_eNotImpError, __FILE__, __LINE__,
				    "Calling a Proc with a block not supported in this version. Use func() {|x| } syntax instead.");
		    return;
#endif
		}
	    } else if (!pi->has_callbacks) {
		first = 0;
	    }
	    start = pi->rd.pos;
	}
    }
}

static VALUE
protect_parse(VALUE pip) {
    oj_sparse2((ParseInfo)pip);

    return Qnil;
}

VALUE
oj_pi_sparse(int argc, VALUE *argv, ParseInfo pi, int fd) {
    volatile VALUE	input;
    volatile VALUE	wrapped_stack;
    VALUE		result = Qnil;
    int			line = 0;

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
    if (Qnil == input) {
	if (Yes == pi->options.nilnil) {
	    return Qnil;
	} else {
	    rb_raise(rb_eTypeError, "Nil is not a valid JSON source.");
	}
    } else if (CompatMode == pi->options.mode && T_STRING == rb_type(input) && No == pi->options.nilnil && 0 == RSTRING_LEN(input)) {
	rb_raise(oj_json_parser_error_class, "An empty string is not a valid JSON string.");
    }
    if (rb_block_given_p()) {
	pi->proc = Qnil;
    } else {
	pi->proc = Qundef;
    }
    oj_reader_init(&pi->rd, input, fd, CompatMode == pi->options.mode);
    pi->json = 0; // indicates reader is in use

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
    // data object and providing a mark function for ruby objects on the
    // value stack (while it is in scope).
    wrapped_stack = oj_stack_init(&pi->stack);
    rb_protect(protect_parse, (VALUE)pi, &line);
    if (Qundef == pi->stack.head->val && !empty_ok(&pi->options)) {
	oj_set_error_at(pi, oj_parse_error_class, __FILE__, __LINE__, "Empty input");
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
    stack_cleanup(&pi->stack);
    if (0 != fd) {
	close(fd);
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
	    // additional the complete JSON source should be returned but that
	    // is not possible without stored all the bytes read and reading
	    // the remaining bytes on the stream. Both seem like a very bad
	    // idea.
	    VALUE	args[] = { oj_encode(rb_str_new2(pi->err.msg)) };

	    rb_exc_raise(rb_class_new_instance(1, args, pi->err.clas));
	} else {
	    oj_err_raise(&pi->err);
	}

	oj_err_raise(&pi->err);
    }
    return result;
}

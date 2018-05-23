/* sax.c
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#include <ctype.h>
#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
#include <strings.h>
#include <sys/types.h>
#if NEEDS_UIO
#include <sys/uio.h>
#endif
#include <unistd.h>
#include <time.h>

#include "ruby.h"
#include "ox.h"
#include "sax.h"
#include "sax_stack.h"
#include "sax_buf.h"
#include "special.h"

#define NAME_MISMATCH	1

#define START_STATE	1
#define BODY_STATE	2
#define AFTER_STATE	3

// error prefixes
#define BAD_BOM		"Bad BOM: "
#define NO_TERM		"Not Terminated: "
#define INVALID_FORMAT	"Invalid Format: "
#define CASE_ERROR	"Case Error: "
#define OUT_OF_ORDER	"Out of Order: "
#define WRONG_CHAR	"Unexpected Character: "
#define EL_MISMATCH	"Start End Mismatch: "
#define INV_ELEMENT	"Invalid Element: "

#define UTF8_STR	"UTF-8"

static void		sax_drive_init(SaxDrive dr, VALUE handler, VALUE io, SaxOptions options);
static void		parse(SaxDrive dr);
// All read functions should return the next character after the 'thing' that was read and leave dr->cur one after that.
static char		read_instruction(SaxDrive dr);
static char		read_doctype(SaxDrive dr);
static char		read_cdata(SaxDrive dr);
static char		read_comment(SaxDrive dr);
static char		read_element_start(SaxDrive dr);
static char		read_element_end(SaxDrive dr);
static char		read_text(SaxDrive dr);
static char		read_jump(SaxDrive dr, const char *pat);
static char		read_attrs(SaxDrive dr, char c, char termc, char term2, int is_xml, int eq_req, Hint h);
static char		read_name_token(SaxDrive dr);
static char		read_quoted_value(SaxDrive dr);

static void		end_element_cb(SaxDrive dr, VALUE name, int pos, int line, int col, Hint h);

static void		hint_clear_empty(SaxDrive dr);
static Nv		hint_try_close(SaxDrive dr, const char *name);

VALUE	ox_sax_value_class = Qnil;

static VALUE protect_parse(VALUE drp) {
    parse((SaxDrive)drp);

    return Qnil;
}

#if HAS_ENCODING_SUPPORT || HAS_PRIVATE_ENCODING
static int
strIsAscii(const char *s) {
    for (; '\0' != *s; s++) {
	if (*s < ' ' || '~' < *s) {
	    return 0;
	}
    }
    return 1;
}
#endif

VALUE
str2sym(SaxDrive dr, const char *str, const char **strp) {
    VALUE	*slot;
    VALUE	sym;

    if (dr->options.symbolize) {
	if (Qundef == (sym = ox_cache_get(ox_symbol_cache, str, &slot, strp))) {
#if HAS_ENCODING_SUPPORT
	    if (0 != dr->encoding && !strIsAscii(str)) {
		VALUE	rstr = rb_str_new2(str);

		// TBD if sym can be pinned down then use this all the time
		rb_enc_associate(rstr, dr->encoding);
		sym = rb_funcall(rstr, ox_to_sym_id, 0);
		*slot = Qundef;
	    } else {
		sym = ID2SYM(rb_intern(str));
		*slot = sym;
	    }
#elif HAS_PRIVATE_ENCODING
	    if (Qnil != dr->encoding && !strIsAscii(str)) {
		VALUE	rstr = rb_str_new2(str);

		rb_funcall(rstr, ox_force_encoding_id, 1, dr->encoding);
		sym = rb_funcall(rstr, ox_to_sym_id, 0);
		// Needed for Ruby 2.2 to get around the GC of symbols created
		// with to_sym which is needed for encoded symbols.
		rb_ary_push(ox_sym_bank, sym);
		*slot = Qundef;
	    } else {
		sym = ID2SYM(rb_intern(str));
		*slot = sym;
	    }
#else
	    sym = ID2SYM(rb_intern(str));
	    *slot = sym;
#endif
	}
    } else {
	sym = rb_str_new2(str);
#if HAS_ENCODING_SUPPORT
	if (0 != dr->encoding) {
	    rb_enc_associate(sym, dr->encoding);
	}
#elif HAS_PRIVATE_ENCODING
	if (Qnil != dr->encoding) {
	    rb_funcall(sym, ox_force_encoding_id, 1, dr->encoding);
	}
#endif
	if (0 != strp) {
	    *strp = StringValuePtr(sym);
	}
    }
    return sym;
}

void
ox_sax_parse(VALUE handler, VALUE io, SaxOptions options) {
    struct _SaxDrive    dr;
    int			line = 0;

    sax_drive_init(&dr, handler, io, options);
#if 0
    printf("*** sax_parse with these flags\n");
    printf("    has_instruct = %s\n", dr.has.instruct ? "true" : "false");
    printf("    has_end_instruct = %s\n", dr.has.end_instruct ? "true" : "false");
    printf("    has_attr = %s\n", dr.has.attr ? "true" : "false");
    printf("    has_attr_value = %s\n", dr.has.attr_value ? "true" : "false");
    printf("    has_attrs_done = %s\n", dr.has.attrs_done ? "true" : "false");
    printf("    has_doctype = %s\n", dr.has.doctype ? "true" : "false");
    printf("    has_comment = %s\n", dr.has.comment ? "true" : "false");
    printf("    has_cdata = %s\n", dr.has.cdata ? "true" : "false");
    printf("    has_text = %s\n", dr.has.text ? "true" : "false");
    printf("    has_value = %s\n", dr.has.value ? "true" : "false");
    printf("    has_start_element = %s\n", dr.has.start_element ? "true" : "false");
    printf("    has_end_element = %s\n", dr.has.end_element ? "true" : "false");
    printf("    has_error = %s\n", dr.has.error ? "true" : "false");
    printf("    has_pos = %s\n", dr.has.pos ? "true" : "false");
    printf("    has_line = %s\n", dr.has.line ? "true" : "false");
    printf("    has_column = %s\n", dr.has.column ? "true" : "false");
#endif
    //parse(&dr);
    rb_protect(protect_parse, (VALUE)&dr, &line);
    ox_sax_drive_cleanup(&dr);
    if (0 != line) {
	rb_jump_tag(line);
    }
}

static void
sax_drive_init(SaxDrive dr, VALUE handler, VALUE io, SaxOptions options) {
    ox_sax_buf_init(&dr->buf, io);
    dr->buf.dr = dr;
    stack_init(&dr->stack);
    dr->handler = handler;
    dr->value_obj = Data_Wrap_Struct(ox_sax_value_class, 0, 0, dr);
    rb_gc_register_address(&dr->value_obj);
    dr->options = *options;
    dr->err = 0;
    dr->blocked = 0;
    dr->abort = false;
    has_init(&dr->has, handler);
#if HAS_ENCODING_SUPPORT
    if ('\0' == *ox_default_options.encoding) {
	VALUE	encoding;

	dr->encoding = 0;
	if (rb_respond_to(io, ox_external_encoding_id) && Qnil != (encoding = rb_funcall(io, ox_external_encoding_id, 0))) {
	    int	e = rb_enc_get_index(encoding);
	    if (0 <= e) {
		dr->encoding = rb_enc_from_index(e);
	    }
	}
    } else {
        dr->encoding = rb_enc_find(ox_default_options.encoding);
    }
#elif HAS_PRIVATE_ENCODING
    if ('\0' == *ox_default_options.encoding) {
	VALUE	encoding;

	if (rb_respond_to(io, ox_external_encoding_id) && Qnil != (encoding = rb_funcall(io, ox_external_encoding_id, 0))) {
	    dr->encoding = encoding;
	} else {
	    dr->encoding = Qnil;
	}
    } else {
        dr->encoding = rb_str_new2(ox_default_options.encoding);
    }
#else
    dr->encoding = 0;
#endif
}

void
ox_sax_drive_cleanup(SaxDrive dr) {
    rb_gc_unregister_address(&dr->value_obj);
    buf_cleanup(&dr->buf);
    stack_cleanup(&dr->stack);
}

static void
ox_sax_drive_error_at(SaxDrive dr, const char *msg, int pos, int line, int col) {
    if (dr->has.error) {
        VALUE   args[3];

        args[0] = rb_str_new2(msg);
        args[1] = LONG2NUM(line);
        args[2] = LONG2NUM(col);
	if (dr->has.pos) {
	    rb_ivar_set(dr->handler, ox_at_pos_id, LONG2NUM(pos));
	}
	if (dr->has.pos) {
	    rb_ivar_set(dr->handler, ox_at_pos_id, LONG2NUM(pos));
	}
	if (dr->has.line) {
	    rb_ivar_set(dr->handler, ox_at_line_id, args[1]);
	}
	if (dr->has.column) {
	    rb_ivar_set(dr->handler, ox_at_column_id, args[2]);
	}
        rb_funcall2(dr->handler, ox_error_id, 3, args);
    }
}

void
ox_sax_drive_error(SaxDrive dr, const char *msg) {
    ox_sax_drive_error_at(dr, msg, dr->buf.pos, dr->buf.line, dr->buf.col);
}

static char
skipBOM(SaxDrive dr) {
    char        c = buf_get(&dr->buf);

    if (0xEF == (uint8_t)c) { /* only UTF8 is supported */
	if (0xBB == (uint8_t)buf_get(&dr->buf) && 0xBF == (uint8_t)buf_get(&dr->buf)) {
#if HAS_ENCODING_SUPPORT
	    dr->encoding = ox_utf8_encoding;
#elif HAS_PRIVATE_ENCODING
	    dr->encoding = ox_utf8_encoding;
#else
	    dr->encoding = UTF8_STR;
#endif
	    c = buf_get(&dr->buf);
	} else {
	    ox_sax_drive_error(dr, BAD_BOM "invalid BOM or a binary file.");
	    c = '\0';
	}
    }
    return c;
}

static void
parse(SaxDrive dr) {
    char        c = skipBOM(dr);
    int		state = START_STATE;
    Nv		parent;

    while ('\0' != c) {
	buf_protect(&dr->buf);
	if ('<' == c) {
	    c = buf_get(&dr->buf);
	    switch (c) {
	    case '?': /* instructions (xml or otherwise) */
		c = read_instruction(dr);
		break;
	    case '!': /* comment or doctype */
		buf_protect(&dr->buf);
		c = buf_get(&dr->buf);
		if ('\0' == c) {
		    ox_sax_drive_error(dr, NO_TERM "DOCTYPE or comment not terminated");

		    goto DONE;
		} else if ('-' == c) {
		    c = buf_get(&dr->buf); /* skip first - and get next character */
		    if ('-' != c) {
			ox_sax_drive_error(dr, INVALID_FORMAT "bad comment format, expected <!--");
		    } else {
			c = buf_get(&dr->buf); /* skip second - */
		    }
		    c = read_comment(dr);
		} else {
		    int	i;
		    int	spaced = 0;
		    int	pos = dr->buf.pos + 1;
		    int	line = dr->buf.line;
		    int	col = dr->buf.col + 1;

		    if (is_white(c)) {
			spaced = 1;
			c = buf_next_non_white(&dr->buf);
		    }
		    dr->buf.str = dr->buf.tail - 1;
		    for (i = 7; 0 < i; i--) {
			c = buf_get(&dr->buf);
		    }
		    if (0 == strncmp("DOCTYPE", dr->buf.str, 7)) {
			if (spaced) {
			    ox_sax_drive_error_at(dr, WRONG_CHAR "<!DOCTYPE can not included spaces", pos, line, col);
			}
			if (START_STATE != state) {
			    ox_sax_drive_error(dr, OUT_OF_ORDER "DOCTYPE can not come after an element");
			}
			c = read_doctype(dr);
		    } else if (0 == strncasecmp("DOCTYPE", dr->buf.str, 7)) {
			if (!dr->options.smart) {
			    ox_sax_drive_error(dr, CASE_ERROR "expected DOCTYPE all in caps");
			}
			if (START_STATE != state) {
			    ox_sax_drive_error(dr, OUT_OF_ORDER "DOCTYPE can not come after an element");
			}
			c = read_doctype(dr);
		    } else if (0 == strncmp("[CDATA[", dr->buf.str, 7)) {
			if (spaced) {
			    ox_sax_drive_error_at(dr, WRONG_CHAR "<![CDATA[ can not included spaces", pos, line, col);
			}
			c = read_cdata(dr);
		    } else if (0 == strncasecmp("[CDATA[", dr->buf.str, 7)) {
			if (!dr->options.smart) {
			    ox_sax_drive_error(dr, CASE_ERROR "expected CDATA all in caps");
			}
			c = read_cdata(dr);
		    } else {
			Nv	parent = stack_peek(&dr->stack);

			if (0 != parent) {
			    parent->childCnt++;
			}
			ox_sax_drive_error_at(dr, WRONG_CHAR "DOCTYPE, CDATA, or comment expected", pos, line, col);
			c = read_name_token(dr);
			if ('>' == c) {
			    c = buf_get(&dr->buf);
			}
		    }
		}
		break;
	    case '/': /* element end */
		parent = stack_peek(&dr->stack);
		if (0 != parent && 0 == parent->childCnt && dr->has.text && !dr->blocked) {
		    VALUE	args[1];
		    int		pos = dr->buf.pos;
		    int		line = dr->buf.line;
		    int		col = dr->buf.col - 1;

		    args[0] = rb_str_new2("");
#if HAS_ENCODING_SUPPORT
		    if (0 != dr->encoding) {
			rb_enc_associate(args[0], dr->encoding);
		    }
#elif HAS_PRIVATE_ENCODING
		    if (Qnil != dr->encoding) {
			rb_funcall(args[0], ox_force_encoding_id, 1, dr->encoding);
		    }
#endif
		    if (dr->has.pos) {
			rb_ivar_set(dr->handler, ox_at_pos_id, LONG2NUM(pos));
		    }
		    if (dr->has.line) {
			rb_ivar_set(dr->handler, ox_at_line_id, LONG2NUM(line));
		    }
		    if (dr->has.column) {
			rb_ivar_set(dr->handler, ox_at_column_id, LONG2NUM(col));
		    }
		    rb_funcall2(dr->handler, ox_text_id, 1, args);
		}
		c = read_element_end(dr);
		if (0 == stack_peek(&dr->stack)) {
		    state = AFTER_STATE;
		}
		break;
	    case '\0':
		goto DONE;
	    default:
		buf_backup(&dr->buf);
		if (AFTER_STATE == state) {
		    ox_sax_drive_error(dr, OUT_OF_ORDER "multiple top level elements");
		}
		state = BODY_STATE;
		c = read_element_start(dr);
		if (0 == stack_peek(&dr->stack)) {
		    state = AFTER_STATE;
		}
		break;
	    }
	} else {
	    buf_reset(&dr->buf);
	    c = read_text(dr);
	}
    }
 DONE:
    if (dr->abort) {
	return;
    }
    if (dr->stack.head < dr->stack.tail) {
	char	msg[256];
	Nv	sp;

	if (dr->has.pos) {
	    rb_ivar_set(dr->handler, ox_at_pos_id, LONG2NUM(dr->buf.pos));
	}
	if (dr->has.line) {
	    rb_ivar_set(dr->handler, ox_at_line_id, LONG2NUM(dr->buf.line));
	}
	if (dr->has.column) {
	    rb_ivar_set(dr->handler, ox_at_column_id, LONG2NUM(dr->buf.col));
	}
	for (sp = dr->stack.tail - 1; dr->stack.head <= sp; sp--) {
	    snprintf(msg, sizeof(msg) - 1, "%selement '%s' not closed", EL_MISMATCH, sp->name);
	    ox_sax_drive_error_at(dr, msg, dr->buf.pos, dr->buf.line, dr->buf.col);
	    if (dr->has.end_element && 0 >= dr->blocked &&
		(NULL == sp->hint || ActiveOverlay == sp->hint->overlay || NestOverlay == sp->hint->overlay)) {
		VALUE       args[1];

		args[0] = sp->val;
		rb_funcall2(dr->handler, ox_end_element_id, 1, args);
	    }
	    if (dr->blocked && NULL != sp->hint && BlockOverlay == sp->hint->overlay) {
		dr->blocked--;
	    }
        }
    }
}

static void
read_content(SaxDrive dr, char *content, size_t len) {
    char	c;
    char	*end = content + len;

    while ('\0' != (c = buf_get(&dr->buf))) {
	if (end <= content) {
	    *content = '\0';
	    ox_sax_drive_error(dr, "processing instruction content too large");
	    return;
	}
	if ('?' == c) {
	    if ('\0' == (c = buf_get(&dr->buf))) {
		ox_sax_drive_error(dr, NO_TERM "document not terminated");
	    }
	    if ('>' == c) {
		*content = '\0';
		return;
	    } else {
		*content++ = c;
	    }
	} else {
	    *content++ = c;
	}
    }
    *content = '\0';
}

/* Entered after the "<?" sequence. Ready to read the rest.
 */
static char
read_instruction(SaxDrive dr) {
    char	content[4096];
    char        c;
    int		coff;
    VALUE	target = Qnil;
    int		is_xml;
    int		pos = dr->buf.pos - 1;
    int		line = dr->buf.line;
    int		col = dr->buf.col - 1;

    buf_protect(&dr->buf);
    if ('\0' == (c = read_name_token(dr))) {
        return c;
    }
    is_xml = (0 == (dr->options.smart ? strcasecmp("xml", dr->buf.str) : strcmp("xml", dr->buf.str)));
    if (dr->has.instruct || dr->has.end_instruct) {
	target = rb_str_new2(dr->buf.str);
    }
    if (dr->has.instruct) {
        VALUE       args[1];

	if (dr->has.pos) {
	    rb_ivar_set(dr->handler, ox_at_pos_id, LONG2NUM(pos));
	}
	if (dr->has.line) {
	    rb_ivar_set(dr->handler, ox_at_line_id, LONG2NUM(line));
	}
	if (dr->has.column) {
	    rb_ivar_set(dr->handler, ox_at_column_id, LONG2NUM(col));
	}
        args[0] = target;
        rb_funcall2(dr->handler, ox_instruct_id, 1, args);
    }
    buf_protect(&dr->buf);
    pos = dr->buf.pos;
    line = dr->buf.line;
    col = dr->buf.col;
    read_content(dr, content, sizeof(content) - 1);
    coff = dr->buf.tail - dr->buf.head;
    buf_reset(&dr->buf);
    dr->err = 0;
    c = read_attrs(dr, c, '?', '?', is_xml, 1, NULL);
    if (dr->has.attrs_done) {
	rb_funcall(dr->handler, ox_attrs_done_id, 0);
    }
    if (dr->err) {
	if (dr->has.text) {
	    VALUE   args[1];

	    if (dr->options.convert_special) {
		ox_sax_collapse_special(dr, content, pos, line, col);
	    }
	    args[0] = rb_str_new2(content);
#if HAS_ENCODING_SUPPORT
	    if (0 != dr->encoding) {
		rb_enc_associate(args[0], dr->encoding);
	    }
#elif HAS_PRIVATE_ENCODING
	    if (Qnil != dr->encoding) {
		rb_funcall(args[0], ox_force_encoding_id, 1, dr->encoding);
	    }
#endif
	    if (dr->has.line) {
		rb_ivar_set(dr->handler, ox_at_line_id, LONG2NUM(line));
	    }
	    if (dr->has.pos) {
		rb_ivar_set(dr->handler, ox_at_pos_id, LONG2NUM(pos));
	    }
	    if (dr->has.column) {
		rb_ivar_set(dr->handler, ox_at_column_id, LONG2NUM(col));
	    }
	    rb_funcall2(dr->handler, ox_text_id, 1, args);
	}
	dr->buf.tail = dr->buf.head + coff;
	c = buf_get(&dr->buf);
    } else {
	pos = dr->buf.pos;
	line = dr->buf.line;
	col = dr->buf.col;
	c = buf_next_non_white(&dr->buf);
	if ('>' == c) {
	    c = buf_get(&dr->buf);
	} else {
	    ox_sax_drive_error_at(dr, NO_TERM "instruction not terminated", pos, line, col);
	    if ('>' == c) {
		c = buf_get(&dr->buf);
	    }
	}
    }
    if (dr->has.end_instruct) {
        VALUE       args[1];

	if (dr->has.pos) {
	    rb_ivar_set(dr->handler, ox_at_pos_id, LONG2NUM(pos));
	}
	if (dr->has.line) {
	    rb_ivar_set(dr->handler, ox_at_line_id, LONG2NUM(line));
	}
	if (dr->has.column) {
	    rb_ivar_set(dr->handler, ox_at_column_id, LONG2NUM(col));
	}
        args[0] = target;
        rb_funcall2(dr->handler, ox_end_instruct_id, 1, args);
    }
    dr->buf.str = 0;

    return c;
}

static char
read_delimited(SaxDrive dr, char end) {
    char	c;

    if ('"' == end || '\'' == end) {
	while (end != (c = buf_get(&dr->buf))) {
	    if ('\0' == c) {
		ox_sax_drive_error(dr, NO_TERM "doctype not terminated");
		return c;
	    }
	}
    } else {
	while (1) {
	    c = buf_get(&dr->buf);
	    if (end == c) {
		return c;
	    }
	    switch (c) {
	    case '\0':
		ox_sax_drive_error(dr, NO_TERM "doctype not terminated");
		return c;
	    case '"':
		c = read_delimited(dr, c);
		break;
	    case '\'':
		c = read_delimited(dr, c);
		break;
	    case '[':
		c = read_delimited(dr, ']');
		break;
	    case '<':
		c = read_delimited(dr, '>');
		break;
	    default:
		break;
	    }
	}
    }
    return c;
}

/* Entered after the "<!DOCTYPE " sequence. Ready to read the rest.
 */
static char
read_doctype(SaxDrive dr) {
    int		pos = dr->buf.pos - 9;
    int		line = dr->buf.line;
    int		col = dr->buf.col - 9;
    char	*s;
    Nv		parent = stack_peek(&dr->stack);

    buf_backup(&dr->buf); /* back up to the start in case the doctype is empty */
    buf_protect(&dr->buf);
    read_delimited(dr, '>');
    if (dr->options.smart && 0 == dr->options.hints) {
	for (s = dr->buf.str; is_white(*s); s++) { }
	if (0 == strncasecmp("HTML", s, 4)) {
	    dr->options.hints = ox_hints_html();
	}
    }
    *(dr->buf.tail - 1) = '\0';
    if (0 != parent) {
	parent->childCnt++;
    }
    if (dr->has.doctype) {
        VALUE       args[1];

	if (dr->has.pos) {
	    rb_ivar_set(dr->handler, ox_at_pos_id, LONG2NUM(pos));
	}
	if (dr->has.line) {
	    rb_ivar_set(dr->handler, ox_at_line_id, LONG2NUM(line));
	}
	if (dr->has.column) {
	    rb_ivar_set(dr->handler, ox_at_column_id, LONG2NUM(col));
	}
        args[0] = rb_str_new2(dr->buf.str);
        rb_funcall2(dr->handler, ox_doctype_id, 1, args);
    }
    dr->buf.str = 0;

    return buf_get(&dr->buf);
}

/* Entered after the "<![CDATA[" sequence. Ready to read the rest.
 */
static char
read_cdata(SaxDrive dr) {
    char        	c;
    char        	zero = '\0';
    int         	end = 0;
    int			pos = dr->buf.pos - 9;
    int			line = dr->buf.line;
    int			col = dr->buf.col - 9;
    struct _CheckPt	cp = CHECK_PT_INIT;
    Nv			parent = stack_peek(&dr->stack);

    // TBD check parent overlay
    if (0 != parent) {
	parent->childCnt++;
    }
    buf_backup(&dr->buf); /* back up to the start in case the cdata is empty */
    buf_protect(&dr->buf);
    while (1) {
        c = buf_get(&dr->buf);
	switch (c) {
	case ']':
            end++;
	    break;
	case '>':
            if (2 <= end) {
                *(dr->buf.tail - 3) = '\0';
		c = buf_get(&dr->buf);
                goto CB;
            }
	    if (!buf_checkset(&cp)) {
		buf_checkpoint(&dr->buf, &cp);
	    }
            end = 0;
	    break;
	case '<':
	    if (!buf_checkset(&cp)) {
		buf_checkpoint(&dr->buf, &cp);
	    }
	    end = 0;
	    break;
	case '\0':
	    if (buf_checkset(&cp)) {
		c = buf_checkback(&dr->buf, &cp);
		ox_sax_drive_error(dr, NO_TERM "CDATA not terminated");
		zero = c;
		*(dr->buf.tail - 1) = '\0';
		goto CB;
	    }
            ox_sax_drive_error(dr, NO_TERM "CDATA not terminated");
            return '\0';
	default:
	    if (1 < end && !buf_checkset(&cp)) {
		buf_checkpoint(&dr->buf, &cp);
	    }
	    end = 0;
	    break;
	}
    }
 CB:
    if (!dr->blocked && (NULL == parent || NULL == parent->hint || OffOverlay != parent->hint->overlay)) {
	if (dr->has.cdata) {
	    VALUE       args[1];

	    args[0] = rb_str_new2(dr->buf.str);
#if HAS_ENCODING_SUPPORT
	    if (0 != dr->encoding) {
		rb_enc_associate(args[0], dr->encoding);
	    }
#elif HAS_PRIVATE_ENCODING
	    if (Qnil != dr->encoding) {
		rb_funcall(args[0], ox_force_encoding_id, 1, dr->encoding);
	    }
#endif
	    if (dr->has.pos) {
		rb_ivar_set(dr->handler, ox_at_pos_id, LONG2NUM(pos));
	    }
	    if (dr->has.line) {
		rb_ivar_set(dr->handler, ox_at_line_id, LONG2NUM(line));
	    }
	    if (dr->has.column) {
		rb_ivar_set(dr->handler, ox_at_column_id, LONG2NUM(col));
	    }
	    rb_funcall2(dr->handler, ox_cdata_id, 1, args);
	}
    }
    if ('\0' != zero) {
	*(dr->buf.tail - 1) = zero;
    }
    dr->buf.str = 0;

    return c;
}

/* Entered after the "<!--" sequence. Ready to read the rest.
 */
static char
read_comment(SaxDrive dr) {
    char        	c;
    char        	zero = '\0';
    int         	end = 0;
    int			pos = dr->buf.pos - 4;
    int			line = dr->buf.line;
    int			col = dr->buf.col - 4;
    struct _CheckPt	cp = CHECK_PT_INIT;

    buf_backup(&dr->buf); /* back up to the start in case the cdata is empty */
    buf_protect(&dr->buf);
    while (1) {
        c = buf_get(&dr->buf);
	switch (c) {
	case '-':
            end++;
	    break;
	case '>':
            if (2 <= end) {
                *(dr->buf.tail - 3) = '\0';
		c = buf_get(&dr->buf);
                goto CB;
            }
	    if (!buf_checkset(&cp)) {
		buf_checkpoint(&dr->buf, &cp);
	    }
            end = 0;
	    break;
	case '<':
	    if (!buf_checkset(&cp)) {
		buf_checkpoint(&dr->buf, &cp);
	    }
	    end = 0;
	    break;
	case '\0':
	    if (buf_checkset(&cp)) {
		c = buf_checkback(&dr->buf, &cp);
		ox_sax_drive_error(dr, NO_TERM "comment not terminated");
		zero = c;
		*(dr->buf.tail - 1) = '\0';
		goto CB;
	    }
            ox_sax_drive_error(dr, NO_TERM "comment not terminated");
            return '\0';
	default:
	    if (1 < end && !buf_checkset(&cp)) {
		buf_checkpoint(&dr->buf, &cp);
	    }
	    end = 0;
	    break;
	}
    }
 CB:
    if (dr->has.comment && !dr->blocked) {
        VALUE	args[1];
	Nv	parent = stack_peek(&dr->stack);
	Hint	h = ox_hint_find(dr->options.hints, "!--");
	
	if (NULL == parent || NULL == parent->hint || OffOverlay != parent->hint->overlay ||
	    (NULL != h && (ActiveOverlay == h->overlay || ActiveOverlay == h->overlay))) {

	    args[0] = rb_str_new2(dr->buf.str);
#if HAS_ENCODING_SUPPORT
	    if (0 != dr->encoding) {
		rb_enc_associate(args[0], dr->encoding);
	    }
#elif HAS_PRIVATE_ENCODING
	    if (Qnil != dr->encoding) {
		rb_funcall(args[0], ox_force_encoding_id, 1, dr->encoding);
	    }
#endif
	    if (dr->has.pos) {
		rb_ivar_set(dr->handler, ox_at_pos_id, LONG2NUM(pos));
	    }
	    if (dr->has.line) {
		rb_ivar_set(dr->handler, ox_at_line_id, LONG2NUM(line));
	    }
	    if (dr->has.column) {
		rb_ivar_set(dr->handler, ox_at_column_id, LONG2NUM(col));
	    }
	    rb_funcall2(dr->handler, ox_comment_id, 1, args);
	}
    }
    if ('\0' != zero) {
	*(dr->buf.tail - 1) = zero;
    }
    dr->buf.str = 0;

    return c;
}

/* Entered after the '<' and the first character after that. Returns status
 * code.
 */
static char
read_element_start(SaxDrive dr) {
    const char		*ename = 0;
    volatile VALUE	name = Qnil;
    char        	c;
    int			closed;
    int			pos = dr->buf.pos;
    int			line = dr->buf.line;
    int			col = dr->buf.col;
    Hint		h = NULL;
    int			stackless = 0;
    Nv			parent = stack_peek(&dr->stack);

    if ('\0' == (c = read_name_token(dr))) {
        return '\0';
    }
    if ('\0' == *dr->buf.str) {
	char	msg[256];

	snprintf(msg, sizeof(msg) - 1, "%sempty element", INVALID_FORMAT);
	ox_sax_drive_error_at(dr, msg, pos, line, col);

	return buf_get(&dr->buf);
    }
    if (0 != parent) {
	parent->childCnt++;
    }
    if (dr->options.smart && 0 == dr->options.hints && stack_empty(&dr->stack) && 0 == strcasecmp("html", dr->buf.str)) {
	dr->options.hints = ox_hints_html();
    }
    if (NULL != dr->options.hints) {
	hint_clear_empty(dr);
	h = ox_hint_find(dr->options.hints, dr->buf.str);
	if (NULL == h) {
	    char	msg[256];

	    snprintf(msg, sizeof(msg), "%s%s is not a valid element type for a %s document type.", INV_ELEMENT, dr->buf.str, dr->options.hints->name);
	    ox_sax_drive_error(dr, msg);
	} else {
	    Nv	top_nv = stack_peek(&dr->stack);

	    if (AbortOverlay == h->overlay) {
		if (rb_respond_to(dr->handler, ox_abort_id)) {
		    VALUE	args[1];

		    args[0] = str2sym(dr, dr->buf.str, NULL);
		    rb_funcall2(dr->handler, ox_abort_id, 1, args);
		}
		dr->abort = true;
		return '\0';
	    }
	    if (BlockOverlay == h->overlay) {
		dr->blocked++;
	    }
	    if (h->empty) {
		stackless = 1;
	    }
	    if (0 != top_nv) {
		char	msg[256];

		if (!h->nest && NestOverlay != h->overlay && 0 == strcasecmp(top_nv->name, h->name)) {
		    snprintf(msg, sizeof(msg) - 1, "%s%s can not be nested in a %s document, closing previous.",
			     INV_ELEMENT, dr->buf.str, dr->options.hints->name);
		    ox_sax_drive_error(dr, msg);
		    stack_pop(&dr->stack);
		    end_element_cb(dr, top_nv->val, pos, line, col, top_nv->hint);
		    top_nv = stack_peek(&dr->stack);
		}
		if (NULL != top_nv && 0 != h->parents && NestOverlay != h->overlay) {
		    const char	**p;
		    int		ok = 0;

		    for (p = h->parents; 0 != *p; p++) {
			if (0 == strcasecmp(*p, top_nv->name)) {
			    ok = 1;
			    break;
			}
		    }
		    if (!ok) {
			snprintf(msg, sizeof(msg) - 1, "%s%s can not be a child of a %s in a %s document.",
				 INV_ELEMENT, h->name, top_nv->name, dr->options.hints->name);
			ox_sax_drive_error(dr, msg);
		    }
		}
	    }
	}
    }
    name = str2sym(dr, dr->buf.str, &ename);
    if (dr->has.start_element && 0 >= dr->blocked && (NULL == h || ActiveOverlay == h->overlay || NestOverlay == h->overlay)) {
        VALUE       args[1];

	if (dr->has.pos) {
	    rb_ivar_set(dr->handler, ox_at_pos_id, LONG2NUM(pos));
	}
	if (dr->has.line) {
	    rb_ivar_set(dr->handler, ox_at_line_id, LONG2NUM(line));
	}
	if (dr->has.column) {
	    rb_ivar_set(dr->handler, ox_at_column_id, LONG2NUM(col));
	}
        args[0] = name;
        rb_funcall2(dr->handler, ox_start_element_id, 1, args);
    }
    if ('/' == c) {
        closed = 1;
    } else if ('>' == c) {
        closed = 0;
    } else {
	buf_protect(&dr->buf);
        c = read_attrs(dr, c, '/', '>', 0, 0, h);
	if (is_white(c)) {
	    c = buf_next_non_white(&dr->buf);
	}
	closed = ('/' == c);
    }
    if (dr->has.attrs_done && 0 >= dr->blocked && (NULL == h || ActiveOverlay == h->overlay || NestOverlay == h->overlay)) {
	rb_funcall(dr->handler, ox_attrs_done_id, 0);
    }
    if (closed) {
	c = buf_next_non_white(&dr->buf);
	pos = dr->buf.pos;
	line = dr->buf.line;
	col = dr->buf.col;
	end_element_cb(dr, name, pos, line, col, h);
    } else if (stackless) {
	end_element_cb(dr, name, pos, line, col, h);
    } else if (NULL != h && h->jump) {
	stack_push(&dr->stack, ename, name, h);
	if ('>' != c) {
	    ox_sax_drive_error(dr, WRONG_CHAR "element not closed");
	    return c;
	}
	read_jump(dr, h->name);
	return '<';
    } else {
	stack_push(&dr->stack, ename, name, h);
    }
    if ('>' != c) {
	ox_sax_drive_error(dr, WRONG_CHAR "element not closed");
	return c;
    }
    dr->buf.str = 0;

    return buf_get(&dr->buf);
}

static Nv
stack_rev_find(SaxDrive dr, const char *name) {
    Nv	nv;

    for (nv = dr->stack.tail - 1; dr->stack.head <= nv; nv--) {
	if (0 == (dr->options.smart ? strcasecmp(name, nv->name) : strcmp(name, nv->name))) {
	    return nv;
	}
    }
    return 0;
}

static char
read_element_end(SaxDrive dr) {
    VALUE       name = Qnil;
    char        c;
    int		pos = dr->buf.pos - 1;
    int		line = dr->buf.line;
    int		col = dr->buf.col - 1;
    Nv		nv;
    Hint	h = NULL;
    
    if ('\0' == (c = read_name_token(dr))) {
        return '\0';
    }
    if (is_white(c)) {
	c = buf_next_non_white(&dr->buf);
    }
    // c should be > and current is one past so read another char
    c = buf_get(&dr->buf);
    nv = stack_peek(&dr->stack);
    if (0 != nv &&
	0 == (dr->options.smart ? strcasecmp(dr->buf.str, nv->name) : strcmp(dr->buf.str, nv->name))) {
	name = nv->val;
	h = nv->hint;
	stack_pop(&dr->stack);
    } else {
	// Mismatched start and end
	char	msg[256];
	Nv	match = stack_rev_find(dr, dr->buf.str);

	if (0 == match) {
	    // Not found so open and close element.
	    h = ox_hint_find(dr->options.hints, dr->buf.str);
	    if (NULL != h && h->empty) {
		// Just close normally
		name = str2sym(dr, dr->buf.str, 0);
		snprintf(msg, sizeof(msg) - 1, "%selement '%s' should not have a separate close element", EL_MISMATCH, dr->buf.str);
		ox_sax_drive_error_at(dr, msg, pos, line, col);
		return c;
	    } else {
		snprintf(msg, sizeof(msg) - 1, "%selement '%s' closed but not opened", EL_MISMATCH, dr->buf.str);
		ox_sax_drive_error_at(dr, msg, pos, line, col);
		name = str2sym(dr, dr->buf.str, 0);
		if (dr->has.start_element && 0 >= dr->blocked && (NULL == h || ActiveOverlay == h->overlay || NestOverlay == h->overlay)) {
		    VALUE       args[1];

		    if (dr->has.pos) {
			rb_ivar_set(dr->handler, ox_at_pos_id, LONG2NUM(pos));
		    }
		    if (dr->has.line) {
			rb_ivar_set(dr->handler, ox_at_line_id, LONG2NUM(line));
		    }
		    if (dr->has.column) {
			rb_ivar_set(dr->handler, ox_at_column_id, LONG2NUM(col));
		    }
		    args[0] = name;
		    rb_funcall2(dr->handler, ox_start_element_id, 1, args);
		}
		if (NULL != h && BlockOverlay == h->overlay && 0 < dr->blocked) {
		    dr->blocked--;
		}
	    }
	} else {
	    // Found a match so close all up to the found element in stack.
	    Nv	n2;

	    if (0 != (n2 = hint_try_close(dr, dr->buf.str))) {
		name = n2->val;
		h = n2->hint;
	    } else {
		snprintf(msg, sizeof(msg) - 1, "%selement '%s' close does not match '%s' open", EL_MISMATCH, dr->buf.str, nv->name);
		ox_sax_drive_error_at(dr, msg, pos, line, col);
		if (dr->has.pos) {
		    rb_ivar_set(dr->handler, ox_at_pos_id, LONG2NUM(pos));
		}
		if (dr->has.line) {
		    rb_ivar_set(dr->handler, ox_at_line_id, LONG2NUM(line));
		}
		if (dr->has.column) {
		    rb_ivar_set(dr->handler, ox_at_column_id, LONG2NUM(col));
		}
		for (nv = stack_pop(&dr->stack); match < nv; nv = stack_pop(&dr->stack)) {
		    if (dr->has.end_element && 0 >= dr->blocked && (NULL == nv->hint || ActiveOverlay == nv->hint->overlay || NestOverlay == nv->hint->overlay)) {
			rb_funcall(dr->handler, ox_end_element_id, 1, nv->val);
		    }
		    if (NULL != nv->hint && BlockOverlay == nv->hint->overlay && 0 < dr->blocked) {
			dr->blocked--;
		    }
		}
		name = nv->val;
		h = nv->hint;
	    }
	}
    }
    end_element_cb(dr, name, pos, line, col, h);

    return c;
}

static char
read_text(SaxDrive dr) {
    VALUE	args[1];
    char        c;
    int		pos = dr->buf.pos;
    int		line = dr->buf.line;
    int		col = dr->buf.col - 1;
    Nv		parent = stack_peek(&dr->stack);
    int		allWhite = 1;

    buf_backup(&dr->buf);
    buf_protect(&dr->buf);
    while ('<' != (c = buf_get(&dr->buf))) {
	switch(c) {
	case ' ':
	case '\t':
	case '\f':
	case '\n':
	case '\r':
	    break;
	case '\0':
	    if (allWhite) {
		return c;
	    }
            ox_sax_drive_error(dr, NO_TERM "text not terminated");
	    goto END_OF_BUF;
	    break;
	default:
	    allWhite = 0;
	    break;
	}
    }
 END_OF_BUF:
    if ('\0' != c) {
	*(dr->buf.tail - 1) = '\0';
    }
    if (allWhite) {
	int	isEnd = ('/' == buf_get(&dr->buf));

	buf_backup(&dr->buf);
	if (dr->has.text &&
	    ((NoSkip == dr->options.skip && !isEnd) ||
	     (OffSkip == dr->options.skip))) {
	    args[0] = rb_str_new2(dr->buf.str);
#if HAS_ENCODING_SUPPORT
	    if (0 != dr->encoding) {
		rb_enc_associate(args[0], dr->encoding);
	    }
#elif HAS_PRIVATE_ENCODING
	    if (Qnil != dr->encoding) {
		rb_funcall(args[0], ox_force_encoding_id, 1, dr->encoding);
	    }
#endif
	    if (dr->has.pos) {
		rb_ivar_set(dr->handler, ox_at_pos_id, LONG2NUM(pos));
	    }
	    if (dr->has.line) {
		rb_ivar_set(dr->handler, ox_at_line_id, LONG2NUM(line));
	    }
	    if (dr->has.column) {
		rb_ivar_set(dr->handler, ox_at_column_id, LONG2NUM(col));
	    }
	    rb_funcall2(dr->handler, ox_text_id, 1, args);
	}
	if (!isEnd || 0 == parent || 0 < parent->childCnt) {
	    return c;
	}
    }
    if (0 != parent) {
	parent->childCnt++;
    }
    if (!dr->blocked && (NULL == parent || NULL == parent->hint || OffOverlay != parent->hint->overlay)) {
	if (dr->has.value) {
	    if (dr->has.pos) {
		rb_ivar_set(dr->handler, ox_at_pos_id, LONG2NUM(pos));
	    }
	    if (dr->has.line) {
		rb_ivar_set(dr->handler, ox_at_line_id, LONG2NUM(line));
	    }
	    if (dr->has.column) {
		rb_ivar_set(dr->handler, ox_at_column_id, LONG2NUM(col));
	    }
	    *args = dr->value_obj;
	    rb_funcall2(dr->handler, ox_value_id, 1, args);
	} else if (dr->has.text) {
	    if (dr->options.convert_special) {
		ox_sax_collapse_special(dr, dr->buf.str, pos, line, col);
	    }
	    switch (dr->options.skip) {
	    case CrSkip:
		buf_collapse_return(dr->buf.str);
		break;
	    case SpcSkip:
		buf_collapse_white(dr->buf.str);
		break;
	    default:
		break;
	    }
	    args[0] = rb_str_new2(dr->buf.str);
#if HAS_ENCODING_SUPPORT
	    if (0 != dr->encoding) {
		rb_enc_associate(args[0], dr->encoding);
	    }
#elif HAS_PRIVATE_ENCODING
	    if (Qnil != dr->encoding) {
		rb_funcall(args[0], ox_force_encoding_id, 1, dr->encoding);
	    }
#endif
	    if (dr->has.pos) {
		rb_ivar_set(dr->handler, ox_at_pos_id, LONG2NUM(pos));
	    }
	    if (dr->has.line) {
		rb_ivar_set(dr->handler, ox_at_line_id, LONG2NUM(line));
	    }
	    if (dr->has.column) {
		rb_ivar_set(dr->handler, ox_at_column_id, LONG2NUM(col));
	    }
	    rb_funcall2(dr->handler, ox_text_id, 1, args);
	}
    }
    dr->buf.str = 0;

    return c;
}

static int
read_jump_term(Buf buf, const char *pat) {
    struct _CheckPt	cp;

    buf_checkpoint(buf, &cp); // right after <
    if ('/' != buf_next_non_white(buf)) {
	return 0;
    }
    if (*pat != tolower(buf_next_non_white(buf))) {
	return 0;
    }
    for (pat++; '\0' != *pat; pat++) {
	if (*pat != tolower(buf_get(buf))) {
	    return 0;
	}
    }
    if ('>' != buf_next_non_white(buf)) {
	return 0;
    }
    buf_checkback(buf, &cp);
    return 1;
}

static char
read_jump(SaxDrive dr, const char *pat) {
    VALUE	args[1];
    char        c;
    int		pos = dr->buf.pos;
    int		line = dr->buf.line;
    int		col = dr->buf.col - 1;
    Nv		parent = stack_peek(&dr->stack);

    buf_protect(&dr->buf);
    while (1) {
	c = buf_get(&dr->buf);
	switch(c) {
	case '<':
	    if (read_jump_term(&dr->buf, pat)) {
		goto END_OF_BUF;
		break;
	    }
	    break;
	case '\0':
            ox_sax_drive_error(dr, NO_TERM "not terminated");
	    goto END_OF_BUF;
	    break;
	default:
	    break;
	}
    }
 END_OF_BUF:
    if ('\0' != c) {
	*(dr->buf.tail - 1) = '\0';
    }
    if (0 != parent) {
	parent->childCnt++;
    }
    // TBD check parent overlay
    if (dr->has.text && !dr->blocked) {
        args[0] = rb_str_new2(dr->buf.str);
#if HAS_ENCODING_SUPPORT
        if (0 != dr->encoding) {
            rb_enc_associate(args[0], dr->encoding);
        }
#elif HAS_PRIVATE_ENCODING
        if (Qnil != dr->encoding) {
	    rb_funcall(args[0], ox_force_encoding_id, 1, dr->encoding);
        }
#endif
	if (dr->has.pos) {
	    rb_ivar_set(dr->handler, ox_at_pos_id, LONG2NUM(pos));
	}
	if (dr->has.line) {
	    rb_ivar_set(dr->handler, ox_at_line_id, LONG2NUM(line));
	}
	if (dr->has.column) {
	    rb_ivar_set(dr->handler, ox_at_column_id, LONG2NUM(col));
	}
        rb_funcall2(dr->handler, ox_text_id, 1, args);
    }
    dr->buf.str = 0;
    if ('\0' != c) {
	*(dr->buf.tail - 1) = '<';
    }
    return c;
}

static char
read_attrs(SaxDrive dr, char c, char termc, char term2, int is_xml, int eq_req, Hint h) {
    VALUE       name = Qnil;
    int         is_encoding = 0;
    int		pos;
    int		line;
    int		col;
    char	*attr_value;

    // already protected by caller
    dr->buf.str = dr->buf.tail;
    if (is_white(c)) {
        c = buf_next_non_white(&dr->buf);
    }
    while (termc != c && term2 != c) {
	buf_backup(&dr->buf);
        if ('\0' == c) {
	    ox_sax_drive_error(dr, NO_TERM "attributes not terminated");
	    return '\0';
        }
	pos = dr->buf.pos + 1;
	line = dr->buf.line;
	col = dr->buf.col + 1;
        if ('\0' == (c = read_name_token(dr))) {
	    ox_sax_drive_error(dr, NO_TERM "error reading token");
	    return '\0';
        }
        if (is_xml && 0 == strcasecmp("encoding", dr->buf.str)) {
            is_encoding = 1;
        }
        if (dr->has.attr || dr->has.attr_value) {
            name = str2sym(dr, dr->buf.str, 0);
        }
        if (is_white(c)) {
            c = buf_next_non_white(&dr->buf);
        }
        if ('=' != c) {
	    if (eq_req) {
		dr->err = 1;
		return c;
	    } else {
		ox_sax_drive_error(dr, WRONG_CHAR "no attribute value");
		attr_value = (char*)"";
	    }
        } else {
	    pos = dr->buf.pos + 1;
	    line = dr->buf.line;
	    col = dr->buf.col + 1;
	    c = read_quoted_value(dr);
	    attr_value = dr->buf.str;
	    if (is_encoding) {
#if HAS_ENCODING_SUPPORT
		dr->encoding = rb_enc_find(dr->buf.str);
#elif HAS_PRIVATE_ENCODING
		dr->encoding = rb_str_new2(dr->buf.str);
#else
		dr->encoding = dr->buf.str;
#endif
		is_encoding = 0;
	    }
	}
	if (0 >= dr->blocked && (NULL == h || ActiveOverlay == h->overlay || NestOverlay == h->overlay)) {
	    if (dr->has.attr_value) {
		VALUE       args[2];

		if (dr->has.pos) {
		    rb_ivar_set(dr->handler, ox_at_pos_id, LONG2NUM(pos));
		}
		if (dr->has.line) {
		    rb_ivar_set(dr->handler, ox_at_line_id, LONG2NUM(line));
		}
		if (dr->has.column) {
		    rb_ivar_set(dr->handler, ox_at_column_id, LONG2NUM(col));
		}
		args[0] = name;
		args[1] = dr->value_obj;
		rb_funcall2(dr->handler, ox_attr_value_id, 2, args);
	    } else if (dr->has.attr) {
		VALUE       args[2];

		args[0] = name;
		if (dr->options.convert_special) {
		    ox_sax_collapse_special(dr, dr->buf.str, pos, line, col);
		}
		args[1] = rb_str_new2(attr_value);
#if HAS_ENCODING_SUPPORT
		if (0 != dr->encoding) {
		    rb_enc_associate(args[1], dr->encoding);
		}
#elif HAS_PRIVATE_ENCODING
		if (Qnil != dr->encoding) {
		    rb_funcall(args[1], ox_force_encoding_id, 1, dr->encoding);
		}
#endif
		if (dr->has.pos) {
		    rb_ivar_set(dr->handler, ox_at_pos_id, LONG2NUM(pos));
		}
		if (dr->has.line) {
		    rb_ivar_set(dr->handler, ox_at_line_id, LONG2NUM(line));
		}
		if (dr->has.column) {
		    rb_ivar_set(dr->handler, ox_at_column_id, LONG2NUM(col));
		}
		rb_funcall2(dr->handler, ox_attr_id, 2, args);
	    }
	}
	if (is_white(c)) {
	    c = buf_next_non_white(&dr->buf);
	}
    }
    dr->buf.str = 0;

    return c;
}

/* The character after the word is returned. dr->buf.tail is one past
 * that. dr->buf.str will point to the token which will be '\0' terminated.
 */
static char
read_name_token(SaxDrive dr) {
    char        c;

    dr->buf.str = dr->buf.tail;
    c = buf_get(&dr->buf);
    if (is_white(c)) {
        c = buf_next_non_white(&dr->buf);
        dr->buf.str = dr->buf.tail - 1;
    }
    while (1) {
	switch (c) {
	case ' ':
	case '\t':
	case '\f':
	case '?':
	case '=':
	case '/':
	case '>':
	case '<':
	case '\n':
	case '\r':
            *(dr->buf.tail - 1) = '\0';
	    return c;
	case '\0':
            /* documents never terminate after a name token */
            ox_sax_drive_error(dr, NO_TERM "document not terminated");
            return '\0';
	case ':':
	    if ('\0' == *dr->options.strip_ns) {
		break;
	    } else if ('*' == *dr->options.strip_ns && '\0' == dr->options.strip_ns[1]) {
		dr->buf.str = dr->buf.tail;
	    } else if (dr->options.smart && 0 == strncasecmp(dr->options.strip_ns, dr->buf.str, dr->buf.tail - dr->buf.str - 1)) {
		dr->buf.str = dr->buf.tail;
	    } else if (0 == strncmp(dr->options.strip_ns, dr->buf.str, dr->buf.tail - dr->buf.str - 1)) {
		dr->buf.str = dr->buf.tail;
	    }
	    break;
	default:
	    break;
	}
        c = buf_get(&dr->buf);
    }
    return '\0';
}

/* The character after the quote or if there is no quote, the character after the word is returned. dr->buf.tail is one past
 * that. dr->buf.str will point to the token which will be '\0' terminated.
 */
static char
read_quoted_value(SaxDrive dr) {
    char	c;

    c = buf_get(&dr->buf);
    if (is_white(c)) {
        c = buf_next_non_white(&dr->buf);
    }
    if ('"' == c || '\'' == c) {
	char	term = c;

        dr->buf.str = dr->buf.tail;
        while (term != (c = buf_get(&dr->buf))) {
            if ('\0' == c) {
                ox_sax_drive_error(dr, NO_TERM "quoted value not terminated");
                return '\0';
            }
        }
	// dr->buf.tail is one past quote char
	*(dr->buf.tail - 1) = '\0'; /* terminate value */
	c = buf_get(&dr->buf);
	return c;
    }
    // not quoted, look for something that terminates the string
    dr->buf.str = dr->buf.tail - 1;
    ox_sax_drive_error(dr, WRONG_CHAR "attribute value not in quotes");
    while ('\0' != (c = buf_get(&dr->buf))) {
	switch (c) {
	case ' ':
	    //case '/':
	case '>':
	case '?': // for instructions
	case '\t':
	case '\n':
	case '\r':
	    *(dr->buf.tail - 1) = '\0'; /* terminate value */
	    // dr->buf.tail is in the correct position, one after the word terminator
	    return c;
	default:
	    break;
	}
    }
    return '\0'; // should never get here
}

static char*
read_hex_uint64(char *b, uint64_t *up) {
    uint64_t	u = 0;
    char	c;

    for (; ';' != *b; b++) {
	c = *b;
	if ('0' <= c && c <= '9') {
	    u = (u << 4) | (uint64_t)(c - '0');
	} else if ('a' <= c && c <= 'f') {
	    u = (u << 4) | (uint64_t)(c - 'a' + 10);
	} else if ('A' <= c && c <= 'F') {
	    u = (u << 4) | (uint64_t)(c - 'A' + 10);
	} else {
	    return 0;
	}
    }
    *up = u;

    return b;
}

static char*
read_10_uint64(char *b, uint64_t *up) {
    uint64_t	u = 0;
    char	c;

    for (; ';' != *b; b++) {
	c = *b;
	if ('0' <= c && c <= '9') {
	    u = (u * 10) + (uint64_t)(c - '0');
	} else {
	    return 0;
	}
    }
    *up = u;

    return b;
}

int
ox_sax_collapse_special(SaxDrive dr, char *str, int pos, int line, int col) {
    char        *s = str;
    char        *b = str;

    while ('\0' != *s) {
        if ('&' == *s) {
            int         c = 0;
            char        *end;

            s++;
            if ('#' == *s) {
		uint64_t	u = 0;
		char		x;

		s++;
		if ('x' == *s || 'X' == *s) {
		    x = *s;
		    s++;
		    end = read_hex_uint64(s, &u);
		} else {
		    x = '\0';
		    end = read_10_uint64(s, &u);
		}
		if (0 == end) {
		    ox_sax_drive_error(dr, NO_TERM "special character does not end with a semicolon");
		    *b++ = '&';
		    *b++ = '#';
		    if ('\0' != x) {
			*b++ = x;
		    }
		    continue;
		}
		if (u <= 0x000000000000007FULL) {
		    *b++ = (char)u;
#if HAS_ENCODING_SUPPORT
		} else if (ox_utf8_encoding == dr->encoding) {
		    b = ox_ucs_to_utf8_chars(b, u);
		} else if (0 == dr->encoding) {
		    dr->encoding = ox_utf8_encoding;
		    b = ox_ucs_to_utf8_chars(b, u);
#elif HAS_PRIVATE_ENCODING
		} else if (ox_utf8_encoding == dr->encoding ||
			   0 == strcasecmp(rb_str_ptr(rb_String(ox_utf8_encoding)), rb_str_ptr(rb_String(dr->encoding)))) {
		    b = ox_ucs_to_utf8_chars(b, u);
		} else if (Qnil == dr->encoding) {
		    dr->encoding = ox_utf8_encoding;
		    b = ox_ucs_to_utf8_chars(b, u);
#else
		} else if (0 == dr->encoding) {
		    dr->encoding = UTF8_STR;
		    b = ox_ucs_to_utf8_chars(b, u);
		} else if (0 == strcasecmp(UTF8_STR, dr->encoding)) {
		    b = ox_ucs_to_utf8_chars(b, u);
#endif
		} else {
		    b = ox_ucs_to_utf8_chars(b, u);
		    /*
		    ox_sax_drive_error(dr, NO_TERM "Invalid encoding, need UTF-8 encoding to parse &#nnnn; character sequences.");
		    *b++ = '&';
		    *b++ = '#';
		    if ('\0' != x) {
			*b++ = x;
		    }
		    continue;
		    */
		}
		s = end + 1;
		continue;
            } else if (0 == strncasecmp(s, "lt;", 3)) {
                c = '<';
                s += 3;
		col += 3;
            } else if (0 == strncasecmp(s, "gt;", 3)) {
                c = '>';
                s += 3;
		col += 3;
            } else if (0 == strncasecmp(s, "amp;", 4)) {
                c = '&';
                s += 4;
		col += 4;
            } else if (0 == strncasecmp(s, "quot;", 5)) {
                c = '"';
                s += 5;
		col += 5;
            } else if (0 == strncasecmp(s, "apos;", 5)) {
                c = '\'';
                s += 5;
            } else {
		ox_sax_drive_error_at(dr, INVALID_FORMAT "Invalid special character sequence", pos, line, col);
		c = '&';
            }
            *b++ = (char)c;
	    col++;
        } else {
	    if ('\n' == *s) {
		line++;
		col = 0;
	    }
	    col++;
            *b++ = *s++;
        }
    }
    *b = '\0';

    return 0;
}

static void
hint_clear_empty(SaxDrive dr) {
    Nv	nv;

    for (nv = stack_peek(&dr->stack); 0 != nv; nv = stack_peek(&dr->stack)) {
	if (0 == nv->hint) {
	    break;
	}
	if (nv->hint->empty) {
	    end_element_cb(dr, nv->val, dr->buf.pos, dr->buf.line, dr->buf.col, nv->hint);
	    stack_pop(&dr->stack);
	} else {
	    break;
	}
    }
}

static Nv
hint_try_close(SaxDrive dr, const char *name) {
    Hint	h = ox_hint_find(dr->options.hints, name);
    Nv		nv;

    if (0 == h) {
	return 0;
    }
    for (nv = stack_peek(&dr->stack); 0 != nv; nv = stack_peek(&dr->stack)) {
	if (0 == strcasecmp(name, nv->name)) {
	    stack_pop(&dr->stack);
	    return nv;
	}
	if (0 == nv->hint) {
	    break;
	}
	if (nv->hint->empty) {
	    end_element_cb(dr, nv->val, dr->buf.pos, dr->buf.line, dr->buf.col, nv->hint);
	    dr->stack.tail = nv;
	} else {
	    break;
	}
    }
    return 0;
}

static void
end_element_cb(SaxDrive dr, VALUE name, int pos, int line, int col, Hint h) {
    if (dr->has.end_element && 0 >= dr->blocked && (NULL == h || ActiveOverlay == h->overlay || NestOverlay == h->overlay)) {
	if (dr->has.pos) {
	    rb_ivar_set(dr->handler, ox_at_pos_id, LONG2NUM(pos));
	}
	if (dr->has.line) {
	    rb_ivar_set(dr->handler, ox_at_line_id, LONG2NUM(line));
	}
	if (dr->has.column) {
	    rb_ivar_set(dr->handler, ox_at_column_id, LONG2NUM(col));
	}
	rb_funcall(dr->handler, ox_end_element_id, 1, name);
    }
    if (NULL != h && BlockOverlay == h->overlay && 0 < dr->blocked) {
	dr->blocked--;
    }
}

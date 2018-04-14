/* builder.c
 * Copyright (c) 2011, 2016 Peter Ohler
 * All rights reserved.
 */

#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "ox.h"
#include "buf.h"
#include "err.h"

#define MAX_DEPTH	128

typedef struct _Element {
    char	*name;
    char	buf[64];
    int		len;
    bool	has_child;
    bool	non_text_child;
} *Element;

typedef struct _Builder {
    struct _Buf		buf;
    int			indent;
    char		encoding[64];
    int			depth;
    FILE		*file;
    struct _Element	stack[MAX_DEPTH];
    long		line;
    long		col;
    long		pos;
} *Builder;

static VALUE		builder_class = Qundef;
static const char	indent_spaces[] = "\n                                                                                                                                "; // 128 spaces

// The : character is equivalent to 10. Used for replacement characters up to
// 10 characters long such as '&#x10FFFF;'. From
// https://www.w3.org/TR/2006/REC-xml11-20060816
#if 0
static const char	xml_friendly_chars[257] = "\
:::::::::11::1::::::::::::::::::\
11611156111111111111111111114141\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111";
#endif

// From 2.3 of the XML 1.1 spec. All over 0x20 except <&", > also. Builder
// uses double quotes for attributes.
static const char	xml_attr_chars[257] = "\
:::::::::11::1::::::::::::::::::\
11611151111111111111111111114141\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111";

// From 3.1 of the XML 1.1 spec. All over 0x20 except <&, > also.
static const char	xml_element_chars[257] = "\
:::::::::11::1::::::::::::::::::\
11111151111111111111111111114141\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111\
11111111111111111111111111111111";

inline static size_t
xml_str_len(const unsigned char *str, size_t len, const char *table) {
    size_t	size = 0;

    for (; 0 < len; str++, len--) {
	size += table[*str];
    }
    return size - len * (size_t)'0';
}

static void
append_indent(Builder b) {
    if (0 >= b->indent) {
	return;
    }
    if (b->buf.head < b->buf.tail) {
	int	cnt = (b->indent * (b->depth + 1)) + 1;

	if (sizeof(indent_spaces) <=  (size_t)cnt) {
	    cnt = sizeof(indent_spaces) - 1;
	}
	buf_append_string(&b->buf, indent_spaces, cnt);
	b->line++;
	b->col = cnt - 1;
	b->pos += cnt;
    }
}

static void
append_string(Builder b, const char *str, size_t size, const char *table, bool strip_invalid_chars) {
    size_t	xsize = xml_str_len((const unsigned char*)str, size, table);

    if (size == xsize) {
	const char	*s = str;
	const char	*end = str + size;

	buf_append_string(&b->buf, str, size);
	b->col += size;
        s = strchr(s, '\n');
        while (NULL != s) {
            b->line++;
            b->col = end - s;
            s = strchr(s + 1, '\n');
        }
	b->pos += size;
    } else {
	char	buf[256];
	char	*end = buf + sizeof(buf) - 1;
	char	*bp = buf;
	int	i = size;
	int	fcnt;

	for (; '\0' != *str && 0 < i; i--, str++) {
	    if ('1' == (fcnt = table[(unsigned char)*str])) {
		if (end <= bp) {
		    buf_append_string(&b->buf, buf, bp - buf);
		    bp = buf;
		}
		if ('\n' == *str) {
		    b->line++;
		    b->col = 1;
		} else {
		    b->col++;
		}
		b->pos++;
		*bp++ = *str;
	    } else {
		b->pos += fcnt - '0';
		b->col += fcnt - '0';
		if (buf < bp) {
		    buf_append_string(&b->buf, buf, bp - buf);
		    bp = buf;
		}
		switch (*str) {
		case '"':
		    buf_append_string(&b->buf, "&quot;", 6);
		    break;
		case '&':
		    buf_append_string(&b->buf, "&amp;", 5);
		    break;
		case '\'':
		    buf_append_string(&b->buf, "&apos;", 6);
		    break;
		case '<':
		    buf_append_string(&b->buf, "&lt;", 4);
		    break;
		case '>':
		    buf_append_string(&b->buf, "&gt;", 4);
		    break;
		default:
		    // Must be one of the invalid characters.
		    if (!strip_invalid_chars) {
			rb_raise(rb_eSyntaxError, "'\\#x%02x' is not a valid XML character.", *str);
		    }
		    break;
		}
	    }
	}
	if (buf < bp) {
	    buf_append_string(&b->buf, buf, bp - buf);
	    bp = buf;
	}
    }
}

static void
append_sym_str(Builder b, VALUE v) {
    const char	*s;
    int		len;

    switch (rb_type(v)) {
    case T_STRING:
	s = StringValuePtr(v);
	len = RSTRING_LEN(v);
	break;
    case T_SYMBOL:
	s = rb_id2name(SYM2ID(v));
	len = strlen(s);
	break;
    default:
	rb_raise(ox_arg_error_class, "expected a Symbol or String");
	break;
    }
    append_string(b, s, len, xml_element_chars, false);
}

static void
i_am_a_child(Builder b, bool is_text) {
    if (0 <= b->depth) {
	Element	e = &b->stack[b->depth];

	if (!e->has_child) {
	    e->has_child = true;
	    buf_append(&b->buf, '>');
	    b->col++;
	    b->pos++;
	}
	if (!is_text) {
	    e->non_text_child = true;
	}
    }
}

static int
append_attr(VALUE key, VALUE value, Builder b) {
    buf_append(&b->buf, ' ');
    b->col++;
    b->pos++;
    append_sym_str(b, key);
    buf_append_string(&b->buf, "=\"", 2);
    b->col += 2;
    b->pos += 2;
    Check_Type(value, T_STRING);
    append_string(b, StringValuePtr(value), (int)RSTRING_LEN(value), xml_attr_chars, false);
    buf_append(&b->buf, '"');
    b->col++;
    b->pos++;

    return ST_CONTINUE;
}

static void
init(Builder b, int fd, int indent, long initial_size) {
    buf_init(&b->buf, fd, initial_size);
    b->indent = indent;
    *b->encoding = '\0';
    b->depth = -1;
    b->line = 1;
    b->col = 1;
    b->pos = 0;
}

static void
builder_free(void *ptr) {
    Builder	b;
    Element	e;
    int		d;

    if (0 == ptr) {
	return;
    }
    b = (Builder)ptr;
    buf_cleanup(&b->buf);
    for (e = b->stack, d = b->depth; 0 < d; d--, e++) {
	if (e->name != e->buf) {
	    free(e->name);
	}
    }
    xfree(ptr);
}

static void
pop(Builder b) {
    Element	e;

    if (0 > b->depth) {
	rb_raise(ox_arg_error_class, "closed too many elements");
    }
    e = &b->stack[b->depth];
    b->depth--;
    if (e->has_child) {
	if (e->non_text_child) {
	    append_indent(b);
	}
	buf_append_string(&b->buf, "</", 2);
	buf_append_string(&b->buf, e->name, e->len);
	buf_append(&b->buf, '>');
	b->col += e->len + 3;
	b->pos += e->len + 3;
	if (e->buf != e->name) {
	    free(e->name);
	    e->name = 0;
	}
    } else {
	buf_append_string(&b->buf, "/>", 2);
	b->col += 2;
	b->pos += 2;
    }
}

static void
bclose(Builder b) {
    while (0 <= b->depth) {
	pop(b);
    }
    if (0 <= b->indent) {
	buf_append(&b->buf, '\n');
    }
    b->line++;
    b->col = 1;
    b->pos++;
    buf_finish(&b->buf);
    if (NULL != b->file) {
	fclose(b->file);
    }
}

static VALUE
to_s(Builder b) {
    volatile VALUE	rstr;

    if (0 != b->buf.fd) {
	rb_raise(ox_arg_error_class, "can not create a String with a stream or file builder.");
    }
    if (0 <= b->indent && '\n' != *(b->buf.tail - 1)) {
	buf_append(&b->buf, '\n');
	b->line++;
	b->col = 1;
	b->pos++;
    }
    *b->buf.tail = '\0'; // for debugging
    rstr = rb_str_new(b->buf.head, buf_len(&b->buf));

    if ('\0' != *b->encoding) {
#if HAS_ENCODING_SUPPORT
	rb_enc_associate(rstr, rb_enc_find(b->encoding));
#endif
    }
    return rstr;
}

/* call-seq: new(options)
 *
 * Creates a new Builder that will write to a string that can be retrieved with
 * the to_s() method. If a block is given it is executed with a single parameter
 * which is the builder instance. The return value is then the generated string.
 *
 * - +options+ - (Hash) formating options
 *   - +:indent+ (Fixnum) indentaion level, negative values excludes terminating newline
 *   - +:size+ (Fixnum) the initial size of the string buffer
 */
static VALUE
builder_new(int argc, VALUE *argv, VALUE self) {
    Builder	b = ALLOC(struct _Builder);
    int		indent = ox_default_options.indent;
    long	buf_size = 0;

    if (1 == argc) {
	volatile VALUE	v;

	rb_check_type(*argv, T_HASH);
	if (Qnil != (v = rb_hash_lookup(*argv, ox_indent_sym))) {
#ifdef RUBY_INTEGER_UNIFICATION
	    if (rb_cInteger != rb_obj_class(v)) {
#else
	    if (rb_cFixnum != rb_obj_class(v)) {
#endif
		rb_raise(ox_parse_error_class, ":indent must be a fixnum.\n");
	    }
	    indent = NUM2INT(v);
	}
	if (Qnil != (v = rb_hash_lookup(*argv, ox_size_sym))) {
#ifdef RUBY_INTEGER_UNIFICATION
	    if (rb_cInteger != rb_obj_class(v)) {
#else
	    if (rb_cFixnum != rb_obj_class(v)) {
#endif
		rb_raise(ox_parse_error_class, ":size must be a fixnum.\n");
	    }
	    buf_size = NUM2LONG(v);
	}
    }
    b->file = NULL;
    init(b, 0, indent, buf_size);

    if (rb_block_given_p()) {
	volatile VALUE	rb = Data_Wrap_Struct(builder_class, NULL, builder_free, b);

	rb_yield(rb);
	bclose(b);

	return to_s(b);
    } else {
	return Data_Wrap_Struct(builder_class, NULL, builder_free, b);
    }
}

/* call-seq: file(filename, options)
 *
 * Creates a new Builder that will write to a file.
 *
 * - +filename+ (String) filename to write to
 * - +options+ - (Hash) formating options
 *   - +:indent+ (Fixnum) indentaion level, negative values excludes terminating newline
 *   - +:size+ (Fixnum) the initial size of the string buffer
 */
static VALUE
builder_file(int argc, VALUE *argv, VALUE self) {
    Builder	b = ALLOC(struct _Builder);
    int		indent = ox_default_options.indent;
    long	buf_size = 0;
    FILE	*f;

    if (1 > argc) {
	rb_raise(ox_arg_error_class, "missing filename");
    }
    Check_Type(*argv, T_STRING);
    if (NULL == (f = fopen(StringValuePtr(*argv), "w"))) {
	xfree(b);
	rb_raise(rb_eIOError, "%s\n", strerror(errno));
    }
    if (2 == argc) {
	volatile VALUE	v;

	rb_check_type(argv[1], T_HASH);
	if (Qnil != (v = rb_hash_lookup(argv[1], ox_indent_sym))) {
#ifdef RUBY_INTEGER_UNIFICATION
	    if (rb_cInteger != rb_obj_class(v)) {
#else
	    if (rb_cFixnum != rb_obj_class(v)) {
#endif
		rb_raise(ox_parse_error_class, ":indent must be a fixnum.\n");
	    }
	    indent = NUM2INT(v);
	}
	if (Qnil != (v = rb_hash_lookup(argv[1], ox_size_sym))) {
#ifdef RUBY_INTEGER_UNIFICATION
	    if (rb_cInteger != rb_obj_class(v)) {
#else
	    if (rb_cFixnum != rb_obj_class(v)) {
#endif
		rb_raise(ox_parse_error_class, ":size must be a fixnum.\n");
	    }
	    buf_size = NUM2LONG(v);
	}
    }
    b->file = f;
    init(b, fileno(f), indent, buf_size);

    if (rb_block_given_p()) {
	volatile VALUE	rb = Data_Wrap_Struct(builder_class, NULL, builder_free, b);
	rb_yield(rb);
	bclose(b);
	return Qnil;
    } else {
	return Data_Wrap_Struct(builder_class, NULL, builder_free, b);
    }
}

/* call-seq: io(io, options)
 *
 * Creates a new Builder that will write to an IO instance.
 *
 * - +io+ (String) IO to write to
 * - +options+ - (Hash) formating options
 *   - +:indent+ (Fixnum) indentaion level, negative values excludes terminating newline
 *   - +:size+ (Fixnum) the initial size of the string buffer
 */
static VALUE
builder_io(int argc, VALUE *argv, VALUE self) {
    Builder		b = ALLOC(struct _Builder);
    int			indent = ox_default_options.indent;
    long		buf_size = 0;
    int			fd;
    volatile VALUE	v;

    if (1 > argc) {
	rb_raise(ox_arg_error_class, "missing IO object");
    }
    if (!rb_respond_to(*argv, ox_fileno_id) ||
	Qnil == (v = rb_funcall(*argv, ox_fileno_id, 0)) ||
	0 == (fd = FIX2INT(v))) {
	rb_raise(rb_eIOError, "expected an IO that has a fileno.");
    }
    if (2 == argc) {
	volatile VALUE	v;

	rb_check_type(argv[1], T_HASH);
	if (Qnil != (v = rb_hash_lookup(argv[1], ox_indent_sym))) {
#ifdef RUBY_INTEGER_UNIFICATION
	    if (rb_cInteger != rb_obj_class(v)) {
#else
	    if (rb_cFixnum != rb_obj_class(v)) {
#endif
		rb_raise(ox_parse_error_class, ":indent must be a fixnum.\n");
	    }
	    indent = NUM2INT(v);
	}
	if (Qnil != (v = rb_hash_lookup(argv[1], ox_size_sym))) {
#ifdef RUBY_INTEGER_UNIFICATION
	    if (rb_cInteger != rb_obj_class(v)) {
#else
	    if (rb_cFixnum != rb_obj_class(v)) {
#endif
		rb_raise(ox_parse_error_class, ":size must be a fixnum.\n");
	    }
	    buf_size = NUM2LONG(v);
	}
    }
    b->file = NULL;
    init(b, fd, indent, buf_size);

    if (rb_block_given_p()) {
	volatile VALUE	rb = Data_Wrap_Struct(builder_class, NULL, builder_free, b);
	rb_yield(rb);
	bclose(b);
	return Qnil;
    } else {
	return Data_Wrap_Struct(builder_class, NULL, builder_free, b);
    }
}

/* call-seq: instruct(decl,options)
 *
 * Adds the top level <?xml?> element.
 *
 * - +decl+ - (String) 'xml' expected
 * - +options+ - (Hash) version or encoding
 */
static VALUE
builder_instruct(int argc, VALUE *argv, VALUE self) {
    Builder	b = (Builder)DATA_PTR(self);

    i_am_a_child(b, false);
    append_indent(b);
    if (0 == argc) {
	buf_append_string(&b->buf, "<?xml?>", 7);
	b->col += 7;
	b->pos += 7;
    } else {
	volatile VALUE	v;

	buf_append_string(&b->buf, "<?", 2);
	b->col += 2;
	b->pos += 2;
	append_sym_str(b, *argv);
	if (1 < argc && rb_cHash == rb_obj_class(argv[1])) {
	    int	len;

	    if (Qnil != (v = rb_hash_lookup(argv[1], ox_version_sym))) {
		if (rb_cString != rb_obj_class(v)) {
		    rb_raise(ox_parse_error_class, ":version must be a Symbol.\n");
		}
		len = (int)RSTRING_LEN(v);
		buf_append_string(&b->buf, " version=\"", 10);
		buf_append_string(&b->buf, StringValuePtr(v), len);
		buf_append(&b->buf, '"');
		b->col += len + 11;
		b->pos += len + 11;
	    }
	    if (Qnil != (v = rb_hash_lookup(argv[1], ox_encoding_sym))) {
		if (rb_cString != rb_obj_class(v)) {
		    rb_raise(ox_parse_error_class, ":encoding must be a Symbol.\n");
		}
		len = (int)RSTRING_LEN(v);
		buf_append_string(&b->buf, " encoding=\"", 11);
		buf_append_string(&b->buf, StringValuePtr(v), len);
		buf_append(&b->buf, '"');
		b->col += len + 12;
		b->pos += len + 12;
		strncpy(b->encoding, StringValuePtr(v), sizeof(b->encoding));
		b->encoding[sizeof(b->encoding) - 1] = '\0';
	    }
	    if (Qnil != (v = rb_hash_lookup(argv[1], ox_standalone_sym))) {
		if (rb_cString != rb_obj_class(v)) {
		    rb_raise(ox_parse_error_class, ":standalone must be a Symbol.\n");
		}
		len = (int)RSTRING_LEN(v);
		buf_append_string(&b->buf, " standalone=\"", 13);
		buf_append_string(&b->buf, StringValuePtr(v), len);
		buf_append(&b->buf, '"');
		b->col += len + 14;
		b->pos += len + 14;
	    }
	}
	buf_append_string(&b->buf, "?>", 2);
	b->col += 2;
	b->pos += 2;
    }
    return Qnil;
}

/* call-seq: element(name,attributes)
 *
 * Adds an element with the name and attributes provided. If a block is given
 * then on closing of the block a pop() is called.
 *
 * - +name+ - (String) name of the element
 * - +attributes+ - (Hash) of the element
 */
static VALUE
builder_element(int argc, VALUE *argv, VALUE self) {
    Builder		b = (Builder)DATA_PTR(self);
    Element		e;
    const char		*name;
    int			len;

    if (1 > argc) {
	rb_raise(ox_arg_error_class, "missing element name");
    }
    i_am_a_child(b, false);
    append_indent(b);
    b->depth++;
    if (MAX_DEPTH <= b->depth) {
	rb_raise(ox_arg_error_class, "XML too deeply nested");
    }
    switch (rb_type(*argv)) {
    case T_STRING:
	name = StringValuePtr(*argv);
	len = RSTRING_LEN(*argv);
	break;
    case T_SYMBOL:
	name = rb_id2name(SYM2ID(*argv));
	len = strlen(name);
	break;
    default:
	rb_raise(ox_arg_error_class, "expected a Symbol or String for an element name");
	break;
    }
    e = &b->stack[b->depth];
    if (sizeof(e->buf) <= (size_t)len) {
	e->name = strdup(name);
	*e->buf = '\0';
    } else {
	strcpy(e->buf, name);
	e->name = e->buf;
    }
    e->len = len;
    e->has_child = false;
    e->non_text_child = false;

    buf_append(&b->buf, '<');
    b->col++;
    b->pos++;
    append_string(b, e->name, len, xml_element_chars, false);
    if (1 < argc && T_HASH == rb_type(argv[1])) {
	rb_hash_foreach(argv[1], append_attr, (VALUE)b);
    }
    // Do not close with > or /> yet. That is done with i_am_a_child() or pop().
    if (rb_block_given_p()) {
	rb_yield(self);
	pop(b);
    }
    return Qnil;
}

/* call-seq: void_element(name,attributes)
 *
 * Adds an void element with the name and attributes provided.
 *
 * - +name+ - (String) name of the element
 * - +attributes+ - (Hash) of the element
 */
static VALUE
builder_void_element(int argc, VALUE *argv, VALUE self) {
    Builder	b = (Builder)DATA_PTR(self);
    const char	*name;
    int		len;

    if (1 > argc) {
	rb_raise(ox_arg_error_class, "missing element name");
    }
    i_am_a_child(b, false);
    append_indent(b);
    switch (rb_type(*argv)) {
    case T_STRING:
	name = StringValuePtr(*argv);
	len = RSTRING_LEN(*argv);
	break;
    case T_SYMBOL:
	name = rb_id2name(SYM2ID(*argv));
	len = strlen(name);
	break;
    default:
	rb_raise(ox_arg_error_class, "expected a Symbol or String for an element name");
	break;
    }
    buf_append(&b->buf, '<');
    b->col++;
    b->pos++;
    append_string(b, name, len, xml_element_chars, false);
    if (1 < argc && T_HASH == rb_type(argv[1])) {
	rb_hash_foreach(argv[1], append_attr, (VALUE)b);
    }
    buf_append_string(&b->buf, ">", 1);
    b->col++;;
    b->pos++;

    return Qnil;
}

/* call-seq: comment(text)
 *
 * Adds a comment element to the XML string being formed.
 * - +text+ - (String) contents of the comment
 */
static VALUE
builder_comment(VALUE self, VALUE text) {
    Builder	b = (Builder)DATA_PTR(self);

    rb_check_type(text, T_STRING);
    i_am_a_child(b, false);
    append_indent(b);
    buf_append_string(&b->buf, "<!--", 4);
    b->col += 5;
    b->pos += 5;
    append_string(b, StringValuePtr(text), RSTRING_LEN(text), xml_element_chars, false);
    buf_append_string(&b->buf, "-->", 3);
    b->col += 5;
    b->pos += 5;

    return Qnil;
}

/* call-seq: doctype(text)
 *
 * Adds a DOCTYPE element to the XML string being formed.
 * - +text+ - (String) contents of the doctype
 */
static VALUE
builder_doctype(VALUE self, VALUE text) {
    Builder	b = (Builder)DATA_PTR(self);

    rb_check_type(text, T_STRING);
    i_am_a_child(b, false);
    append_indent(b);
    buf_append_string(&b->buf, "<!DOCTYPE ", 10);
    b->col += 10;
    b->pos += 10;
    append_string(b, StringValuePtr(text), RSTRING_LEN(text), xml_element_chars, false);
    buf_append(&b->buf, '>');
    b->col++;
    b->pos++;

    return Qnil;
}

/* call-seq: text(text)
 *
 * Adds a text element to the XML string being formed.
 * - +text+ - (String) contents of the text field
 * - +strip_invalid_chars+ - [true|false] strips any characters invalid for XML, defaults to false
 */
static VALUE
builder_text(int argc, VALUE *argv, VALUE self) {
    Builder		b = (Builder)DATA_PTR(self);
    volatile VALUE	v;
    volatile VALUE	strip_invalid_chars;

    if ((0 == argc) || (argc > 2)) {
	rb_raise(rb_eArgError, "wrong number of arguments (given %d, expected 1..2)", argc);
    }
    v = argv[0];
    if (2 == argc) {
	strip_invalid_chars = argv[1];
    } else {
	strip_invalid_chars = Qfalse;
    }

    if (T_STRING != rb_type(v)) {
	v = rb_funcall(v, ox_to_s_id, 0);
    }
    i_am_a_child(b, true);
    append_string(b, StringValuePtr(v), RSTRING_LEN(v), xml_element_chars, RTEST(strip_invalid_chars));

    return Qnil;
}

/* call-seq: cdata(data)
 *
 * Adds a CDATA element to the XML string being formed.
 * - +data+ - (String) contents of the CDATA element
 */
static VALUE
builder_cdata(VALUE self, VALUE data) {
    Builder		b = (Builder)DATA_PTR(self);
    volatile VALUE	v = data;
    const char		*str;
    const char		*s;
    const char		*end;
    int			len;

    if (T_STRING != rb_type(v)) {
	v = rb_funcall(v, ox_to_s_id, 0);
    }
    str = StringValuePtr(v);
    len = (int)RSTRING_LEN(v);
    s = str;
    end = str + len;
    i_am_a_child(b, false);
    append_indent(b);
    buf_append_string(&b->buf, "<![CDATA[", 9);
    b->col += 9;
    b->pos += 9;
    buf_append_string(&b->buf, str, len);
    b->col += len;
    s = strchr(s, '\n');
    while (NULL != s) {
        b->line++;
        b->col = end - s;
        s = strchr(s + 1, '\n');
    }
    b->pos += len;
    buf_append_string(&b->buf, "]]>", 3);
    b->col += 3;
    b->pos += 3;

    return Qnil;
}

/* call-seq: raw(text)
 *
 * Adds the provided string directly to the XML without formatting or modifications.
 *
 * - +text+ - (String) contents to be added
 */
static VALUE
builder_raw(VALUE self, VALUE text) {
    Builder		b = (Builder)DATA_PTR(self);
    volatile VALUE	v = text;
    const char		*str;
    const char		*s;
    const char		*end;
    int			len;

    if (T_STRING != rb_type(v)) {
	v = rb_funcall(v, ox_to_s_id, 0);
    }
    str = StringValuePtr(v);
    len = (int)RSTRING_LEN(v);
    s = str;
    end = str + len;
    i_am_a_child(b, true);
    buf_append_string(&b->buf, str, len);
    b->col += len;
    s = strchr(s, '\n');
    while (NULL != s) {
        b->line++;
        b->col = end - s;
        s = strchr(s + 1, '\n');
    }
    b->pos += len;

    return Qnil;
}

/* call-seq: to_s()
 *
 * Returns the JSON document string in what ever state the construction is at.
 */
static VALUE
builder_to_s(VALUE self) {
    return to_s((Builder)DATA_PTR(self));
}

/* call-seq: line()
 *
 * Returns the current line in the output. The first line is line 1.
 */
static VALUE
builder_line(VALUE self) {
    return LONG2NUM(((Builder)DATA_PTR(self))->line);
}

/* call-seq: column()
 *
 * Returns the current column in the output. The first character in a line is at
 * column 1.
 */
static VALUE
builder_column(VALUE self) {
    return LONG2NUM(((Builder)DATA_PTR(self))->col);
}

/* call-seq: pos()
 *
 * Returns the number of bytes written.
 */
static VALUE
builder_pos(VALUE self) {
    return LONG2NUM(((Builder)DATA_PTR(self))->pos);
}

/* call-seq: pop()
 *
 * Closes the current element.
 */
static VALUE
builder_pop(VALUE self) {
    pop((Builder)DATA_PTR(self));

    return Qnil;
}

/* call-seq: close()
 *
 * Closes the all elements and the document.
 */
static VALUE
builder_close(VALUE self) {
    bclose((Builder)DATA_PTR(self));

    return Qnil;
}

/*
 * Document-class: Ox::Builder
 *
 * An XML builder.
 */
void ox_init_builder(VALUE ox) {
    builder_class = rb_define_class_under(ox, "Builder", rb_cObject);
    rb_define_module_function(builder_class, "new", builder_new, -1);
    rb_define_module_function(builder_class, "file", builder_file, -1);
    rb_define_module_function(builder_class, "io", builder_io, -1);
    rb_define_method(builder_class, "instruct", builder_instruct, -1);
    rb_define_method(builder_class, "comment", builder_comment, 1);
    rb_define_method(builder_class, "doctype", builder_doctype, 1);
    rb_define_method(builder_class, "element", builder_element, -1);
    rb_define_method(builder_class, "void_element", builder_void_element, -1);
    rb_define_method(builder_class, "text", builder_text, -1);
    rb_define_method(builder_class, "cdata", builder_cdata, 1);
    rb_define_method(builder_class, "raw", builder_raw, 1);
    rb_define_method(builder_class, "pop", builder_pop, 0);
    rb_define_method(builder_class, "close", builder_close, 0);
    rb_define_method(builder_class, "to_s", builder_to_s, 0);
    rb_define_method(builder_class, "line", builder_line, 0);
    rb_define_method(builder_class, "column", builder_column, 0);
    rb_define_method(builder_class, "pos", builder_pos, 0);
}

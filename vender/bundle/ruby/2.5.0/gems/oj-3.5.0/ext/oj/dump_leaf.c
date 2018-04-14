/* dump_leaf.c
 * Copyright (c) 2012, 2017, Peter Ohler
 * All rights reserved.
 */

#include <errno.h>

#include "oj.h"
#include "dump.h"

static void	dump_leaf(Leaf leaf, int depth, Out out);

static void
grow(Out out, size_t len) {
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
	rb_raise(rb_eNoMemError, "Failed to create string. [%d:%s]\n", ENOSPC, strerror(ENOSPC));
    }
    out->buf = buf;
    out->end = buf + size;
    out->cur = out->buf + pos;
}


inline static void
dump_chars(const char *s, size_t size, Out out) {
    if (out->end - out->cur <= (long)size) {
	grow(out, size);
    }
    memcpy(out->cur, s, size);
    out->cur += size;
    *out->cur = '\0';
}

static void
dump_leaf_str(Leaf leaf, Out out) {
    switch (leaf->value_type) {
    case STR_VAL:
	oj_dump_cstr(leaf->str, strlen(leaf->str), 0, 0, out);
	break;
    case RUBY_VAL:
	oj_dump_cstr(rb_string_value_cstr(&leaf->value), RSTRING_LEN(leaf->value), 0, 0, out);
	break;
    case COL_VAL:
    default:
	rb_raise(rb_eTypeError, "Unexpected value type %02x.\n", leaf->value_type);
	break;
    }
}

static void
dump_leaf_fixnum(Leaf leaf, Out out) {
    switch (leaf->value_type) {
    case STR_VAL:
	dump_chars(leaf->str, strlen(leaf->str), out);
	break;
    case RUBY_VAL:
	if (T_BIGNUM == rb_type(leaf->value)) {
	    oj_dump_bignum(leaf->value, 0, out, false);
	} else {
	    oj_dump_fixnum(leaf->value, 0, out, false);
	}
	break;
    case COL_VAL:
    default:
	rb_raise(rb_eTypeError, "Unexpected value type %02x.\n", leaf->value_type);
	break;
    }
}

static void
dump_leaf_float(Leaf leaf, Out out) {
    switch (leaf->value_type) {
    case STR_VAL:
	dump_chars(leaf->str, strlen(leaf->str), out);
	break;
    case RUBY_VAL:
	oj_dump_float(leaf->value, 0, out, false);
	break;
    case COL_VAL:
    default:
	rb_raise(rb_eTypeError, "Unexpected value type %02x.\n", leaf->value_type);
	break;
    }
}

static void
dump_leaf_array(Leaf leaf, int depth, Out out) {
    size_t	size;
    int		d2 = depth + 1;

    size = 2;
    if (out->end - out->cur <= (long)size) {
	grow(out, size);
    }
    *out->cur++ = '[';
    if (0 == leaf->elements) {
	*out->cur++ = ']';
    } else {
	Leaf	first = leaf->elements->next;
	Leaf	e = first;

	size = d2 * out->indent + 2;
	do {
	    if (out->end - out->cur <= (long)size) {
		grow(out, size);
	    }
	    fill_indent(out, d2);
	    dump_leaf(e, d2, out);
	    if (e->next != first) {
		*out->cur++ = ',';
	    }
	    e = e->next;
	} while (e != first);
	size = depth * out->indent + 1;
	if (out->end - out->cur <= (long)size) {
	    grow(out, size);
	}
	fill_indent(out, depth);
	*out->cur++ = ']';
    }
    *out->cur = '\0';
}

static void
dump_leaf_hash(Leaf leaf, int depth, Out out) {
    size_t	size;
    int		d2 = depth + 1;

    size = 2;
    if (out->end - out->cur <= (long)size) {
	grow(out, size);
    }
    *out->cur++ = '{';
    if (0 == leaf->elements) {
	*out->cur++ = '}';
    } else {
	Leaf	first = leaf->elements->next;
	Leaf	e = first;

	size = d2 * out->indent + 2;
	do {
	    if (out->end - out->cur <= (long)size) {
		grow(out, size);
	    }
	    fill_indent(out, d2);
	    oj_dump_cstr(e->key, strlen(e->key), 0, 0, out);
	    *out->cur++ = ':';
	    dump_leaf(e, d2, out);
	    if (e->next != first) {
		*out->cur++ = ',';
	    }
	    e = e->next;
	} while (e != first);
	size = depth * out->indent + 1;
	if (out->end - out->cur <= (long)size) {
	    grow(out, size);
	}
	fill_indent(out, depth);
	*out->cur++ = '}';
    }
    *out->cur = '\0';
}

static void
dump_leaf(Leaf leaf, int depth, Out out) {
    switch (leaf->rtype) {
    case T_NIL:
	oj_dump_nil(Qnil, 0, out, false);
	break;
    case T_TRUE:
	oj_dump_true(Qtrue, 0, out, false);
	break;
    case T_FALSE:
	oj_dump_false(Qfalse, 0, out, false);
	break;
    case T_STRING:
	dump_leaf_str(leaf, out);
	break;
    case T_FIXNUM:
	dump_leaf_fixnum(leaf, out);
	break;
    case T_FLOAT:
	dump_leaf_float(leaf, out);
	break;
    case T_ARRAY:
	dump_leaf_array(leaf, depth, out);
	break;
    case T_HASH:
	dump_leaf_hash(leaf, depth, out);
	break;
    default:
	rb_raise(rb_eTypeError, "Unexpected type %02x.\n", leaf->rtype);
	break;
    }
}

void
oj_dump_leaf_to_json(Leaf leaf, Options copts, Out out) {
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
    dump_leaf(leaf, 0, out);
}

void
oj_write_leaf_to_file(Leaf leaf, const char *path, Options copts) {
    char	buf[4096];
    struct _Out out;
    size_t	size;
    FILE	*f;

    out.buf = buf;
    out.end = buf + sizeof(buf) - BUFFER_EXTRA;
    out.allocated = false;
    out.omit_nil = copts->dump_opts.omit_nil;
    oj_dump_leaf_to_json(leaf, copts, &out);
    size = out.cur - out.buf;
    if (0 == (f = fopen(path, "w"))) {
	rb_raise(rb_eIOError, "%s\n", strerror(errno));
    }
    if (size != fwrite(out.buf, 1, size, f)) {
	int	err = ferror(f);

	rb_raise(rb_eIOError, "Write failed. [%d:%s]\n", err, strerror(err));
    }
    if (out.allocated) {
	xfree(out.buf);
    }
    fclose(f);
}

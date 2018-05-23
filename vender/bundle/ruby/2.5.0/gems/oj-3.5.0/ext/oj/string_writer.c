/* strwriter.c
 * Copyright (c) 2012, 2017, Peter Ohler
 * All rights reserved.
 */

#include "dump.h"
#include "encode.h"

extern VALUE	Oj;

static void
key_check(StrWriter sw, const char *key) {
    DumpType	type = sw->types[sw->depth];

    if (0 == key && (ObjectNew == type || ObjectType == type)) {
	rb_raise(rb_eStandardError, "Can not push onto an Object without a key.");
    }
}

static void
push_type(StrWriter sw, DumpType type) {
    if (sw->types_end <= sw->types + sw->depth + 1) {
	size_t	size = (sw->types_end - sw->types) * 2;

	REALLOC_N(sw->types, char, size);
	sw->types_end = sw->types + size;
    }
    sw->depth++;
    sw->types[sw->depth] = type;
}

static void
maybe_comma(StrWriter sw) {
    switch (sw->types[sw->depth]) {
    case ObjectNew:
	sw->types[sw->depth] = ObjectType;
	break;
    case ArrayNew:
	sw->types[sw->depth] = ArrayType;
	break;
    case ObjectType:
    case ArrayType:
	// Always have a few characters available in the out.buf.
	*sw->out.cur++ = ',';
	break;
    }
}

// Used by stream writer also.
void
oj_str_writer_init(StrWriter sw, int buf_size) {
    sw->opts = oj_default_options;
    sw->depth = 0;
    sw->types = ALLOC_N(char, 256);
    sw->types_end = sw->types + 256;
    *sw->types = '\0';
    sw->keyWritten = 0;

    if (0 == buf_size) {
	buf_size = 4096;
    } else if (buf_size < 1024) {
	buf_size = 1024;
    }
    sw->out.buf = ALLOC_N(char, buf_size);
    sw->out.end = sw->out.buf + buf_size - 10;
    sw->out.allocated = true;
    sw->out.cur = sw->out.buf;
    *sw->out.cur = '\0';
    sw->out.circ_cnt = 0;
    sw->out.hash_cnt = 0;
    sw->out.opts = &sw->opts;
    sw->out.indent = sw->opts.indent;
    sw->out.depth = 0;
    sw->out.argc = 0;
    sw->out.argv = NULL;
    sw->out.caller = 0;
    sw->out.ropts = NULL;
}

void
oj_str_writer_push_key(StrWriter sw, const char *key) {
    DumpType	type = sw->types[sw->depth];
    long	size;

    if (sw->keyWritten) {
	rb_raise(rb_eStandardError, "Can not push more than one key before pushing a non-key.");
    }
    if (ObjectNew != type && ObjectType != type) {
	rb_raise(rb_eStandardError, "Can only push a key onto an Object.");
    }
    size = sw->depth * sw->out.indent + 3;
    assure_size(&sw->out, size);
    maybe_comma(sw);
    if (0 < sw->depth) {
	fill_indent(&sw->out, sw->depth);
    }
    oj_dump_cstr(key, strlen(key), 0, 0, &sw->out);
    *sw->out.cur++ = ':';
    sw->keyWritten = 1;
}

void
oj_str_writer_push_object(StrWriter sw, const char *key) {
    if (sw->keyWritten) {
	sw->keyWritten = 0;
	assure_size(&sw->out, 1);
    } else {
	long	size;

	key_check(sw, key);
	size = sw->depth * sw->out.indent + 3;
	assure_size(&sw->out, size);
	maybe_comma(sw);
	if (0 < sw->depth) {
	    fill_indent(&sw->out, sw->depth);
	}
	if (0 != key) {
	    oj_dump_cstr(key, strlen(key), 0, 0, &sw->out);
	    *sw->out.cur++ = ':';
	}
    }
    *sw->out.cur++ = '{';
    push_type(sw, ObjectNew);
}

void
oj_str_writer_push_array(StrWriter sw, const char *key) {
    if (sw->keyWritten) {
	sw->keyWritten = 0;
	assure_size(&sw->out, 1);
    } else {
	long	size;

	key_check(sw, key);
	size = sw->depth * sw->out.indent + 3;
	assure_size(&sw->out, size);
	maybe_comma(sw);
	if (0 < sw->depth) {
	    fill_indent(&sw->out, sw->depth);
	}
	if (0 != key) {
	    oj_dump_cstr(key, strlen(key), 0, 0, &sw->out);
	    *sw->out.cur++ = ':';
	}
    }
    *sw->out.cur++ = '[';
    push_type(sw, ArrayNew);
}

void
oj_str_writer_push_value(StrWriter sw, VALUE val, const char *key) {
    Out	out = &sw->out;
    
    if (sw->keyWritten) {
	sw->keyWritten = 0;
    } else {
	long	size;

	key_check(sw, key);
	size = sw->depth * out->indent + 3;
	assure_size(out, size);
	maybe_comma(sw);
	if (0 < sw->depth) {
	    fill_indent(&sw->out, sw->depth);
	}
	if (0 != key) {
	    oj_dump_cstr(key, strlen(key), 0, 0, out);
	    *out->cur++ = ':';
	}
    }
    switch (out->opts->mode) {
    case StrictMode:	oj_dump_strict_val(val, sw->depth, out);				break;
    case NullMode:	oj_dump_null_val(val, sw->depth, out);					break;
    case ObjectMode:	oj_dump_obj_val(val, sw->depth, out);					break;
    case CompatMode:	oj_dump_compat_val(val, sw->depth, out, Yes == out->opts->to_json);	break;
    case RailsMode:	oj_dump_rails_val(val, sw->depth, out);					break;
    case CustomMode:	oj_dump_custom_val(val, sw->depth, out, true);				break;
    default:		oj_dump_custom_val(val, sw->depth, out, true);				break;
    }
}

void
oj_str_writer_push_json(StrWriter sw, const char *json, const char *key) {
    if (sw->keyWritten) {
	sw->keyWritten = 0;
    } else {
	long	size;

	key_check(sw, key);
	size = sw->depth * sw->out.indent + 3;
	assure_size(&sw->out, size);
	maybe_comma(sw);
	if (0 < sw->depth) {
	    fill_indent(&sw->out, sw->depth);
	}
	if (0 != key) {
	    oj_dump_cstr(key, strlen(key), 0, 0, &sw->out);
	    *sw->out.cur++ = ':';
	}
    }
    oj_dump_raw(json, strlen(json), &sw->out);
}

void
oj_str_writer_pop(StrWriter sw) {
    long	size;
    DumpType	type = sw->types[sw->depth];

    if (sw->keyWritten) {
	sw->keyWritten = 0;
	rb_raise(rb_eStandardError, "Can not pop after writing a key but no value.");
    }
    sw->depth--;
    if (0 > sw->depth) {
	rb_raise(rb_eStandardError, "Can not pop with no open array or object.");
    }
    size = sw->depth * sw->out.indent + 2;
    assure_size(&sw->out, size);
    fill_indent(&sw->out, sw->depth);
    switch (type) {
    case ObjectNew:
    case ObjectType:
	*sw->out.cur++ = '}';
	break;
    case ArrayNew:
    case ArrayType:
	*sw->out.cur++ = ']';
	break;
    }
    if (0 == sw->depth && 0 <= sw->out.indent) {
	*sw->out.cur++ = '\n';
    }
}

void
oj_str_writer_pop_all(StrWriter sw) {
    while (0 < sw->depth) {
	oj_str_writer_pop(sw);
    }
}

static void
str_writer_free(void *ptr) {
    StrWriter	sw;

    if (0 == ptr) {
	return;
    }
    sw = (StrWriter)ptr;
    xfree(sw->out.buf);
    xfree(sw->types);
    xfree(ptr);
}

/* Document-method: new
 * call-seq: new(io, options)
 *
 * Creates a new StringWriter. Options are supported according the the
 * specified mode or the mode in the default options. Note that if mimic_JSON
 * or Oj.optimize_rails has not been called then the behavior of the modes may
 * not be the same as if they were.
 *
 * In addition to the regular dump options for the various modes a
 * _:buffer_size_ option is available. It should be set to a positive
 * integer. It is considered a hint of how large the initial internal buffer
 * should be.
 *
 * - *io* [_IO_] stream to write to
 * - *options* [_Hash_] formating options
 */
static VALUE
str_writer_new(int argc, VALUE *argv, VALUE self) {
    StrWriter	sw = ALLOC(struct _StrWriter);
    
    oj_str_writer_init(sw, 0);
    if (1 == argc) {
	oj_parse_options(argv[0], &sw->opts);
    }
    sw->out.argc = argc - 1;
    sw->out.argv = argv + 1;
    sw->out.indent = sw->opts.indent;

    return Data_Wrap_Struct(oj_string_writer_class, 0, str_writer_free, sw);
}

/* Document-method: push_key
 * call-seq: push_key(key)
 *
 * Pushes a key onto the JSON document. The key will be used for the next push
 * if currently in a JSON object and ignored otherwise. If a key is provided on
 * the next push then that new key will be ignored.
 * - *key* [_String_] the key pending for the next push
 */
static VALUE
str_writer_push_key(VALUE self, VALUE key) {
    StrWriter	sw = (StrWriter)DATA_PTR(self);

    rb_check_type(key, T_STRING);
    oj_str_writer_push_key(sw, StringValuePtr(key));

    return Qnil;
}

/* Document-method: push_object
 * call-seq: push_object(key=nil)
 *
 * Pushes an object onto the JSON document. Future pushes will be to this object
 * until a pop() is called.
 * - *key* [_String_] the key if adding to an object in the JSON document
 */
static VALUE
str_writer_push_object(int argc, VALUE *argv, VALUE self) {
    StrWriter	sw = (StrWriter)DATA_PTR(self);

    switch (argc) {
    case 0:
	oj_str_writer_push_object(sw, 0);
	break;
    case 1:
	if (Qnil == argv[0]) {
	    oj_str_writer_push_object(sw, 0);
	} else {
	    rb_check_type(argv[0], T_STRING);
	    oj_str_writer_push_object(sw, StringValuePtr(argv[0]));
	}
	break;
    default:
	rb_raise(rb_eArgError, "Wrong number of argument to 'push_object'.");
	break;
    }
    if (rb_block_given_p()) {
	rb_yield(Qnil);
	oj_str_writer_pop(sw);
    }
    return Qnil;
}

/* Document-method: push_array
 * call-seq: push_array(key=nil)
 *
 * Pushes an array onto the JSON document. Future pushes will be to this object
 * until a pop() is called.
 * - *key* [_String_] the key if adding to an object in the JSON document
 */
static VALUE
str_writer_push_array(int argc, VALUE *argv, VALUE self) {
    StrWriter	sw = (StrWriter)DATA_PTR(self);

    switch (argc) {
    case 0:
	oj_str_writer_push_array(sw, 0);
	break;
    case 1:
	if (Qnil == argv[0]) {
	    oj_str_writer_push_array(sw, 0);
	} else {
	    rb_check_type(argv[0], T_STRING);
	    oj_str_writer_push_array(sw, StringValuePtr(argv[0]));
	}
	break;
    default:
	rb_raise(rb_eArgError, "Wrong number of argument to 'push_object'.");
	break;
    }
    if (rb_block_given_p()) {
	rb_yield(Qnil);
	oj_str_writer_pop(sw);
    }
    return Qnil;
}

/* Document-method: push_value
 * call-seq: push_value(value, key=nil)
 *
 * Pushes a value onto the JSON document.
 * - *value* [_Object_] value to add to the JSON document
 * - *key* [_String_] the key if adding to an object in the JSON document
 */
static VALUE
str_writer_push_value(int argc, VALUE *argv, VALUE self) {
    switch (argc) {
    case 1:
	oj_str_writer_push_value((StrWriter)DATA_PTR(self), *argv, 0);
	break;
    case 2:
	if (Qnil == argv[1]) {
	    oj_str_writer_push_value((StrWriter)DATA_PTR(self), *argv, 0);
	} else {
	    rb_check_type(argv[1], T_STRING);
	    oj_str_writer_push_value((StrWriter)DATA_PTR(self), *argv, StringValuePtr(argv[1]));
	}
	break;
    default:
	rb_raise(rb_eArgError, "Wrong number of argument to 'push_value'.");
	break;
    }
    return Qnil;
}

/* Document-method: push_json
 * call-seq: push_json(value, key=nil)
 *
 * Pushes a string onto the JSON document. The String must be a valid JSON
 * encoded string. No additional checking is done to verify the validity of the
 * string.
 * - *value* [_Object_] value to add to the JSON document
 * - *key* [_String_] the key if adding to an object in the JSON document
 */
static VALUE
str_writer_push_json(int argc, VALUE *argv, VALUE self) {
    rb_check_type(argv[0], T_STRING);
    switch (argc) {
    case 1:
	oj_str_writer_push_json((StrWriter)DATA_PTR(self), StringValuePtr(*argv), 0);
	break;
    case 2:
	if (Qnil == argv[1]) {
	    oj_str_writer_push_json((StrWriter)DATA_PTR(self), StringValuePtr(*argv), 0);
	} else {
	    rb_check_type(argv[1], T_STRING);
	    oj_str_writer_push_json((StrWriter)DATA_PTR(self), StringValuePtr(*argv), StringValuePtr(argv[1]));
	}
	break;
    default:
	rb_raise(rb_eArgError, "Wrong number of argument to 'push_json'.");
	break;
    }
    return Qnil;
}
/* Document-method: pop
 * call-seq: pop()
 *
 * Pops up a level in the JSON document closing the array or object that is
 * currently open.
 */
static VALUE
str_writer_pop(VALUE self) {
    oj_str_writer_pop((StrWriter)DATA_PTR(self));
    return Qnil;
}

/* Document-method: pop_all
 * call-seq: pop_all()
 *
 * Pops all level in the JSON document closing all the array or object that is
 * currently open.
 */
static VALUE
str_writer_pop_all(VALUE self) {
    oj_str_writer_pop_all((StrWriter)DATA_PTR(self));

    return Qnil;
}

/* Document-method: reset
 * call-seq: reset()
 *
 * Reset the writer back to the empty state.
 */
static VALUE
str_writer_reset(VALUE self) {
    StrWriter	sw = (StrWriter)DATA_PTR(self);

    sw->depth = 0;
    *sw->types = '\0';
    sw->keyWritten = 0;
    sw->out.cur = sw->out.buf;
    *sw->out.cur = '\0';

    return Qnil;
}

/* Document-method: to_s
 * call-seq: to_s()
 *
 * Returns the JSON document string in what ever state the construction is at.
 *
 * *return* [_String_]
 */
static VALUE
str_writer_to_s(VALUE self) {
    StrWriter	sw = (StrWriter)DATA_PTR(self);
    VALUE	rstr = rb_str_new(sw->out.buf, sw->out.cur - sw->out.buf);

    return oj_encode(rstr);
}

/* Document-class: Oj::StringWriter
 * 
 * Supports building a JSON document one element at a time. Build the document
 * by pushing values into the document. Pushing an array or an object will
 * create that element in the JSON document and subsequent pushes will add the
 * elements to that array or object until a pop() is called. When complete
 * calling to_s() will return the JSON document. Note tha calling to_s() before
 * construction is complete will return the document in it's current state.
 */
void
oj_string_writer_init() {
    oj_string_writer_class = rb_define_class_under(Oj, "StringWriter", rb_cObject);
    rb_define_module_function(oj_string_writer_class, "new", str_writer_new, -1);
    rb_define_method(oj_string_writer_class, "push_key", str_writer_push_key, 1);
    rb_define_method(oj_string_writer_class, "push_object", str_writer_push_object, -1);
    rb_define_method(oj_string_writer_class, "push_array", str_writer_push_array, -1);
    rb_define_method(oj_string_writer_class, "push_value", str_writer_push_value, -1);
    rb_define_method(oj_string_writer_class, "push_json", str_writer_push_json, -1);
    rb_define_method(oj_string_writer_class, "pop", str_writer_pop, 0);
    rb_define_method(oj_string_writer_class, "pop_all", str_writer_pop_all, 0);
    rb_define_method(oj_string_writer_class, "reset", str_writer_reset, 0);
    rb_define_method(oj_string_writer_class, "to_s", str_writer_to_s, 0);
}

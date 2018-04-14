/* stream_writer.c
 * Copyright (c) 2012, 2017, Peter Ohler
 * All rights reserved.
 */

#include <errno.h>

#include <ruby.h>

#include "oj.h"

extern VALUE	Oj;

static void
stream_writer_free(void *ptr) {
    StreamWriter	sw;

    if (0 == ptr) {
	return;
    }
    sw = (StreamWriter)ptr;
    xfree(sw->sw.out.buf);
    xfree(sw->sw.types);
    xfree(ptr);
}

static void
stream_writer_reset_buf(StreamWriter sw) {
    sw->sw.out.cur = sw->sw.out.buf;
    *sw->sw.out.cur = '\0';
}

static void
stream_writer_write(StreamWriter sw) {
    ssize_t	size = sw->sw.out.cur - sw->sw.out.buf;

    switch (sw->type) {
    case STRING_IO:
	rb_funcall(sw->stream, oj_write_id, 1, rb_str_new(sw->sw.out.buf, size));
	break;
    case STREAM_IO:
	rb_funcall(sw->stream, oj_write_id, 1, rb_str_new(sw->sw.out.buf, size));
	break;
    case FILE_IO:
	if (size != write(sw->fd, sw->sw.out.buf, size)) {
	    rb_raise(rb_eIOError, "Write failed. [_%d_:%s]\n", errno, strerror(errno));
	}
	break;
    default:
	rb_raise(rb_eArgError, "expected an IO Object.");
    }
    stream_writer_reset_buf(sw);
}

static VALUE	buffer_size_sym = Qundef;

/* Document-method: new
 * call-seq: new(io, options)
 *
 * Creates a new StreamWriter. Options are supported according the the
 * specified mode or the mode in the default options. Note that if mimic_JSON
 * or Oj.optimize_rails has not been called then the behavior of the modes may
 * not be the same as if they were.
 *
 * In addition to the regular dump options for the various modes a
 * _:buffer_size_ option is available. It should be set to a positive
 * integer. It is considered a hint of how large the initial internal buffer
 * should be and also a hint on when to flush.
 *
 * - *io* [_IO_] stream to write to
 * - *options* [_Hash_] formating options
 */
static VALUE
stream_writer_new(int argc, VALUE *argv, VALUE self) {
    StreamWriterType	type = STREAM_IO;
    int			fd = 0;
    VALUE		stream = argv[0];
    VALUE		clas = rb_obj_class(stream);
    StreamWriter	sw;
#if !IS_WINDOWS
    VALUE		s;
#endif
    
    if (oj_stringio_class == clas) {
	type = STRING_IO;
#if !IS_WINDOWS
    } else if (rb_respond_to(stream, oj_fileno_id) &&
	       Qnil != (s = rb_funcall(stream, oj_fileno_id, 0)) &&
	       0 != (fd = FIX2INT(s))) {
	type = FILE_IO;
#endif
    } else if (rb_respond_to(stream, oj_write_id)) {
	type = STREAM_IO;
    } else {
	rb_raise(rb_eArgError, "expected an IO Object.");
    }
    sw = ALLOC(struct _StreamWriter);
    if (2 == argc && T_HASH == rb_type(argv[1])) {
	volatile VALUE	v;
	int		buf_size = 0;

	if (Qundef == buffer_size_sym) {
	    buffer_size_sym = ID2SYM(rb_intern("buffer_size"));	rb_gc_register_address(&buffer_size_sym);
	    
	}
	if (Qnil != (v = rb_hash_lookup(argv[1], buffer_size_sym))) {
#ifdef RUBY_INTEGER_UNIFICATION
	    if (rb_cInteger != rb_obj_class(v)) {
		rb_raise(rb_eArgError, ":buffer size must be a Integer.");
	    }
#else
	    if (T_FIXNUM != rb_type(v)) {
		rb_raise(rb_eArgError, ":buffer size must be a Integer.");
	    }
#endif
	    buf_size = FIX2INT(v);
	}
	oj_str_writer_init(&sw->sw, buf_size);
	oj_parse_options(argv[1], &sw->sw.opts);
	sw->flush_limit = buf_size;
    } else {
	oj_str_writer_init(&sw->sw, 4096);
	sw->flush_limit = 0;
    }
    sw->sw.out.indent = sw->sw.opts.indent;
    sw->stream = stream;
    sw->type = type;
    sw->fd = fd;

    return Data_Wrap_Struct(oj_stream_writer_class, 0, stream_writer_free, sw);
}

/* Document-method: push_key
 * call-seq: push_key(key)
 *
 * Pushes a key onto the JSON document. The key will be used for the next push
 * if currently in a JSON object and ignored otherwise. If a key is provided on
 * the next push then that new key will be ignored.
 *
 * - *key* [_String_] the key pending for the next push
 */
static VALUE
stream_writer_push_key(VALUE self, VALUE key) {
    StreamWriter	sw = (StreamWriter)DATA_PTR(self);

    rb_check_type(key, T_STRING);
    oj_str_writer_push_key(&sw->sw, StringValuePtr(key));
    if (sw->flush_limit < sw->sw.out.cur - sw->sw.out.buf) {
	stream_writer_write(sw);
    }
    return Qnil;
}

/* Document-method: push_object
 * call-seq: push_object(key=nil)
 *
 * Pushes an object onto the JSON document. Future pushes will be to this object
 * until a pop() is called.
 *
 * - *key* [_String_] the key if adding to an object in the JSON document
 */
static VALUE
stream_writer_push_object(int argc, VALUE *argv, VALUE self) {
    StreamWriter	sw = (StreamWriter)DATA_PTR(self);

    switch (argc) {
    case 0:
	oj_str_writer_push_object(&sw->sw, 0);
	break;
    case 1:
	if (Qnil == argv[0]) {
	    oj_str_writer_push_object(&sw->sw, 0);
	} else {
	    rb_check_type(argv[0], T_STRING);
	    oj_str_writer_push_object(&sw->sw, StringValuePtr(argv[0]));
	}
	break;
    default:
	rb_raise(rb_eArgError, "Wrong number of argument to 'push_object'.");
	break;
    }
    if (sw->flush_limit < sw->sw.out.cur - sw->sw.out.buf) {
	stream_writer_write(sw);
    }
    return Qnil;
}

/* Document-method: push_array
 * call-seq: push_array(key=nil)
 *
 * Pushes an array onto the JSON document. Future pushes will be to this object
 * until a pop() is called.
 *
 * - *key* [_String_] the key if adding to an object in the JSON document
 */
static VALUE
stream_writer_push_array(int argc, VALUE *argv, VALUE self) {
    StreamWriter	sw = (StreamWriter)DATA_PTR(self);

    switch (argc) {
    case 0:
	oj_str_writer_push_array(&sw->sw, 0);
	break;
    case 1:
	if (Qnil == argv[0]) {
	    oj_str_writer_push_array(&sw->sw, 0);
	} else {
	    rb_check_type(argv[0], T_STRING);
	    oj_str_writer_push_array(&sw->sw, StringValuePtr(argv[0]));
	}
	break;
    default:
	rb_raise(rb_eArgError, "Wrong number of argument to 'push_object'.");
	break;
    }
    if (sw->flush_limit < sw->sw.out.cur - sw->sw.out.buf) {
	stream_writer_write(sw);
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
stream_writer_push_value(int argc, VALUE *argv, VALUE self) {
    StreamWriter	sw = (StreamWriter)DATA_PTR(self);

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
    if (sw->flush_limit < sw->sw.out.cur - sw->sw.out.buf) {
	stream_writer_write(sw);
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
stream_writer_push_json(int argc, VALUE *argv, VALUE self) {
    StreamWriter	sw = (StreamWriter)DATA_PTR(self);

    rb_check_type(argv[0], T_STRING);
    switch (argc) {
    case 1:
	oj_str_writer_push_json((StrWriter)DATA_PTR(self), StringValuePtr(*argv), 0);
	break;
    case 2:
	if (Qnil == argv[0]) {
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
    if (sw->flush_limit < sw->sw.out.cur - sw->sw.out.buf) {
	stream_writer_write(sw);
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
stream_writer_pop(VALUE self) {
    StreamWriter	sw = (StreamWriter)DATA_PTR(self);

    oj_str_writer_pop(&sw->sw);
    if (sw->flush_limit < sw->sw.out.cur - sw->sw.out.buf) {
	stream_writer_write(sw);
    }
    return Qnil;
}

/* Document-method: pop_all
 * call-seq: pop_all()
 *
 * Pops all level in the JSON document closing all the array or object that is
 * currently open.
 */
static VALUE
stream_writer_pop_all(VALUE self) {
    StreamWriter	sw = (StreamWriter)DATA_PTR(self);

    oj_str_writer_pop_all(&sw->sw);
    stream_writer_write(sw);

    return Qnil;
}

/* Document-method: flush
 * call-seq: flush()
 *
 * Flush any remaining characters in the buffer.
 */
static VALUE
stream_writer_flush(VALUE self) {
    stream_writer_write((StreamWriter)DATA_PTR(self));

    return Qnil;
}

/* Document-class: Oj::StreamWriter
 * 
 * Supports building a JSON document one element at a time. Build the IO stream
 * document by pushing values into the document. Pushing an array or an object
 * will create that element in the JSON document and subsequent pushes will add
 * the elements to that array or object until a pop() is called.
 */
void
oj_stream_writer_init() {
    oj_stream_writer_class = rb_define_class_under(Oj, "StreamWriter", rb_cObject);
    rb_define_module_function(oj_stream_writer_class, "new", stream_writer_new, -1);
    rb_define_method(oj_stream_writer_class, "push_key", stream_writer_push_key, 1);
    rb_define_method(oj_stream_writer_class, "push_object", stream_writer_push_object, -1);
    rb_define_method(oj_stream_writer_class, "push_array", stream_writer_push_array, -1);
    rb_define_method(oj_stream_writer_class, "push_value", stream_writer_push_value, -1);
    rb_define_method(oj_stream_writer_class, "push_json", stream_writer_push_json, -1);
    rb_define_method(oj_stream_writer_class, "pop", stream_writer_pop, 0);
    rb_define_method(oj_stream_writer_class, "pop_all", stream_writer_pop_all, 0);
    rb_define_method(oj_stream_writer_class, "flush", stream_writer_flush, 0);
}



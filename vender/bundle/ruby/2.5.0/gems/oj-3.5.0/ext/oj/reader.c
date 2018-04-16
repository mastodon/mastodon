/* reader.c
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

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
#include "oj.h"
#include "reader.h"

#define BUF_PAD	4

static VALUE		rescue_cb(VALUE rdr, VALUE err);
static VALUE		io_cb(VALUE rdr);
static VALUE		partial_io_cb(VALUE rdr);
static int		read_from_io(Reader reader);
static int		read_from_fd(Reader reader);
static int		read_from_io_partial(Reader reader);
//static int		read_from_str(Reader reader);

void
oj_reader_init(Reader reader, VALUE io, int fd, bool to_s) {
    VALUE	io_class = rb_obj_class(io);
    VALUE	stat;
    VALUE	ftype;

    reader->head = reader->base;
    *((char*)reader->head) = '\0';
    reader->end = reader->head + sizeof(reader->base) - BUF_PAD;
    reader->tail = reader->head;
    reader->read_end = reader->head;
    reader->pro = 0;
    reader->str = 0;
    reader->pos = 0;
    reader->line = 1;
    reader->col = 0;
    reader->free_head = 0;

    if (0 != fd) {
	reader->read_func = read_from_fd;
	reader->fd = fd;
    } else if (rb_cString == io_class) {
	reader->read_func = 0;
	reader->in_str = StringValuePtr(io);
	reader->head = (char*)reader->in_str;
	reader->tail = reader->head;
	reader->read_end = reader->head + RSTRING_LEN(io);
    } else if (oj_stringio_class == io_class) {
	VALUE	s = rb_funcall2(io, oj_string_id, 0, 0);

	reader->read_func = 0;
	reader->in_str = StringValuePtr(s);
	reader->head = (char*)reader->in_str;
	reader->tail = reader->head;
	reader->read_end = reader->head + RSTRING_LEN(s);
    } else if (rb_cFile == io_class &&
	       Qnil != (stat = rb_funcall(io, oj_stat_id, 0)) &&
	       Qnil != (ftype = rb_funcall(stat, oj_ftype_id, 0)) &&
	       0 == strcmp("file", StringValuePtr(ftype)) &&
	       0 == FIX2INT(rb_funcall(io, oj_pos_id, 0))) {
	reader->read_func = read_from_fd;
	reader->fd = FIX2INT(rb_funcall(io, oj_fileno_id, 0));
    } else if (rb_respond_to(io, oj_readpartial_id)) {
	reader->read_func = read_from_io_partial;
	reader->io = io;
    } else if (rb_respond_to(io, oj_read_id)) {
	reader->read_func = read_from_io;
	reader->io = io;
    } else if (to_s) {
	volatile VALUE	rstr = rb_funcall(io, oj_to_s_id, 0);
	
	reader->read_func = 0;
	reader->in_str = StringValuePtr(rstr);
	reader->head = (char*)reader->in_str;
	reader->tail = reader->head;
	reader->read_end = reader->head + RSTRING_LEN(rstr);
    } else {	
	rb_raise(rb_eArgError, "parser io argument must be a String or respond to readpartial() or read().\n");
    }
}

int
oj_reader_read(Reader reader) {
    int		err;
    size_t	shift = 0;

    if (0 == reader->read_func) {
	return -1;
    }
    // if there is not much room to read into, shift or realloc a larger buffer.
    if (reader->head < reader->tail && 4096 > reader->end - reader->tail) {
	if (0 == reader->pro) {
	    shift = reader->tail - reader->head;
	} else {
	    shift = reader->pro - reader->head - 1; // leave one character so we can backup one
	}
	if (0 >= shift) { /* no space left so allocate more */
	    const char	*old = reader->head;
	    size_t	size = reader->end - reader->head + BUF_PAD;
	
	    if (reader->head == reader->base) {
		reader->head = ALLOC_N(char, size * 2);
		memcpy((char*)reader->head, old, size);
	    } else {
		REALLOC_N(reader->head, char, size * 2);
	    }
	    reader->free_head = 1;
	    reader->end = reader->head + size * 2 - BUF_PAD;
	    reader->tail = reader->head + (reader->tail - old);
	    reader->read_end = reader->head + (reader->read_end - old);
	    if (0 != reader->pro) {
		reader->pro = reader->head + (reader->pro - old);
	    }
	    if (0 != reader->str) {
		reader->str = reader->head + (reader->str - old);
	    }
	} else {
	    memmove((char*)reader->head, reader->head + shift, reader->read_end - (reader->head + shift));
	    reader->tail -= shift;
	    reader->read_end -= shift;
	    if (0 != reader->pro) {
		reader->pro -= shift;
	    }
	    if (0 != reader->str) {
		reader->str -= shift;
	    }
	}
    }
    err = reader->read_func(reader);
    *(char*)reader->read_end = '\0';

    return err;
}

static VALUE
rescue_cb(VALUE rbuf, VALUE err) {
    VALUE	clas = rb_obj_class(err);

    if (rb_eTypeError != clas && rb_eEOFError != clas) {
	Reader	reader = (Reader)rbuf;

	rb_raise(clas, "at line %d, column %d\n", reader->line, reader->col);
    }
    return Qfalse;
}

static VALUE
partial_io_cb(VALUE rbuf) {
    Reader	reader = (Reader)rbuf;
    VALUE	args[1];
    VALUE	rstr;
    char	*str;
    size_t	cnt;

    args[0] = ULONG2NUM(reader->end - reader->tail);
    rstr = rb_funcall2(reader->io, oj_readpartial_id, 1, args);
    if (Qnil == rstr) {
	return Qfalse;
    }
    str = StringValuePtr(rstr);
    cnt = RSTRING_LEN(rstr);
    //printf("*** partial read %lu bytes, str: '%s'\n", cnt, str);
    strcpy(reader->tail, str);
    reader->read_end = reader->tail + cnt;

    return Qtrue;
}

static VALUE
io_cb(VALUE rbuf) {
    Reader	reader = (Reader)rbuf;
    VALUE	args[1];
    VALUE	rstr;
    char	*str;
    size_t	cnt;

    args[0] = ULONG2NUM(reader->end - reader->tail);
    rstr = rb_funcall2(reader->io, oj_read_id, 1, args);
    if (Qnil == rstr) {
	return Qfalse;
    }
    str = StringValuePtr(rstr);
    cnt = RSTRING_LEN(rstr);
    //printf("*** read %lu bytes, str: '%s'\n", cnt, str);
    strcpy(reader->tail, str);
    reader->read_end = reader->tail + cnt;

    return Qtrue;
}

static int
read_from_io_partial(Reader reader) {
    return (Qfalse == rb_rescue(partial_io_cb, (VALUE)reader, rescue_cb, (VALUE)reader));
}

static int
read_from_io(Reader reader) {
    return (Qfalse == rb_rescue(io_cb, (VALUE)reader, rescue_cb, (VALUE)reader));
}

static int
read_from_fd(Reader reader) {
    ssize_t	cnt;
    size_t	max = reader->end - reader->tail;

    cnt = read(reader->fd, reader->tail, max);
    if (cnt <= 0) {
	return -1;
    } else if (0 != cnt) {
	reader->read_end = reader->tail + cnt;
    }
    return 0;
}

// This is only called when the end of the string is reached so just return -1.
/*
static int
read_from_str(Reader reader) {
    return -1;
}
*/

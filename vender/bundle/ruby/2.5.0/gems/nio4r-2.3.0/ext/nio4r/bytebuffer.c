#include "nio4r.h"

static VALUE mNIO = Qnil;
static VALUE cNIO_ByteBuffer = Qnil;
static VALUE cNIO_ByteBuffer_OverflowError = Qnil;
static VALUE cNIO_ByteBuffer_UnderflowError = Qnil;
static VALUE cNIO_ByteBuffer_MarkUnsetError = Qnil;

/* Allocator/deallocator */
static VALUE NIO_ByteBuffer_allocate(VALUE klass);
static void NIO_ByteBuffer_gc_mark(struct NIO_ByteBuffer *byteBuffer);
static void NIO_ByteBuffer_free(struct NIO_ByteBuffer *byteBuffer);

/* Methods */
static VALUE NIO_ByteBuffer_initialize(VALUE self, VALUE capacity);
static VALUE NIO_ByteBuffer_clear(VALUE self);
static VALUE NIO_ByteBuffer_get_position(VALUE self);
static VALUE NIO_ByteBuffer_set_position(VALUE self, VALUE new_position);
static VALUE NIO_ByteBuffer_get_limit(VALUE self);
static VALUE NIO_ByteBuffer_set_limit(VALUE self, VALUE new_limit);
static VALUE NIO_ByteBuffer_capacity(VALUE self);
static VALUE NIO_ByteBuffer_remaining(VALUE self);
static VALUE NIO_ByteBuffer_full(VALUE self);
static VALUE NIO_ByteBuffer_get(int argc, VALUE *argv, VALUE self);
static VALUE NIO_ByteBuffer_fetch(VALUE self, VALUE index);
static VALUE NIO_ByteBuffer_put(VALUE self, VALUE string);
static VALUE NIO_ByteBuffer_write_to(VALUE self, VALUE file);
static VALUE NIO_ByteBuffer_read_from(VALUE self, VALUE file);
static VALUE NIO_ByteBuffer_flip(VALUE self);
static VALUE NIO_ByteBuffer_rewind(VALUE self);
static VALUE NIO_ByteBuffer_mark(VALUE self);
static VALUE NIO_ByteBuffer_reset(VALUE self);
static VALUE NIO_ByteBuffer_compact(VALUE self);
static VALUE NIO_ByteBuffer_each(VALUE self);
static VALUE NIO_ByteBuffer_inspect(VALUE self);

#define MARK_UNSET -1

void Init_NIO_ByteBuffer()
{
    mNIO = rb_define_module("NIO");
    cNIO_ByteBuffer = rb_define_class_under(mNIO, "ByteBuffer", rb_cObject);
    rb_define_alloc_func(cNIO_ByteBuffer, NIO_ByteBuffer_allocate);

    cNIO_ByteBuffer_OverflowError  = rb_define_class_under(cNIO_ByteBuffer, "OverflowError", rb_eIOError);
    cNIO_ByteBuffer_UnderflowError = rb_define_class_under(cNIO_ByteBuffer, "UnderflowError", rb_eIOError);
    cNIO_ByteBuffer_MarkUnsetError = rb_define_class_under(cNIO_ByteBuffer, "MarkUnsetError", rb_eIOError);

    rb_include_module(cNIO_ByteBuffer, rb_mEnumerable);

    rb_define_method(cNIO_ByteBuffer, "initialize", NIO_ByteBuffer_initialize, 1);
    rb_define_method(cNIO_ByteBuffer, "clear", NIO_ByteBuffer_clear, 0);
    rb_define_method(cNIO_ByteBuffer, "position", NIO_ByteBuffer_get_position, 0);
    rb_define_method(cNIO_ByteBuffer, "position=", NIO_ByteBuffer_set_position, 1);
    rb_define_method(cNIO_ByteBuffer, "limit", NIO_ByteBuffer_get_limit, 0);
    rb_define_method(cNIO_ByteBuffer, "limit=", NIO_ByteBuffer_set_limit, 1);
    rb_define_method(cNIO_ByteBuffer, "capacity", NIO_ByteBuffer_capacity, 0);
    rb_define_method(cNIO_ByteBuffer, "size", NIO_ByteBuffer_capacity, 0);
    rb_define_method(cNIO_ByteBuffer, "remaining", NIO_ByteBuffer_remaining, 0);
    rb_define_method(cNIO_ByteBuffer, "full?", NIO_ByteBuffer_full, 0);
    rb_define_method(cNIO_ByteBuffer, "get", NIO_ByteBuffer_get, -1);
    rb_define_method(cNIO_ByteBuffer, "[]", NIO_ByteBuffer_fetch, 1);
    rb_define_method(cNIO_ByteBuffer, "<<", NIO_ByteBuffer_put, 1);
    rb_define_method(cNIO_ByteBuffer, "read_from", NIO_ByteBuffer_read_from, 1);
    rb_define_method(cNIO_ByteBuffer, "write_to", NIO_ByteBuffer_write_to, 1);
    rb_define_method(cNIO_ByteBuffer, "flip", NIO_ByteBuffer_flip, 0);
    rb_define_method(cNIO_ByteBuffer, "rewind", NIO_ByteBuffer_rewind, 0);
    rb_define_method(cNIO_ByteBuffer, "mark", NIO_ByteBuffer_mark, 0);
    rb_define_method(cNIO_ByteBuffer, "reset", NIO_ByteBuffer_reset, 0);
    rb_define_method(cNIO_ByteBuffer, "compact", NIO_ByteBuffer_compact, 0);
    rb_define_method(cNIO_ByteBuffer, "each", NIO_ByteBuffer_each, 0);
    rb_define_method(cNIO_ByteBuffer, "inspect", NIO_ByteBuffer_inspect, 0);
}

static VALUE NIO_ByteBuffer_allocate(VALUE klass)
{
    struct NIO_ByteBuffer *bytebuffer = (struct NIO_ByteBuffer *)xmalloc(sizeof(struct NIO_ByteBuffer));
    bytebuffer->buffer = NULL;
    return Data_Wrap_Struct(klass, NIO_ByteBuffer_gc_mark, NIO_ByteBuffer_free, bytebuffer);
}

static void NIO_ByteBuffer_gc_mark(struct NIO_ByteBuffer *buffer)
{
}

static void NIO_ByteBuffer_free(struct NIO_ByteBuffer *buffer)
{
    if(buffer->buffer)
      xfree(buffer->buffer);
    xfree(buffer);
}

static VALUE NIO_ByteBuffer_initialize(VALUE self, VALUE capacity)
{
    struct NIO_ByteBuffer *buffer;
    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);

    buffer->capacity = NUM2INT(capacity);
    buffer->buffer = xmalloc(buffer->capacity);

    NIO_ByteBuffer_clear(self);

    return self;
}

static VALUE NIO_ByteBuffer_clear(VALUE self)
{
    struct NIO_ByteBuffer *buffer;
    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);

    memset(buffer->buffer, 0, buffer->capacity);

    buffer->position = 0;
    buffer->limit = buffer->capacity;
    buffer->mark = MARK_UNSET;

    return self;
}

static VALUE NIO_ByteBuffer_get_position(VALUE self)
{
    struct NIO_ByteBuffer *buffer;
    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);

    return INT2NUM(buffer->position);
}

static VALUE NIO_ByteBuffer_set_position(VALUE self, VALUE new_position)
{
    int pos;
    struct NIO_ByteBuffer *buffer;
    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);

    pos = NUM2INT(new_position);

    if(pos < 0) {
        rb_raise(rb_eArgError, "negative position given");
    }

    if(pos > buffer->limit) {
        rb_raise(rb_eArgError, "specified position exceeds limit");
    }

    buffer->position = pos;

    if(buffer->mark > buffer->position) {
        buffer->mark = MARK_UNSET;
    }

    return new_position;
}

static VALUE NIO_ByteBuffer_get_limit(VALUE self)
{
    struct NIO_ByteBuffer *buffer;
    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);

    return INT2NUM(buffer->limit);
}

static VALUE NIO_ByteBuffer_set_limit(VALUE self, VALUE new_limit)
{
    int lim;
    struct NIO_ByteBuffer *buffer;
    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);

    lim = NUM2INT(new_limit);

    if(lim < 0) {
        rb_raise(rb_eArgError, "negative limit given");
    }

    if(lim > buffer->capacity) {
        rb_raise(rb_eArgError, "specified limit exceeds capacity");
    }

    buffer->limit = lim;

    if(buffer->position > lim) {
        buffer->position = lim;
    }

    if(buffer->mark > lim) {
        buffer->mark = MARK_UNSET;
    }

    return new_limit;
}

static VALUE NIO_ByteBuffer_capacity(VALUE self)
{
    struct NIO_ByteBuffer *buffer;
    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);

    return INT2NUM(buffer->capacity);
}

static VALUE NIO_ByteBuffer_remaining(VALUE self)
{
    struct NIO_ByteBuffer *buffer;
    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);

    return INT2NUM(buffer->limit - buffer->position);
}

static VALUE NIO_ByteBuffer_full(VALUE self)
{
    struct NIO_ByteBuffer *buffer;
    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);

    return buffer->position == buffer->limit ? Qtrue : Qfalse;
}

static VALUE NIO_ByteBuffer_get(int argc, VALUE *argv, VALUE self)
{
    int len;
    VALUE length, result;
    struct NIO_ByteBuffer *buffer;
    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);

    rb_scan_args(argc, argv, "01", &length);

    if(length == Qnil) {
        len = buffer->limit - buffer->position;
    } else {
        len = NUM2INT(length);
    }

    if(len < 0) {
        rb_raise(rb_eArgError, "negative length given");
    }

    if(len > buffer->limit - buffer->position) {
        rb_raise(cNIO_ByteBuffer_UnderflowError, "not enough data in buffer");
    }

    result = rb_str_new(buffer->buffer + buffer->position, len);
    buffer->position += len;

    return result;
}

static VALUE NIO_ByteBuffer_fetch(VALUE self, VALUE index)
{
    int i;
    struct NIO_ByteBuffer *buffer;
    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);

    i = NUM2INT(index);

    if(i < 0) {
        rb_raise(rb_eArgError, "negative index given");
    }

    if(i >= buffer->limit) {
        rb_raise(rb_eArgError, "specified index exceeds limit");
    }

    return INT2NUM(buffer->buffer[i]);
}

static VALUE NIO_ByteBuffer_put(VALUE self, VALUE string)
{
    long length;
    struct NIO_ByteBuffer *buffer;
    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);

    StringValue(string);
    length = RSTRING_LEN(string);

    if(length > buffer->limit - buffer->position) {
        rb_raise(cNIO_ByteBuffer_OverflowError, "buffer is full");
    }

    memcpy(buffer->buffer + buffer->position, StringValuePtr(string), length);
    buffer->position += length;

    return self;
}

static VALUE NIO_ByteBuffer_read_from(VALUE self, VALUE io)
{
    struct NIO_ByteBuffer *buffer;
    rb_io_t *fptr;
    ssize_t nbytes, bytes_read;

    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);
    GetOpenFile(rb_convert_type(io, T_FILE, "IO", "to_io"), fptr);
    rb_io_set_nonblock(fptr);

    nbytes = buffer->limit - buffer->position;
    if(nbytes == 0) {
        rb_raise(cNIO_ByteBuffer_OverflowError, "buffer is full");
    }

    bytes_read = read(FPTR_TO_FD(fptr), buffer->buffer + buffer->position, nbytes);

    if(bytes_read < 0) {
        if(errno == EAGAIN) {
            return INT2NUM(0);
        } else {
            rb_sys_fail("write");
        }
    }

    buffer->position += bytes_read;

    return INT2NUM(bytes_read);
}

static VALUE NIO_ByteBuffer_write_to(VALUE self, VALUE io)
{
    struct NIO_ByteBuffer *buffer;
    rb_io_t *fptr;
    ssize_t nbytes, bytes_written;

    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);
    GetOpenFile(rb_convert_type(io, T_FILE, "IO", "to_io"), fptr);
    rb_io_set_nonblock(fptr);

    nbytes = buffer->limit - buffer->position;
    if(nbytes == 0) {
        rb_raise(cNIO_ByteBuffer_UnderflowError, "no data remaining in buffer");
    }

    bytes_written = write(FPTR_TO_FD(fptr), buffer->buffer + buffer->position, nbytes);

    if(bytes_written < 0) {
        if(errno == EAGAIN) {
            return INT2NUM(0);
        } else {
            rb_sys_fail("write");
        }
    }

    buffer->position += bytes_written;

    return INT2NUM(bytes_written);
}

static VALUE NIO_ByteBuffer_flip(VALUE self)
{
    struct NIO_ByteBuffer *buffer;
    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);

    buffer->limit = buffer->position;
    buffer->position = 0;
    buffer->mark = MARK_UNSET;

    return self;
}

static VALUE NIO_ByteBuffer_rewind(VALUE self)
{
    struct NIO_ByteBuffer *buffer;
    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);

    buffer->position = 0;
    buffer->mark = MARK_UNSET;

    return self;
}

static VALUE NIO_ByteBuffer_mark(VALUE self)
{
    struct NIO_ByteBuffer *buffer;
    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);

    buffer->mark = buffer->position;
    return self;
}

static VALUE NIO_ByteBuffer_reset(VALUE self)
{
    struct NIO_ByteBuffer *buffer;
    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);

    if(buffer->mark < 0) {
        rb_raise(cNIO_ByteBuffer_MarkUnsetError, "mark has not been set");
    } else {
        buffer->position = buffer->mark;
    }

    return self;
}

static VALUE NIO_ByteBuffer_compact(VALUE self)
{
    struct NIO_ByteBuffer *buffer;
    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);

    memmove(buffer->buffer, buffer->buffer + buffer->position, buffer->limit - buffer->position);
    buffer->position = buffer->limit - buffer->position;
    buffer->limit = buffer->capacity;

    return self;
}

static VALUE NIO_ByteBuffer_each(VALUE self)
{
    int i;
    struct NIO_ByteBuffer *buffer;
    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);

    if(rb_block_given_p()) {
        for(i = 0; i < buffer->limit; i++) {
            rb_yield(INT2NUM(buffer->buffer[i]));
        }
    } else {
        rb_raise(rb_eArgError, "no block given");
    }

    return self;
}

static VALUE NIO_ByteBuffer_inspect(VALUE self)
{
    struct NIO_ByteBuffer *buffer;
    Data_Get_Struct(self, struct NIO_ByteBuffer, buffer);

    return rb_sprintf(
        "#<%s:%p @position=%d @limit=%d @capacity=%d>",
        rb_class2name(CLASS_OF(self)),
        (void*)self,
        buffer->position,
        buffer->limit,
        buffer->capacity
    );
}

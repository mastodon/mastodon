#define RSTRING_NOT_MODIFIED 1
#include "ruby.h"

#include <sys/types.h>

struct buf_int {
  uint8_t* top;
  uint8_t* cur;

  size_t size;
};

#define BUF_DEFAULT_SIZE 4096
#define BUF_TOLERANCE 32

static void buf_free(struct buf_int* internal) {
  xfree(internal->top);
  xfree(internal);
}

static VALUE buf_alloc(VALUE self) {
  VALUE buf;
  struct buf_int* internal;

  buf = Data_Make_Struct(self, struct buf_int, 0, buf_free, internal);

  internal->size = BUF_DEFAULT_SIZE;
  internal->top = ALLOC_N(uint8_t, BUF_DEFAULT_SIZE);
  internal->cur = internal->top;

  return buf;
}

static VALUE buf_append(VALUE self, VALUE str) {
  struct buf_int* b;
  size_t used, str_len, new_size;

  Data_Get_Struct(self, struct buf_int, b);

  used = b->cur - b->top;

  StringValue(str);
  str_len = RSTRING_LEN(str);

  new_size = used + str_len;

  if(new_size > b->size) {
    size_t n = b->size + (b->size / 2);
    uint8_t* top;
    uint8_t* old;

    new_size = (n > new_size ? n : new_size + BUF_TOLERANCE);

    top = ALLOC_N(uint8_t, new_size);
    old = b->top;
    memcpy(top, old, used);
    b->top = top;
    b->cur = top + used;
    b->size = new_size;
    xfree(old);
  }

  memcpy(b->cur, RSTRING_PTR(str), str_len);
  b->cur += str_len;

  return self;
}

static VALUE buf_append2(int argc, VALUE* argv, VALUE self) {
  struct buf_int* b;
  size_t used, new_size;
  int i;
  VALUE str;

  Data_Get_Struct(self, struct buf_int, b);

  used = b->cur - b->top;
  new_size = used;

  for(i = 0; i < argc; i++) {
    StringValue(argv[i]);

    str = argv[i];

    new_size += RSTRING_LEN(str);
  }

  if(new_size > b->size) {
    size_t n = b->size + (b->size / 2);
    uint8_t* top;
    uint8_t* old;

    new_size = (n > new_size ? n : new_size + BUF_TOLERANCE);

    top = ALLOC_N(uint8_t, new_size);
    old = b->top;
    memcpy(top, old, used);
    b->top = top;
    b->cur = top + used;
    b->size = new_size;
    xfree(old);
  }

  for(i = 0; i < argc; i++) {
    long str_len;
    str = argv[i];
    str_len = RSTRING_LEN(str);
    memcpy(b->cur, RSTRING_PTR(str), str_len);
    b->cur += str_len;
  }

  return self;
}

static VALUE buf_to_str(VALUE self) {
  struct buf_int* b;
  Data_Get_Struct(self, struct buf_int, b);

  return rb_str_new((const char*)(b->top), b->cur - b->top);
}

static VALUE buf_used(VALUE self) {
  struct buf_int* b;
  Data_Get_Struct(self, struct buf_int, b);

  return INT2FIX(b->cur - b->top);
}

static VALUE buf_capa(VALUE self) {
  struct buf_int* b;
  Data_Get_Struct(self, struct buf_int, b);

  return INT2FIX(b->size);
}

static VALUE buf_reset(VALUE self) {
  struct buf_int* b;
  Data_Get_Struct(self, struct buf_int, b);

  b->cur = b->top;
  return self;
}

void Init_io_buffer(VALUE puma) {
  VALUE buf = rb_define_class_under(puma, "IOBuffer", rb_cObject);

  rb_define_alloc_func(buf, buf_alloc);
  rb_define_method(buf, "<<", buf_append, 1);
  rb_define_method(buf, "append", buf_append2, -1);
  rb_define_method(buf, "to_str", buf_to_str, 0);
  rb_define_method(buf, "to_s", buf_to_str, 0);
  rb_define_method(buf, "used", buf_used, 0);
  rb_define_method(buf, "capacity", buf_capa, 0);
  rb_define_method(buf, "reset", buf_reset, 0);
}

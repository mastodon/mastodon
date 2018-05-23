#include <xml_io.h>

static ID id_read, id_write;

VALUE read_check(VALUE *args) {
  return rb_funcall(args[0], id_read, 1, args[1]);
}

VALUE read_failed(void) {
	return Qundef;
}

int io_read_callback(void * ctx, char * buffer, int len) {
  VALUE string, args[2];
  size_t str_len, safe_len;

  args[0] = (VALUE)ctx;
  args[1] = INT2NUM(len);

  string = rb_rescue(read_check, (VALUE)args, read_failed, 0);

  if (NIL_P(string)) return 0;
  if (string == Qundef) return -1;

  str_len = (size_t)RSTRING_LEN(string);
  safe_len = str_len > (size_t)len ? (size_t)len : str_len;
  memcpy(buffer, StringValuePtr(string), safe_len);

  return (int)safe_len;
}

VALUE write_check(VALUE *args) {
  return rb_funcall(args[0], id_write, 1, args[1]);
}

VALUE write_failed(void) {
	return Qundef;
}

int io_write_callback(void * ctx, char * buffer, int len) {
  VALUE args[2], size;

  args[0] = (VALUE)ctx;
  args[1] = rb_str_new(buffer, (long)len);

  size = rb_rescue(write_check, (VALUE)args, write_failed, 0);

  if (size == Qundef) return -1;

  return NUM2INT(size);
}

int io_close_callback(void * ctx) {
  return 0;
}

void init_nokogiri_io() {
  id_read = rb_intern("read");
  id_write = rb_intern("write");
}

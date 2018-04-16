#include <ruby.h>
#include <ow-crypt.h>

VALUE mCrypt;

static VALUE crypt_salt(VALUE self, VALUE prefix, VALUE count, VALUE input)
{
  char * salt;
  VALUE str_salt;

  salt = crypt_gensalt_ra(
      StringValuePtr(prefix),
      NUM2ULONG(count),
      NIL_P(input) ? NULL : StringValuePtr(input),
      NIL_P(input) ? 0 : RSTRING_LEN(input));

  if(!salt) return Qnil;

  str_salt = rb_str_new2(salt);
  free(salt);

  return str_salt;
}

static VALUE ra(VALUE self, VALUE key, VALUE setting)
{
  char * value;
  void * data;
  int size;
  VALUE out;

  data = NULL;
  size = 0xDEADBEEF;

  if(NIL_P(key) || NIL_P(setting)) return Qnil;

  value = crypt_ra(
      NIL_P(key) ? NULL : StringValuePtr(key),
      NIL_P(setting) ? NULL : StringValuePtr(setting),
      &data,
      &size);

  if(!value) return Qnil;

  out = rb_str_new(data, size - 1);

  free(data);

  return out;
}

void Init_crypt()
{
  mCrypt = rb_define_module("Crypt");
  rb_define_singleton_method(mCrypt, "salt", crypt_salt, 3);
  rb_define_singleton_method(mCrypt, "crypt", ra, 2);
}

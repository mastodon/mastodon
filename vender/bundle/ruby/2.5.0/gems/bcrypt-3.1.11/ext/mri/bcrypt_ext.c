#include <ruby.h>
#include <ow-crypt.h>

static VALUE mBCrypt;
static VALUE cBCryptEngine;

/* Given a logarithmic cost parameter, generates a salt for use with +bc_crypt+.
*/
static VALUE bc_salt(VALUE self, VALUE prefix, VALUE count, VALUE input) {
    char * salt;
    VALUE str_salt;

    salt = crypt_gensalt_ra(
	    StringValuePtr(prefix),
	    NUM2ULONG(count),
	    NIL_P(input) ? NULL : StringValuePtr(input),
	    NIL_P(input) ? 0 : RSTRING_LEN(input));

    if(!salt) return Qnil;

    str_salt = rb_str_new2(salt);
    xfree(salt);

    return str_salt;
}

/* Given a secret and a salt, generates a salted hash (which you can then store safely).
*/
static VALUE bc_crypt(VALUE self, VALUE key, VALUE setting) {
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

    xfree(data);

    return out;
}

/* Create the BCrypt and BCrypt::Engine modules, and populate them with methods. */
void Init_bcrypt_ext(){
    mBCrypt = rb_define_module("BCrypt");
    cBCryptEngine = rb_define_class_under(mBCrypt, "Engine", rb_cObject);

    rb_define_singleton_method(cBCryptEngine, "__bc_salt", bc_salt, 3);
    rb_define_singleton_method(cBCryptEngine, "__bc_crypt", bc_crypt, 2);
}

/* vim: set noet sws=4 sw=4: */

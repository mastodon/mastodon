#ifndef CHARLOCK_COMMON_H
#define CHARLOCK_COMMON_H

// tell rbx not to use it's caching compat layer
// by doing this we're making a promize to RBX that
// we'll never modify the pointers we get back from RSTRING_PTR
#define RSTRING_NOT_MODIFIED

#include <ruby.h>
#ifdef HAVE_RUBY_ENCODING_H
#include <ruby/encoding.h>
#endif

static inline VALUE charlock_new_enc_str(const char *str, size_t len, void *encoding)
{
#ifdef HAVE_RUBY_ENCODING_H
	return rb_external_str_new_with_enc(str, len, (rb_encoding *)encoding);
#else
	return rb_str_new(str, len);
#endif
}

static inline VALUE charlock_new_str(const char *str, size_t len)
{
#ifdef HAVE_RUBY_ENCODING_H
	return rb_external_str_new_with_enc(str, len, rb_utf8_encoding());
#else
	return rb_str_new(str, len);
#endif
}

static inline VALUE charlock_new_str2(const char *str)
{
#ifdef HAVE_RUBY_ENCODING_H
	return rb_external_str_new_with_enc(str, strlen(str), rb_utf8_encoding());
#else
	return rb_str_new2(str);
#endif
}

#endif

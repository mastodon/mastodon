#include "unicode/ucnv.h"
#include "common.h"

extern VALUE rb_mCharlockHolmes;
static VALUE rb_cConverter;

static VALUE rb_converter_convert(VALUE self, VALUE rb_txt, VALUE rb_src_enc, VALUE rb_dst_enc) {
	VALUE rb_out;
	const char *src_enc;
	const char *dst_enc;
	const char *src_txt;
	char *out_buf;
	void *rb_enc = NULL;
	int32_t src_len;
	int32_t out_len;
	UErrorCode status = U_ZERO_ERROR;

	Check_Type(rb_txt, T_STRING);
	Check_Type(rb_src_enc, T_STRING);
	Check_Type(rb_dst_enc, T_STRING);

	src_txt = RSTRING_PTR(rb_txt);
	src_len = RSTRING_LEN(rb_txt);
	src_enc = RSTRING_PTR(rb_src_enc);
	dst_enc = RSTRING_PTR(rb_dst_enc);

	// first determin the size of the output buffer
	out_len = ucnv_convert(dst_enc, src_enc, NULL, 0, src_txt, src_len, &status);
	if (status != U_BUFFER_OVERFLOW_ERROR) {
		rb_raise(rb_eArgError, "%s", u_errorName(status));
	}
	out_buf = malloc(out_len);

	// now do the actual conversion
	status = U_ZERO_ERROR;
	out_len = ucnv_convert(dst_enc, src_enc, out_buf, out_len, src_txt, src_len, &status);
	if (U_FAILURE(status)) {
		free(out_buf);
		rb_raise(rb_eArgError, "%s", u_errorName(status));
	}

#ifdef HAVE_RUBY_ENCODING_H
	rb_enc = (void *)rb_enc_find(dst_enc);
#endif

	rb_out = charlock_new_enc_str(out_buf, out_len, rb_enc);

	free(out_buf);

	return rb_out;
}

void _init_charlock_converter() {
	rb_cConverter = rb_define_class_under(rb_mCharlockHolmes, "Converter", rb_cObject);

	rb_define_singleton_method(rb_cConverter, "convert", rb_converter_convert, 3);
}

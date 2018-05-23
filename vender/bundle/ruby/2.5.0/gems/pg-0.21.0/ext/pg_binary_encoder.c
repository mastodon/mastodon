/*
 * pg_column_map.c - PG::ColumnMap class extension
 * $Id: pg_binary_encoder.c,v e61a06f1f5ed 2015/12/25 21:14:21 lars $
 *
 */

#include "pg.h"
#include "util.h"
#ifdef HAVE_INTTYPES_H
#include <inttypes.h>
#endif

VALUE rb_mPG_BinaryEncoder;


/*
 * Document-class: PG::BinaryEncoder::Boolean < PG::SimpleEncoder
 *
 * This is the encoder class for the PostgreSQL boolean type.
 *
 * It accepts true and false. Other values will raise an exception.
 *
 */
static int
pg_bin_enc_boolean(t_pg_coder *conv, VALUE value, char *out, VALUE *intermediate, int enc_idx)
{
	char mybool;
	switch(value){
		case Qtrue : mybool = 1; break;
		case Qfalse : mybool = 0; break;
		default :
			rb_raise( rb_eTypeError, "wrong data for binary boolean converter" );
	}
	if(out) *out = mybool;
	return 1;
}

/*
 * Document-class: PG::BinaryEncoder::Int2 < PG::SimpleEncoder
 *
 * This is the encoder class for the PostgreSQL int2 type.
 *
 * Non-Number values are expected to have method +to_i+ defined.
 *
 */
static int
pg_bin_enc_int2(t_pg_coder *conv, VALUE value, char *out, VALUE *intermediate, int enc_idx)
{
	if(out){
		write_nbo16(NUM2INT(*intermediate), out);
	}else{
		*intermediate = pg_obj_to_i(value);
	}
	return 2;
}

/*
 * Document-class: PG::BinaryEncoder::Int2 < PG::SimpleEncoder
 *
 * This is the encoder class for the PostgreSQL int4 type.
 *
 * Non-Number values are expected to have method +to_i+ defined.
 *
 */
static int
pg_bin_enc_int4(t_pg_coder *conv, VALUE value, char *out, VALUE *intermediate, int enc_idx)
{
	if(out){
		write_nbo32(NUM2LONG(*intermediate), out);
	}else{
		*intermediate = pg_obj_to_i(value);
	}
	return 4;
}

/*
 * Document-class: PG::BinaryEncoder::Int2 < PG::SimpleEncoder
 *
 * This is the encoder class for the PostgreSQL int8 type.
 *
 * Non-Number values are expected to have method +to_i+ defined.
 *
 */
static int
pg_bin_enc_int8(t_pg_coder *conv, VALUE value, char *out, VALUE *intermediate, int enc_idx)
{
	if(out){
		write_nbo64(NUM2LL(*intermediate), out);
	}else{
		*intermediate = pg_obj_to_i(value);
	}
	return 8;
}

/*
 * Document-class: PG::BinaryEncoder::FromBase64 < PG::CompositeEncoder
 *
 * This is an encoder class for conversion of base64 encoded data
 * to it's binary representation.
 *
 */
static int
pg_bin_enc_from_base64(t_pg_coder *conv, VALUE value, char *out, VALUE *intermediate, int enc_idx)
{
	int strlen;
	VALUE subint;
	t_pg_composite_coder *this = (t_pg_composite_coder *)conv;
	t_pg_coder_enc_func enc_func = pg_coder_enc_func(this->elem);

	if(out){
		/* Second encoder pass, if required */
		strlen = enc_func(this->elem, value, out, intermediate, enc_idx);
		strlen = base64_decode( out, out, strlen );

		return strlen;
	} else {
		/* First encoder pass */
		strlen = enc_func(this->elem, value, NULL, &subint, enc_idx);

		if( strlen == -1 ){
			/* Encoded string is returned in subint */
			VALUE out_str;

			strlen = RSTRING_LENINT(subint);
			out_str = rb_str_new(NULL, BASE64_DECODED_SIZE(strlen));

			strlen = base64_decode( RSTRING_PTR(out_str), RSTRING_PTR(subint), strlen);
			rb_str_set_len( out_str, strlen );
			*intermediate = out_str;

			return -1;
		} else {
			*intermediate = subint;

			return BASE64_DECODED_SIZE(strlen);
		}
	}
}

void
init_pg_binary_encoder()
{
	/* This module encapsulates all encoder classes with binary output format */
	rb_mPG_BinaryEncoder = rb_define_module_under( rb_mPG, "BinaryEncoder" );

	/* Make RDoc aware of the encoder classes... */
	/* dummy = rb_define_class_under( rb_mPG_BinaryEncoder, "Boolean", rb_cPG_SimpleEncoder ); */
	pg_define_coder( "Boolean", pg_bin_enc_boolean, rb_cPG_SimpleEncoder, rb_mPG_BinaryEncoder );
	/* dummy = rb_define_class_under( rb_mPG_BinaryEncoder, "Int2", rb_cPG_SimpleEncoder ); */
	pg_define_coder( "Int2", pg_bin_enc_int2, rb_cPG_SimpleEncoder, rb_mPG_BinaryEncoder );
	/* dummy = rb_define_class_under( rb_mPG_BinaryEncoder, "Int4", rb_cPG_SimpleEncoder ); */
	pg_define_coder( "Int4", pg_bin_enc_int4, rb_cPG_SimpleEncoder, rb_mPG_BinaryEncoder );
	/* dummy = rb_define_class_under( rb_mPG_BinaryEncoder, "Int8", rb_cPG_SimpleEncoder ); */
	pg_define_coder( "Int8", pg_bin_enc_int8, rb_cPG_SimpleEncoder, rb_mPG_BinaryEncoder );
	/* dummy = rb_define_class_under( rb_mPG_BinaryEncoder, "String", rb_cPG_SimpleEncoder ); */
	pg_define_coder( "String", pg_coder_enc_to_s, rb_cPG_SimpleEncoder, rb_mPG_BinaryEncoder );
	/* dummy = rb_define_class_under( rb_mPG_BinaryEncoder, "Bytea", rb_cPG_SimpleEncoder ); */
	pg_define_coder( "Bytea", pg_coder_enc_to_s, rb_cPG_SimpleEncoder, rb_mPG_BinaryEncoder );

	/* dummy = rb_define_class_under( rb_mPG_BinaryEncoder, "FromBase64", rb_cPG_CompositeEncoder ); */
	pg_define_coder( "FromBase64", pg_bin_enc_from_base64, rb_cPG_CompositeEncoder, rb_mPG_BinaryEncoder );
}

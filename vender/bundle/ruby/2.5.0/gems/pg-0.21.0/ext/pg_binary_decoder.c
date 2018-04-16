/*
 * pg_column_map.c - PG::ColumnMap class extension
 * $Id: pg_binary_decoder.c,v fcf731d3dff7 2015/09/08 12:25:06 jfali $
 *
 */

#include "pg.h"
#include "util.h"
#ifdef HAVE_INTTYPES_H
#include <inttypes.h>
#endif

VALUE rb_mPG_BinaryDecoder;


/*
 * Document-class: PG::BinaryDecoder::Boolean < PG::SimpleDecoder
 *
 * This is a decoder class for conversion of PostgreSQL binary bool type
 * to Ruby true or false objects.
 *
 */
static VALUE
pg_bin_dec_boolean(t_pg_coder *conv, char *val, int len, int tuple, int field, int enc_idx)
{
	if (len < 1) {
		rb_raise( rb_eTypeError, "wrong data for binary boolean converter in tuple %d field %d", tuple, field);
	}
	return *val == 0 ? Qfalse : Qtrue;
}

/*
 * Document-class: PG::BinaryDecoder::Integer < PG::SimpleDecoder
 *
 * This is a decoder class for conversion of PostgreSQL binary int2, int4 and int8 types
 * to Ruby Integer objects.
 *
 */
static VALUE
pg_bin_dec_integer(t_pg_coder *conv, char *val, int len, int tuple, int field, int enc_idx)
{
	switch( len ){
		case 2:
			return INT2NUM(read_nbo16(val));
		case 4:
			return LONG2NUM(read_nbo32(val));
		case 8:
			return LL2NUM(read_nbo64(val));
		default:
			rb_raise( rb_eTypeError, "wrong data for binary integer converter in tuple %d field %d length %d", tuple, field, len);
	}
}

/*
 * Document-class: PG::BinaryDecoder::Float < PG::SimpleDecoder
 *
 * This is a decoder class for conversion of PostgreSQL binary float4 and float8 types
 * to Ruby Float objects.
 *
 */
static VALUE
pg_bin_dec_float(t_pg_coder *conv, char *val, int len, int tuple, int field, int enc_idx)
{
	union {
		float f;
		int32_t i;
	} swap4;
	union {
		double f;
		int64_t i;
	} swap8;

	switch( len ){
		case 4:
			swap4.i = read_nbo32(val);
			return rb_float_new(swap4.f);
		case 8:
			swap8.i = read_nbo64(val);
			return rb_float_new(swap8.f);
		default:
			rb_raise( rb_eTypeError, "wrong data for BinaryFloat converter in tuple %d field %d length %d", tuple, field, len);
	}
}

/*
 * Document-class: PG::BinaryDecoder::Bytea < PG::SimpleDecoder
 *
 * This decoder class delivers the data received from the server as binary String object.
 * It is therefore suitable for conversion of PostgreSQL bytea data as well as any other
 * data in binary format.
 *
 */
VALUE
pg_bin_dec_bytea(t_pg_coder *conv, char *val, int len, int tuple, int field, int enc_idx)
{
	VALUE ret;
	ret = rb_tainted_str_new( val, len );
	PG_ENCODING_SET_NOCHECK( ret, rb_ascii8bit_encindex() );
	return ret;
}

/*
 * Document-class: PG::BinaryDecoder::ToBase64 < PG::CompositeDecoder
 *
 * This is a decoder class for conversion of binary (bytea) to base64 data.
 *
 */
static VALUE
pg_bin_dec_to_base64(t_pg_coder *conv, char *val, int len, int tuple, int field, int enc_idx)
{
	t_pg_composite_coder *this = (t_pg_composite_coder *)conv;
	t_pg_coder_dec_func dec_func = pg_coder_dec_func(this->elem, this->comp.format);
	int encoded_len = BASE64_ENCODED_SIZE(len);
	/* create a buffer of the encoded length */
	VALUE out_value = rb_tainted_str_new(NULL, encoded_len);

	base64_encode( RSTRING_PTR(out_value), val, len );

	/* Is it a pure String conversion? Then we can directly send out_value to the user. */
	if( this->comp.format == 0 && dec_func == pg_text_dec_string ){
		PG_ENCODING_SET_NOCHECK( out_value, enc_idx );
		return out_value;
	}
	if( this->comp.format == 1 && dec_func == pg_bin_dec_bytea ){
		PG_ENCODING_SET_NOCHECK( out_value, rb_ascii8bit_encindex() );
		return out_value;
	}
	out_value = dec_func(this->elem, RSTRING_PTR(out_value), encoded_len, tuple, field, enc_idx);

	return out_value;
}

/*
 * Document-class: PG::BinaryDecoder::String < PG::SimpleDecoder
 *
 * This is a decoder class for conversion of PostgreSQL text output to
 * to Ruby String object. The output value will have the character encoding
 * set with PG::Connection#internal_encoding= .
 *
 */

void
init_pg_binary_decoder()
{
	/* This module encapsulates all decoder classes with binary input format */
	rb_mPG_BinaryDecoder = rb_define_module_under( rb_mPG, "BinaryDecoder" );

	/* Make RDoc aware of the decoder classes... */
	/* dummy = rb_define_class_under( rb_mPG_BinaryDecoder, "Boolean", rb_cPG_SimpleDecoder ); */
	pg_define_coder( "Boolean", pg_bin_dec_boolean, rb_cPG_SimpleDecoder, rb_mPG_BinaryDecoder );
	/* dummy = rb_define_class_under( rb_mPG_BinaryDecoder, "Integer", rb_cPG_SimpleDecoder ); */
	pg_define_coder( "Integer", pg_bin_dec_integer, rb_cPG_SimpleDecoder, rb_mPG_BinaryDecoder );
	/* dummy = rb_define_class_under( rb_mPG_BinaryDecoder, "Float", rb_cPG_SimpleDecoder ); */
	pg_define_coder( "Float", pg_bin_dec_float, rb_cPG_SimpleDecoder, rb_mPG_BinaryDecoder );
	/* dummy = rb_define_class_under( rb_mPG_BinaryDecoder, "String", rb_cPG_SimpleDecoder ); */
	pg_define_coder( "String", pg_text_dec_string, rb_cPG_SimpleDecoder, rb_mPG_BinaryDecoder );
	/* dummy = rb_define_class_under( rb_mPG_BinaryDecoder, "Bytea", rb_cPG_SimpleDecoder ); */
	pg_define_coder( "Bytea", pg_bin_dec_bytea, rb_cPG_SimpleDecoder, rb_mPG_BinaryDecoder );

	/* dummy = rb_define_class_under( rb_mPG_BinaryDecoder, "ToBase64", rb_cPG_CompositeDecoder ); */
	pg_define_coder( "ToBase64", pg_bin_dec_to_base64, rb_cPG_CompositeDecoder, rb_mPG_BinaryDecoder );
}

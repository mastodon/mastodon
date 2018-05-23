/*
 * pg_type_map_all_strings.c - PG::TypeMapAllStrings class extension
 * $Id: pg_type_map_all_strings.c,v c53f993a4254 2014/12/12 21:57:29 lars $
 *
 * This is the default typemap.
 *
 */

#include "pg.h"

VALUE rb_cTypeMapAllStrings;
VALUE pg_typemap_all_strings;

static VALUE
pg_tmas_fit_to_result( VALUE self, VALUE result )
{
	return self;
}

static VALUE
pg_tmas_result_value( t_typemap *p_typemap, VALUE result, int tuple, int field )
{
	VALUE ret;
	char * val;
	int len;
	t_pg_result *p_result = pgresult_get_this(result);

	if (PQgetisnull(p_result->pgresult, tuple, field)) {
		return Qnil;
	}

	val = PQgetvalue( p_result->pgresult, tuple, field );
	len = PQgetlength( p_result->pgresult, tuple, field );

	if ( 0 == PQfformat(p_result->pgresult, field) ) {
		ret = pg_text_dec_string(NULL, val, len, tuple, field, ENCODING_GET(result));
	} else {
		ret = pg_bin_dec_bytea(NULL, val, len, tuple, field, ENCODING_GET(result));
	}

	return ret;
}

static VALUE
pg_tmas_fit_to_query( VALUE self, VALUE params )
{
	return self;
}

static t_pg_coder *
pg_tmas_typecast_query_param( t_typemap *p_typemap, VALUE param_value, int field )
{
	return NULL;
}

static int
pg_tmas_fit_to_copy_get( VALUE self )
{
	/* We can not predict the number of columns for copy */
	return 0;
}

static VALUE
pg_tmas_typecast_copy_get( t_typemap *p_typemap, VALUE field_str, int fieldno, int format, int enc_idx )
{
	if( format == 0 ){
		PG_ENCODING_SET_NOCHECK( field_str, enc_idx );
	} else {
		PG_ENCODING_SET_NOCHECK( field_str, rb_ascii8bit_encindex() );
	}
	return field_str;
}

static VALUE
pg_tmas_s_allocate( VALUE klass )
{
	t_typemap *this;
	VALUE self;

	self = Data_Make_Struct( klass, t_typemap, NULL, -1, this );

	this->funcs.fit_to_result = pg_tmas_fit_to_result;
	this->funcs.fit_to_query = pg_tmas_fit_to_query;
	this->funcs.fit_to_copy_get = pg_tmas_fit_to_copy_get;
	this->funcs.typecast_result_value = pg_tmas_result_value;
	this->funcs.typecast_query_param = pg_tmas_typecast_query_param;
	this->funcs.typecast_copy_get = pg_tmas_typecast_copy_get;

	return self;
}


void
init_pg_type_map_all_strings()
{
	/*
	 * Document-class: PG::TypeMapAllStrings < PG::TypeMap
	 *
	 * This type map casts all values received from the database server to Strings
	 * and sends all values to the server after conversion to String by +#to_s+ .
	 * That means, it is hard coded to PG::TextEncoder::String for value encoding
	 * and to PG::TextDecoder::String for text format respectivly PG::BinaryDecoder::Bytea
	 * for binary format received from the server.
	 *
	 * It is suitable for type casting query bind parameters, result values and
	 * COPY IN/OUT data.
	 *
	 * This is the default type map for each PG::Connection .
	 *
	 */
	rb_cTypeMapAllStrings = rb_define_class_under( rb_mPG, "TypeMapAllStrings", rb_cTypeMap );
	rb_define_alloc_func( rb_cTypeMapAllStrings, pg_tmas_s_allocate );

	pg_typemap_all_strings = rb_funcall( rb_cTypeMapAllStrings, rb_intern("new"), 0 );
	rb_gc_register_address( &pg_typemap_all_strings );
}

/*
 * pg_type_map_in_ruby.c - PG::TypeMapInRuby class extension
 * $Id: pg_type_map_in_ruby.c,v 3d89d3aae4fd 2015/01/05 16:19:41 kanis $
 *
 */

#include "pg.h"

VALUE rb_cTypeMapInRuby;
static VALUE s_id_fit_to_result;
static VALUE s_id_fit_to_query;
static VALUE s_id_fit_to_copy_get;
static VALUE s_id_typecast_result_value;
static VALUE s_id_typecast_query_param;
static VALUE s_id_typecast_copy_get;

typedef struct {
	t_typemap typemap;
	VALUE self;
} t_tmir;


/*
 * call-seq:
 *    typemap.fit_to_result( result )
 *
 * Check that the type map fits to the result.
 *
 * This method is called, when a type map is assigned to a result.
 * It must return a PG::TypeMap object or raise an Exception.
 * This can be +self+ or some other type map that fits to the result.
 *
 */
static VALUE
pg_tmir_fit_to_result( VALUE self, VALUE result )
{
	t_tmir *this = DATA_PTR( self );
	t_typemap *default_tm;
	t_typemap *p_new_typemap;
	VALUE sub_typemap;
	VALUE new_typemap;

	if( rb_respond_to(self, s_id_fit_to_result) ){
		new_typemap = rb_funcall( self, s_id_fit_to_result, 1, result );

		if ( !rb_obj_is_kind_of(new_typemap, rb_cTypeMap) ) {
			rb_raise( rb_eTypeError, "wrong return type from fit_to_result: %s expected kind of PG::TypeMap",
					rb_obj_classname( new_typemap ) );
		}
		Check_Type( new_typemap, T_DATA );
	} else {
		new_typemap = self;
	}

	/* Ensure that the default type map fits equaly. */
	default_tm = DATA_PTR( this->typemap.default_typemap );
	sub_typemap = default_tm->funcs.fit_to_result( this->typemap.default_typemap, result );

	if( sub_typemap != this->typemap.default_typemap ){
		new_typemap = rb_obj_dup( new_typemap );
	}

	p_new_typemap = DATA_PTR(new_typemap);
	p_new_typemap->default_typemap = sub_typemap;
	return new_typemap;
}

static VALUE
pg_tmir_result_value( t_typemap *p_typemap, VALUE result, int tuple, int field )
{
	t_tmir *this = (t_tmir *) p_typemap;

	return rb_funcall( this->self, s_id_typecast_result_value, 3, result, INT2NUM(tuple), INT2NUM(field) );
}

/*
 * call-seq:
 *    typemap.typecast_result_value( result, tuple, field )
 *
 * Retrieve and cast a field of the given result.
 *
 * This method implementation uses the #default_type_map to get the
 * field value. It can be derived to change this behaviour.
 *
 * Parameters:
 * * +result+ : The PG::Result received from the database.
 * * +tuple+ : The row number to retrieve.
 * * +field+ : The column number to retrieve.
 *
 * Note: Calling any value retrieving methods of +result+ will result
 * in an (endless) recursion. Instead super() can be used to retrieve
 * the value using the default_typemap.
 *
 */
static VALUE
pg_tmir_typecast_result_value( VALUE self, VALUE result, VALUE tuple, VALUE field )
{
	t_tmir *this = DATA_PTR( self );
	t_typemap *default_tm = DATA_PTR( this->typemap.default_typemap );
	return default_tm->funcs.typecast_result_value( default_tm, result, NUM2INT(tuple), NUM2INT(field) );
}

/*
 * call-seq:
 *    typemap.fit_to_query( params )
 *
 * Check that the type map fits to the given user values.
 *
 * This method is called, when a type map is used for sending a query
 * and for encoding of copy data, before the value is casted.
 *
 */
static VALUE
pg_tmir_fit_to_query( VALUE self, VALUE params )
{
	t_tmir *this = DATA_PTR( self );
	t_typemap *default_tm;

	if( rb_respond_to(self, s_id_fit_to_query) ){
		rb_funcall( self, s_id_fit_to_query, 1, params );
	}

	/* Ensure that the default type map fits equaly. */
	default_tm = DATA_PTR( this->typemap.default_typemap );
	default_tm->funcs.fit_to_query( this->typemap.default_typemap, params );

	return self;
}

static t_pg_coder *
pg_tmir_query_param( t_typemap *p_typemap, VALUE param_value, int field )
{
	t_tmir *this = (t_tmir *) p_typemap;

	VALUE coder = rb_funcall( this->self, s_id_typecast_query_param, 2, param_value, INT2NUM(field) );

	if ( NIL_P(coder) ){
		return NULL;
	} else if( rb_obj_is_kind_of(coder, rb_cPG_Coder) ) {
		return DATA_PTR(coder);
	} else {
		rb_raise( rb_eTypeError, "wrong return type from typecast_query_param: %s expected nil or kind of PG::Coder",
				rb_obj_classname( coder ) );
	}
}

/*
 * call-seq:
 *    typemap.typecast_query_param( param_value, field )
 *
 * Cast a field string for transmission to the server.
 *
 * This method implementation uses the #default_type_map to cast param_value.
 * It can be derived to change this behaviour.
 *
 * Parameters:
 * * +param_value+ : The value from the user.
 * * +field+ : The field number from left to right.
 *
 */
static VALUE
pg_tmir_typecast_query_param( VALUE self, VALUE param_value, VALUE field )
{
	t_tmir *this = DATA_PTR( self );
	t_typemap *default_tm = DATA_PTR( this->typemap.default_typemap );
	t_pg_coder *p_coder = default_tm->funcs.typecast_query_param( default_tm, param_value, NUM2INT(field) );

	return p_coder ? p_coder->coder_obj : Qnil;
}

/* This is to fool rdoc's C parser */
#if 0
/*
 * call-seq:
 *    typemap.fit_to_copy_get()
 *
 * Check that the type map can be used for PG::Connection#get_copy_data.
 *
 * This method is called, when a type map is used for decoding copy data,
 * before the value is casted.
 *
 */
static VALUE pg_tmir_fit_to_copy_get_dummy( VALUE self ){}
#endif

static int
pg_tmir_fit_to_copy_get( VALUE self )
{
	t_tmir *this = DATA_PTR( self );
	t_typemap *default_tm;
	VALUE num_columns = INT2NUM(0);

	if( rb_respond_to(self, s_id_fit_to_copy_get) ){
		num_columns = rb_funcall( self, s_id_fit_to_copy_get, 0 );
	}

	if ( !rb_obj_is_kind_of(num_columns, rb_cInteger) ) {
		rb_raise( rb_eTypeError, "wrong return type from fit_to_copy_get: %s expected kind of Integer",
				rb_obj_classname( num_columns ) );
	}
	/* Ensure that the default type map fits equaly. */
	default_tm = DATA_PTR( this->typemap.default_typemap );
	default_tm->funcs.fit_to_copy_get( this->typemap.default_typemap );

	return NUM2INT(num_columns);;
}

static VALUE
pg_tmir_copy_get( t_typemap *p_typemap, VALUE field_str, int fieldno, int format, int enc_idx )
{
	t_tmir *this = (t_tmir *) p_typemap;
	rb_encoding *p_encoding = rb_enc_from_index(enc_idx);
	VALUE enc = rb_enc_from_encoding(p_encoding);
	/* field_str is reused in-place by pg_text_dec_copy_row(), so we need to make
	 * a copy of the string buffer for use in ruby space. */
	VALUE field_str_copy = rb_str_dup(field_str);
	rb_str_modify(field_str_copy);

	return rb_funcall( this->self, s_id_typecast_copy_get, 4, field_str_copy, INT2NUM(fieldno), INT2NUM(format), enc );
}

/*
 * call-seq:
 *    typemap.typecast_copy_get( field_str, fieldno, format, encoding )
 *
 * Cast a field string received by PG::Connection#get_copy_data.
 *
 * This method implementation uses the #default_type_map to cast field_str.
 * It can be derived to change this behaviour.
 *
 * Parameters:
 * * +field_str+ : The String received from the server.
 * * +fieldno+ : The field number from left to right.
 * * +format+ : The format code (0 = text, 1 = binary)
 * * +encoding+ : The encoding of the connection and encoding the returned
 *   value should get.
 *
 */
static VALUE
pg_tmir_typecast_copy_get( VALUE self, VALUE field_str, VALUE fieldno, VALUE format, VALUE enc )
{
	t_tmir *this = DATA_PTR( self );
	t_typemap *default_tm = DATA_PTR( this->typemap.default_typemap );
	int enc_idx = rb_to_encoding_index( enc );

	return default_tm->funcs.typecast_copy_get( default_tm, field_str, NUM2INT(fieldno), NUM2INT(format), enc_idx );
}

static VALUE
pg_tmir_s_allocate( VALUE klass )
{
	t_tmir *this;
	VALUE self;

	self = Data_Make_Struct( klass, t_tmir, NULL, -1, this );

	this->typemap.funcs.fit_to_result = pg_tmir_fit_to_result;
	this->typemap.funcs.fit_to_query = pg_tmir_fit_to_query;
	this->typemap.funcs.fit_to_copy_get = pg_tmir_fit_to_copy_get;
	this->typemap.funcs.typecast_result_value = pg_tmir_result_value;
	this->typemap.funcs.typecast_query_param = pg_tmir_query_param;
	this->typemap.funcs.typecast_copy_get = pg_tmir_copy_get;
	this->typemap.default_typemap = pg_typemap_all_strings;
	this->self = self;

	return self;
}


void
init_pg_type_map_in_ruby()
{
	s_id_fit_to_result = rb_intern("fit_to_result");
	s_id_fit_to_query = rb_intern("fit_to_query");
	s_id_fit_to_copy_get = rb_intern("fit_to_copy_get");
	s_id_typecast_result_value = rb_intern("typecast_result_value");
	s_id_typecast_query_param = rb_intern("typecast_query_param");
	s_id_typecast_copy_get = rb_intern("typecast_copy_get");

	/*
	 * Document-class: PG::TypeMapInRuby < PG::TypeMap
	 *
	 * This class can be used to implement a type map in ruby, typically as a
	 * #default_type_map in a type map chain.
	 *
	 * This API is EXPERIMENTAL and could change in the future.
	 *
	 */
	rb_cTypeMapInRuby = rb_define_class_under( rb_mPG, "TypeMapInRuby", rb_cTypeMap );
	rb_define_alloc_func( rb_cTypeMapInRuby, pg_tmir_s_allocate );
	/* rb_define_method( rb_cTypeMapInRuby, "fit_to_result", pg_tmir_fit_to_result, 1 ); */
	/* rb_define_method( rb_cTypeMapInRuby, "fit_to_query", pg_tmir_fit_to_query, 1 ); */
	/* rb_define_method( rb_cTypeMapInRuby, "fit_to_copy_get", pg_tmir_fit_to_copy_get_dummy, 0 ); */
	rb_define_method( rb_cTypeMapInRuby, "typecast_result_value", pg_tmir_typecast_result_value, 3 );
	rb_define_method( rb_cTypeMapInRuby, "typecast_query_param", pg_tmir_typecast_query_param, 2 );
	rb_define_method( rb_cTypeMapInRuby, "typecast_copy_get", pg_tmir_typecast_copy_get, 4 );
	/* rb_mDefaultTypeMappable = rb_define_module_under( rb_cTypeMap, "DefaultTypeMappable"); */
	rb_include_module( rb_cTypeMapInRuby, rb_mDefaultTypeMappable );
}

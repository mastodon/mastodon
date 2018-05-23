/*
 * pg_coder.c - PG::Coder class extension
 *
 */

#include "pg.h"

VALUE rb_cPG_Coder;
VALUE rb_cPG_SimpleCoder;
VALUE rb_cPG_SimpleEncoder;
VALUE rb_cPG_SimpleDecoder;
VALUE rb_cPG_CompositeCoder;
VALUE rb_cPG_CompositeEncoder;
VALUE rb_cPG_CompositeDecoder;
VALUE rb_mPG_BinaryFormatting;
static ID s_id_encode;
static ID s_id_decode;
static ID s_id_CFUNC;

static VALUE
pg_coder_allocate( VALUE klass )
{
	rb_raise( rb_eTypeError, "PG::Coder cannot be instantiated directly");
}

void
pg_coder_init_encoder( VALUE self )
{
	t_pg_coder *this = DATA_PTR( self );
	VALUE klass = rb_class_of(self);
	if( rb_const_defined( klass, s_id_CFUNC ) ){
		VALUE cfunc = rb_const_get( klass, s_id_CFUNC );
		this->enc_func = DATA_PTR(cfunc);
	} else {
		this->enc_func = NULL;
	}
	this->dec_func = NULL;
	this->coder_obj = self;
	this->oid = 0;
	this->format = 0;
	rb_iv_set( self, "@name", Qnil );
}

void
pg_coder_init_decoder( VALUE self )
{
	t_pg_coder *this = DATA_PTR( self );
	VALUE klass = rb_class_of(self);
	this->enc_func = NULL;
	if( rb_const_defined( klass, s_id_CFUNC ) ){
		VALUE cfunc = rb_const_get( klass, s_id_CFUNC );
		this->dec_func = DATA_PTR(cfunc);
	} else {
		this->dec_func = NULL;
	}
	this->coder_obj = self;
	this->oid = 0;
	this->format = 0;
	rb_iv_set( self, "@name", Qnil );
}

static VALUE
pg_simple_encoder_allocate( VALUE klass )
{
	t_pg_coder *this;
	VALUE self = Data_Make_Struct( klass, t_pg_coder, NULL, -1, this );
	pg_coder_init_encoder( self );
	return self;
}

static VALUE
pg_composite_encoder_allocate( VALUE klass )
{
	t_pg_composite_coder *this;
	VALUE self = Data_Make_Struct( klass, t_pg_composite_coder, NULL, -1, this );
	pg_coder_init_encoder( self );
	this->elem = NULL;
	this->needs_quotation = 1;
	this->delimiter = ',';
	rb_iv_set( self, "@elements_type", Qnil );
	return self;
}

static VALUE
pg_simple_decoder_allocate( VALUE klass )
{
	t_pg_coder *this;
	VALUE self = Data_Make_Struct( klass, t_pg_coder, NULL, -1, this );
	pg_coder_init_decoder( self );
	return self;
}

static VALUE
pg_composite_decoder_allocate( VALUE klass )
{
	t_pg_composite_coder *this;
	VALUE self = Data_Make_Struct( klass, t_pg_composite_coder, NULL, -1, this );
	pg_coder_init_decoder( self );
	this->elem = NULL;
	this->needs_quotation = 1;
	this->delimiter = ',';
	rb_iv_set( self, "@elements_type", Qnil );
	return self;
}

/*
 * call-seq:
 *    coder.encode( value [, encoding] )
 *
 * Encodes the given Ruby object into string representation, without
 * sending data to/from the database server.
 *
 * A nil value is passed through.
 *
 */
static VALUE
pg_coder_encode(int argc, VALUE *argv, VALUE self)
{
	VALUE res;
	VALUE intermediate;
	VALUE value;
	int len, len2;
	int enc_idx;
	t_pg_coder *this = DATA_PTR(self);

	if(argc < 1 || argc > 2){
		rb_raise(rb_eArgError, "wrong number of arguments (%i for 1..2)", argc);
	}else if(argc == 1){
		enc_idx = rb_ascii8bit_encindex();
	}else{
		enc_idx = rb_to_encoding_index(argv[1]);
	}
	value = argv[0];

	if( NIL_P(value) )
		return Qnil;

	if( !this->enc_func ){
		rb_raise(rb_eRuntimeError, "no encoder function defined");
	}

	len = this->enc_func( this, value, NULL, &intermediate, enc_idx );

	if( len == -1 ){
		/* The intermediate value is a String that can be used directly. */
		OBJ_INFECT(intermediate, value);
		return intermediate;
	}

	res = rb_str_new(NULL, len);
	PG_ENCODING_SET_NOCHECK(res, enc_idx);
	len2 = this->enc_func( this, value, RSTRING_PTR(res), &intermediate, enc_idx );
	if( len < len2 ){
		rb_bug("%s: result length of first encoder run (%i) is less than second run (%i)",
			rb_obj_classname( self ), len, len2 );
	}
	rb_str_set_len( res, len2 );
	OBJ_INFECT(res, value);

	RB_GC_GUARD(intermediate);

	return res;
}

/*
 * call-seq:
 *    coder.decode( string, tuple=nil, field=nil )
 *
 * Decodes the given string representation into a Ruby object, without
 * sending data to/from the database server.
 *
 * A nil value is passed through and non String values are expected to have
 * #to_str defined.
 *
 */
static VALUE
pg_coder_decode(int argc, VALUE *argv, VALUE self)
{
	char *val;
	int tuple = -1;
	int field = -1;
	VALUE res;
	t_pg_coder *this = DATA_PTR(self);

	if(argc < 1 || argc > 3){
		rb_raise(rb_eArgError, "wrong number of arguments (%i for 1..3)", argc);
	}else if(argc >= 3){
		tuple = NUM2INT(argv[1]);
		field = NUM2INT(argv[2]);
	}

	if( NIL_P(argv[0]) )
		return Qnil;

	val = StringValuePtr(argv[0]);
	if( !this->dec_func ){
		rb_raise(rb_eRuntimeError, "no decoder function defined");
	}

	res = this->dec_func(this, val, RSTRING_LEN(argv[0]), tuple, field, ENCODING_GET(argv[0]));
	OBJ_INFECT(res, argv[0]);

	return res;
}

/*
 * call-seq:
 *    coder.oid = Integer
 *
 * Specifies the type OID that is sent alongside with an encoded
 * query parameter value.
 *
 * The default is +0+.
 */
static VALUE
pg_coder_oid_set(VALUE self, VALUE oid)
{
	t_pg_coder *this = DATA_PTR(self);
	this->oid = NUM2UINT(oid);
	return oid;
}

/*
 * call-seq:
 *    coder.oid -> Integer
 *
 * The type OID that is sent alongside with an encoded
 * query parameter value.
 */
static VALUE
pg_coder_oid_get(VALUE self)
{
	t_pg_coder *this = DATA_PTR(self);
	return UINT2NUM(this->oid);
}

/*
 * call-seq:
 *    coder.format = Integer
 *
 * Specifies the format code that is sent alongside with an encoded
 * query parameter value.
 *
 * The default is +0+.
 */
static VALUE
pg_coder_format_set(VALUE self, VALUE format)
{
	t_pg_coder *this = DATA_PTR(self);
	this->format = NUM2INT(format);
	return format;
}

/*
 * call-seq:
 *    coder.format -> Integer
 *
 * The format code that is sent alongside with an encoded
 * query parameter value.
 */
static VALUE
pg_coder_format_get(VALUE self)
{
	t_pg_coder *this = DATA_PTR(self);
	return INT2NUM(this->format);
}

/*
 * call-seq:
 *    coder.needs_quotation = Boolean
 *
 * Specifies whether the assigned #elements_type requires quotation marks to
 * be transferred safely. Encoding with #needs_quotation=false is somewhat
 * faster.
 *
 * The default is +true+. This option is ignored for decoding of values.
 */
static VALUE
pg_coder_needs_quotation_set(VALUE self, VALUE needs_quotation)
{
	t_pg_composite_coder *this = DATA_PTR(self);
	this->needs_quotation = RTEST(needs_quotation);
	return needs_quotation;
}

/*
 * call-seq:
 *    coder.needs_quotation -> Boolean
 *
 * Specifies whether the assigned #elements_type requires quotation marks to
 * be transferred safely.
 */
static VALUE
pg_coder_needs_quotation_get(VALUE self)
{
	t_pg_composite_coder *this = DATA_PTR(self);
	return this->needs_quotation ? Qtrue : Qfalse;
}

/*
 * call-seq:
 *    coder.delimiter = String
 *
 * Specifies the character that separates values within the composite type.
 * The default is a comma.
 * This must be a single one-byte character.
 */
static VALUE
pg_coder_delimiter_set(VALUE self, VALUE delimiter)
{
	t_pg_composite_coder *this = DATA_PTR(self);
	StringValue(delimiter);
	if(RSTRING_LEN(delimiter) != 1)
		rb_raise( rb_eArgError, "delimiter size must be one byte");
	this->delimiter = *RSTRING_PTR(delimiter);
	return delimiter;
}

/*
 * call-seq:
 *    coder.delimiter -> String
 *
 * The character that separates values within the composite type.
 */
static VALUE
pg_coder_delimiter_get(VALUE self)
{
	t_pg_composite_coder *this = DATA_PTR(self);
	return rb_str_new(&this->delimiter, 1);
}

/*
 * call-seq:
 *    coder.elements_type = coder
 *
 * Specifies the PG::Coder object that is used to encode or decode
 * the single elementes of this composite type.
 *
 * If set to +nil+ all values are encoded and decoded as String objects.
 */
static VALUE
pg_coder_elements_type_set(VALUE self, VALUE elem_type)
{
	t_pg_composite_coder *this = DATA_PTR( self );

	if ( NIL_P(elem_type) ){
		this->elem = NULL;
	} else if ( rb_obj_is_kind_of(elem_type, rb_cPG_Coder) ){
		this->elem = DATA_PTR( elem_type );
	} else {
		rb_raise( rb_eTypeError, "wrong elements type %s (expected some kind of PG::Coder)",
				rb_obj_classname( elem_type ) );
	}

	rb_iv_set( self, "@elements_type", elem_type );
	return elem_type;
}

void
pg_define_coder( const char *name, void *func, VALUE base_klass, VALUE nsp )
{
	VALUE cfunc_obj = Data_Wrap_Struct( rb_cObject, NULL, NULL, func );
	VALUE coder_klass = rb_define_class_under( nsp, name, base_klass );
	if( nsp==rb_mPG_BinaryEncoder || nsp==rb_mPG_BinaryDecoder )
		rb_include_module( coder_klass, rb_mPG_BinaryFormatting );

	rb_define_const( coder_klass, "CFUNC", cfunc_obj );

	RB_GC_GUARD(cfunc_obj);
}


static int
pg_text_enc_in_ruby(t_pg_coder *conv, VALUE value, char *out, VALUE *intermediate, int enc_idx)
{
	int arity = rb_obj_method_arity(conv->coder_obj, s_id_encode);
	if( arity == 1 ){
		VALUE out_str = rb_funcall( conv->coder_obj, s_id_encode, 1, value );
		StringValue( out_str );
		*intermediate = rb_str_export_to_enc(out_str, rb_enc_from_index(enc_idx));
	}else{
		VALUE enc = rb_enc_from_encoding(rb_enc_from_index(enc_idx));
		VALUE out_str = rb_funcall( conv->coder_obj, s_id_encode, 2, value, enc );
		StringValue( out_str );
		*intermediate = out_str;
	}
	return -1;
}

t_pg_coder_enc_func
pg_coder_enc_func(t_pg_coder *this)
{
	if( this ){
		if( this->enc_func ){
			return this->enc_func;
		}else{
			return pg_text_enc_in_ruby;
		}
	}else{
		/* no element encoder defined -> use std to_str conversion */
		return pg_coder_enc_to_s;
	}
}

static VALUE
pg_text_dec_in_ruby(t_pg_coder *this, char *val, int len, int tuple, int field, int enc_idx)
{
	VALUE string = pg_text_dec_string(this, val, len, tuple, field, enc_idx);
	return rb_funcall( this->coder_obj, s_id_decode, 3, string, INT2NUM(tuple), INT2NUM(field) );
}

static VALUE
pg_bin_dec_in_ruby(t_pg_coder *this, char *val, int len, int tuple, int field, int enc_idx)
{
	VALUE string = pg_bin_dec_bytea(this, val, len, tuple, field, enc_idx);
	return rb_funcall( this->coder_obj, s_id_decode, 3, string, INT2NUM(tuple), INT2NUM(field) );
}

t_pg_coder_dec_func
pg_coder_dec_func(t_pg_coder *this, int binary)
{
	if( this ){
		if( this->dec_func ){
			return this->dec_func;
		}else{
			return binary ? pg_bin_dec_in_ruby : pg_text_dec_in_ruby;
		}
	}else{
		/* no element decoder defined -> use std String conversion */
		return binary ? pg_bin_dec_bytea : pg_text_dec_string;
	}
}


void
init_pg_coder()
{
	s_id_encode = rb_intern("encode");
	s_id_decode = rb_intern("decode");
	s_id_CFUNC = rb_intern("CFUNC");

	/* Document-class: PG::Coder < Object
	 *
	 * This is the base class for all type cast encoder and decoder classes.
	 *
	 * It can be used for implicit type casts by a PG::TypeMap or to
	 * convert single values to/from their string representation by #encode
	 * and #decode.
	 *
	 * Ruby +nil+ values are not handled by encoders, but are always transmitted
	 * as SQL +NULL+ value. Vice versa SQL +NULL+ values are not handled by decoders,
	 * but are always returned as a +nil+ value.
	 */
	rb_cPG_Coder = rb_define_class_under( rb_mPG, "Coder", rb_cObject );
	rb_define_alloc_func( rb_cPG_Coder, pg_coder_allocate );
	rb_define_method( rb_cPG_Coder, "oid=", pg_coder_oid_set, 1 );
	rb_define_method( rb_cPG_Coder, "oid", pg_coder_oid_get, 0 );
	rb_define_method( rb_cPG_Coder, "format=", pg_coder_format_set, 1 );
	rb_define_method( rb_cPG_Coder, "format", pg_coder_format_get, 0 );
	/*
	 * Name of the coder or the corresponding data type.
	 *
	 * This accessor is only used in PG::Coder#inspect .
	 */
	rb_define_attr(   rb_cPG_Coder, "name", 1, 1 );
	rb_define_method( rb_cPG_Coder, "encode", pg_coder_encode, -1 );
	rb_define_method( rb_cPG_Coder, "decode", pg_coder_decode, -1 );

	/* Document-class: PG::SimpleCoder < PG::Coder */
	rb_cPG_SimpleCoder = rb_define_class_under( rb_mPG, "SimpleCoder", rb_cPG_Coder );

	/* Document-class: PG::SimpleEncoder < PG::SimpleCoder */
	rb_cPG_SimpleEncoder = rb_define_class_under( rb_mPG, "SimpleEncoder", rb_cPG_SimpleCoder );
	rb_define_alloc_func( rb_cPG_SimpleEncoder, pg_simple_encoder_allocate );
	/* Document-class: PG::SimpleDecoder < PG::SimpleCoder */
	rb_cPG_SimpleDecoder = rb_define_class_under( rb_mPG, "SimpleDecoder", rb_cPG_SimpleCoder );
	rb_define_alloc_func( rb_cPG_SimpleDecoder, pg_simple_decoder_allocate );

	/* Document-class: PG::CompositeCoder < PG::Coder
	 *
	 * This is the base class for all type cast classes of PostgreSQL types,
	 * that are made up of some sub type.
	 */
	rb_cPG_CompositeCoder = rb_define_class_under( rb_mPG, "CompositeCoder", rb_cPG_Coder );
	rb_define_method( rb_cPG_CompositeCoder, "elements_type=", pg_coder_elements_type_set, 1 );
	rb_define_attr( rb_cPG_CompositeCoder, "elements_type", 1, 0 );
	rb_define_method( rb_cPG_CompositeCoder, "needs_quotation=", pg_coder_needs_quotation_set, 1 );
	rb_define_method( rb_cPG_CompositeCoder, "needs_quotation?", pg_coder_needs_quotation_get, 0 );
	rb_define_method( rb_cPG_CompositeCoder, "delimiter=", pg_coder_delimiter_set, 1 );
	rb_define_method( rb_cPG_CompositeCoder, "delimiter", pg_coder_delimiter_get, 0 );

	/* Document-class: PG::CompositeEncoder < PG::CompositeCoder */
	rb_cPG_CompositeEncoder = rb_define_class_under( rb_mPG, "CompositeEncoder", rb_cPG_CompositeCoder );
	rb_define_alloc_func( rb_cPG_CompositeEncoder, pg_composite_encoder_allocate );
	/* Document-class: PG::CompositeDecoder < PG::CompositeCoder */
	rb_cPG_CompositeDecoder = rb_define_class_under( rb_mPG, "CompositeDecoder", rb_cPG_CompositeCoder );
	rb_define_alloc_func( rb_cPG_CompositeDecoder, pg_composite_decoder_allocate );

	rb_mPG_BinaryFormatting = rb_define_module_under( rb_cPG_Coder, "BinaryFormatting");
}

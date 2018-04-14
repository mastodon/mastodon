/*
 * pg_type_map_by_mri_type.c - PG::TypeMapByMriType class extension
 * $Id: pg_type_map_by_mri_type.c,v 1269b8ad77b8 2015/02/06 16:38:23 lars $
 *
 * This type map can be used to select value encoders based on the MRI-internal
 * value type code.
 *
 */

#include "pg.h"

static VALUE rb_cTypeMapByMriType;

#define FOR_EACH_MRI_TYPE(func) \
	func(T_FIXNUM) \
	func(T_TRUE) \
	func(T_FALSE) \
	func(T_FLOAT) \
	func(T_BIGNUM) \
	func(T_COMPLEX) \
	func(T_RATIONAL) \
	func(T_ARRAY) \
	func(T_STRING) \
	func(T_SYMBOL) \
	func(T_OBJECT) \
	func(T_CLASS) \
	func(T_MODULE) \
	func(T_REGEXP) \
	func(T_HASH) \
	func(T_STRUCT) \
	func(T_FILE) \
	func(T_DATA)

#define DECLARE_CODER(type) \
	t_pg_coder *coder_##type; \
	VALUE ask_##type; \
	VALUE coder_obj_##type;

typedef struct {
	t_typemap typemap;
	struct pg_tmbmt_converter {
		FOR_EACH_MRI_TYPE( DECLARE_CODER )
	} coders;
} t_tmbmt;


#define CASE_AND_GET(type) \
	case type: \
		p_coder = this->coders.coder_##type; \
		ask_for_coder = this->coders.ask_##type; \
		break;

static t_pg_coder *
pg_tmbmt_typecast_query_param( t_typemap *p_typemap, VALUE param_value, int field )
{
	t_tmbmt *this = (t_tmbmt *)p_typemap;
	t_pg_coder *p_coder;
	VALUE ask_for_coder;

	switch(TYPE(param_value)){
			FOR_EACH_MRI_TYPE( CASE_AND_GET )
		default:
			/* unknown MRI type */
			p_coder = NULL;
			ask_for_coder = Qnil;
	}

	if( !NIL_P(ask_for_coder) ){
		/* No static Coder object, but proc/method given to ask for the Coder to use. */
		VALUE obj;

		obj = rb_funcall(ask_for_coder, rb_intern("call"), 1, param_value);

		if( rb_obj_is_kind_of(obj, rb_cPG_Coder) ){
			Data_Get_Struct(obj, t_pg_coder, p_coder);
		}else{
			rb_raise(rb_eTypeError, "argument %d has invalid type %s (should be nil or some kind of PG::Coder)",
						field+1, rb_obj_classname( obj ));
		}
	}

	if( !p_coder ){
		t_typemap *default_tm = DATA_PTR( this->typemap.default_typemap );
		return default_tm->funcs.typecast_query_param( default_tm, param_value, field );
	}

	return p_coder;
}

static VALUE
pg_tmbmt_fit_to_query( VALUE self, VALUE params )
{
	t_tmbmt *this = (t_tmbmt *)DATA_PTR(self);
	/* Nothing to check at this typemap, but ensure that the default type map fits. */
	t_typemap *default_tm = DATA_PTR( this->typemap.default_typemap );
	default_tm->funcs.fit_to_query( this->typemap.default_typemap, params );
	return self;
}

#define GC_MARK_AS_USED(type) \
	rb_gc_mark( this->coders.ask_##type ); \
	rb_gc_mark( this->coders.coder_obj_##type );

static void
pg_tmbmt_mark( t_tmbmt *this )
{
	rb_gc_mark(this->typemap.default_typemap);
	FOR_EACH_MRI_TYPE( GC_MARK_AS_USED );
}

#define INIT_VARIABLES(type) \
	this->coders.coder_##type = NULL; \
	this->coders.ask_##type = Qnil; \
	this->coders.coder_obj_##type = Qnil;

static VALUE
pg_tmbmt_s_allocate( VALUE klass )
{
	t_tmbmt *this;
	VALUE self;

	self = Data_Make_Struct( klass, t_tmbmt, pg_tmbmt_mark, -1, this );
	this->typemap.funcs.fit_to_result = pg_typemap_fit_to_result;
	this->typemap.funcs.fit_to_query = pg_tmbmt_fit_to_query;
	this->typemap.funcs.fit_to_copy_get = pg_typemap_fit_to_copy_get;
	this->typemap.funcs.typecast_result_value = pg_typemap_result_value;
	this->typemap.funcs.typecast_query_param = pg_tmbmt_typecast_query_param;
	this->typemap.funcs.typecast_copy_get = pg_typemap_typecast_copy_get;
	this->typemap.default_typemap = pg_typemap_all_strings;

	FOR_EACH_MRI_TYPE( INIT_VARIABLES );

	return self;
}

#define COMPARE_AND_ASSIGN(type) \
	else if(!strcmp(p_mri_type, #type)){ \
		this->coders.coder_obj_##type = coder; \
		if(NIL_P(coder)){ \
			this->coders.coder_##type = NULL; \
			this->coders.ask_##type = Qnil; \
		}else if(rb_obj_is_kind_of(coder, rb_cPG_Coder)){ \
			Data_Get_Struct(coder, t_pg_coder, this->coders.coder_##type); \
			this->coders.ask_##type = Qnil; \
		}else if(RB_TYPE_P(coder, T_SYMBOL)){ \
			this->coders.coder_##type = NULL; \
			this->coders.ask_##type = rb_obj_method( self, coder ); \
		}else{ \
			this->coders.coder_##type = NULL; \
			this->coders.ask_##type = coder; \
		} \
	}

/*
 * call-seq:
 *    typemap.[mri_type] = coder
 *
 * Assigns a new PG::Coder object to the type map. The encoder
 * is registered for type casts of the given +mri_type+ .
 *
 * +coder+ can be one of the following:
 * * +nil+        - Values are forwarded to the #default_type_map .
 * * a PG::Coder  - Values are encoded by the given encoder
 * * a Symbol     - The method of this type map (or a derivation) that is called for each value to sent.
 *   It must return a PG::Coder.
 * * a Proc       - The Proc object is called for each value. It must return a PG::Coder.
 *
 * +mri_type+ must be one of the following strings:
 * * +T_FIXNUM+
 * * +T_TRUE+
 * * +T_FALSE+
 * * +T_FLOAT+
 * * +T_BIGNUM+
 * * +T_COMPLEX+
 * * +T_RATIONAL+
 * * +T_ARRAY+
 * * +T_STRING+
 * * +T_SYMBOL+
 * * +T_OBJECT+
 * * +T_CLASS+
 * * +T_MODULE+
 * * +T_REGEXP+
 * * +T_HASH+
 * * +T_STRUCT+
 * * +T_FILE+
 * * +T_DATA+
 */
static VALUE
pg_tmbmt_aset( VALUE self, VALUE mri_type, VALUE coder )
{
	t_tmbmt *this = DATA_PTR( self );
	char *p_mri_type;

	p_mri_type = StringValueCStr(mri_type);

	if(0){}
	FOR_EACH_MRI_TYPE( COMPARE_AND_ASSIGN )
	else{
		VALUE mri_type_inspect = rb_inspect( mri_type );
		rb_raise(rb_eArgError, "unknown mri_type %s", StringValueCStr(mri_type_inspect));
	}

	return self;
}

#define COMPARE_AND_GET(type) \
	else if(!strcmp(p_mri_type, #type)){ \
		coder = this->coders.coder_obj_##type; \
	}

/*
 * call-seq:
 *    typemap.[mri_type] -> coder
 *
 * Returns the encoder object for the given +mri_type+
 *
 * See #[]= for allowed +mri_type+ .
 */
static VALUE
pg_tmbmt_aref( VALUE self, VALUE mri_type )
{
	VALUE coder;
	t_tmbmt *this = DATA_PTR( self );
	char *p_mri_type;

	p_mri_type = StringValueCStr(mri_type);

	if(0){}
	FOR_EACH_MRI_TYPE( COMPARE_AND_GET )
	else{
		VALUE mri_type_inspect = rb_inspect( mri_type );
		rb_raise(rb_eArgError, "unknown mri_type %s", StringValueCStr(mri_type_inspect));
	}

	return coder;
}

#define ADD_TO_HASH(type) \
	rb_hash_aset( hash_coders, rb_obj_freeze(rb_str_new2(#type)), this->coders.coder_obj_##type );


/*
 * call-seq:
 *    typemap.coders -> Hash
 *
 * Returns all mri types and their assigned encoder object.
 */
static VALUE
pg_tmbmt_coders( VALUE self )
{
	t_tmbmt *this = DATA_PTR( self );
	VALUE hash_coders = rb_hash_new();

	FOR_EACH_MRI_TYPE( ADD_TO_HASH );

	return rb_obj_freeze(hash_coders);
}

void
init_pg_type_map_by_mri_type()
{
	/*
	 * Document-class: PG::TypeMapByMriType < PG::TypeMap
	 *
	 * This type map casts values based on the Ruby object type code of the given value
	 * to be sent.
	 *
	 * This type map is usable for type casting query bind parameters and COPY data
	 * for PG::Connection#put_copy_data . Therefore only encoders might be assigned by
	 * the #[]= method.
	 *
	 * _Note_ : This type map is not portable across Ruby implementations and is less flexible
	 * than PG::TypeMapByClass.
	 * It is kept only for performance comparisons, but PG::TypeMapByClass proved to be equally
	 * fast in almost all cases.
	 *
	 */
	rb_cTypeMapByMriType = rb_define_class_under( rb_mPG, "TypeMapByMriType", rb_cTypeMap );
	rb_define_alloc_func( rb_cTypeMapByMriType, pg_tmbmt_s_allocate );
	rb_define_method( rb_cTypeMapByMriType, "[]=", pg_tmbmt_aset, 2 );
	rb_define_method( rb_cTypeMapByMriType, "[]", pg_tmbmt_aref, 1 );
	rb_define_method( rb_cTypeMapByMriType, "coders", pg_tmbmt_coders, 0 );
	rb_include_module( rb_cTypeMapByMriType, rb_mDefaultTypeMappable );
}

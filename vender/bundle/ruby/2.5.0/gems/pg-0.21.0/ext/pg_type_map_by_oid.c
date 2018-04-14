/*
 * pg_type_map_by_oid.c - PG::TypeMapByOid class extension
 * $Id: pg_type_map_by_oid.c,v c99d26015e3c 2014/12/12 20:58:25 lars $
 *
 */

#include "pg.h"

static VALUE rb_cTypeMapByOid;
static ID s_id_decode;

typedef struct {
	t_typemap typemap;
	int max_rows_for_online_lookup;

	struct pg_tmbo_converter {
		VALUE oid_to_coder;

		struct pg_tmbo_oid_cache_entry {
			Oid oid;
			t_pg_coder *p_coder;
		} cache_row[0x100];
	} format[2];
} t_tmbo;

static VALUE pg_tmbo_s_allocate( VALUE klass );


/*
 * We use the OID's minor 8 Bits as index to a 256 entry cache. This avoids full ruby hash lookups
 * for each value in most cases.
 */
#define CACHE_LOOKUP(this, form, oid) ( &this->format[(form)].cache_row[(oid) & 0xff] )

static t_pg_coder *
pg_tmbo_lookup_oid(t_tmbo *this, int format, Oid oid)
{
	t_pg_coder *conv;
	struct pg_tmbo_oid_cache_entry *p_ce;

	p_ce = CACHE_LOOKUP(this, format, oid);

	/* Has the entry the expected OID and is it a non empty entry? */
	if( p_ce->oid == oid && (oid || p_ce->p_coder) ) {
		conv = p_ce->p_coder;
	} else {
		VALUE obj = rb_hash_lookup( this->format[format].oid_to_coder, UINT2NUM( oid ));
		/* obj must be nil or some kind of PG::Coder, this is checked at insertion */
		conv = NIL_P(obj) ? NULL : DATA_PTR(obj);
		/* Write the retrieved coder to the cache */
		p_ce->oid = oid;
		p_ce->p_coder = conv;
	}
	return conv;
}

/* Build a TypeMapByColumn that fits to the given result */
static VALUE
pg_tmbo_build_type_map_for_result2( t_tmbo *this, PGresult *pgresult )
{
	t_tmbc *p_colmap;
	int i;
	VALUE colmap;
	int nfields = PQnfields( pgresult );

	p_colmap = xmalloc(sizeof(t_tmbc) + sizeof(struct pg_tmbc_converter) * nfields);
	/* Set nfields to 0 at first, so that GC mark function doesn't access uninitialized memory. */
	p_colmap->nfields = 0;
	p_colmap->typemap.funcs = pg_tmbc_funcs;
	p_colmap->typemap.default_typemap = pg_typemap_all_strings;

	colmap = pg_tmbc_allocate();
	DATA_PTR(colmap) = p_colmap;

	for(i=0; i<nfields; i++)
	{
		int format = PQfformat(pgresult, i);

		if( format < 0 || format > 1 )
			rb_raise(rb_eArgError, "result field %d has unsupported format code %d", i+1, format);

		p_colmap->convs[i].cconv = pg_tmbo_lookup_oid( this, format, PQftype(pgresult, i) );
	}

	p_colmap->nfields = nfields;

	return colmap;
}

static VALUE
pg_tmbo_result_value(t_typemap *p_typemap, VALUE result, int tuple, int field)
{
	int format;
	t_pg_coder *p_coder;
	t_pg_result *p_result = pgresult_get_this(result);
	t_tmbo *this = (t_tmbo*) p_typemap;
	t_typemap *default_tm;

	if (PQgetisnull(p_result->pgresult, tuple, field)) {
		return Qnil;
	}

	format = PQfformat( p_result->pgresult, field );

	if( format < 0 || format > 1 )
		rb_raise(rb_eArgError, "result field %d has unsupported format code %d", field+1, format);

	p_coder = pg_tmbo_lookup_oid( this, format, PQftype(p_result->pgresult, field) );
	if( p_coder ){
		char * val = PQgetvalue( p_result->pgresult, tuple, field );
		int len = PQgetlength( p_result->pgresult, tuple, field );
		t_pg_coder_dec_func dec_func = pg_coder_dec_func( p_coder, format );
		return dec_func( p_coder, val, len, tuple, field, ENCODING_GET(result) );
	}

	default_tm = DATA_PTR( this->typemap.default_typemap );
	return default_tm->funcs.typecast_result_value( default_tm, result, tuple, field );
}

static VALUE
pg_tmbo_fit_to_result( VALUE self, VALUE result )
{
	t_tmbo *this = DATA_PTR( self );
	PGresult *pgresult = pgresult_get( result );

	/* Ensure that the default type map fits equaly. */
	t_typemap *default_tm = DATA_PTR( this->typemap.default_typemap );
	VALUE sub_typemap = default_tm->funcs.fit_to_result( this->typemap.default_typemap, result );

	if( PQntuples( pgresult ) <= this->max_rows_for_online_lookup ){
		/* Do a hash lookup for each result value in pg_tmbc_result_value() */

		/* Did the default type return the same object ? */
		if( sub_typemap == this->typemap.default_typemap ){
			return self;
		} else {
			/* The default type map built a new object, so we need to propagate it
			 * and build a copy of this type map. */
			VALUE new_typemap = pg_tmbo_s_allocate( rb_cTypeMapByOid );
			t_tmbo *p_new_typemap = DATA_PTR(new_typemap);
			*p_new_typemap = *this;
			p_new_typemap->typemap.default_typemap = sub_typemap;
			return new_typemap;
		}
	}else{
		/* Build a new TypeMapByColumn that fits to the given result and
		 * uses a fast array lookup.
		 */
		VALUE new_typemap = pg_tmbo_build_type_map_for_result2( this, pgresult );
		t_tmbo *p_new_typemap = DATA_PTR(new_typemap);
		p_new_typemap->typemap.default_typemap = sub_typemap;
		return new_typemap;
	}
}

static void
pg_tmbo_mark( t_tmbo *this )
{
	int i;

	rb_gc_mark(this->typemap.default_typemap);
	for( i=0; i<2; i++){
		rb_gc_mark(this->format[i].oid_to_coder);
	}
}

static VALUE
pg_tmbo_s_allocate( VALUE klass )
{
	t_tmbo *this;
	VALUE self;
	int i;

	self = Data_Make_Struct( klass, t_tmbo, pg_tmbo_mark, -1, this );

	this->typemap.funcs.fit_to_result = pg_tmbo_fit_to_result;
	this->typemap.funcs.fit_to_query = pg_typemap_fit_to_query;
	this->typemap.funcs.fit_to_copy_get = pg_typemap_fit_to_copy_get;
	this->typemap.funcs.typecast_result_value = pg_tmbo_result_value;
	this->typemap.funcs.typecast_query_param = pg_typemap_typecast_query_param;
	this->typemap.funcs.typecast_copy_get = pg_typemap_typecast_copy_get;
	this->typemap.default_typemap = pg_typemap_all_strings;
	this->max_rows_for_online_lookup = 10;

	for( i=0; i<2; i++){
		this->format[i].oid_to_coder = rb_hash_new();
	}

	return self;
}

/*
 * call-seq:
 *    typemap.add_coder( coder )
 *
 * Assigns a new PG::Coder object to the type map. The decoder
 * is registered for type casts based on it's PG::Coder#oid and
 * PG::Coder#format attributes.
 *
 * Later changes of the oid or format code within the coder object
 * will have no effect to the type map.
 *
 */
static VALUE
pg_tmbo_add_coder( VALUE self, VALUE coder )
{
	VALUE hash;
	t_tmbo *this = DATA_PTR( self );
	t_pg_coder *p_coder;
	struct pg_tmbo_oid_cache_entry *p_ce;

	if( !rb_obj_is_kind_of(coder, rb_cPG_Coder) )
		rb_raise(rb_eArgError, "invalid type %s (should be some kind of PG::Coder)",
							rb_obj_classname( coder ));

	Data_Get_Struct(coder, t_pg_coder, p_coder);

	if( p_coder->format < 0 || p_coder->format > 1 )
		rb_raise(rb_eArgError, "invalid format code %d", p_coder->format);

	/* Update cache entry */
	p_ce = CACHE_LOOKUP(this, p_coder->format, p_coder->oid);
	p_ce->oid = p_coder->oid;
	p_ce->p_coder = p_coder;
	/* Write coder into the hash of the given format */
	hash = this->format[p_coder->format].oid_to_coder;
	rb_hash_aset( hash, UINT2NUM(p_coder->oid), coder);

	return self;
}

/*
 * call-seq:
 *    typemap.rm_coder( format, oid )
 *
 * Removes a PG::Coder object from the type map based on the given
 * oid and format codes.
 *
 * Returns the removed coder object.
 */
static VALUE
pg_tmbo_rm_coder( VALUE self, VALUE format, VALUE oid )
{
	VALUE hash;
	VALUE coder;
	t_tmbo *this = DATA_PTR( self );
	int i_format = NUM2INT(format);
	struct pg_tmbo_oid_cache_entry *p_ce;

	if( i_format < 0 || i_format > 1 )
		rb_raise(rb_eArgError, "invalid format code %d", i_format);

	/* Mark the cache entry as empty */
	p_ce = CACHE_LOOKUP(this, i_format, NUM2UINT(oid));
	p_ce->oid = 0;
	p_ce->p_coder = NULL;
	hash = this->format[i_format].oid_to_coder;
	coder = rb_hash_delete( hash, oid );

	return coder;
}

/*
 * call-seq:
 *    typemap.coders -> Array
 *
 * Array of all assigned PG::Coder objects.
 */
static VALUE
pg_tmbo_coders( VALUE self )
{
	t_tmbo *this = DATA_PTR( self );

	return rb_ary_concat(
			rb_funcall(this->format[0].oid_to_coder, rb_intern("values"), 0),
			rb_funcall(this->format[1].oid_to_coder, rb_intern("values"), 0));
}

/*
 * call-seq:
 *    typemap.max_rows_for_online_lookup = number
 *
 * Threshold for doing Hash lookups versus creation of a dedicated PG::TypeMapByColumn.
 * The type map will do Hash lookups for each result value, if the number of rows
 * is below or equal +number+.
 *
 */
static VALUE
pg_tmbo_max_rows_for_online_lookup_set( VALUE self, VALUE value )
{
	t_tmbo *this = DATA_PTR( self );
	this->max_rows_for_online_lookup = NUM2INT(value);
	return value;
}

/*
 * call-seq:
 *    typemap.max_rows_for_online_lookup -> Integer
 */
static VALUE
pg_tmbo_max_rows_for_online_lookup_get( VALUE self )
{
	t_tmbo *this = DATA_PTR( self );
	return INT2NUM(this->max_rows_for_online_lookup);
}

/*
 * call-seq:
 *    typemap.build_column_map( result )
 *
 * This builds a PG::TypeMapByColumn that fits to the given PG::Result object
 * based on it's type OIDs.
 *
 */
static VALUE
pg_tmbo_build_column_map( VALUE self, VALUE result )
{
	t_tmbo *this = DATA_PTR( self );

	if ( !rb_obj_is_kind_of(result, rb_cPGresult) ) {
		rb_raise( rb_eTypeError, "wrong argument type %s (expected kind of PG::Result)",
				rb_obj_classname( result ) );
	}

	return pg_tmbo_build_type_map_for_result2( this, pgresult_get(result) );
}


void
init_pg_type_map_by_oid()
{
	s_id_decode = rb_intern("decode");

	/*
	 * Document-class: PG::TypeMapByOid < PG::TypeMap
	 *
	 * This type map casts values based on the type OID of the given column
	 * in the result set.
	 *
	 * This type map is only suitable to cast values from PG::Result objects.
	 * Therefore only decoders might be assigned by the #add_coder method.
	 *
	 * Fields with no match to any of the registered type OID / format combination
	 * are forwarded to the #default_type_map .
	 */
	rb_cTypeMapByOid = rb_define_class_under( rb_mPG, "TypeMapByOid", rb_cTypeMap );
	rb_define_alloc_func( rb_cTypeMapByOid, pg_tmbo_s_allocate );
	rb_define_method( rb_cTypeMapByOid, "add_coder", pg_tmbo_add_coder, 1 );
	rb_define_method( rb_cTypeMapByOid, "rm_coder", pg_tmbo_rm_coder, 2 );
	rb_define_method( rb_cTypeMapByOid, "coders", pg_tmbo_coders, 0 );
	rb_define_method( rb_cTypeMapByOid, "max_rows_for_online_lookup=", pg_tmbo_max_rows_for_online_lookup_set, 1 );
	rb_define_method( rb_cTypeMapByOid, "max_rows_for_online_lookup", pg_tmbo_max_rows_for_online_lookup_get, 0 );
	rb_define_method( rb_cTypeMapByOid, "build_column_map", pg_tmbo_build_column_map, 1 );
	rb_include_module( rb_cTypeMapByOid, rb_mDefaultTypeMappable );
}

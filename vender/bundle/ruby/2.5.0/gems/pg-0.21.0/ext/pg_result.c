/*
 * pg_result.c - PG::Result class extension
 * $Id: pg_result.c,v c4a1abc36c47 2017/06/02 01:00:09 ged $
 *
 */

#include "pg.h"


VALUE rb_cPGresult;

static void pgresult_gc_free( t_pg_result * );
static VALUE pgresult_type_map_set( VALUE, VALUE );
static VALUE pgresult_s_allocate( VALUE );
static t_pg_result *pgresult_get_this( VALUE );
static t_pg_result *pgresult_get_this_safe( VALUE );



/*
 * Global functions
 */

/*
 * Result constructor
 */
VALUE
pg_new_result(PGresult *result, VALUE rb_pgconn)
{
	int nfields = result ? PQnfields(result) : 0;
	VALUE self = pgresult_s_allocate( rb_cPGresult );
	t_pg_result *this;

	this = (t_pg_result *)xmalloc(sizeof(*this) +  sizeof(*this->fnames) * nfields);
	DATA_PTR(self) = this;

	this->pgresult = result;
	this->connection = rb_pgconn;
	this->typemap = pg_typemap_all_strings;
	this->p_typemap = DATA_PTR( this->typemap );
	this->autoclear = 0;
	this->nfields = -1;
	this->tuple_hash = Qnil;

	PG_ENCODING_SET_NOCHECK(self, ENCODING_GET(rb_pgconn));

	if( result ){
		t_pg_connection *p_conn = pg_get_connection(rb_pgconn);
		VALUE typemap = p_conn->type_map_for_results;

		/* Type check is done when assigned to PG::Connection. */
		t_typemap *p_typemap = DATA_PTR(typemap);

		this->typemap = p_typemap->funcs.fit_to_result( typemap, self );
		this->p_typemap = DATA_PTR( this->typemap );
	}

	return self;
}

VALUE
pg_new_result_autoclear(PGresult *result, VALUE rb_pgconn)
{
	VALUE self = pg_new_result(result, rb_pgconn);
	t_pg_result *this = pgresult_get_this(self);
	this->autoclear = 1;
	return self;
}

/*
 * call-seq:
 *    res.check -> nil
 *
 * Raises appropriate exception if PG::Result is in a bad state.
 */
VALUE
pg_result_check( VALUE self )
{
	t_pg_result *this = pgresult_get_this(self);
	VALUE error, exception, klass;
	char * sqlstate;

	if(this->pgresult == NULL)
	{
		PGconn *conn = pg_get_pgconn(this->connection);
		error = rb_str_new2( PQerrorMessage(conn) );
	}
	else
	{
		switch (PQresultStatus(this->pgresult))
		{
		case PGRES_TUPLES_OK:
		case PGRES_COPY_OUT:
		case PGRES_COPY_IN:
#ifdef HAVE_CONST_PGRES_COPY_BOTH
		case PGRES_COPY_BOTH:
#endif
#ifdef HAVE_CONST_PGRES_SINGLE_TUPLE
		case PGRES_SINGLE_TUPLE:
#endif
		case PGRES_EMPTY_QUERY:
		case PGRES_COMMAND_OK:
			return self;
		case PGRES_BAD_RESPONSE:
		case PGRES_FATAL_ERROR:
		case PGRES_NONFATAL_ERROR:
			error = rb_str_new2( PQresultErrorMessage(this->pgresult) );
			break;
		default:
			error = rb_str_new2( "internal error : unknown result status." );
		}
	}

	PG_ENCODING_SET_NOCHECK( error, ENCODING_GET(self) );

	sqlstate = PQresultErrorField( this->pgresult, PG_DIAG_SQLSTATE );
	klass = lookup_error_class( sqlstate );
	exception = rb_exc_new3( klass, error );
	rb_iv_set( exception, "@connection", this->connection );
	rb_iv_set( exception, "@result", this->pgresult ? self : Qnil );
	rb_exc_raise( exception );

	/* Not reached */
	return self;
}


/*
 * :TODO: This shouldn't be a global function, but it needs to be as long as pg_new_result
 * doesn't handle blocks, check results, etc. Once connection and result are disentangled
 * a bit more, I can make this a static pgresult_clear() again.
 */

/*
 * call-seq:
 *    res.clear() -> nil
 *
 * Clears the PG::Result object as the result of the query.
 *
 * If PG::Result#autoclear? is true then the result is marked as cleared
 * and the underlying C struct will be cleared automatically by libpq.
 *
 */
VALUE
pg_result_clear(VALUE self)
{
	t_pg_result *this = pgresult_get_this(self);
	if( !this->autoclear )
		PQclear(pgresult_get(self));
	this->pgresult = NULL;
	return Qnil;
}

/*
 * call-seq:
 *    res.cleared?      -> boolean
 *
 * Returns +true+ if the backend result memory has been free'd.
 */
VALUE
pgresult_cleared_p( VALUE self )
{
	t_pg_result *this = pgresult_get_this(self);
	return this->pgresult ? Qfalse : Qtrue;
}

/*
 * call-seq:
 *    res.autoclear?      -> boolean
 *
 * Returns +true+ if the underlying C struct will be cleared automatically by libpq.
 * Elsewise the result is cleared by PG::Result#clear or by the GC when it's no longer in use.
 *
 */
VALUE
pgresult_autoclear_p( VALUE self )
{
	t_pg_result *this = pgresult_get_this(self);
	return this->autoclear ? Qtrue : Qfalse;
}

/*
 * DATA pointer functions
 */

/*
 * GC Mark function
 */
static void
pgresult_gc_mark( t_pg_result *this )
{
	int i;

	if( !this ) return;
	rb_gc_mark( this->connection );
	rb_gc_mark( this->typemap );
	rb_gc_mark( this->tuple_hash );

	for( i=0; i < this->nfields; i++ ){
		rb_gc_mark( this->fnames[i] );
	}
}

/*
 * GC Free function
 */
static void
pgresult_gc_free( t_pg_result *this )
{
	if( !this ) return;
	if(this->pgresult != NULL && !this->autoclear)
		PQclear(this->pgresult);

	xfree(this);
}

/*
 * Fetch the PG::Result object data pointer and check it's
 * PGresult data pointer for sanity.
 */
static t_pg_result *
pgresult_get_this_safe( VALUE self )
{
	t_pg_result *this = pgresult_get_this(self);

	if (this->pgresult == NULL) rb_raise(rb_ePGerror, "result has been cleared");
	return this;
}

/*
 * Fetch the PGresult pointer for the result object and check validity
 *
 * Note: This function is used externally by the sequel_pg gem,
 * so do changes carefully.
 *
 */
PGresult*
pgresult_get(VALUE self)
{
	t_pg_result *this = pgresult_get_this(self);

	if (this->pgresult == NULL) rb_raise(rb_ePGerror, "result has been cleared");
	return this->pgresult;
}

/*
 * Document-method: allocate
 *
 * call-seq:
 *   PG::Result.allocate -> result
 */
static VALUE
pgresult_s_allocate( VALUE klass )
{
	VALUE self = Data_Wrap_Struct( klass, pgresult_gc_mark, pgresult_gc_free, NULL );

	return self;
}

static void pgresult_init_fnames(VALUE self)
{
	t_pg_result *this = pgresult_get_this_safe(self);

	if( this->nfields == -1 ){
		int i;
		int nfields = PQnfields(this->pgresult);

		for( i=0; i<nfields; i++ ){
			VALUE fname = rb_tainted_str_new2(PQfname(this->pgresult, i));
			PG_ENCODING_SET_NOCHECK(fname, ENCODING_GET(self));
			this->fnames[i] = rb_obj_freeze(fname);
			this->nfields = i + 1;

			RB_GC_GUARD(fname);
		}
		this->nfields = nfields;
	}
}

/********************************************************************
 *
 * Document-class: PG::Result
 *
 * The class to represent the query result tuples (rows).
 * An instance of this class is created as the result of every query.
 * You may need to invoke the #clear method of the instance when finished with
 * the result for better memory performance.
 *
 * Example:
 *    require 'pg'
 *    conn = PG.connect(:dbname => 'test')
 *    res  = conn.exec('SELECT 1 AS a, 2 AS b, NULL AS c')
 *    res.getvalue(0,0) # '1'
 *    res[0]['b']       # '2'
 *    res[0]['c']       # nil
 *
 */

/**************************************************************************
 * PG::Result INSTANCE METHODS
 **************************************************************************/

/*
 * call-seq:
 *    res.result_status() -> Integer
 *
 * Returns the status of the query. The status value is one of:
 * * +PGRES_EMPTY_QUERY+
 * * +PGRES_COMMAND_OK+
 * * +PGRES_TUPLES_OK+
 * * +PGRES_COPY_OUT+
 * * +PGRES_COPY_IN+
 * * +PGRES_BAD_RESPONSE+
 * * +PGRES_NONFATAL_ERROR+
 * * +PGRES_FATAL_ERROR+
 * * +PGRES_COPY_BOTH+
 */
static VALUE
pgresult_result_status(VALUE self)
{
	return INT2FIX(PQresultStatus(pgresult_get(self)));
}

/*
 * call-seq:
 *    res.res_status( status ) -> String
 *
 * Returns the string representation of status +status+.
 *
*/
static VALUE
pgresult_res_status(VALUE self, VALUE status)
{
	VALUE ret = rb_tainted_str_new2(PQresStatus(NUM2INT(status)));
	PG_ENCODING_SET_NOCHECK(ret, ENCODING_GET(self));
	return ret;
}

/*
 * call-seq:
 *    res.error_message() -> String
 *
 * Returns the error message of the command as a string.
 */
static VALUE
pgresult_error_message(VALUE self)
{
	VALUE ret = rb_tainted_str_new2(PQresultErrorMessage(pgresult_get(self)));
	PG_ENCODING_SET_NOCHECK(ret, ENCODING_GET(self));
	return ret;
}

/*
 * call-seq:
 *    res.error_field(fieldcode) -> String
 *
 * Returns the individual field of an error.
 *
 * +fieldcode+ is one of:
 * * +PG_DIAG_SEVERITY+
 * * +PG_DIAG_SQLSTATE+
 * * +PG_DIAG_MESSAGE_PRIMARY+
 * * +PG_DIAG_MESSAGE_DETAIL+
 * * +PG_DIAG_MESSAGE_HINT+
 * * +PG_DIAG_STATEMENT_POSITION+
 * * +PG_DIAG_INTERNAL_POSITION+
 * * +PG_DIAG_INTERNAL_QUERY+
 * * +PG_DIAG_CONTEXT+
 * * +PG_DIAG_SOURCE_FILE+
 * * +PG_DIAG_SOURCE_LINE+
 * * +PG_DIAG_SOURCE_FUNCTION+
 *
 * An example:
 *
 *   begin
 *       conn.exec( "SELECT * FROM nonexistant_table" )
 *   rescue PG::Error => err
 *       p [
 *           err.result.error_field( PG::Result::PG_DIAG_SEVERITY ),
 *           err.result.error_field( PG::Result::PG_DIAG_SQLSTATE ),
 *           err.result.error_field( PG::Result::PG_DIAG_MESSAGE_PRIMARY ),
 *           err.result.error_field( PG::Result::PG_DIAG_MESSAGE_DETAIL ),
 *           err.result.error_field( PG::Result::PG_DIAG_MESSAGE_HINT ),
 *           err.result.error_field( PG::Result::PG_DIAG_STATEMENT_POSITION ),
 *           err.result.error_field( PG::Result::PG_DIAG_INTERNAL_POSITION ),
 *           err.result.error_field( PG::Result::PG_DIAG_INTERNAL_QUERY ),
 *           err.result.error_field( PG::Result::PG_DIAG_CONTEXT ),
 *           err.result.error_field( PG::Result::PG_DIAG_SOURCE_FILE ),
 *           err.result.error_field( PG::Result::PG_DIAG_SOURCE_LINE ),
 *           err.result.error_field( PG::Result::PG_DIAG_SOURCE_FUNCTION ),
 *       ]
 *   end
 *
 * Outputs:
 *
 *   ["ERROR", "42P01", "relation \"nonexistant_table\" does not exist", nil, nil,
 *    "15", nil, nil, nil, "path/to/parse_relation.c", "857", "parserOpenTable"]
 */
static VALUE
pgresult_error_field(VALUE self, VALUE field)
{
	PGresult *result = pgresult_get( self );
	int fieldcode = NUM2INT( field );
	char * fieldstr = PQresultErrorField( result, fieldcode );
	VALUE ret = Qnil;

	if ( fieldstr ) {
		ret = rb_tainted_str_new2( fieldstr );
		PG_ENCODING_SET_NOCHECK( ret, ENCODING_GET(self ));
	}

	return ret;
}

/*
 * call-seq:
 *    res.ntuples() -> Integer
 *
 * Returns the number of tuples in the query result.
 */
static VALUE
pgresult_ntuples(VALUE self)
{
	return INT2FIX(PQntuples(pgresult_get(self)));
}

static VALUE
pgresult_ntuples_for_enum(VALUE self, VALUE args, VALUE eobj)
{
    return pgresult_ntuples(self);
}

/*
 * call-seq:
 *    res.nfields() -> Integer
 *
 * Returns the number of columns in the query result.
 */
static VALUE
pgresult_nfields(VALUE self)
{
	return INT2NUM(PQnfields(pgresult_get(self)));
}

/*
 * call-seq:
 *    res.fname( index ) -> String
 *
 * Returns the name of the column corresponding to _index_.
 */
static VALUE
pgresult_fname(VALUE self, VALUE index)
{
	VALUE fname;
	PGresult *result = pgresult_get(self);
	int i = NUM2INT(index);

	if (i < 0 || i >= PQnfields(result)) {
		rb_raise(rb_eArgError,"invalid field number %d", i);
	}

	fname = rb_tainted_str_new2(PQfname(result, i));
	PG_ENCODING_SET_NOCHECK(fname, ENCODING_GET(self));
	return rb_obj_freeze(fname);
}

/*
 * call-seq:
 *    res.fnumber( name ) -> Integer
 *
 * Returns the index of the field specified by the string +name+.
 * The given +name+ is treated like an identifier in an SQL command, that is,
 * it is downcased unless double-quoted. For example, given a query result
 * generated from the SQL command:
 *
 *   result = conn.exec( %{SELECT 1 AS FOO, 2 AS "BAR"} )
 *
 * we would have the results:
 *
 *   result.fname( 0 )            # => "foo"
 *   result.fname( 1 )            # => "BAR"
 *   result.fnumber( "FOO" )      # => 0
 *   result.fnumber( "foo" )      # => 0
 *   result.fnumber( "BAR" )      # => ArgumentError
 *   result.fnumber( %{"BAR"} )   # => 1
 *
 * Raises an ArgumentError if the specified +name+ isn't one of the field names;
 * raises a TypeError if +name+ is not a String.
 */
static VALUE
pgresult_fnumber(VALUE self, VALUE name)
{
	int n;

	Check_Type(name, T_STRING);

	n = PQfnumber(pgresult_get(self), StringValueCStr(name));
	if (n == -1) {
		rb_raise(rb_eArgError,"Unknown field: %s", StringValueCStr(name));
	}
	return INT2FIX(n);
}

/*
 * call-seq:
 *    res.ftable( column_number ) -> Integer
 *
 * Returns the Oid of the table from which the column _column_number_
 * was fetched.
 *
 * Raises ArgumentError if _column_number_ is out of range or if
 * the Oid is undefined for that column.
 */
static VALUE
pgresult_ftable(VALUE self, VALUE column_number)
{
	Oid n ;
	int col_number = NUM2INT(column_number);
	PGresult *pgresult = pgresult_get(self);

	if( col_number < 0 || col_number >= PQnfields(pgresult))
		rb_raise(rb_eArgError,"Invalid column index: %d", col_number);

	n = PQftable(pgresult, col_number);
	return UINT2NUM(n);
}

/*
 * call-seq:
 *    res.ftablecol( column_number ) -> Integer
 *
 * Returns the column number (within its table) of the table from
 * which the column _column_number_ is made up.
 *
 * Raises ArgumentError if _column_number_ is out of range or if
 * the column number from its table is undefined for that column.
 */
static VALUE
pgresult_ftablecol(VALUE self, VALUE column_number)
{
	int col_number = NUM2INT(column_number);
	PGresult *pgresult = pgresult_get(self);

	int n;

	if( col_number < 0 || col_number >= PQnfields(pgresult))
		rb_raise(rb_eArgError,"Invalid column index: %d", col_number);

	n = PQftablecol(pgresult, col_number);
	return INT2FIX(n);
}

/*
 * call-seq:
 *    res.fformat( column_number ) -> Integer
 *
 * Returns the format (0 for text, 1 for binary) of column
 * _column_number_.
 *
 * Raises ArgumentError if _column_number_ is out of range.
 */
static VALUE
pgresult_fformat(VALUE self, VALUE column_number)
{
	PGresult *result = pgresult_get(self);
	int fnumber = NUM2INT(column_number);
	if (fnumber < 0 || fnumber >= PQnfields(result)) {
		rb_raise(rb_eArgError, "Column number is out of range: %d",
			fnumber);
	}
	return INT2FIX(PQfformat(result, fnumber));
}

/*
 * call-seq:
 *    res.ftype( column_number )  -> Integer
 *
 * Returns the data type associated with _column_number_.
 *
 * The integer returned is the internal +OID+ number (in PostgreSQL)
 * of the type. To get a human-readable value for the type, use the
 * returned OID and the field's #fmod value with the format_type() SQL
 * function:
 *
 *   # Get the type of the second column of the result 'res'
 *   typename = conn.
 *     exec( "SELECT format_type($1,$2)", [res.ftype(1), res.fmod(1)] ).
 *     getvalue( 0, 0 )
 *
 * Raises an ArgumentError if _column_number_ is out of range.
 */
static VALUE
pgresult_ftype(VALUE self, VALUE index)
{
	PGresult* result = pgresult_get(self);
	int i = NUM2INT(index);
	if (i < 0 || i >= PQnfields(result)) {
		rb_raise(rb_eArgError, "invalid field number %d", i);
	}
	return UINT2NUM(PQftype(result, i));
}

/*
 * call-seq:
 *    res.fmod( column_number )
 *
 * Returns the type modifier associated with column _column_number_. See
 * the #ftype method for an example of how to use this.
 *
 * Raises an ArgumentError if _column_number_ is out of range.
 */
static VALUE
pgresult_fmod(VALUE self, VALUE column_number)
{
	PGresult *result = pgresult_get(self);
	int fnumber = NUM2INT(column_number);
	int modifier;
	if (fnumber < 0 || fnumber >= PQnfields(result)) {
		rb_raise(rb_eArgError, "Column number is out of range: %d",
			fnumber);
	}
	modifier = PQfmod(result,fnumber);

	return INT2NUM(modifier);
}

/*
 * call-seq:
 *    res.fsize( index )
 *
 * Returns the size of the field type in bytes.  Returns <tt>-1</tt> if the field is variable sized.
 *
 *   res = conn.exec("SELECT myInt, myVarChar50 FROM foo")
 *   res.size(0) => 4
 *   res.size(1) => -1
 */
static VALUE
pgresult_fsize(VALUE self, VALUE index)
{
	PGresult *result;
	int i = NUM2INT(index);

	result = pgresult_get(self);
	if (i < 0 || i >= PQnfields(result)) {
		rb_raise(rb_eArgError,"invalid field number %d", i);
	}
	return INT2NUM(PQfsize(result, i));
}


/*
 * call-seq:
 *    res.getvalue( tup_num, field_num )
 *
 * Returns the value in tuple number _tup_num_, field _field_num_,
 * or +nil+ if the field is +NULL+.
 */
static VALUE
pgresult_getvalue(VALUE self, VALUE tup_num, VALUE field_num)
{
	t_pg_result *this = pgresult_get_this_safe(self);
	int i = NUM2INT(tup_num);
	int j = NUM2INT(field_num);

	if(i < 0 || i >= PQntuples(this->pgresult)) {
		rb_raise(rb_eArgError,"invalid tuple number %d", i);
	}
	if(j < 0 || j >= PQnfields(this->pgresult)) {
		rb_raise(rb_eArgError,"invalid field number %d", j);
	}
	return this->p_typemap->funcs.typecast_result_value(this->p_typemap, self, i, j);
}

/*
 * call-seq:
 *    res.getisnull(tuple_position, field_position) -> boolean
 *
 * Returns +true+ if the specified value is +nil+; +false+ otherwise.
 */
static VALUE
pgresult_getisnull(VALUE self, VALUE tup_num, VALUE field_num)
{
	PGresult *result;
	int i = NUM2INT(tup_num);
	int j = NUM2INT(field_num);

	result = pgresult_get(self);
	if (i < 0 || i >= PQntuples(result)) {
		rb_raise(rb_eArgError,"invalid tuple number %d", i);
	}
	if (j < 0 || j >= PQnfields(result)) {
		rb_raise(rb_eArgError,"invalid field number %d", j);
	}
	return PQgetisnull(result, i, j) ? Qtrue : Qfalse;
}

/*
 * call-seq:
 *    res.getlength( tup_num, field_num ) -> Integer
 *
 * Returns the (String) length of the field in bytes.
 *
 * Equivalent to <tt>res.value(<i>tup_num</i>,<i>field_num</i>).length</tt>.
 */
static VALUE
pgresult_getlength(VALUE self, VALUE tup_num, VALUE field_num)
{
	PGresult *result;
	int i = NUM2INT(tup_num);
	int j = NUM2INT(field_num);

	result = pgresult_get(self);
	if (i < 0 || i >= PQntuples(result)) {
		rb_raise(rb_eArgError,"invalid tuple number %d", i);
	}
	if (j < 0 || j >= PQnfields(result)) {
		rb_raise(rb_eArgError,"invalid field number %d", j);
	}
	return INT2FIX(PQgetlength(result, i, j));
}

/*
 * call-seq:
 *    res.nparams() -> Integer
 *
 * Returns the number of parameters of a prepared statement.
 * Only useful for the result returned by conn.describePrepared
 */
static VALUE
pgresult_nparams(VALUE self)
{
	PGresult *result;

	result = pgresult_get(self);
	return INT2FIX(PQnparams(result));
}

/*
 * call-seq:
 *    res.paramtype( param_number ) -> Oid
 *
 * Returns the Oid of the data type of parameter _param_number_.
 * Only useful for the result returned by conn.describePrepared
 */
static VALUE
pgresult_paramtype(VALUE self, VALUE param_number)
{
	PGresult *result;

	result = pgresult_get(self);
	return UINT2NUM(PQparamtype(result,NUM2INT(param_number)));
}

/*
 * call-seq:
 *    res.cmd_status() -> String
 *
 * Returns the status string of the last query command.
 */
static VALUE
pgresult_cmd_status(VALUE self)
{
	VALUE ret = rb_tainted_str_new2(PQcmdStatus(pgresult_get(self)));
	PG_ENCODING_SET_NOCHECK(ret, ENCODING_GET(self));
	return ret;
}

/*
 * call-seq:
 *    res.cmd_tuples() -> Integer
 *
 * Returns the number of tuples (rows) affected by the SQL command.
 *
 * If the SQL command that generated the PG::Result was not one of:
 *
 * * <tt>SELECT</tt>
 * * <tt>CREATE TABLE AS</tt>
 * * <tt>INSERT</tt>
 * * <tt>UPDATE</tt>
 * * <tt>DELETE</tt>
 * * <tt>MOVE</tt>
 * * <tt>FETCH</tt>
 * * <tt>COPY</tt>
 * * an +EXECUTE+ of a prepared query that contains an +INSERT+, +UPDATE+, or +DELETE+ statement
 *
 * or if no tuples were affected, <tt>0</tt> is returned.
 */
static VALUE
pgresult_cmd_tuples(VALUE self)
{
	long n;
	n = strtol(PQcmdTuples(pgresult_get(self)),NULL, 10);
	return INT2NUM(n);
}

/*
 * call-seq:
 *    res.oid_value() -> Integer
 *
 * Returns the +oid+ of the inserted row if applicable,
 * otherwise +nil+.
 */
static VALUE
pgresult_oid_value(VALUE self)
{
	Oid n = PQoidValue(pgresult_get(self));
	if (n == InvalidOid)
		return Qnil;
	else
		return UINT2NUM(n);
}

/* Utility methods not in libpq */

/*
 * call-seq:
 *    res[ n ] -> Hash
 *
 * Returns tuple _n_ as a hash.
 */
static VALUE
pgresult_aref(VALUE self, VALUE index)
{
	t_pg_result *this = pgresult_get_this_safe(self);
	int tuple_num = NUM2INT(index);
	int field_num;
	int num_tuples = PQntuples(this->pgresult);
	VALUE tuple;

	if( this->nfields == -1 )
		pgresult_init_fnames( self );

	if ( tuple_num < 0 || tuple_num >= num_tuples )
		rb_raise( rb_eIndexError, "Index %d is out of range", tuple_num );

	/* We reuse the Hash of the previous output for larger row counts.
	 * This is somewhat faster than populating an empty Hash object. */
	tuple = NIL_P(this->tuple_hash) ? rb_hash_new() : this->tuple_hash;
	for ( field_num = 0; field_num < this->nfields; field_num++ ) {
		VALUE val = this->p_typemap->funcs.typecast_result_value(this->p_typemap, self, tuple_num, field_num);
		rb_hash_aset( tuple, this->fnames[field_num], val );
	}
	/* Store a copy of the filled hash for use at the next row. */
	if( num_tuples > 10 )
		this->tuple_hash = rb_hash_dup(tuple);

	return tuple;
}

/*
 * call-seq:
 *    res.each_row { |row| ... }
 *
 * Yields each row of the result. The row is a list of column values.
 */
static VALUE
pgresult_each_row(VALUE self)
{
	t_pg_result *this;
	int row;
	int field;
	int num_rows;
	int num_fields;

	RETURN_SIZED_ENUMERATOR(self, 0, NULL, pgresult_ntuples_for_enum);

	this = pgresult_get_this_safe(self);
	num_rows = PQntuples(this->pgresult);
	num_fields = PQnfields(this->pgresult);

	for ( row = 0; row < num_rows; row++ ) {
		PG_VARIABLE_LENGTH_ARRAY(VALUE, row_values, num_fields, PG_MAX_COLUMNS)

		/* populate the row */
		for ( field = 0; field < num_fields; field++ ) {
			row_values[field] = this->p_typemap->funcs.typecast_result_value(this->p_typemap, self, row, field);
		}
		rb_yield( rb_ary_new4( num_fields, row_values ));
	}

	return Qnil;
}

/*
 * call-seq:
 *    res.values -> Array
 *
 * Returns all tuples as an array of arrays.
 */
static VALUE
pgresult_values(VALUE self)
{
	t_pg_result *this = pgresult_get_this_safe(self);
	int row;
	int field;
	int num_rows = PQntuples(this->pgresult);
	int num_fields = PQnfields(this->pgresult);
	VALUE results = rb_ary_new2( num_rows );

	for ( row = 0; row < num_rows; row++ ) {
		PG_VARIABLE_LENGTH_ARRAY(VALUE, row_values, num_fields, PG_MAX_COLUMNS)

		/* populate the row */
		for ( field = 0; field < num_fields; field++ ) {
			row_values[field] = this->p_typemap->funcs.typecast_result_value(this->p_typemap, self, row, field);
		}
		rb_ary_store( results, row, rb_ary_new4( num_fields, row_values ) );
	}

	return results;
}

/*
 * Make a Ruby array out of the encoded values from the specified
 * column in the given result.
 */
static VALUE
make_column_result_array( VALUE self, int col )
{
	t_pg_result *this = pgresult_get_this_safe(self);
	int rows = PQntuples( this->pgresult );
	int i;
	VALUE results = rb_ary_new2( rows );

	if ( col >= PQnfields(this->pgresult) )
		rb_raise( rb_eIndexError, "no column %d in result", col );

	for ( i=0; i < rows; i++ ) {
		VALUE val = this->p_typemap->funcs.typecast_result_value(this->p_typemap, self, i, col);
		rb_ary_store( results, i, val );
	}

	return results;
}


/*
 *  call-seq:
 *     res.column_values( n )   -> array
 *
 *  Returns an Array of the values from the nth column of each
 *  tuple in the result.
 *
 */
static VALUE
pgresult_column_values(VALUE self, VALUE index)
{
	int col = NUM2INT( index );
	return make_column_result_array( self, col );
}


/*
 *  call-seq:
 *     res.field_values( field )   -> array
 *
 *  Returns an Array of the values from the given _field_ of each tuple in the result.
 *
 */
static VALUE
pgresult_field_values( VALUE self, VALUE field )
{
	PGresult *result = pgresult_get( self );
	const char *fieldname = StringValueCStr( field );
	int fnum = PQfnumber( result, fieldname );

	if ( fnum < 0 )
		rb_raise( rb_eIndexError, "no such field '%s' in result", fieldname );

	return make_column_result_array( self, fnum );
}


/*
 * call-seq:
 *    res.each{ |tuple| ... }
 *
 * Invokes block for each tuple in the result set.
 */
static VALUE
pgresult_each(VALUE self)
{
	PGresult *result;
	int tuple_num;

	RETURN_SIZED_ENUMERATOR(self, 0, NULL, pgresult_ntuples_for_enum);

	result = pgresult_get(self);

	for(tuple_num = 0; tuple_num < PQntuples(result); tuple_num++) {
		rb_yield(pgresult_aref(self, INT2NUM(tuple_num)));
	}
	return self;
}

/*
 * call-seq:
 *    res.fields() -> Array
 *
 * Returns an array of Strings representing the names of the fields in the result.
 */
static VALUE
pgresult_fields(VALUE self)
{
	t_pg_result *this = pgresult_get_this_safe(self);

	if( this->nfields == -1 )
		pgresult_init_fnames( self );

	return rb_ary_new4( this->nfields, this->fnames );
}

/*
 * call-seq:
 *    res.type_map = typemap
 *
 * Set the TypeMap that is used for type casts of result values to ruby objects.
 *
 * All value retrieval methods will respect the type map and will do the
 * type casts from PostgreSQL's wire format to Ruby objects on the fly,
 * according to the rules and decoders defined in the given typemap.
 *
 * +typemap+ must be a kind of PG::TypeMap .
 *
 */
static VALUE
pgresult_type_map_set(VALUE self, VALUE typemap)
{
	t_pg_result *this = pgresult_get_this(self);
	t_typemap *p_typemap;

	if ( !rb_obj_is_kind_of(typemap, rb_cTypeMap) ) {
		rb_raise( rb_eTypeError, "wrong argument type %s (expected kind of PG::TypeMap)",
				rb_obj_classname( typemap ) );
	}
	Data_Get_Struct(typemap, t_typemap, p_typemap);

	this->typemap = p_typemap->funcs.fit_to_result( typemap, self );
	this->p_typemap = DATA_PTR( this->typemap );

	return typemap;
}

/*
 * call-seq:
 *    res.type_map -> value
 *
 * Returns the TypeMap that is currently set for type casts of result values to ruby objects.
 *
 */
static VALUE
pgresult_type_map_get(VALUE self)
{
	t_pg_result *this = pgresult_get_this(self);

	return this->typemap;
}

#ifdef HAVE_PQSETSINGLEROWMODE
/*
 * call-seq:
 *    res.stream_each{ |tuple| ... }
 *
 * Invokes block for each tuple in the result set in single row mode.
 *
 * This is a convenience method for retrieving all result tuples
 * as they are transferred. It is an alternative to repeated calls of
 * PG::Connection#get_result , but given that it avoids the overhead of
 * wrapping each row into a dedicated result object, it delivers data in nearly
 * the same speed as with ordinary results.
 *
 * The result must be in status PGRES_SINGLE_TUPLE.
 * It iterates over all tuples until the status changes to PGRES_TUPLES_OK.
 * A PG::Error is raised for any errors from the server.
 *
 * Row description data does not change while the iteration. All value retrieval
 * methods refer to only the current row. Result#ntuples returns +1+ while
 * the iteration and +0+ after all tuples were yielded.
 *
 * Example:
 *   conn.send_query( "first SQL query; second SQL query" )
 *   conn.set_single_row_mode
 *   conn.get_result.stream_each do |row|
 *     # do something with the received row of the first query
 *   end
 *   conn.get_result.stream_each do |row|
 *     # do something with the received row of the second query
 *   end
 *   conn.get_result  # => nil   (no more results)
 */
static VALUE
pgresult_stream_each(VALUE self)
{
	t_pg_result *this;
	int nfields;
	PGconn *pgconn;
	PGresult *pgresult;

	RETURN_ENUMERATOR(self, 0, NULL);

	this = pgresult_get_this_safe(self);
	pgconn = pg_get_pgconn(this->connection);
	pgresult = this->pgresult;
	nfields = PQnfields(pgresult);

	for(;;){
		int tuple_num;
		int ntuples = PQntuples(pgresult);

		switch( PQresultStatus(pgresult) ){
			case PGRES_TUPLES_OK:
				if( ntuples == 0 )
					return self;
				rb_raise( rb_eInvalidResultStatus, "PG::Result is not in single row mode");
			case PGRES_SINGLE_TUPLE:
				break;
			default:
				pg_result_check( self );
		}

		for(tuple_num = 0; tuple_num < ntuples; tuple_num++) {
			rb_yield(pgresult_aref(self, INT2NUM(tuple_num)));
		}

		if( !this->autoclear ){
			PQclear( pgresult );
			this->pgresult = NULL;
		}

		pgresult = gvl_PQgetResult(pgconn);
		if( pgresult == NULL )
			rb_raise( rb_eNoResultError, "no result received - possibly an intersection with another result retrieval");

		if( nfields != PQnfields(pgresult) )
			rb_raise( rb_eInvalidChangeOfResultFields, "number of fields must not change in single row mode");

		this->pgresult = pgresult;
	}

	/* never reached */
	return self;
}

/*
 * call-seq:
 *    res.stream_each_row { |row| ... }
 *
 * Yields each row of the result set in single row mode.
 * The row is a list of column values.
 *
 * This method works equally to #stream_each , but yields an Array of
 * values.
 */
static VALUE
pgresult_stream_each_row(VALUE self)
{
	t_pg_result *this;
	int row;
	int nfields;
	PGconn *pgconn;
	PGresult *pgresult;

	RETURN_ENUMERATOR(self, 0, NULL);

	this = pgresult_get_this_safe(self);
	pgconn = pg_get_pgconn(this->connection);
	pgresult = this->pgresult;
	nfields = PQnfields(pgresult);

	for(;;){
		int ntuples = PQntuples(pgresult);

		switch( PQresultStatus(pgresult) ){
			case PGRES_TUPLES_OK:
				if( ntuples == 0 )
					return self;
				rb_raise( rb_eInvalidResultStatus, "PG::Result is not in single row mode");
			case PGRES_SINGLE_TUPLE:
				break;
			default:
				pg_result_check( self );
		}

		for ( row = 0; row < ntuples; row++ ) {
			PG_VARIABLE_LENGTH_ARRAY(VALUE, row_values, nfields, PG_MAX_COLUMNS)
			int field;

			/* populate the row */
			for ( field = 0; field < nfields; field++ ) {
				row_values[field] = this->p_typemap->funcs.typecast_result_value(this->p_typemap, self, row, field);
			}
			rb_yield( rb_ary_new4( nfields, row_values ));
		}

		if( !this->autoclear ){
			PQclear( pgresult );
			this->pgresult = NULL;
		}

		pgresult = gvl_PQgetResult(pgconn);
		if( pgresult == NULL )
			rb_raise( rb_eNoResultError, "no result received - possibly an intersection with another result retrieval");

		if( nfields != PQnfields(pgresult) )
			rb_raise( rb_eInvalidChangeOfResultFields, "number of fields must not change in single row mode");

		this->pgresult = pgresult;
	}

	/* never reached */
	return self;
}
#endif


void
init_pg_result()
{
	rb_cPGresult = rb_define_class_under( rb_mPG, "Result", rb_cObject );
	rb_define_alloc_func( rb_cPGresult, pgresult_s_allocate );
	rb_include_module(rb_cPGresult, rb_mEnumerable);
	rb_include_module(rb_cPGresult, rb_mPGconstants);

	/******     PG::Result INSTANCE METHODS: libpq     ******/
	rb_define_method(rb_cPGresult, "result_status", pgresult_result_status, 0);
	rb_define_method(rb_cPGresult, "res_status", pgresult_res_status, 1);
	rb_define_method(rb_cPGresult, "error_message", pgresult_error_message, 0);
	rb_define_alias( rb_cPGresult, "result_error_message", "error_message");
	rb_define_method(rb_cPGresult, "error_field", pgresult_error_field, 1);
	rb_define_alias( rb_cPGresult, "result_error_field", "error_field" );
	rb_define_method(rb_cPGresult, "clear", pg_result_clear, 0);
	rb_define_method(rb_cPGresult, "check", pg_result_check, 0);
	rb_define_alias (rb_cPGresult, "check_result", "check");
	rb_define_method(rb_cPGresult, "ntuples", pgresult_ntuples, 0);
	rb_define_alias(rb_cPGresult, "num_tuples", "ntuples");
	rb_define_method(rb_cPGresult, "nfields", pgresult_nfields, 0);
	rb_define_alias(rb_cPGresult, "num_fields", "nfields");
	rb_define_method(rb_cPGresult, "fname", pgresult_fname, 1);
	rb_define_method(rb_cPGresult, "fnumber", pgresult_fnumber, 1);
	rb_define_method(rb_cPGresult, "ftable", pgresult_ftable, 1);
	rb_define_method(rb_cPGresult, "ftablecol", pgresult_ftablecol, 1);
	rb_define_method(rb_cPGresult, "fformat", pgresult_fformat, 1);
	rb_define_method(rb_cPGresult, "ftype", pgresult_ftype, 1);
	rb_define_method(rb_cPGresult, "fmod", pgresult_fmod, 1);
	rb_define_method(rb_cPGresult, "fsize", pgresult_fsize, 1);
	rb_define_method(rb_cPGresult, "getvalue", pgresult_getvalue, 2);
	rb_define_method(rb_cPGresult, "getisnull", pgresult_getisnull, 2);
	rb_define_method(rb_cPGresult, "getlength", pgresult_getlength, 2);
	rb_define_method(rb_cPGresult, "nparams", pgresult_nparams, 0);
	rb_define_method(rb_cPGresult, "paramtype", pgresult_paramtype, 1);
	rb_define_method(rb_cPGresult, "cmd_status", pgresult_cmd_status, 0);
	rb_define_method(rb_cPGresult, "cmd_tuples", pgresult_cmd_tuples, 0);
	rb_define_alias(rb_cPGresult, "cmdtuples", "cmd_tuples");
	rb_define_method(rb_cPGresult, "oid_value", pgresult_oid_value, 0);

	/******     PG::Result INSTANCE METHODS: other     ******/
	rb_define_method(rb_cPGresult, "[]", pgresult_aref, 1);
	rb_define_method(rb_cPGresult, "each", pgresult_each, 0);
	rb_define_method(rb_cPGresult, "fields", pgresult_fields, 0);
	rb_define_method(rb_cPGresult, "each_row", pgresult_each_row, 0);
	rb_define_method(rb_cPGresult, "values", pgresult_values, 0);
	rb_define_method(rb_cPGresult, "column_values", pgresult_column_values, 1);
	rb_define_method(rb_cPGresult, "field_values", pgresult_field_values, 1);
	rb_define_method(rb_cPGresult, "cleared?", pgresult_cleared_p, 0);
	rb_define_method(rb_cPGresult, "autoclear?", pgresult_autoclear_p, 0);

	rb_define_method(rb_cPGresult, "type_map=", pgresult_type_map_set, 1);
	rb_define_method(rb_cPGresult, "type_map", pgresult_type_map_get, 0);

#ifdef HAVE_PQSETSINGLEROWMODE
	/******     PG::Result INSTANCE METHODS: streaming     ******/
	rb_define_method(rb_cPGresult, "stream_each", pgresult_stream_each, 0);
	rb_define_method(rb_cPGresult, "stream_each_row", pgresult_stream_each_row, 0);
#endif
}



/*
 * pg_connection.c - PG::Connection class extension
 * $Id: pg_connection.c,v 2e17f315848e 2017/01/14 20:05:06 lars $
 *
 */

#include "pg.h"

/* Number of bytes that are reserved on the stack for query params. */
#define QUERYDATA_BUFFER_SIZE 4000


VALUE rb_cPGconn;
static ID s_id_encode;
static VALUE sym_type, sym_format, sym_value;

static PQnoticeReceiver default_notice_receiver = NULL;
static PQnoticeProcessor default_notice_processor = NULL;

static VALUE pgconn_finish( VALUE );
#ifdef M17N_SUPPORTED
static VALUE pgconn_set_default_encoding( VALUE self );
void pgconn_set_internal_encoding_index( VALUE );
#endif

#ifndef HAVE_RB_THREAD_FD_SELECT
#define rb_fdset_t fd_set
#define rb_fd_init(f)
#define rb_fd_zero(f)  FD_ZERO(f)
#define rb_fd_set(n, f)  FD_SET(n, f)
#define rb_fd_term(f)
#define rb_thread_fd_select rb_thread_select
#endif

/*
 * Global functions
 */

/*
 * Fetch the PG::Connection object data pointer.
 */
t_pg_connection *
pg_get_connection( VALUE self )
{
	t_pg_connection *this;
	Data_Get_Struct( self, t_pg_connection, this);

	return this;
}

/*
 * Fetch the PG::Connection object data pointer and check it's
 * PGconn data pointer for sanity.
 */
static t_pg_connection *
pg_get_connection_safe( VALUE self )
{
	t_pg_connection *this;
	Data_Get_Struct( self, t_pg_connection, this);

	if ( !this->pgconn )
		rb_raise( rb_eConnectionBad, "connection is closed" );

	return this;
}

/*
 * Fetch the PGconn data pointer and check it for sanity.
 *
 * Note: This function is used externally by the sequel_pg gem,
 * so do changes carefully.
 *
 */
PGconn *
pg_get_pgconn( VALUE self )
{
	t_pg_connection *this;
	Data_Get_Struct( self, t_pg_connection, this);

	if ( !this->pgconn )
		rb_raise( rb_eConnectionBad, "connection is closed" );

	return this->pgconn;
}



/*
 * Close the associated socket IO object if there is one.
 */
static void
pgconn_close_socket_io( VALUE self )
{
	t_pg_connection *this = pg_get_connection( self );
	VALUE socket_io = this->socket_io;

	if ( RTEST(socket_io) ) {
#if defined(_WIN32) && defined(HAVE_RB_W32_WRAP_IO_HANDLE)
		int ruby_sd = NUM2INT(rb_funcall( socket_io, rb_intern("fileno"), 0 ));
		if( rb_w32_unwrap_io_handle(ruby_sd) ){
			rb_raise(rb_eConnectionBad, "Could not unwrap win32 socket handle");
		}
#endif
		rb_funcall( socket_io, rb_intern("close"), 0 );
	}

	this->socket_io = Qnil;
}


/*
 * Create a Ruby Array of Hashes out of a PGconninfoOptions array.
 */
static VALUE
pgconn_make_conninfo_array( const PQconninfoOption *options )
{
	VALUE ary = rb_ary_new();
	VALUE hash;
	int i = 0;

	if (!options) return Qnil;

	for(i = 0; options[i].keyword != NULL; i++) {
		hash = rb_hash_new();
		if(options[i].keyword)
			rb_hash_aset(hash, ID2SYM(rb_intern("keyword")), rb_str_new2(options[i].keyword));
		if(options[i].envvar)
			rb_hash_aset(hash, ID2SYM(rb_intern("envvar")), rb_str_new2(options[i].envvar));
		if(options[i].compiled)
			rb_hash_aset(hash, ID2SYM(rb_intern("compiled")), rb_str_new2(options[i].compiled));
		if(options[i].val)
			rb_hash_aset(hash, ID2SYM(rb_intern("val")), rb_str_new2(options[i].val));
		if(options[i].label)
			rb_hash_aset(hash, ID2SYM(rb_intern("label")), rb_str_new2(options[i].label));
		if(options[i].dispchar)
			rb_hash_aset(hash, ID2SYM(rb_intern("dispchar")), rb_str_new2(options[i].dispchar));
		rb_hash_aset(hash, ID2SYM(rb_intern("dispsize")), INT2NUM(options[i].dispsize));
		rb_ary_push(ary, hash);
	}

	return ary;
}

static const char *pg_cstr_enc(VALUE str, int enc_idx){
	const char *ptr = StringValueCStr(str);
	if( ENCODING_GET(str) == enc_idx ){
		return ptr;
	} else {
		str = rb_str_export_to_enc(str, rb_enc_from_index(enc_idx));
		return StringValueCStr(str);
	}
}


/*
 * GC Mark function
 */
static void
pgconn_gc_mark( t_pg_connection *this )
{
	rb_gc_mark( this->socket_io );
	rb_gc_mark( this->notice_receiver );
	rb_gc_mark( this->notice_processor );
	rb_gc_mark( this->type_map_for_queries );
	rb_gc_mark( this->type_map_for_results );
	rb_gc_mark( this->trace_stream );
	rb_gc_mark( this->external_encoding );
	rb_gc_mark( this->encoder_for_put_copy_data );
	rb_gc_mark( this->decoder_for_get_copy_data );
}


/*
 * GC Free function
 */
static void
pgconn_gc_free( t_pg_connection *this )
{
	if (this->pgconn != NULL)
		PQfinish( this->pgconn );

	xfree(this);
}


/**************************************************************************
 * Class Methods
 **************************************************************************/

/*
 * Document-method: allocate
 *
 * call-seq:
 *   PG::Connection.allocate -> conn
 */
static VALUE
pgconn_s_allocate( VALUE klass )
{
	t_pg_connection *this;
	VALUE self = Data_Make_Struct( klass, t_pg_connection, pgconn_gc_mark, pgconn_gc_free, this );

	this->pgconn = NULL;
	this->socket_io = Qnil;
	this->notice_receiver = Qnil;
	this->notice_processor = Qnil;
	this->type_map_for_queries = pg_typemap_all_strings;
	this->type_map_for_results = pg_typemap_all_strings;
	this->encoder_for_put_copy_data = Qnil;
	this->decoder_for_get_copy_data = Qnil;
	this->trace_stream = Qnil;
	this->external_encoding = Qnil;

	return self;
}


/*
 * Document-method: new
 *
 * call-seq:
 *    PG::Connection.new -> conn
 *    PG::Connection.new(connection_hash) -> conn
 *    PG::Connection.new(connection_string) -> conn
 *    PG::Connection.new(host, port, options, tty, dbname, user, password) ->  conn
 *
 * Create a connection to the specified server.
 *
 * [+host+]
 *   server hostname
 * [+hostaddr+]
 *   server address (avoids hostname lookup, overrides +host+)
 * [+port+]
 *   server port number
 * [+dbname+]
 *   connecting database name
 * [+user+]
 *   login user name
 * [+password+]
 *   login password
 * [+connect_timeout+]
 *   maximum time to wait for connection to succeed
 * [+options+]
 *   backend options
 * [+tty+]
 *   (ignored in newer versions of PostgreSQL)
 * [+sslmode+]
 *   (disable|allow|prefer|require)
 * [+krbsrvname+]
 *   kerberos service name
 * [+gsslib+]
 *   GSS library to use for GSSAPI authentication
 * [+service+]
 *   service name to use for additional parameters
 *
 * Examples:
 *
 *   # Connect using all defaults
 *   PG::Connection.new
 *
 *   # As a Hash
 *   PG::Connection.new( :dbname => 'test', :port => 5432 )
 *
 *   # As a String
 *   PG::Connection.new( "dbname=test port=5432" )
 *
 *   # As an Array
 *   PG::Connection.new( nil, 5432, nil, nil, 'test', nil, nil )
 *
 * If the Ruby default internal encoding is set (i.e., Encoding.default_internal != nil), the
 * connection will have its +client_encoding+ set accordingly.
 *
 * Raises a PG::Error if the connection fails.
 */
static VALUE
pgconn_init(int argc, VALUE *argv, VALUE self)
{
	t_pg_connection *this;
	VALUE conninfo;
	VALUE error;

	this = pg_get_connection( self );
	conninfo = rb_funcall2( rb_cPGconn, rb_intern("parse_connect_args"), argc, argv );
	this->pgconn = gvl_PQconnectdb(StringValueCStr(conninfo));

	if(this->pgconn == NULL)
		rb_raise(rb_ePGerror, "PQconnectdb() unable to allocate structure");

	if (PQstatus(this->pgconn) == CONNECTION_BAD) {
		error = rb_exc_new2(rb_eConnectionBad, PQerrorMessage(this->pgconn));
		rb_iv_set(error, "@connection", self);
		rb_exc_raise(error);
	}

#ifdef M17N_SUPPORTED
	pgconn_set_default_encoding( self );
#endif

	if (rb_block_given_p()) {
		return rb_ensure(rb_yield, self, pgconn_finish, self);
	}
	return self;
}

/*
 * call-seq:
 *    PG::Connection.connect_start(connection_hash)       -> conn
 *    PG::Connection.connect_start(connection_string)     -> conn
 *    PG::Connection.connect_start(host, port, options, tty, dbname, login, password) ->  conn
 *
 * This is an asynchronous version of PG::Connection.connect().
 *
 * Use #connect_poll to poll the status of the connection.
 *
 * NOTE: this does *not* set the connection's +client_encoding+ for you if
 * Encoding.default_internal is set. To set it after the connection is established,
 * call #internal_encoding=. You can also set it automatically by setting
 * ENV['PGCLIENTENCODING'], or include the 'options' connection parameter.
 *
 */
static VALUE
pgconn_s_connect_start( int argc, VALUE *argv, VALUE klass )
{
	VALUE rb_conn;
	VALUE conninfo;
	VALUE error;
	t_pg_connection *this;

	/*
	 * PG::Connection.connect_start must act as both alloc() and initialize()
	 * because it is not invoked by calling new().
	 */
	rb_conn  = pgconn_s_allocate( klass );
	this = pg_get_connection( rb_conn );
	conninfo = rb_funcall2( klass, rb_intern("parse_connect_args"), argc, argv );
	this->pgconn = gvl_PQconnectStart( StringValueCStr(conninfo) );

	if( this->pgconn == NULL )
		rb_raise(rb_ePGerror, "PQconnectStart() unable to allocate structure");

	if ( PQstatus(this->pgconn) == CONNECTION_BAD ) {
		error = rb_exc_new2(rb_eConnectionBad, PQerrorMessage(this->pgconn));
		rb_iv_set(error, "@connection", rb_conn);
		rb_exc_raise(error);
	}

	if ( rb_block_given_p() ) {
		return rb_ensure( rb_yield, rb_conn, pgconn_finish, rb_conn );
	}
	return rb_conn;
}

#ifdef HAVE_PQPING
/*
 * call-seq:
 *    PG::Connection.ping(connection_hash)       -> Integer
 *    PG::Connection.ping(connection_string)     -> Integer
 *    PG::Connection.ping(host, port, options, tty, dbname, login, password) ->  Integer
 *
 * Check server status.
 *
 * Returns one of:
 * [+PQPING_OK+]
 *   server is accepting connections
 * [+PQPING_REJECT+]
 *   server is alive but rejecting connections
 * [+PQPING_NO_RESPONSE+]
 *   could not establish connection
 * [+PQPING_NO_ATTEMPT+]
 *   connection not attempted (bad params)
 */
static VALUE
pgconn_s_ping( int argc, VALUE *argv, VALUE klass )
{
	PGPing ping;
	VALUE conninfo;

	conninfo = rb_funcall2( klass, rb_intern("parse_connect_args"), argc, argv );
	ping     = PQping( StringValueCStr(conninfo) );

	return INT2FIX((int)ping);
}
#endif


/*
 * Document-method: PG::Connection.conndefaults
 *
 * call-seq:
 *    PG::Connection.conndefaults() -> Array
 *
 * Returns an array of hashes. Each hash has the keys:
 * [+:keyword+]
 *   the name of the option
 * [+:envvar+]
 *   the environment variable to fall back to
 * [+:compiled+]
 *   the compiled in option as a secondary fallback
 * [+:val+]
 *   the option's current value, or +nil+ if not known
 * [+:label+]
 *   the label for the field
 * [+:dispchar+]
 *   "" for normal, "D" for debug, and "*" for password
 * [+:dispsize+]
 *   field size
 */
static VALUE
pgconn_s_conndefaults(VALUE self)
{
	PQconninfoOption *options = PQconndefaults();
	VALUE array = pgconn_make_conninfo_array( options );

	PQconninfoFree(options);

	UNUSED( self );

	return array;
}


/*
 * call-seq:
 *    PG::Connection.encrypt_password( password, username ) -> String
 *
 * This function is intended to be used by client applications that
 * send commands like: +ALTER USER joe PASSWORD 'pwd'+.
 * The arguments are the cleartext password, and the SQL name
 * of the user it is for.
 *
 * Return value is the encrypted password.
 */
static VALUE
pgconn_s_encrypt_password(VALUE self, VALUE password, VALUE username)
{
	char *encrypted = NULL;
	VALUE rval = Qnil;

	UNUSED( self );

	Check_Type(password, T_STRING);
	Check_Type(username, T_STRING);

	encrypted = PQencryptPassword(StringValueCStr(password), StringValueCStr(username));
	rval = rb_str_new2( encrypted );
	PQfreemem( encrypted );

	OBJ_INFECT( rval, password );
	OBJ_INFECT( rval, username );

	return rval;
}


/**************************************************************************
 * PG::Connection INSTANCE METHODS
 **************************************************************************/

/*
 * call-seq:
 *    conn.connect_poll() -> Integer
 *
 * Returns one of:
 * [+PGRES_POLLING_READING+]
 *   wait until the socket is ready to read
 * [+PGRES_POLLING_WRITING+]
 *   wait until the socket is ready to write
 * [+PGRES_POLLING_FAILED+]
 *   the asynchronous connection has failed
 * [+PGRES_POLLING_OK+]
 *   the asynchronous connection is ready
 *
 * Example:
 *   conn = PG::Connection.connect_start("dbname=mydatabase")
 *   socket = conn.socket_io
 *   status = conn.connect_poll
 *   while(status != PG::PGRES_POLLING_OK) do
 *     # do some work while waiting for the connection to complete
 *     if(status == PG::PGRES_POLLING_READING)
 *       if(not select([socket], [], [], 10.0))
 *         raise "Asynchronous connection timed out!"
 *       end
 *     elsif(status == PG::PGRES_POLLING_WRITING)
 *       if(not select([], [socket], [], 10.0))
 *         raise "Asynchronous connection timed out!"
 *       end
 *     end
 *     status = conn.connect_poll
 *   end
 *   # now conn.status == CONNECTION_OK, and connection
 *   # is ready.
 */
static VALUE
pgconn_connect_poll(VALUE self)
{
	PostgresPollingStatusType status;
	status = gvl_PQconnectPoll(pg_get_pgconn(self));
	return INT2FIX((int)status);
}

/*
 * call-seq:
 *    conn.finish
 *
 * Closes the backend connection.
 */
static VALUE
pgconn_finish( VALUE self )
{
	t_pg_connection *this = pg_get_connection_safe( self );

	pgconn_close_socket_io( self );
	PQfinish( this->pgconn );
	this->pgconn = NULL;
	return Qnil;
}


/*
 * call-seq:
 *    conn.finished?      -> boolean
 *
 * Returns +true+ if the backend connection has been closed.
 */
static VALUE
pgconn_finished_p( VALUE self )
{
	t_pg_connection *this = pg_get_connection( self );
	if ( this->pgconn ) return Qfalse;
	return Qtrue;
}


/*
 * call-seq:
 *    conn.reset()
 *
 * Resets the backend connection. This method closes the
 * backend connection and tries to re-connect.
 */
static VALUE
pgconn_reset( VALUE self )
{
	pgconn_close_socket_io( self );
	gvl_PQreset( pg_get_pgconn(self) );
	return self;
}

/*
 * call-seq:
 *    conn.reset_start() -> nil
 *
 * Initiate a connection reset in a nonblocking manner.
 * This will close the current connection and attempt to
 * reconnect using the same connection parameters.
 * Use #reset_poll to check the status of the
 * connection reset.
 */
static VALUE
pgconn_reset_start(VALUE self)
{
	pgconn_close_socket_io( self );
	if(gvl_PQresetStart(pg_get_pgconn(self)) == 0)
		rb_raise(rb_eUnableToSend, "reset has failed");
	return Qnil;
}

/*
 * call-seq:
 *    conn.reset_poll -> Integer
 *
 * Checks the status of a connection reset operation.
 * See #connect_start and #connect_poll for
 * usage information and return values.
 */
static VALUE
pgconn_reset_poll(VALUE self)
{
	PostgresPollingStatusType status;
	status = gvl_PQresetPoll(pg_get_pgconn(self));
	return INT2FIX((int)status);
}


/*
 * call-seq:
 *    conn.db()
 *
 * Returns the connected database name.
 */
static VALUE
pgconn_db(VALUE self)
{
	char *db = PQdb(pg_get_pgconn(self));
	if (!db) return Qnil;
	return rb_tainted_str_new2(db);
}

/*
 * call-seq:
 *    conn.user()
 *
 * Returns the authenticated user name.
 */
static VALUE
pgconn_user(VALUE self)
{
	char *user = PQuser(pg_get_pgconn(self));
	if (!user) return Qnil;
	return rb_tainted_str_new2(user);
}

/*
 * call-seq:
 *    conn.pass()
 *
 * Returns the authenticated user name.
 */
static VALUE
pgconn_pass(VALUE self)
{
	char *user = PQpass(pg_get_pgconn(self));
	if (!user) return Qnil;
	return rb_tainted_str_new2(user);
}

/*
 * call-seq:
 *    conn.host()
 *
 * Returns the connected server name.
 */
static VALUE
pgconn_host(VALUE self)
{
	char *host = PQhost(pg_get_pgconn(self));
	if (!host) return Qnil;
	return rb_tainted_str_new2(host);
}

/*
 * call-seq:
 *    conn.port()
 *
 * Returns the connected server port number.
 */
static VALUE
pgconn_port(VALUE self)
{
	char* port = PQport(pg_get_pgconn(self));
	return INT2NUM(atol(port));
}

/*
 * call-seq:
 *    conn.tty()
 *
 * Returns the connected pgtty. (Obsolete)
 */
static VALUE
pgconn_tty(VALUE self)
{
	char *tty = PQtty(pg_get_pgconn(self));
	if (!tty) return Qnil;
	return rb_tainted_str_new2(tty);
}

/*
 * call-seq:
 *    conn.options()
 *
 * Returns backend option string.
 */
static VALUE
pgconn_options(VALUE self)
{
	char *options = PQoptions(pg_get_pgconn(self));
	if (!options) return Qnil;
	return rb_tainted_str_new2(options);
}


#ifdef HAVE_PQCONNINFO
/*
 * call-seq:
 *    conn.conninfo   -> hash
 *
 * Returns the connection options used by a live connection.
 *
 */
static VALUE
pgconn_conninfo( VALUE self )
{
	PGconn *conn = pg_get_pgconn(self);
	PQconninfoOption *options = PQconninfo( conn );
	VALUE array = pgconn_make_conninfo_array( options );

	PQconninfoFree(options);

	return array;
}
#endif


/*
 * call-seq:
 *    conn.status()
 *
 * Returns status of connection : CONNECTION_OK or CONNECTION_BAD
 */
static VALUE
pgconn_status(VALUE self)
{
	return INT2NUM(PQstatus(pg_get_pgconn(self)));
}

/*
 * call-seq:
 *    conn.transaction_status()
 *
 * returns one of the following statuses:
 *   PQTRANS_IDLE    = 0 (connection idle)
 *   PQTRANS_ACTIVE  = 1 (command in progress)
 *   PQTRANS_INTRANS = 2 (idle, within transaction block)
 *   PQTRANS_INERROR = 3 (idle, within failed transaction)
 *   PQTRANS_UNKNOWN = 4 (cannot determine status)
 */
static VALUE
pgconn_transaction_status(VALUE self)
{
	return INT2NUM(PQtransactionStatus(pg_get_pgconn(self)));
}

/*
 * call-seq:
 *    conn.parameter_status( param_name ) -> String
 *
 * Returns the setting of parameter _param_name_, where
 * _param_name_ is one of
 * * +server_version+
 * * +server_encoding+
 * * +client_encoding+
 * * +is_superuser+
 * * +session_authorization+
 * * +DateStyle+
 * * +TimeZone+
 * * +integer_datetimes+
 * * +standard_conforming_strings+
 *
 * Returns nil if the value of the parameter is not known.
 */
static VALUE
pgconn_parameter_status(VALUE self, VALUE param_name)
{
	const char *ret = PQparameterStatus(pg_get_pgconn(self), StringValueCStr(param_name));
	if(ret == NULL)
		return Qnil;
	else
		return rb_tainted_str_new2(ret);
}

/*
 * call-seq:
 *   conn.protocol_version -> Integer
 *
 * The 3.0 protocol will normally be used when communicating with PostgreSQL 7.4
 * or later servers; pre-7.4 servers support only protocol 2.0. (Protocol 1.0 is
 * obsolete and not supported by libpq.)
 */
static VALUE
pgconn_protocol_version(VALUE self)
{
	return INT2NUM(PQprotocolVersion(pg_get_pgconn(self)));
}

/*
 * call-seq:
 *   conn.server_version -> Integer
 *
 * The number is formed by converting the major, minor, and revision
 * numbers into two-decimal-digit numbers and appending them together.
 * For example, version 7.4.2 will be returned as 70402, and version
 * 8.1 will be returned as 80100 (leading zeroes are not shown). Zero
 * is returned if the connection is bad.
 *
 */
static VALUE
pgconn_server_version(VALUE self)
{
	return INT2NUM(PQserverVersion(pg_get_pgconn(self)));
}

/*
 * call-seq:
 *    conn.error_message -> String
 *
 * Returns the error message about connection.
 */
static VALUE
pgconn_error_message(VALUE self)
{
	char *error = PQerrorMessage(pg_get_pgconn(self));
	if (!error) return Qnil;
	return rb_tainted_str_new2(error);
}

/*
 * call-seq:
 *    conn.socket() -> Integer
 *
 * Returns the socket's file descriptor for this connection.
 * <tt>IO.for_fd()</tt> can be used to build a proper IO object to the socket.
 * If you do so, you will likely also want to set <tt>autoclose=false</tt>
 * on it to prevent Ruby from closing the socket to PostgreSQL if it
 * goes out of scope. Alternatively, you can use #socket_io, which
 * creates an IO that's associated with the connection object itself,
 * and so won't go out of scope until the connection does.
 *
 * *Note:* On Windows the file descriptor is not really usable,
 * since it can not be used to build a Ruby IO object.
 */
static VALUE
pgconn_socket(VALUE self)
{
	int sd;
	if( (sd = PQsocket(pg_get_pgconn(self))) < 0)
		rb_raise(rb_eConnectionBad, "PQsocket() can't get socket descriptor");
	return INT2NUM(sd);
}


#if !defined(_WIN32) || defined(HAVE_RB_W32_WRAP_IO_HANDLE)

/*
 * call-seq:
 *    conn.socket_io() -> IO
 *
 * Fetch a memoized IO object created from the Connection's underlying socket.
 * This object can be used for IO.select to wait for events while running
 * asynchronous API calls.
 *
 * Using this instead of #socket avoids the problem of the underlying connection
 * being closed by Ruby when an IO created using <tt>IO.for_fd(conn.socket)</tt>
 * goes out of scope.
 *
 * This method can also be used on Windows but requires Ruby-2.0+.
 */
static VALUE
pgconn_socket_io(VALUE self)
{
	int sd;
	int ruby_sd;
	ID id_autoclose = rb_intern("autoclose=");
	t_pg_connection *this = pg_get_connection_safe( self );
	VALUE socket_io = this->socket_io;

	if ( !RTEST(socket_io) ) {
		if( (sd = PQsocket(this->pgconn)) < 0)
			rb_raise(rb_eConnectionBad, "PQsocket() can't get socket descriptor");

		#ifdef _WIN32
			ruby_sd = rb_w32_wrap_io_handle((HANDLE)(intptr_t)sd, O_RDWR|O_BINARY|O_NOINHERIT);
		#else
			ruby_sd = sd;
		#endif

		socket_io = rb_funcall( rb_cIO, rb_intern("for_fd"), 1, INT2NUM(ruby_sd) );

		/* Disable autoclose feature, when supported */
		if( rb_respond_to(socket_io, id_autoclose) ){
			rb_funcall( socket_io, id_autoclose, 1, Qfalse );
		}

		this->socket_io = socket_io;
	}

	return socket_io;
}

#endif

/*
 * call-seq:
 *    conn.backend_pid() -> Integer
 *
 * Returns the process ID of the backend server
 * process for this connection.
 * Note that this is a PID on database server host.
 */
static VALUE
pgconn_backend_pid(VALUE self)
{
	return INT2NUM(PQbackendPID(pg_get_pgconn(self)));
}

/*
 * call-seq:
 *    conn.connection_needs_password() -> Boolean
 *
 * Returns +true+ if the authentication method required a
 * password, but none was available. +false+ otherwise.
 */
static VALUE
pgconn_connection_needs_password(VALUE self)
{
	return PQconnectionNeedsPassword(pg_get_pgconn(self)) ? Qtrue : Qfalse;
}

/*
 * call-seq:
 *    conn.connection_used_password() -> Boolean
 *
 * Returns +true+ if the authentication method used
 * a caller-supplied password, +false+ otherwise.
 */
static VALUE
pgconn_connection_used_password(VALUE self)
{
	return PQconnectionUsedPassword(pg_get_pgconn(self)) ? Qtrue : Qfalse;
}


/* :TODO: get_ssl */


static VALUE pgconn_exec_params( int, VALUE *, VALUE );

/*
 * call-seq:
 *    conn.exec(sql) -> PG::Result
 *    conn.exec(sql) {|pg_result| block }
 *
 * Sends SQL query request specified by _sql_ to PostgreSQL.
 * Returns a PG::Result instance on success.
 * On failure, it raises a PG::Error.
 *
 * For backward compatibility, if you pass more than one parameter to this method,
 * it will call #exec_params for you. New code should explicitly use #exec_params if
 * argument placeholders are used.
 *
 * If the optional code block is given, it will be passed <i>result</i> as an argument,
 * and the PG::Result object will  automatically be cleared when the block terminates.
 * In this instance, <code>conn.exec</code> returns the value of the block.
 *
 * #exec is implemented on the synchronous command processing API of libpq, whereas
 * #async_exec is implemented on the asynchronous API.
 * #exec is somewhat faster that #async_exec, but blocks any signals to be processed until
 * the query is finished. This is most notably visible by a delayed reaction to Control+C.
 * Both methods ensure that other threads can process while waiting for the server to
 * complete the request.
 */
static VALUE
pgconn_exec(int argc, VALUE *argv, VALUE self)
{
	PGconn *conn = pg_get_pgconn(self);
	PGresult *result = NULL;
	VALUE rb_pgresult;

	/* If called with no parameters, use PQexec */
	if ( argc == 1 ) {
		VALUE query_str = argv[0];

		result = gvl_PQexec(conn, pg_cstr_enc(query_str, ENCODING_GET(self)));
		rb_pgresult = pg_new_result(result, self);
		pg_result_check(rb_pgresult);
		if (rb_block_given_p()) {
			return rb_ensure(rb_yield, rb_pgresult, pg_result_clear, rb_pgresult);
		}
		return rb_pgresult;
	}

	/* Otherwise, just call #exec_params instead for backward-compatibility */
	else {
		return pgconn_exec_params( argc, argv, self );
	}

}


struct linked_typecast_data {
	struct linked_typecast_data *next;
	char data[0];
};

/* This struct is allocated on the stack for all query execution functions. */
struct query_params_data {

	/*
	 * Filled by caller
	 */

	/* The character encoding index of the connection. Any strings
	 * given as query parameters are converted to this encoding.
	 */
	int enc_idx;
	/* Is the query function to execute one with types array? */
	int with_types;
	/* Array of query params from user space */
	VALUE params;
	/* The typemap given from user space */
	VALUE typemap;

	/*
	 * Filled by alloc_query_params()
	 */

	/* Wraps the pointer of allocated memory, if function parameters dont't
	 * fit in the memory_pool below.
	 */
	VALUE heap_pool;

	/* Pointer to the value string pointers (either within memory_pool or heap_pool).
	 * The value strings itself are either directly within RString memory or,
	 * in case of type casted values, within memory_pool or typecast_heap_chain.
	 */
	char **values;
	/* Pointer to the param lengths (either within memory_pool or heap_pool) */
	int *lengths;
	/* Pointer to the format codes (either within memory_pool or heap_pool) */
	int *formats;
	/* Pointer to the OID types (either within memory_pool or heap_pool) */
	Oid *types;

	/* This array takes the string values for the timeframe of the query,
	 * if param value convertion is required
	 */
	VALUE gc_array;

	/* Wraps a single linked list of allocated memory chunks for type casted params.
	 * Used when the memory_pool is to small.
	 */
	VALUE typecast_heap_chain;

	/* This memory pool is used to place above query function parameters on it. */
	char memory_pool[QUERYDATA_BUFFER_SIZE];
};

static void
free_typecast_heap_chain(struct linked_typecast_data *chain_entry)
{
	while(chain_entry){
		struct linked_typecast_data *next = chain_entry->next;
		xfree(chain_entry);
		chain_entry = next;
	}
}

static char *
alloc_typecast_buf( VALUE *typecast_heap_chain, int len )
{
	/* Allocate a new memory chunk from heap */
	struct linked_typecast_data *allocated =
		(struct linked_typecast_data *)xmalloc(sizeof(struct linked_typecast_data) + len);

	/* Did we already wrap a memory chain per T_DATA object? */
	if( NIL_P( *typecast_heap_chain ) ){
		/* Leave free'ing of the buffer chain to the GC, when paramsData has left the stack */
		*typecast_heap_chain = Data_Wrap_Struct( rb_cObject, NULL, free_typecast_heap_chain, allocated );
		allocated->next = NULL;
	} else {
		/* Append to the chain */
		allocated->next = DATA_PTR( *typecast_heap_chain );
		DATA_PTR( *typecast_heap_chain ) = allocated;
	}

	return &allocated->data[0];
}


static int
alloc_query_params(struct query_params_data *paramsData)
{
	VALUE param_value;
	t_typemap *p_typemap;
	int nParams;
	int i=0;
	t_pg_coder *conv;
	unsigned int required_pool_size;
	char *memory_pool;

	Check_Type(paramsData->params, T_ARRAY);

	p_typemap = DATA_PTR( paramsData->typemap );
	p_typemap->funcs.fit_to_query( paramsData->typemap, paramsData->params );

	paramsData->heap_pool = Qnil;
	paramsData->typecast_heap_chain = Qnil;
	paramsData->gc_array = Qnil;

	nParams = (int)RARRAY_LEN(paramsData->params);

	required_pool_size = nParams * (
			sizeof(char *) +
			sizeof(int) +
			sizeof(int) +
			(paramsData->with_types ? sizeof(Oid) : 0));

	if( sizeof(paramsData->memory_pool) < required_pool_size ){
		/* Allocate one combined memory pool for all possible function parameters */
		memory_pool = (char*)xmalloc( required_pool_size );
		/* Leave free'ing of the buffer to the GC, when paramsData has left the stack */
		paramsData->heap_pool = Data_Wrap_Struct( rb_cObject, NULL, -1, memory_pool );
		required_pool_size = 0;
	}else{
		/* Use stack memory for function parameters */
		memory_pool = paramsData->memory_pool;
	}

	paramsData->values = (char **)memory_pool;
	paramsData->lengths = (int *)((char*)paramsData->values + sizeof(char *) * nParams);
	paramsData->formats = (int *)((char*)paramsData->lengths + sizeof(int) * nParams);
	paramsData->types = (Oid *)((char*)paramsData->formats + sizeof(int) * nParams);

	{
		char *typecast_buf = paramsData->memory_pool + required_pool_size;

		for ( i = 0; i < nParams; i++ ) {
			param_value = rb_ary_entry(paramsData->params, i);

			paramsData->formats[i] = 0;
			if( paramsData->with_types )
				paramsData->types[i] = 0;

			/* Let the given typemap select a coder for this param */
			conv = p_typemap->funcs.typecast_query_param(p_typemap, param_value, i);

			/* Using a coder object for the param_value? Then set it's format code and oid. */
			if( conv ){
				paramsData->formats[i] = conv->format;
				if( paramsData->with_types )
					paramsData->types[i] = conv->oid;
			} else {
					/* No coder, but got we a hash form for the query param?
					 * Then take format code and oid from there. */
				if (TYPE(param_value) == T_HASH) {
					VALUE format_value = rb_hash_aref(param_value, sym_format);
					if( !NIL_P(format_value) )
						paramsData->formats[i] = NUM2INT(format_value);
					if( paramsData->with_types ){
						VALUE type_value = rb_hash_aref(param_value, sym_type);
						if( !NIL_P(type_value) )
							paramsData->types[i] = NUM2UINT(type_value);
					}
					param_value = rb_hash_aref(param_value, sym_value);
				}
			}

			if( NIL_P(param_value) ){
				paramsData->values[i] = NULL;
				paramsData->lengths[i] = 0;
			} else {
				t_pg_coder_enc_func enc_func = pg_coder_enc_func( conv );
				VALUE intermediate;

				/* 1st pass for retiving the required memory space */
				int len = enc_func(conv, param_value, NULL, &intermediate, paramsData->enc_idx);

				if( len == -1 ){
					/* The intermediate value is a String that can be used directly. */

					/* Ensure that the String object is zero terminated as expected by libpq. */
					if( paramsData->formats[i] == 0 )
						StringValueCStr(intermediate);
					/* In case a new string object was generated, make sure it doesn't get freed by the GC */
					if( intermediate != param_value ){
						if( NIL_P(paramsData->gc_array) )
							paramsData->gc_array = rb_ary_new();
						rb_ary_push(paramsData->gc_array, intermediate);
					}
					paramsData->values[i] = RSTRING_PTR(intermediate);
					paramsData->lengths[i] = RSTRING_LENINT(intermediate);

				} else {
					/* Is the stack memory pool too small to take the type casted value? */
					if( sizeof(paramsData->memory_pool) < required_pool_size + len + 1){
						typecast_buf = alloc_typecast_buf( &paramsData->typecast_heap_chain, len + 1 );
					}

					/* 2nd pass for writing the data to prepared buffer */
					len = enc_func(conv, param_value, typecast_buf, &intermediate, paramsData->enc_idx);
					paramsData->values[i] = typecast_buf;
					if( paramsData->formats[i] == 0 ){
						/* text format strings must be zero terminated and lengths are ignored */
						typecast_buf[len] = 0;
						typecast_buf += len + 1;
						required_pool_size += len + 1;
					} else {
						paramsData->lengths[i] = len;
						typecast_buf += len;
						required_pool_size += len;
					}
				}

				RB_GC_GUARD(intermediate);
			}
		}
	}

	return nParams;
}

static void
free_query_params(struct query_params_data *paramsData)
{
	/* currently nothing to free */
}

void
pgconn_query_assign_typemap( VALUE self, struct query_params_data *paramsData )
{
	if(NIL_P(paramsData->typemap)){
		/* Use default typemap for queries. It's type is checked when assigned. */
		paramsData->typemap = pg_get_connection(self)->type_map_for_queries;
	}else{
		/* Check type of method param */
		if ( !rb_obj_is_kind_of(paramsData->typemap, rb_cTypeMap) ) {
			rb_raise( rb_eTypeError, "wrong argument type %s (expected kind of PG::TypeMap)",
					rb_obj_classname( paramsData->typemap ) );
		}
		Check_Type( paramsData->typemap, T_DATA );
	}
}

/*
 * call-seq:
 *    conn.exec_params(sql, params[, result_format[, type_map]] ) -> PG::Result
 *    conn.exec_params(sql, params[, result_format[, type_map]] ) {|pg_result| block }
 *
 * Sends SQL query request specified by +sql+ to PostgreSQL using placeholders
 * for parameters.
 *
 * Returns a PG::Result instance on success. On failure, it raises a PG::Error.
 *
 * +params+ is an array of the bind parameters for the SQL query.
 * Each element of the +params+ array may be either:
 *   a hash of the form:
 *     {:value  => String (value of bind parameter)
 *      :type   => Integer (oid of type of bind parameter)
 *      :format => Integer (0 for text, 1 for binary)
 *     }
 *   or, it may be a String. If it is a string, that is equivalent to the hash:
 *     { :value => <string value>, :type => 0, :format => 0 }
 *
 * PostgreSQL bind parameters are represented as $1, $1, $2, etc.,
 * inside the SQL query. The 0th element of the +params+ array is bound
 * to $1, the 1st element is bound to $2, etc. +nil+ is treated as +NULL+.
 *
 * If the types are not specified, they will be inferred by PostgreSQL.
 * Instead of specifying type oids, it's recommended to simply add
 * explicit casts in the query to ensure that the right type is used.
 *
 * For example: "SELECT $1::int"
 *
 * The optional +result_format+ should be 0 for text results, 1
 * for binary.
 *
 * type_map can be a PG::TypeMap derivation (such as PG::BasicTypeMapForQueries).
 * This will type cast the params form various Ruby types before transmission
 * based on the encoders defined by the type map. When a type encoder is used
 * the format and oid of a given bind parameter are retrieved from the encoder
 * instead out of the hash form described above.
 *
 * If the optional code block is given, it will be passed <i>result</i> as an argument,
 * and the PG::Result object will  automatically be cleared when the block terminates.
 * In this instance, <code>conn.exec</code> returns the value of the block.
 */
static VALUE
pgconn_exec_params( int argc, VALUE *argv, VALUE self )
{
	PGconn *conn = pg_get_pgconn(self);
	PGresult *result = NULL;
	VALUE rb_pgresult;
	VALUE command, in_res_fmt;
	int nParams;
	int resultFormat;
	struct query_params_data paramsData = { ENCODING_GET(self) };

	rb_scan_args(argc, argv, "13", &command, &paramsData.params, &in_res_fmt, &paramsData.typemap);
	paramsData.with_types = 1;

	/*
	 * Handle the edge-case where the caller is coming from #exec, but passed an explict +nil+
	 * for the second parameter.
	 */
	if ( NIL_P(paramsData.params) ) {
		return pgconn_exec( 1, argv, self );
	}
	pgconn_query_assign_typemap( self, &paramsData );

	resultFormat = NIL_P(in_res_fmt) ? 0 : NUM2INT(in_res_fmt);
	nParams = alloc_query_params( &paramsData );

	result = gvl_PQexecParams(conn, pg_cstr_enc(command, paramsData.enc_idx), nParams, paramsData.types,
		(const char * const *)paramsData.values, paramsData.lengths, paramsData.formats, resultFormat);

	free_query_params( &paramsData );

	rb_pgresult = pg_new_result(result, self);
	pg_result_check(rb_pgresult);

	if (rb_block_given_p()) {
		return rb_ensure(rb_yield, rb_pgresult, pg_result_clear, rb_pgresult);
	}

	return rb_pgresult;
}

/*
 * call-seq:
 *    conn.prepare(stmt_name, sql [, param_types ] ) -> PG::Result
 *
 * Prepares statement _sql_ with name _name_ to be executed later.
 * Returns a PG::Result instance on success.
 * On failure, it raises a PG::Error.
 *
 * +param_types+ is an optional parameter to specify the Oids of the
 * types of the parameters.
 *
 * If the types are not specified, they will be inferred by PostgreSQL.
 * Instead of specifying type oids, it's recommended to simply add
 * explicit casts in the query to ensure that the right type is used.
 *
 * For example: "SELECT $1::int"
 *
 * PostgreSQL bind parameters are represented as $1, $1, $2, etc.,
 * inside the SQL query.
 */
static VALUE
pgconn_prepare(int argc, VALUE *argv, VALUE self)
{
	PGconn *conn = pg_get_pgconn(self);
	PGresult *result = NULL;
	VALUE rb_pgresult;
	VALUE name, command, in_paramtypes;
	VALUE param;
	int i = 0;
	int nParams = 0;
	Oid *paramTypes = NULL;
	const char *name_cstr;
	const char *command_cstr;
	int enc_idx = ENCODING_GET(self);

	rb_scan_args(argc, argv, "21", &name, &command, &in_paramtypes);
	name_cstr = pg_cstr_enc(name, enc_idx);
	command_cstr = pg_cstr_enc(command, enc_idx);

	if(! NIL_P(in_paramtypes)) {
		Check_Type(in_paramtypes, T_ARRAY);
		nParams = (int)RARRAY_LEN(in_paramtypes);
		paramTypes = ALLOC_N(Oid, nParams);
		for(i = 0; i < nParams; i++) {
			param = rb_ary_entry(in_paramtypes, i);
			if(param == Qnil)
				paramTypes[i] = 0;
			else
				paramTypes[i] = NUM2UINT(param);
		}
	}
	result = gvl_PQprepare(conn, name_cstr, command_cstr, nParams, paramTypes);

	xfree(paramTypes);

	rb_pgresult = pg_new_result(result, self);
	pg_result_check(rb_pgresult);
	return rb_pgresult;
}

/*
 * call-seq:
 *    conn.exec_prepared(statement_name [, params, result_format[, type_map]] ) -> PG::Result
 *    conn.exec_prepared(statement_name [, params, result_format[, type_map]] ) {|pg_result| block }
 *
 * Execute prepared named statement specified by _statement_name_.
 * Returns a PG::Result instance on success.
 * On failure, it raises a PG::Error.
 *
 * +params+ is an array of the optional bind parameters for the
 * SQL query. Each element of the +params+ array may be either:
 *   a hash of the form:
 *     {:value  => String (value of bind parameter)
 *      :format => Integer (0 for text, 1 for binary)
 *     }
 *   or, it may be a String. If it is a string, that is equivalent to the hash:
 *     { :value => <string value>, :format => 0 }
 *
 * PostgreSQL bind parameters are represented as $1, $1, $2, etc.,
 * inside the SQL query. The 0th element of the +params+ array is bound
 * to $1, the 1st element is bound to $2, etc. +nil+ is treated as +NULL+.
 *
 * The optional +result_format+ should be 0 for text results, 1
 * for binary.
 *
 * type_map can be a PG::TypeMap derivation (such as PG::BasicTypeMapForQueries).
 * This will type cast the params form various Ruby types before transmission
 * based on the encoders defined by the type map. When a type encoder is used
 * the format and oid of a given bind parameter are retrieved from the encoder
 * instead out of the hash form described above.
 *
 * If the optional code block is given, it will be passed <i>result</i> as an argument,
 * and the PG::Result object will  automatically be cleared when the block terminates.
 * In this instance, <code>conn.exec_prepared</code> returns the value of the block.
 */
static VALUE
pgconn_exec_prepared(int argc, VALUE *argv, VALUE self)
{
	PGconn *conn = pg_get_pgconn(self);
	PGresult *result = NULL;
	VALUE rb_pgresult;
	VALUE name, in_res_fmt;
	int nParams;
	int resultFormat;
	struct query_params_data paramsData = { ENCODING_GET(self) };

	rb_scan_args(argc, argv, "13", &name, &paramsData.params, &in_res_fmt, &paramsData.typemap);
	paramsData.with_types = 0;

	if(NIL_P(paramsData.params)) {
		paramsData.params = rb_ary_new2(0);
	}
	pgconn_query_assign_typemap( self, &paramsData );

	resultFormat = NIL_P(in_res_fmt) ? 0 : NUM2INT(in_res_fmt);
	nParams = alloc_query_params( &paramsData );

	result = gvl_PQexecPrepared(conn, pg_cstr_enc(name, paramsData.enc_idx), nParams,
		(const char * const *)paramsData.values, paramsData.lengths, paramsData.formats,
		resultFormat);

	free_query_params( &paramsData );

	rb_pgresult = pg_new_result(result, self);
	pg_result_check(rb_pgresult);
	if (rb_block_given_p()) {
		return rb_ensure(rb_yield, rb_pgresult,
			pg_result_clear, rb_pgresult);
	}
	return rb_pgresult;
}

/*
 * call-seq:
 *    conn.describe_prepared( statement_name ) -> PG::Result
 *
 * Retrieve information about the prepared statement
 * _statement_name_.
 */
static VALUE
pgconn_describe_prepared(VALUE self, VALUE stmt_name)
{
	PGresult *result;
	VALUE rb_pgresult;
	PGconn *conn = pg_get_pgconn(self);
	const char *stmt;
	if(NIL_P(stmt_name)) {
		stmt = NULL;
	}
	else {
		stmt = pg_cstr_enc(stmt_name, ENCODING_GET(self));
	}
	result = gvl_PQdescribePrepared(conn, stmt);
	rb_pgresult = pg_new_result(result, self);
	pg_result_check(rb_pgresult);
	return rb_pgresult;
}


/*
 * call-seq:
 *    conn.describe_portal( portal_name ) -> PG::Result
 *
 * Retrieve information about the portal _portal_name_.
 */
static VALUE
pgconn_describe_portal(self, stmt_name)
	VALUE self, stmt_name;
{
	PGresult *result;
	VALUE rb_pgresult;
	PGconn *conn = pg_get_pgconn(self);
	const char *stmt;
	if(NIL_P(stmt_name)) {
		stmt = NULL;
	}
	else {
		stmt = pg_cstr_enc(stmt_name, ENCODING_GET(self));
	}
	result = gvl_PQdescribePortal(conn, stmt);
	rb_pgresult = pg_new_result(result, self);
	pg_result_check(rb_pgresult);
	return rb_pgresult;
}


/*
 * call-seq:
 *    conn.make_empty_pgresult( status ) -> PG::Result
 *
 * Constructs and empty PG::Result with status _status_.
 * _status_ may be one of:
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
pgconn_make_empty_pgresult(VALUE self, VALUE status)
{
	PGresult *result;
	VALUE rb_pgresult;
	PGconn *conn = pg_get_pgconn(self);
	result = PQmakeEmptyPGresult(conn, NUM2INT(status));
	rb_pgresult = pg_new_result(result, self);
	pg_result_check(rb_pgresult);
	return rb_pgresult;
}


/*
 * call-seq:
 *    conn.escape_string( str ) -> String
 *
 * Returns a SQL-safe version of the String _str_.
 * This is the preferred way to make strings safe for inclusion in
 * SQL queries.
 *
 * Consider using exec_params, which avoids the need for passing values
 * inside of SQL commands.
 *
 * Encoding of escaped string will be equal to client encoding of connection.
 *
 * NOTE: This class version of this method can only be used safely in client
 * programs that use a single PostgreSQL connection at a time (in this case it can
 * find out what it needs to know "behind the scenes"). It might give the wrong
 * results if used in programs that use multiple database connections; use the
 * same method on the connection object in such cases.
 */
static VALUE
pgconn_s_escape(VALUE self, VALUE string)
{
	size_t size;
	int error;
	VALUE result;
	int enc_idx;
	int singleton = !rb_obj_is_kind_of(self, rb_cPGconn);

	Check_Type(string, T_STRING);
	enc_idx = ENCODING_GET( singleton ? string : self );
	if( ENCODING_GET(string) != enc_idx ){
		string = rb_str_export_to_enc(string, rb_enc_from_index(enc_idx));
	}

	result = rb_str_new(NULL, RSTRING_LEN(string) * 2 + 1);
	PG_ENCODING_SET_NOCHECK(result, enc_idx);
	if( !singleton ) {
		size = PQescapeStringConn(pg_get_pgconn(self), RSTRING_PTR(result),
			RSTRING_PTR(string), RSTRING_LEN(string), &error);
		if(error) {
			rb_raise(rb_ePGerror, "%s", PQerrorMessage(pg_get_pgconn(self)));
		}
	} else {
		size = PQescapeString(RSTRING_PTR(result), RSTRING_PTR(string), RSTRING_LEN(string));
	}
	rb_str_set_len(result, size);
	OBJ_INFECT(result, string);

	return result;
}

/*
 * call-seq:
 *   conn.escape_bytea( string ) -> String
 *
 * Escapes binary data for use within an SQL command with the type +bytea+.
 *
 * Certain byte values must be escaped (but all byte values may be escaped)
 * when used as part of a +bytea+ literal in an SQL statement. In general, to
 * escape a byte, it is converted into the three digit octal number equal to
 * the octet value, and preceded by two backslashes. The single quote (') and
 * backslash (\) characters have special alternative escape sequences.
 * #escape_bytea performs this operation, escaping only the minimally required
 * bytes.
 *
 * Consider using exec_params, which avoids the need for passing values inside of
 * SQL commands.
 *
 * NOTE: This class version of this method can only be used safely in client
 * programs that use a single PostgreSQL connection at a time (in this case it can
 * find out what it needs to know "behind the scenes"). It might give the wrong
 * results if used in programs that use multiple database connections; use the
 * same method on the connection object in such cases.
 */
static VALUE
pgconn_s_escape_bytea(VALUE self, VALUE str)
{
	unsigned char *from, *to;
	size_t from_len, to_len;
	VALUE ret;

	Check_Type(str, T_STRING);
	from      = (unsigned char*)RSTRING_PTR(str);
	from_len  = RSTRING_LEN(str);

	if ( rb_obj_is_kind_of(self, rb_cPGconn) ) {
		to = PQescapeByteaConn(pg_get_pgconn(self), from, from_len, &to_len);
	} else {
		to = PQescapeBytea( from, from_len, &to_len);
	}

	ret = rb_str_new((char*)to, to_len - 1);
	OBJ_INFECT(ret, str);
	PQfreemem(to);
	return ret;
}


/*
 * call-seq:
 *   PG::Connection.unescape_bytea( string )
 *
 * Converts an escaped string representation of binary data into binary data --- the
 * reverse of #escape_bytea. This is needed when retrieving +bytea+ data in text format,
 * but not when retrieving it in binary format.
 *
 */
static VALUE
pgconn_s_unescape_bytea(VALUE self, VALUE str)
{
	unsigned char *from, *to;
	size_t to_len;
	VALUE ret;

	UNUSED( self );

	Check_Type(str, T_STRING);
	from = (unsigned char*)StringValueCStr(str);

	to = PQunescapeBytea(from, &to_len);

	ret = rb_str_new((char*)to, to_len);
	OBJ_INFECT(ret, str);
	PQfreemem(to);
	return ret;
}

#ifdef HAVE_PQESCAPELITERAL
/*
 * call-seq:
 *    conn.escape_literal( str ) -> String
 *
 * Escape an arbitrary String +str+ as a literal.
 */
static VALUE
pgconn_escape_literal(VALUE self, VALUE string)
{
	PGconn *conn = pg_get_pgconn(self);
	char *escaped = NULL;
	VALUE error;
	VALUE result = Qnil;
	int enc_idx = ENCODING_GET(self);

	Check_Type(string, T_STRING);
	if( ENCODING_GET(string) != enc_idx ){
		string = rb_str_export_to_enc(string, rb_enc_from_index(enc_idx));
	}

	escaped = PQescapeLiteral(conn, RSTRING_PTR(string), RSTRING_LEN(string));
	if (escaped == NULL)
	{
		error = rb_exc_new2(rb_ePGerror, PQerrorMessage(conn));
		rb_iv_set(error, "@connection", self);
		rb_exc_raise(error);
		return Qnil;
	}
	result = rb_str_new2(escaped);
	PQfreemem(escaped);
	OBJ_INFECT(result, string);
	PG_ENCODING_SET_NOCHECK(result, enc_idx);

	return result;
}
#endif

#ifdef HAVE_PQESCAPEIDENTIFIER
/*
 * call-seq:
 *    conn.escape_identifier( str ) -> String
 *
 * Escape an arbitrary String +str+ as an identifier.
 *
 * This method does the same as #quote_ident with a String argument,
 * but it doesn't support an Array argument and it makes use of libpq
 * to process the string.
 */
static VALUE
pgconn_escape_identifier(VALUE self, VALUE string)
{
	PGconn *conn = pg_get_pgconn(self);
	char *escaped = NULL;
	VALUE error;
	VALUE result = Qnil;
	int enc_idx = ENCODING_GET(self);

	Check_Type(string, T_STRING);
	if( ENCODING_GET(string) != enc_idx ){
		string = rb_str_export_to_enc(string, rb_enc_from_index(enc_idx));
	}

	escaped = PQescapeIdentifier(conn, RSTRING_PTR(string), RSTRING_LEN(string));
	if (escaped == NULL)
	{
		error = rb_exc_new2(rb_ePGerror, PQerrorMessage(conn));
		rb_iv_set(error, "@connection", self);
		rb_exc_raise(error);
		return Qnil;
	}
	result = rb_str_new2(escaped);
	PQfreemem(escaped);
	OBJ_INFECT(result, string);
	PG_ENCODING_SET_NOCHECK(result, enc_idx);

	return result;
}
#endif

#ifdef HAVE_PQSETSINGLEROWMODE
/*
 * call-seq:
 *    conn.set_single_row_mode -> self
 *
 * To enter single-row mode, call this method immediately after a successful
 * call of send_query (or a sibling function). This mode selection is effective
 * only for the currently executing query.
 * Then call Connection#get_result repeatedly, until it returns nil.
 *
 * Each (but the last) received Result has exactly one row and a
 * Result#result_status of PGRES_SINGLE_TUPLE. The last Result has
 * zero rows and is used to indicate a successful execution of the query.
 * All of these Result objects will contain the same row description data
 * (column names, types, etc) that an ordinary Result object for the query
 * would have.
 *
 * *Caution:* While processing a query, the server may return some rows and
 * then encounter an error, causing the query to be aborted. Ordinarily, pg
 * discards any such rows and reports only the error. But in single-row mode,
 * those rows will have already been returned to the application. Hence, the
 * application will see some Result objects followed by an Error raised in get_result.
 * For proper transactional behavior, the application must be designed to discard
 * or undo whatever has been done with the previously-processed rows, if the query
 * ultimately fails.
 *
 * Example:
 *   conn.send_query( "your SQL command" )
 *   conn.set_single_row_mode
 *   loop do
 *     res = conn.get_result or break
 *     res.check
 *     res.each do |row|
 *       # do something with the received row
 *     end
 *   end
 *
 */
static VALUE
pgconn_set_single_row_mode(VALUE self)
{
	PGconn *conn = pg_get_pgconn(self);
	VALUE error;

	if( PQsetSingleRowMode(conn) == 0 )
	{
		error = rb_exc_new2(rb_ePGerror, PQerrorMessage(conn));
		rb_iv_set(error, "@connection", self);
		rb_exc_raise(error);
	}

	return self;
}
#endif

/*
 * call-seq:
 *    conn.send_query(sql [, params, result_format[, type_map ]] ) -> nil
 *
 * Sends SQL query request specified by _sql_ to PostgreSQL for
 * asynchronous processing, and immediately returns.
 * On failure, it raises a PG::Error.
 *
 * +params+ is an optional array of the bind parameters for the SQL query.
 * Each element of the +params+ array may be either:
 *   a hash of the form:
 *     {:value  => String (value of bind parameter)
 *      :type   => Integer (oid of type of bind parameter)
 *      :format => Integer (0 for text, 1 for binary)
 *     }
 *   or, it may be a String. If it is a string, that is equivalent to the hash:
 *     { :value => <string value>, :type => 0, :format => 0 }
 *
 * PostgreSQL bind parameters are represented as $1, $1, $2, etc.,
 * inside the SQL query. The 0th element of the +params+ array is bound
 * to $1, the 1st element is bound to $2, etc. +nil+ is treated as +NULL+.
 *
 * If the types are not specified, they will be inferred by PostgreSQL.
 * Instead of specifying type oids, it's recommended to simply add
 * explicit casts in the query to ensure that the right type is used.
 *
 * For example: "SELECT $1::int"
 *
 * The optional +result_format+ should be 0 for text results, 1
 * for binary.
 *
 * type_map can be a PG::TypeMap derivation (such as PG::BasicTypeMapForQueries).
 * This will type cast the params form various Ruby types before transmission
 * based on the encoders defined by the type map. When a type encoder is used
 * the format and oid of a given bind parameter are retrieved from the encoder
 * instead out of the hash form described above.
 *
 */
static VALUE
pgconn_send_query(int argc, VALUE *argv, VALUE self)
{
	PGconn *conn = pg_get_pgconn(self);
	int result;
	VALUE command, in_res_fmt;
	VALUE error;
	int nParams;
	int resultFormat;
	struct query_params_data paramsData = { ENCODING_GET(self) };

	rb_scan_args(argc, argv, "13", &command, &paramsData.params, &in_res_fmt, &paramsData.typemap);
	paramsData.with_types = 1;

	/* If called with no parameters, use PQsendQuery */
	if(NIL_P(paramsData.params)) {
		if(gvl_PQsendQuery(conn, pg_cstr_enc(command, paramsData.enc_idx)) == 0) {
			error = rb_exc_new2(rb_eUnableToSend, PQerrorMessage(conn));
			rb_iv_set(error, "@connection", self);
			rb_exc_raise(error);
		}
		return Qnil;
	}

	/* If called with parameters, and optionally result_format,
	 * use PQsendQueryParams
	 */

	pgconn_query_assign_typemap( self, &paramsData );
	resultFormat = NIL_P(in_res_fmt) ? 0 : NUM2INT(in_res_fmt);
	nParams = alloc_query_params( &paramsData );

	result = gvl_PQsendQueryParams(conn, pg_cstr_enc(command, paramsData.enc_idx), nParams, paramsData.types,
		(const char * const *)paramsData.values, paramsData.lengths, paramsData.formats, resultFormat);

	free_query_params( &paramsData );

	if(result == 0) {
		error = rb_exc_new2(rb_eUnableToSend, PQerrorMessage(conn));
		rb_iv_set(error, "@connection", self);
		rb_exc_raise(error);
	}
	return Qnil;
}

/*
 * call-seq:
 *    conn.send_prepare( stmt_name, sql [, param_types ] ) -> nil
 *
 * Prepares statement _sql_ with name _name_ to be executed later.
 * Sends prepare command asynchronously, and returns immediately.
 * On failure, it raises a PG::Error.
 *
 * +param_types+ is an optional parameter to specify the Oids of the
 * types of the parameters.
 *
 * If the types are not specified, they will be inferred by PostgreSQL.
 * Instead of specifying type oids, it's recommended to simply add
 * explicit casts in the query to ensure that the right type is used.
 *
 * For example: "SELECT $1::int"
 *
 * PostgreSQL bind parameters are represented as $1, $1, $2, etc.,
 * inside the SQL query.
 */
static VALUE
pgconn_send_prepare(int argc, VALUE *argv, VALUE self)
{
	PGconn *conn = pg_get_pgconn(self);
	int result;
	VALUE name, command, in_paramtypes;
	VALUE param;
	VALUE error;
	int i = 0;
	int nParams = 0;
	Oid *paramTypes = NULL;
	const char *name_cstr;
	const char *command_cstr;
	int enc_idx = ENCODING_GET(self);

	rb_scan_args(argc, argv, "21", &name, &command, &in_paramtypes);
	name_cstr = pg_cstr_enc(name, enc_idx);
	command_cstr = pg_cstr_enc(command, enc_idx);

	if(! NIL_P(in_paramtypes)) {
		Check_Type(in_paramtypes, T_ARRAY);
		nParams = (int)RARRAY_LEN(in_paramtypes);
		paramTypes = ALLOC_N(Oid, nParams);
		for(i = 0; i < nParams; i++) {
			param = rb_ary_entry(in_paramtypes, i);
			if(param == Qnil)
				paramTypes[i] = 0;
			else
				paramTypes[i] = NUM2UINT(param);
		}
	}
	result = gvl_PQsendPrepare(conn, name_cstr, command_cstr, nParams, paramTypes);

	xfree(paramTypes);

	if(result == 0) {
		error = rb_exc_new2(rb_eUnableToSend, PQerrorMessage(conn));
		rb_iv_set(error, "@connection", self);
		rb_exc_raise(error);
	}
	return Qnil;
}

/*
 * call-seq:
 *    conn.send_query_prepared( statement_name [, params, result_format[, type_map ]] )
 *      -> nil
 *
 * Execute prepared named statement specified by _statement_name_
 * asynchronously, and returns immediately.
 * On failure, it raises a PG::Error.
 *
 * +params+ is an array of the optional bind parameters for the
 * SQL query. Each element of the +params+ array may be either:
 *   a hash of the form:
 *     {:value  => String (value of bind parameter)
 *      :format => Integer (0 for text, 1 for binary)
 *     }
 *   or, it may be a String. If it is a string, that is equivalent to the hash:
 *     { :value => <string value>, :format => 0 }
 *
 * PostgreSQL bind parameters are represented as $1, $1, $2, etc.,
 * inside the SQL query. The 0th element of the +params+ array is bound
 * to $1, the 1st element is bound to $2, etc. +nil+ is treated as +NULL+.
 *
 * The optional +result_format+ should be 0 for text results, 1
 * for binary.
 *
 * type_map can be a PG::TypeMap derivation (such as PG::BasicTypeMapForQueries).
 * This will type cast the params form various Ruby types before transmission
 * based on the encoders defined by the type map. When a type encoder is used
 * the format and oid of a given bind parameter are retrieved from the encoder
 * instead out of the hash form described above.
 *
 */
static VALUE
pgconn_send_query_prepared(int argc, VALUE *argv, VALUE self)
{
	PGconn *conn = pg_get_pgconn(self);
	int result;
	VALUE name, in_res_fmt;
	VALUE error;
	int nParams;
	int resultFormat;
	struct query_params_data paramsData = { ENCODING_GET(self) };

	rb_scan_args(argc, argv, "13", &name, &paramsData.params, &in_res_fmt, &paramsData.typemap);
	paramsData.with_types = 0;

	if(NIL_P(paramsData.params)) {
		paramsData.params = rb_ary_new2(0);
		resultFormat = 0;
	}
	pgconn_query_assign_typemap( self, &paramsData );

	resultFormat = NIL_P(in_res_fmt) ? 0 : NUM2INT(in_res_fmt);
	nParams = alloc_query_params( &paramsData );

	result = gvl_PQsendQueryPrepared(conn, pg_cstr_enc(name, paramsData.enc_idx), nParams,
		(const char * const *)paramsData.values, paramsData.lengths, paramsData.formats,
		resultFormat);

	free_query_params( &paramsData );

	if(result == 0) {
		error = rb_exc_new2(rb_eUnableToSend, PQerrorMessage(conn));
		rb_iv_set(error, "@connection", self);
		rb_exc_raise(error);
	}
	return Qnil;
}

/*
 * call-seq:
 *    conn.send_describe_prepared( statement_name ) -> nil
 *
 * Asynchronously send _command_ to the server. Does not block.
 * Use in combination with +conn.get_result+.
 */
static VALUE
pgconn_send_describe_prepared(VALUE self, VALUE stmt_name)
{
	VALUE error;
	PGconn *conn = pg_get_pgconn(self);
	/* returns 0 on failure */
	if(gvl_PQsendDescribePrepared(conn, pg_cstr_enc(stmt_name, ENCODING_GET(self))) == 0) {
		error = rb_exc_new2(rb_eUnableToSend, PQerrorMessage(conn));
		rb_iv_set(error, "@connection", self);
		rb_exc_raise(error);
	}
	return Qnil;
}


/*
 * call-seq:
 *    conn.send_describe_portal( portal_name ) -> nil
 *
 * Asynchronously send _command_ to the server. Does not block.
 * Use in combination with +conn.get_result+.
 */
static VALUE
pgconn_send_describe_portal(VALUE self, VALUE portal)
{
	VALUE error;
	PGconn *conn = pg_get_pgconn(self);
	/* returns 0 on failure */
	if(gvl_PQsendDescribePortal(conn, pg_cstr_enc(portal, ENCODING_GET(self))) == 0) {
		error = rb_exc_new2(rb_eUnableToSend, PQerrorMessage(conn));
		rb_iv_set(error, "@connection", self);
		rb_exc_raise(error);
	}
	return Qnil;
}


/*
 * call-seq:
 *    conn.get_result() -> PG::Result
 *    conn.get_result() {|pg_result| block }
 *
 * Blocks waiting for the next result from a call to
 * #send_query (or another asynchronous command), and returns
 * it. Returns +nil+ if no more results are available.
 *
 * Note: call this function repeatedly until it returns +nil+, or else
 * you will not be able to issue further commands.
 *
 * If the optional code block is given, it will be passed <i>result</i> as an argument,
 * and the PG::Result object will  automatically be cleared when the block terminates.
 * In this instance, <code>conn.exec</code> returns the value of the block.
 */
static VALUE
pgconn_get_result(VALUE self)
{
	PGconn *conn = pg_get_pgconn(self);
	PGresult *result;
	VALUE rb_pgresult;

	result = gvl_PQgetResult(conn);
	if(result == NULL)
		return Qnil;
	rb_pgresult = pg_new_result(result, self);
	if (rb_block_given_p()) {
		return rb_ensure(rb_yield, rb_pgresult,
			pg_result_clear, rb_pgresult);
	}
	return rb_pgresult;
}

/*
 * call-seq:
 *    conn.consume_input()
 *
 * If input is available from the server, consume it.
 * After calling +consume_input+, you can check +is_busy+
 * or *notifies* to see if the state has changed.
 */
static VALUE
pgconn_consume_input(self)
	VALUE self;
{
	VALUE error;
	PGconn *conn = pg_get_pgconn(self);
	/* returns 0 on error */
	if(PQconsumeInput(conn) == 0) {
		error = rb_exc_new2(rb_eConnectionBad, PQerrorMessage(conn));
		rb_iv_set(error, "@connection", self);
		rb_exc_raise(error);
	}
	return Qnil;
}

/*
 * call-seq:
 *    conn.is_busy() -> Boolean
 *
 * Returns +true+ if a command is busy, that is, if
 * PQgetResult would block. Otherwise returns +false+.
 */
static VALUE
pgconn_is_busy(self)
	VALUE self;
{
	return gvl_PQisBusy(pg_get_pgconn(self)) ? Qtrue : Qfalse;
}

/*
 * call-seq:
 *    conn.setnonblocking(Boolean) -> nil
 *
 * Sets the nonblocking status of the connection.
 * In the blocking state, calls to #send_query
 * will block until the message is sent to the server,
 * but will not wait for the query results.
 * In the nonblocking state, calls to #send_query
 * will return an error if the socket is not ready for
 * writing.
 * Note: This function does not affect #exec, because
 * that function doesn't return until the server has
 * processed the query and returned the results.
 * Returns +nil+.
 */
static VALUE
pgconn_setnonblocking(self, state)
	VALUE self, state;
{
	int arg;
	VALUE error;
	PGconn *conn = pg_get_pgconn(self);
	if(state == Qtrue)
		arg = 1;
	else if (state == Qfalse)
		arg = 0;
	else
		rb_raise(rb_eArgError, "Boolean value expected");

	if(PQsetnonblocking(conn, arg) == -1) {
		error = rb_exc_new2(rb_ePGerror, PQerrorMessage(conn));
		rb_iv_set(error, "@connection", self);
		rb_exc_raise(error);
	}
	return Qnil;
}


/*
 * call-seq:
 *    conn.isnonblocking() -> Boolean
 *
 * Returns +true+ if a command is busy, that is, if
 * PQgetResult would block. Otherwise returns +false+.
 */
static VALUE
pgconn_isnonblocking(self)
	VALUE self;
{
	return PQisnonblocking(pg_get_pgconn(self)) ? Qtrue : Qfalse;
}

/*
 * call-seq:
 *    conn.flush() -> Boolean
 *
 * Attempts to flush any queued output data to the server.
 * Returns +true+ if data is successfully flushed, +false+
 * if not (can only return +false+ if connection is
 * nonblocking.
 * Raises PG::Error if some other failure occurred.
 */
static VALUE
pgconn_flush(self)
	VALUE self;
{
	PGconn *conn = pg_get_pgconn(self);
	int ret;
	VALUE error;
	ret = PQflush(conn);
	if(ret == -1) {
		error = rb_exc_new2(rb_ePGerror, PQerrorMessage(conn));
		rb_iv_set(error, "@connection", self);
		rb_exc_raise(error);
	}
	return (ret) ? Qfalse : Qtrue;
}

/*
 * call-seq:
 *    conn.cancel() -> String
 *
 * Requests cancellation of the command currently being
 * processed. (Only implemented in PostgreSQL >= 8.0)
 *
 * Returns +nil+ on success, or a string containing the
 * error message if a failure occurs.
 */
static VALUE
pgconn_cancel(VALUE self)
{
#ifdef HAVE_PQGETCANCEL
	char errbuf[256];
	PGcancel *cancel;
	VALUE retval;
	int ret;

	cancel = PQgetCancel(pg_get_pgconn(self));
	if(cancel == NULL)
		rb_raise(rb_ePGerror,"Invalid connection!");

	ret = gvl_PQcancel(cancel, errbuf, 256);
	if(ret == 1)
		retval = Qnil;
	else
		retval = rb_str_new2(errbuf);

	PQfreeCancel(cancel);
	return retval;
#else
	rb_notimplement();
#endif
}


/*
 * call-seq:
 *    conn.notifies()
 *
 * Returns a hash of the unprocessed notifications.
 * If there is no unprocessed notifier, it returns +nil+.
 */
static VALUE
pgconn_notifies(VALUE self)
{
	PGconn* conn = pg_get_pgconn(self);
	PGnotify *notification;
	VALUE hash;
	VALUE sym_relname, sym_be_pid, sym_extra;
	VALUE relname, be_pid, extra;

	sym_relname = ID2SYM(rb_intern("relname"));
	sym_be_pid = ID2SYM(rb_intern("be_pid"));
	sym_extra = ID2SYM(rb_intern("extra"));

	notification = gvl_PQnotifies(conn);
	if (notification == NULL) {
		return Qnil;
	}

	hash = rb_hash_new();
	relname = rb_tainted_str_new2(notification->relname);
	be_pid = INT2NUM(notification->be_pid);
	extra = rb_tainted_str_new2(notification->extra);
	PG_ENCODING_SET_NOCHECK( relname, ENCODING_GET(self) );
	PG_ENCODING_SET_NOCHECK( extra, ENCODING_GET(self) );

	rb_hash_aset(hash, sym_relname, relname);
	rb_hash_aset(hash, sym_be_pid, be_pid);
	rb_hash_aset(hash, sym_extra, extra);

	PQfreemem(notification);
	return hash;
}

/* Win32 + Ruby 1.8 */
#if !defined( HAVE_RUBY_VM_H ) && defined( _WIN32 )

/*
 * Duplicate the sockets from libpq and create temporary CRT FDs
 */
void create_crt_fd(fd_set *os_set, fd_set *crt_set)
{
	int i;
	crt_set->fd_count = os_set->fd_count;
	for (i = 0; i < os_set->fd_count; i++) {
		WSAPROTOCOL_INFO wsa_pi;
		/* dupicate the SOCKET */
		int r = WSADuplicateSocket(os_set->fd_array[i], GetCurrentProcessId(), &wsa_pi);
		SOCKET s = WSASocket(wsa_pi.iAddressFamily, wsa_pi.iSocketType, wsa_pi.iProtocol, &wsa_pi, 0, 0);
		/* create the CRT fd so ruby can get back to the SOCKET */
		int fd = _open_osfhandle(s, O_RDWR|O_BINARY);
		os_set->fd_array[i] = s;
		crt_set->fd_array[i] = fd;
	}
}

/*
 * Clean up the CRT FDs from create_crt_fd()
 */
void cleanup_crt_fd(fd_set *os_set, fd_set *crt_set)
{
	int i;
	for (i = 0; i < os_set->fd_count; i++) {
		/* cleanup the CRT fd */
		_close(crt_set->fd_array[i]);
		/* cleanup the duplicated SOCKET */
		closesocket(os_set->fd_array[i]);
	}
}
#endif

/* Win32 + Ruby 1.9+ */
#if defined( HAVE_RUBY_VM_H ) && defined( _WIN32 )
/*
 * On Windows, use platform-specific strategies to wait for the socket
 * instead of rb_thread_select().
 */

int rb_w32_wait_events( HANDLE *events, int num, DWORD timeout );

/* If WIN32 and Ruby 1.9 do not use rb_thread_select() which sometimes hangs
 * and does not wait (nor sleep) any time even if timeout is given.
 * Instead use the Winsock events and rb_w32_wait_events(). */

static void *
wait_socket_readable( PGconn *conn, struct timeval *ptimeout, void *(*is_readable)(PGconn *) )
{
	int sd = PQsocket( conn );
	void *retval;
	struct timeval aborttime={0,0}, currtime, waittime;
	DWORD timeout_milisec = INFINITE;
	DWORD wait_ret;
	WSAEVENT hEvent;

	if ( sd < 0 )
		rb_raise(rb_eConnectionBad, "PQsocket() can't get socket descriptor");

	hEvent = WSACreateEvent();

	/* Check for connection errors (PQisBusy is true on connection errors) */
	if( PQconsumeInput(conn) == 0 ) {
		WSACloseEvent( hEvent );
		rb_raise( rb_eConnectionBad, "PQconsumeInput() %s", PQerrorMessage(conn) );
	}

	if ( ptimeout ) {
		gettimeofday(&currtime, NULL);
		timeradd(&currtime, ptimeout, &aborttime);
	}

	while ( !(retval=is_readable(conn)) ) {
		if ( WSAEventSelect(sd, hEvent, FD_READ|FD_CLOSE) == SOCKET_ERROR ) {
			WSACloseEvent( hEvent );
			rb_raise( rb_eConnectionBad, "WSAEventSelect socket error: %d", WSAGetLastError() );
		}

		if ( ptimeout ) {
			gettimeofday(&currtime, NULL);
			timersub(&aborttime, &currtime, &waittime);
			timeout_milisec = (DWORD)( waittime.tv_sec * 1e3 + waittime.tv_usec / 1e3 );
		}

		/* Is the given timeout valid? */
		if( !ptimeout || (waittime.tv_sec >= 0 && waittime.tv_usec >= 0) ){
			/* Wait for the socket to become readable before checking again */
			wait_ret = rb_w32_wait_events( &hEvent, 1, timeout_milisec );
		} else {
			wait_ret = WAIT_TIMEOUT;
		}

		if ( wait_ret == WAIT_TIMEOUT ) {
			WSACloseEvent( hEvent );
			return NULL;
		} else if ( wait_ret == WAIT_OBJECT_0 ) {
			/* The event we were waiting for. */
		} else if ( wait_ret == WAIT_OBJECT_0 + 1) {
			/* This indicates interruption from timer thread, GC, exception
			 * from other threads etc... */
			rb_thread_check_ints();
		} else if ( wait_ret == WAIT_FAILED ) {
			WSACloseEvent( hEvent );
			rb_raise( rb_eConnectionBad, "Wait on socket error (WaitForMultipleObjects): %lu", GetLastError() );
		} else {
			WSACloseEvent( hEvent );
			rb_raise( rb_eConnectionBad, "Wait on socket abandoned (WaitForMultipleObjects)" );
		}

		/* Check for connection errors (PQisBusy is true on connection errors) */
		if ( PQconsumeInput(conn) == 0 ) {
			WSACloseEvent( hEvent );
			rb_raise( rb_eConnectionBad, "PQconsumeInput() %s", PQerrorMessage(conn) );
		}
	}

	WSACloseEvent( hEvent );
	return retval;
}

#else

/* non Win32 or Win32+Ruby-1.8 */

static void *
wait_socket_readable( PGconn *conn, struct timeval *ptimeout, void *(*is_readable)(PGconn *))
{
	int sd = PQsocket( conn );
	int ret;
	void *retval;
	rb_fdset_t sd_rset;
	struct timeval aborttime={0,0}, currtime, waittime;
#ifdef _WIN32
	rb_fdset_t crt_sd_rset;
#endif

	if ( sd < 0 )
		rb_raise(rb_eConnectionBad, "PQsocket() can't get socket descriptor");

	/* Check for connection errors (PQisBusy is true on connection errors) */
	if ( PQconsumeInput(conn) == 0 )
		rb_raise( rb_eConnectionBad, "PQconsumeInput() %s", PQerrorMessage(conn) );

	rb_fd_init( &sd_rset );

	if ( ptimeout ) {
		gettimeofday(&currtime, NULL);
		timeradd(&currtime, ptimeout, &aborttime);
	}

	while ( !(retval=is_readable(conn)) ) {
		rb_fd_zero( &sd_rset );
		rb_fd_set( sd, &sd_rset );

#ifdef _WIN32
		/* Ruby's FD_SET is modified on win32 to convert a file descriptor
		 * to osfhandle, but we already get a osfhandle from PQsocket().
		 * Therefore it's overwritten here. */
		sd_rset.fd_array[0] = sd;
		create_crt_fd(&sd_rset, &crt_sd_rset);
#endif

		if ( ptimeout ) {
			gettimeofday(&currtime, NULL);
			timersub(&aborttime, &currtime, &waittime);
		}

		/* Is the given timeout valid? */
		if( !ptimeout || (waittime.tv_sec >= 0 && waittime.tv_usec >= 0) ){
			/* Wait for the socket to become readable before checking again */
			ret = rb_thread_fd_select( sd+1, &sd_rset, NULL, NULL, ptimeout ? &waittime : NULL );
		} else {
			ret = 0;
		}


#ifdef _WIN32
		cleanup_crt_fd(&sd_rset, &crt_sd_rset);
#endif

		if ( ret < 0 ){
			rb_fd_term( &sd_rset );
			rb_sys_fail( "rb_thread_select()" );
		}

		/* Return false if the select() timed out */
		if ( ret == 0 ){
			rb_fd_term( &sd_rset );
			return NULL;
		}

		/* Check for connection errors (PQisBusy is true on connection errors) */
		if ( PQconsumeInput(conn) == 0 ){
			rb_fd_term( &sd_rset );
			rb_raise( rb_eConnectionBad, "PQconsumeInput() %s", PQerrorMessage(conn) );
		}
	}

	rb_fd_term( &sd_rset );
	return retval;
}


#endif

static void *
notify_readable(PGconn *conn)
{
	return (void*)gvl_PQnotifies(conn);
}

/*
 * call-seq:
 *    conn.wait_for_notify( [ timeout ] ) -> String
 *    conn.wait_for_notify( [ timeout ] ) { |event, pid| block }
 *    conn.wait_for_notify( [ timeout ] ) { |event, pid, payload| block } # PostgreSQL 9.0
 *
 * Blocks while waiting for notification(s), or until the optional
 * _timeout_ is reached, whichever comes first.  _timeout_ is
 * measured in seconds and can be fractional.
 *
 * Returns +nil+ if _timeout_ is reached, the name of the NOTIFY
 * event otherwise.  If used in block form, passes the name of the
 * NOTIFY +event+ and the generating +pid+ into the block.
 *
 * Under PostgreSQL 9.0 and later, if the notification is sent with
 * the optional +payload+ string, it will be given to the block as the
 * third argument.
 *
 */
static VALUE
pgconn_wait_for_notify(int argc, VALUE *argv, VALUE self)
{
	PGconn *conn = pg_get_pgconn( self );
	PGnotify *pnotification;
	struct timeval timeout;
	struct timeval *ptimeout = NULL;
	VALUE timeout_in = Qnil, relname = Qnil, be_pid = Qnil, extra = Qnil;
	double timeout_sec;

	rb_scan_args( argc, argv, "01", &timeout_in );

	if ( RTEST(timeout_in) ) {
		timeout_sec = NUM2DBL( timeout_in );
		timeout.tv_sec = (time_t)timeout_sec;
		timeout.tv_usec = (suseconds_t)( (timeout_sec - (long)timeout_sec) * 1e6 );
		ptimeout = &timeout;
	}

	pnotification = (PGnotify*) wait_socket_readable( conn, ptimeout, notify_readable);

	/* Return nil if the select timed out */
	if ( !pnotification ) return Qnil;

	relname = rb_tainted_str_new2( pnotification->relname );
	PG_ENCODING_SET_NOCHECK( relname, ENCODING_GET(self) );
	be_pid = INT2NUM( pnotification->be_pid );
#ifdef HAVE_ST_NOTIFY_EXTRA
	if ( *pnotification->extra ) {
		extra = rb_tainted_str_new2( pnotification->extra );
		PG_ENCODING_SET_NOCHECK( extra, ENCODING_GET(self) );
	}
#endif
	PQfreemem( pnotification );

	if ( rb_block_given_p() )
		rb_yield_values( 3, relname, be_pid, extra );

	return relname;
}


/*
 * call-seq:
 *    conn.put_copy_data( buffer [, encoder] ) -> Boolean
 *
 * Transmits _buffer_ as copy data to the server.
 * Returns true if the data was sent, false if it was
 * not sent (false is only possible if the connection
 * is in nonblocking mode, and this command would block).
 *
 * encoder can be a PG::Coder derivation (typically PG::TextEncoder::CopyRow).
 * This encodes the received data fields from an Array of Strings. Optionally
 * the encoder can type cast the fields form various Ruby types in one step,
 * if PG::TextEncoder::CopyRow#type_map is set accordingly.
 *
 * Raises an exception if an error occurs.
 *
 * See also #copy_data.
 *
 */
static VALUE
pgconn_put_copy_data(int argc, VALUE *argv, VALUE self)
{
	int ret;
	int len;
	t_pg_connection *this = pg_get_connection_safe( self );
	VALUE value;
	VALUE buffer = Qnil;
	VALUE encoder;
	VALUE intermediate;
	t_pg_coder *p_coder = NULL;

	rb_scan_args( argc, argv, "11", &value, &encoder );

	if( NIL_P(encoder) ){
		if( NIL_P(this->encoder_for_put_copy_data) ){
			buffer = value;
		} else {
			p_coder = DATA_PTR( this->encoder_for_put_copy_data );
		}
	} else if( rb_obj_is_kind_of(encoder, rb_cPG_Coder) ) {
		Data_Get_Struct( encoder, t_pg_coder, p_coder );
	} else {
		rb_raise( rb_eTypeError, "wrong encoder type %s (expected some kind of PG::Coder)",
				rb_obj_classname( encoder ) );
	}

	if( p_coder ){
		t_pg_coder_enc_func enc_func;
		int enc_idx = ENCODING_GET(self);

		enc_func = pg_coder_enc_func( p_coder );
		len = enc_func( p_coder, value, NULL, &intermediate, enc_idx);

		if( len == -1 ){
			/* The intermediate value is a String that can be used directly. */
			buffer = intermediate;
		} else {
			buffer = rb_str_new(NULL, len);
			len = enc_func( p_coder, value, RSTRING_PTR(buffer), &intermediate, enc_idx);
			rb_str_set_len( buffer, len );
		}
	}

	Check_Type(buffer, T_STRING);

	ret = gvl_PQputCopyData(this->pgconn, RSTRING_PTR(buffer), RSTRING_LENINT(buffer));
	if(ret == -1) {
		VALUE error = rb_exc_new2(rb_ePGerror, PQerrorMessage(this->pgconn));
		rb_iv_set(error, "@connection", self);
		rb_exc_raise(error);
	}
	RB_GC_GUARD(intermediate);
	RB_GC_GUARD(buffer);

	return (ret) ? Qtrue : Qfalse;
}

/*
 * call-seq:
 *    conn.put_copy_end( [ error_message ] ) -> Boolean
 *
 * Sends end-of-data indication to the server.
 *
 * _error_message_ is an optional parameter, and if set,
 * forces the COPY command to fail with the string
 * _error_message_.
 *
 * Returns true if the end-of-data was sent, false if it was
 * not sent (false is only possible if the connection
 * is in nonblocking mode, and this command would block).
 */
static VALUE
pgconn_put_copy_end(int argc, VALUE *argv, VALUE self)
{
	VALUE str;
	VALUE error;
	int ret;
	const char *error_message = NULL;
	PGconn *conn = pg_get_pgconn(self);

	if (rb_scan_args(argc, argv, "01", &str) == 0)
		error_message = NULL;
	else
		error_message = pg_cstr_enc(str, ENCODING_GET(self));

	ret = gvl_PQputCopyEnd(conn, error_message);
	if(ret == -1) {
		error = rb_exc_new2(rb_ePGerror, PQerrorMessage(conn));
		rb_iv_set(error, "@connection", self);
		rb_exc_raise(error);
	}
	return (ret) ? Qtrue : Qfalse;
}

/*
 * call-seq:
 *    conn.get_copy_data( [ async = false [, decoder = nil ]] ) -> String
 *
 * Return a string containing one row of data, +nil+
 * if the copy is done, or +false+ if the call would
 * block (only possible if _async_ is true).
 *
 * decoder can be a PG::Coder derivation (typically PG::TextDecoder::CopyRow).
 * This decodes the received data fields as Array of Strings. Optionally
 * the decoder can type cast the fields to various Ruby types in one step,
 * if PG::TextDecoder::CopyRow#type_map is set accordingly.
 *
 * See also #copy_data.
 *
 */
static VALUE
pgconn_get_copy_data(int argc, VALUE *argv, VALUE self )
{
	VALUE async_in;
	VALUE error;
	VALUE result;
	int ret;
	char *buffer;
	VALUE decoder;
	t_pg_coder *p_coder = NULL;
	t_pg_connection *this = pg_get_connection_safe( self );

	rb_scan_args(argc, argv, "02", &async_in, &decoder);

	if( NIL_P(decoder) ){
		if( !NIL_P(this->decoder_for_get_copy_data) ){
			p_coder = DATA_PTR( this->decoder_for_get_copy_data );
		}
	} else if( rb_obj_is_kind_of(decoder, rb_cPG_Coder) ) {
		Data_Get_Struct( decoder, t_pg_coder, p_coder );
	} else {
		rb_raise( rb_eTypeError, "wrong decoder type %s (expected some kind of PG::Coder)",
				rb_obj_classname( decoder ) );
	}

	ret = gvl_PQgetCopyData(this->pgconn, &buffer, RTEST(async_in));
	if(ret == -2) { /* error */
		error = rb_exc_new2(rb_ePGerror, PQerrorMessage(this->pgconn));
		rb_iv_set(error, "@connection", self);
		rb_exc_raise(error);
	}
	if(ret == -1) { /* No data left */
		return Qnil;
	}
	if(ret == 0) { /* would block */
		return Qfalse;
	}

	if( p_coder ){
		t_pg_coder_dec_func dec_func = pg_coder_dec_func( p_coder, p_coder->format );
		result =  dec_func( p_coder, buffer, ret, 0, 0, ENCODING_GET(self) );
	} else {
		result = rb_tainted_str_new(buffer, ret);
	}

	PQfreemem(buffer);
	return result;
}

/*
 * call-seq:
 *    conn.set_error_verbosity( verbosity ) -> Integer
 *
 * Sets connection's verbosity to _verbosity_ and returns
 * the previous setting. Available settings are:
 * * PQERRORS_TERSE
 * * PQERRORS_DEFAULT
 * * PQERRORS_VERBOSE
 */
static VALUE
pgconn_set_error_verbosity(VALUE self, VALUE in_verbosity)
{
	PGconn *conn = pg_get_pgconn(self);
	PGVerbosity verbosity = NUM2INT(in_verbosity);
	return INT2FIX(PQsetErrorVerbosity(conn, verbosity));
}

/*
 * call-seq:
 *    conn.trace( stream ) -> nil
 *
 * Enables tracing message passing between backend. The
 * trace message will be written to the stream _stream_,
 * which must implement a method +fileno+ that returns
 * a writable file descriptor.
 */
static VALUE
pgconn_trace(VALUE self, VALUE stream)
{
	VALUE fileno;
	FILE *new_fp;
	int old_fd, new_fd;
	VALUE new_file;
	t_pg_connection *this = pg_get_connection_safe( self );

	if(rb_respond_to(stream,rb_intern("fileno")) == Qfalse)
		rb_raise(rb_eArgError, "stream does not respond to method: fileno");

	fileno = rb_funcall(stream, rb_intern("fileno"), 0);
	if(fileno == Qnil)
		rb_raise(rb_eArgError, "can't get file descriptor from stream");

	/* Duplicate the file descriptor and re-open
	 * it. Then, make it into a ruby File object
	 * and assign it to an instance variable.
	 * This prevents a problem when the File
	 * object passed to this function is closed
	 * before the connection object is. */
	old_fd = NUM2INT(fileno);
	new_fd = dup(old_fd);
	new_fp = fdopen(new_fd, "w");

	if(new_fp == NULL)
		rb_raise(rb_eArgError, "stream is not writable");

	new_file = rb_funcall(rb_cIO, rb_intern("new"), 1, INT2NUM(new_fd));
	this->trace_stream = new_file;

	PQtrace(this->pgconn, new_fp);
	return Qnil;
}

/*
 * call-seq:
 *    conn.untrace() -> nil
 *
 * Disables the message tracing.
 */
static VALUE
pgconn_untrace(VALUE self)
{
	t_pg_connection *this = pg_get_connection_safe( self );

	PQuntrace(this->pgconn);
	rb_funcall(this->trace_stream, rb_intern("close"), 0);
	this->trace_stream = Qnil;
	return Qnil;
}


/*
 * Notice callback proxy function -- delegate the callback to the
 * currently-registered Ruby notice_receiver object.
 */
void
notice_receiver_proxy(void *arg, const PGresult *pgresult)
{
	VALUE self = (VALUE)arg;
	t_pg_connection *this = pg_get_connection( self );

	if (this->notice_receiver != Qnil) {
		VALUE result = pg_new_result_autoclear( (PGresult *)pgresult, self );

		rb_funcall(this->notice_receiver, rb_intern("call"), 1, result);
		pg_result_clear( result );
	}
	return;
}

/*
 * call-seq:
 *   conn.set_notice_receiver {|result| ... } -> Proc
 *
 * Notice and warning messages generated by the server are not returned
 * by the query execution functions, since they do not imply failure of
 * the query. Instead they are passed to a notice handling function, and
 * execution continues normally after the handler returns. The default
 * notice handling function prints the message on <tt>stderr</tt>, but the
 * application can override this behavior by supplying its own handling
 * function.
 *
 * For historical reasons, there are two levels of notice handling, called the
 * notice receiver and notice processor. The default behavior is for the notice
 * receiver to format the notice and pass a string to the notice processor for
 * printing. However, an application that chooses to provide its own notice
 * receiver will typically ignore the notice processor layer and just do all
 * the work in the notice receiver.
 *
 * This function takes a new block to act as the handler, which should
 * accept a single parameter that will be a PG::Result object, and returns
 * the Proc object previously set, or +nil+ if it was previously the default.
 *
 * If you pass no arguments, it will reset the handler to the default.
 *
 * *Note:* The +result+ passed to the block should not be used outside
 * of the block, since the corresponding C object could be freed after the
 * block finishes.
 */
static VALUE
pgconn_set_notice_receiver(VALUE self)
{
	VALUE proc, old_proc;
	t_pg_connection *this = pg_get_connection_safe( self );

	/* If default_notice_receiver is unset, assume that the current
	 * notice receiver is the default, and save it to a global variable.
	 * This should not be a problem because the default receiver is
	 * always the same, so won't vary among connections.
	 */
	if(default_notice_receiver == NULL)
		default_notice_receiver = PQsetNoticeReceiver(this->pgconn, NULL, NULL);

	old_proc = this->notice_receiver;
	if( rb_block_given_p() ) {
		proc = rb_block_proc();
		PQsetNoticeReceiver(this->pgconn, gvl_notice_receiver_proxy, (void *)self);
	} else {
		/* if no block is given, set back to default */
		proc = Qnil;
		PQsetNoticeReceiver(this->pgconn, default_notice_receiver, NULL);
	}

	this->notice_receiver = proc;
	return old_proc;
}


/*
 * Notice callback proxy function -- delegate the callback to the
 * currently-registered Ruby notice_processor object.
 */
void
notice_processor_proxy(void *arg, const char *message)
{
	VALUE self = (VALUE)arg;
	t_pg_connection *this = pg_get_connection( self );

	if (this->notice_receiver != Qnil) {
		VALUE message_str = rb_tainted_str_new2(message);
		PG_ENCODING_SET_NOCHECK( message_str, ENCODING_GET(self) );
		rb_funcall(this->notice_receiver, rb_intern("call"), 1, message_str);
	}
	return;
}

/*
 * call-seq:
 *   conn.set_notice_processor {|message| ... } -> Proc
 *
 * See #set_notice_receiver for the desription of what this and the
 * notice_processor methods do.
 *
 * This function takes a new block to act as the notice processor and returns
 * the Proc object previously set, or +nil+ if it was previously the default.
 * The block should accept a single String object.
 *
 * If you pass no arguments, it will reset the handler to the default.
 */
static VALUE
pgconn_set_notice_processor(VALUE self)
{
	VALUE proc, old_proc;
	t_pg_connection *this = pg_get_connection_safe( self );

	/* If default_notice_processor is unset, assume that the current
	 * notice processor is the default, and save it to a global variable.
	 * This should not be a problem because the default processor is
	 * always the same, so won't vary among connections.
	 */
	if(default_notice_processor == NULL)
		default_notice_processor = PQsetNoticeProcessor(this->pgconn, NULL, NULL);

	old_proc = this->notice_receiver;
	if( rb_block_given_p() ) {
		proc = rb_block_proc();
		PQsetNoticeProcessor(this->pgconn, gvl_notice_processor_proxy, (void *)self);
	} else {
		/* if no block is given, set back to default */
		proc = Qnil;
		PQsetNoticeProcessor(this->pgconn, default_notice_processor, NULL);
	}

	this->notice_receiver = proc;
	return old_proc;
}


/*
 * call-seq:
 *    conn.get_client_encoding() -> String
 *
 * Returns the client encoding as a String.
 */
static VALUE
pgconn_get_client_encoding(VALUE self)
{
	char *encoding = (char *)pg_encoding_to_char(PQclientEncoding(pg_get_pgconn(self)));
	return rb_tainted_str_new2(encoding);
}


/*
 * call-seq:
 *    conn.set_client_encoding( encoding )
 *
 * Sets the client encoding to the _encoding_ String.
 */
static VALUE
pgconn_set_client_encoding(VALUE self, VALUE str)
{
	PGconn *conn = pg_get_pgconn( self );

	Check_Type(str, T_STRING);

	if ( (gvl_PQsetClientEncoding(conn, StringValueCStr(str))) == -1 ) {
		rb_raise(rb_ePGerror, "invalid encoding name: %s",StringValueCStr(str));
	}
#ifdef M17N_SUPPORTED
	pgconn_set_internal_encoding_index( self );
#endif

	return Qnil;
}

/*
 * call-seq:
 *    conn.transaction { |conn| ... } -> result of the block
 *
 * Executes a +BEGIN+ at the start of the block,
 * and a +COMMIT+ at the end of the block, or
 * +ROLLBACK+ if any exception occurs.
 */
static VALUE
pgconn_transaction(VALUE self)
{
	PGconn *conn = pg_get_pgconn(self);
	PGresult *result;
	VALUE rb_pgresult;
	VALUE block_result = Qnil;
	int status;

	if (rb_block_given_p()) {
		result = gvl_PQexec(conn, "BEGIN");
		rb_pgresult = pg_new_result(result, self);
		pg_result_check(rb_pgresult);
		block_result = rb_protect(rb_yield, self, &status);
		if(status == 0) {
			result = gvl_PQexec(conn, "COMMIT");
			rb_pgresult = pg_new_result(result, self);
			pg_result_check(rb_pgresult);
		}
		else {
			/* exception occurred, ROLLBACK and re-raise */
			result = gvl_PQexec(conn, "ROLLBACK");
			rb_pgresult = pg_new_result(result, self);
			pg_result_check(rb_pgresult);
			rb_jump_tag(status);
		}

	}
	else {
		/* no block supplied? */
		rb_raise(rb_eArgError, "Must supply block for PG::Connection#transaction");
	}
	return block_result;
}


/*
 * call-seq:
 *    conn.quote_ident( str ) -> String
 *    conn.quote_ident( array ) -> String
 *    PG::Connection.quote_ident( str ) -> String
 *    PG::Connection.quote_ident( array ) -> String
 *
 * Returns a string that is safe for inclusion in a SQL query as an
 * identifier. Note: this is not a quote function for values, but for
 * identifiers.
 *
 * For example, in a typical SQL query: <tt>SELECT FOO FROM MYTABLE</tt>
 * The identifier <tt>FOO</tt> is folded to lower case, so it actually
 * means <tt>foo</tt>. If you really want to access the case-sensitive
 * field name <tt>FOO</tt>, use this function like
 * <tt>conn.quote_ident('FOO')</tt>, which will return <tt>"FOO"</tt>
 * (with double-quotes). PostgreSQL will see the double-quotes, and
 * it will not fold to lower case.
 *
 * Similarly, this function also protects against special characters,
 * and other things that might allow SQL injection if the identifier
 * comes from an untrusted source.
 *
 * If the parameter is an Array, then all it's values are separately quoted
 * and then joined by a "." character. This can be used for identifiers in
 * the form "schema"."table"."column" .
 *
 * This method is functional identical to the encoder PG::TextEncoder::Identifier .
 *
 * If the instance method form is used and the input string character encoding
 * is different to the connection encoding, then the string is converted to this
 * encoding, so that the returned string is always encoded as PG::Connection#internal_encoding .
 *
 * In the singleton form (PG::Connection.quote_ident) the character encoding
 * of the result string is set to the character encoding of the input string.
 */
static VALUE
pgconn_s_quote_ident(VALUE self, VALUE str_or_array)
{
	VALUE ret;
	int enc_idx;

	if( rb_obj_is_kind_of(self, rb_cPGconn) ){
		enc_idx = ENCODING_GET( self );
	}else{
		enc_idx = RB_TYPE_P(str_or_array, T_STRING) ? ENCODING_GET( str_or_array ) : rb_ascii8bit_encindex();
	}
	pg_text_enc_identifier(NULL, str_or_array, NULL, &ret, enc_idx);

	OBJ_INFECT(ret, str_or_array);

	return ret;
}


static void *
get_result_readable(PGconn *conn)
{
	return gvl_PQisBusy(conn) ? NULL : (void*)1;
}


/*
 * call-seq:
 *    conn.block( [ timeout ] ) -> Boolean
 *
 * Blocks until the server is no longer busy, or until the
 * optional _timeout_ is reached, whichever comes first.
 * _timeout_ is measured in seconds and can be fractional.
 *
 * Returns +false+ if _timeout_ is reached, +true+ otherwise.
 *
 * If +true+ is returned, +conn.is_busy+ will return +false+
 * and +conn.get_result+ will not block.
 */
static VALUE
pgconn_block( int argc, VALUE *argv, VALUE self ) {
	PGconn *conn = pg_get_pgconn( self );

	/* If WIN32 and Ruby 1.9 do not use rb_thread_select() which sometimes hangs
	 * and does not wait (nor sleep) any time even if timeout is given.
	 * Instead use the Winsock events and rb_w32_wait_events(). */

	struct timeval timeout;
	struct timeval *ptimeout = NULL;
	VALUE timeout_in;
	double timeout_sec;
	void *ret;

	if ( rb_scan_args(argc, argv, "01", &timeout_in) == 1 ) {
		timeout_sec = NUM2DBL( timeout_in );
		timeout.tv_sec = (time_t)timeout_sec;
		timeout.tv_usec = (suseconds_t)((timeout_sec - (long)timeout_sec) * 1e6);
		ptimeout = &timeout;
	}

	ret = wait_socket_readable( conn, ptimeout, get_result_readable);

	if( !ret )
		return Qfalse;

	return Qtrue;
}


/*
 * call-seq:
 *    conn.get_last_result( ) -> PG::Result
 *
 * This function retrieves all available results
 * on the current connection (from previously issued
 * asynchronous commands like +send_query()+) and
 * returns the last non-NULL result, or +nil+ if no
 * results are available.
 *
 * This function is similar to #get_result
 * except that it is designed to get one and only
 * one result.
 */
static VALUE
pgconn_get_last_result(VALUE self)
{
	PGconn *conn = pg_get_pgconn(self);
	VALUE rb_pgresult = Qnil;
	PGresult *cur, *prev;


	cur = prev = NULL;
	while ((cur = gvl_PQgetResult(conn)) != NULL) {
		int status;

		if (prev) PQclear(prev);
		prev = cur;

		status = PQresultStatus(cur);
		if (status == PGRES_COPY_OUT || status == PGRES_COPY_IN)
			break;
	}

	if (prev) {
		rb_pgresult = pg_new_result( prev, self );
		pg_result_check(rb_pgresult);
	}

	return rb_pgresult;
}

/*
 * call-seq:
 *    conn.async_exec(sql [, params, result_format ] ) -> PG::Result
 *    conn.async_exec(sql [, params, result_format ] ) {|pg_result| block }
 *
 * This function has the same behavior as #exec,
 * but is implemented using the asynchronous command
 * processing API of libpq.
 */
static VALUE
pgconn_async_exec(int argc, VALUE *argv, VALUE self)
{
	VALUE rb_pgresult = Qnil;

	/* remove any remaining results from the queue */
	pgconn_block( 0, NULL, self ); /* wait for input (without blocking) before reading the last result */
	pgconn_get_last_result( self );

	pgconn_send_query( argc, argv, self );
	pgconn_block( 0, NULL, self );
	rb_pgresult = pgconn_get_last_result( self );

	if ( rb_block_given_p() ) {
		return rb_ensure( rb_yield, rb_pgresult, pg_result_clear, rb_pgresult );
	}
	return rb_pgresult;
}


#ifdef HAVE_PQSSLATTRIBUTE
/* Since PostgreSQL-9.5: */

/*
 * call-seq:
 *    conn.ssl_in_use? -> Boolean
 *
 * Returns +true+ if the connection uses SSL, +false+ if not.
 *
 */
static VALUE
pgconn_ssl_in_use(VALUE self)
{
	return PQsslInUse(pg_get_pgconn(self)) ? Qtrue : Qfalse;
}


/*
 * call-seq:
 *    conn.ssl_attribute(attribute_name) -> String
 *
 * Returns SSL-related information about the connection.
 *
 * The list of available attributes varies depending on the SSL library being used,
 * and the type of connection. If an attribute is not available, returns nil.
 *
 * The following attributes are commonly available:
 *
 * [+library+]
 *   Name of the SSL implementation in use. (Currently, only "OpenSSL" is implemented)
 * [+protocol+]
 *   SSL/TLS version in use. Common values are "SSLv2", "SSLv3", "TLSv1", "TLSv1.1" and "TLSv1.2", but an implementation may return other strings if some other protocol is used.
 * [+key_bits+]
 *   Number of key bits used by the encryption algorithm.
 * [+cipher+]
 *   A short name of the ciphersuite used, e.g. "DHE-RSA-DES-CBC3-SHA". The names are specific to each SSL implementation.
 * [+compression+]
 *   If SSL compression is in use, returns the name of the compression algorithm, or "on" if compression is used but the algorithm is not known. If compression is not in use, returns "off".
 *
 *
 * See also #ssl_attribute_names and http://www.postgresql.org/docs/current/interactive/libpq-status.html#LIBPQ-PQSSLATTRIBUTE
 */
static VALUE
pgconn_ssl_attribute(VALUE self, VALUE attribute_name)
{
	const char *p_attr;

	p_attr = PQsslAttribute(pg_get_pgconn(self), StringValueCStr(attribute_name));
	return p_attr ? rb_str_new_cstr(p_attr) : Qnil;
}

/*
 * call-seq:
 *    conn.ssl_attribute_names -> Array<String>
 *
 * Return an array of SSL attribute names available.
 *
 * See also #ssl_attribute
 *
 */
static VALUE
pgconn_ssl_attribute_names(VALUE self)
{
	int i;
	const char * const * p_list = PQsslAttributeNames(pg_get_pgconn(self));
	VALUE ary = rb_ary_new();

	for ( i = 0; p_list[i]; i++ ) {
		rb_ary_push( ary, rb_str_new_cstr( p_list[i] ));
	}
	return ary;
}


#endif


/**************************************************************************
 * LARGE OBJECT SUPPORT
 **************************************************************************/

/*
 * call-seq:
 *    conn.lo_creat( [mode] ) -> Integer
 *
 * Creates a large object with mode _mode_. Returns a large object Oid.
 * On failure, it raises PG::Error.
 */
static VALUE
pgconn_locreat(int argc, VALUE *argv, VALUE self)
{
	Oid lo_oid;
	int mode;
	VALUE nmode;
	PGconn *conn = pg_get_pgconn(self);

	if (rb_scan_args(argc, argv, "01", &nmode) == 0)
		mode = INV_READ;
	else
		mode = NUM2INT(nmode);

	lo_oid = lo_creat(conn, mode);
	if (lo_oid == 0)
		rb_raise(rb_ePGerror, "lo_creat failed");

	return UINT2NUM(lo_oid);
}

/*
 * call-seq:
 *    conn.lo_create( oid ) -> Integer
 *
 * Creates a large object with oid _oid_. Returns the large object Oid.
 * On failure, it raises PG::Error.
 */
static VALUE
pgconn_locreate(VALUE self, VALUE in_lo_oid)
{
	Oid ret, lo_oid;
	PGconn *conn = pg_get_pgconn(self);
	lo_oid = NUM2UINT(in_lo_oid);

	ret = lo_create(conn, lo_oid);
	if (ret == InvalidOid)
		rb_raise(rb_ePGerror, "lo_create failed");

	return UINT2NUM(ret);
}

/*
 * call-seq:
 *    conn.lo_import(file) -> Integer
 *
 * Import a file to a large object. Returns a large object Oid.
 *
 * On failure, it raises a PG::Error.
 */
static VALUE
pgconn_loimport(VALUE self, VALUE filename)
{
	Oid lo_oid;

	PGconn *conn = pg_get_pgconn(self);

	Check_Type(filename, T_STRING);

	lo_oid = lo_import(conn, StringValueCStr(filename));
	if (lo_oid == 0) {
		rb_raise(rb_ePGerror, "%s", PQerrorMessage(conn));
	}
	return UINT2NUM(lo_oid);
}

/*
 * call-seq:
 *    conn.lo_export( oid, file ) -> nil
 *
 * Saves a large object of _oid_ to a _file_.
 */
static VALUE
pgconn_loexport(VALUE self, VALUE lo_oid, VALUE filename)
{
	PGconn *conn = pg_get_pgconn(self);
	Oid oid;
	Check_Type(filename, T_STRING);

	oid = NUM2UINT(lo_oid);

	if (lo_export(conn, oid, StringValueCStr(filename)) < 0) {
		rb_raise(rb_ePGerror, "%s", PQerrorMessage(conn));
	}
	return Qnil;
}

/*
 * call-seq:
 *    conn.lo_open( oid, [mode] ) -> Integer
 *
 * Open a large object of _oid_. Returns a large object descriptor
 * instance on success. The _mode_ argument specifies the mode for
 * the opened large object,which is either +INV_READ+, or +INV_WRITE+.
 *
 * If _mode_ is omitted, the default is +INV_READ+.
 */
static VALUE
pgconn_loopen(int argc, VALUE *argv, VALUE self)
{
	Oid lo_oid;
	int fd, mode;
	VALUE nmode, selfid;
	PGconn *conn = pg_get_pgconn(self);

	rb_scan_args(argc, argv, "11", &selfid, &nmode);
	lo_oid = NUM2UINT(selfid);
	if(NIL_P(nmode))
		mode = INV_READ;
	else
		mode = NUM2INT(nmode);

	if((fd = lo_open(conn, lo_oid, mode)) < 0) {
		rb_raise(rb_ePGerror, "can't open large object: %s", PQerrorMessage(conn));
	}
	return INT2FIX(fd);
}

/*
 * call-seq:
 *    conn.lo_write( lo_desc, buffer ) -> Integer
 *
 * Writes the string _buffer_ to the large object _lo_desc_.
 * Returns the number of bytes written.
 */
static VALUE
pgconn_lowrite(VALUE self, VALUE in_lo_desc, VALUE buffer)
{
	int n;
	PGconn *conn = pg_get_pgconn(self);
	int fd = NUM2INT(in_lo_desc);

	Check_Type(buffer, T_STRING);

	if( RSTRING_LEN(buffer) < 0) {
		rb_raise(rb_ePGerror, "write buffer zero string");
	}
	if((n = lo_write(conn, fd, StringValuePtr(buffer),
				RSTRING_LEN(buffer))) < 0) {
		rb_raise(rb_ePGerror, "lo_write failed: %s", PQerrorMessage(conn));
	}

	return INT2FIX(n);
}

/*
 * call-seq:
 *    conn.lo_read( lo_desc, len ) -> String
 *
 * Attempts to read _len_ bytes from large object _lo_desc_,
 * returns resulting data.
 */
static VALUE
pgconn_loread(VALUE self, VALUE in_lo_desc, VALUE in_len)
{
	int ret;
  PGconn *conn = pg_get_pgconn(self);
	int len = NUM2INT(in_len);
	int lo_desc = NUM2INT(in_lo_desc);
	VALUE str;
	char *buffer;

  buffer = ALLOC_N(char, len);
	if(buffer == NULL)
		rb_raise(rb_eNoMemError, "ALLOC failed!");

	if (len < 0){
		rb_raise(rb_ePGerror,"nagative length %d given", len);
	}

	if((ret = lo_read(conn, lo_desc, buffer, len)) < 0)
		rb_raise(rb_ePGerror, "lo_read failed");

	if(ret == 0) {
		xfree(buffer);
		return Qnil;
	}

	str = rb_tainted_str_new(buffer, ret);
	xfree(buffer);

	return str;
}


/*
 * call-seq:
 *    conn.lo_lseek( lo_desc, offset, whence ) -> Integer
 *
 * Move the large object pointer _lo_desc_ to offset _offset_.
 * Valid values for _whence_ are +SEEK_SET+, +SEEK_CUR+, and +SEEK_END+.
 * (Or 0, 1, or 2.)
 */
static VALUE
pgconn_lolseek(VALUE self, VALUE in_lo_desc, VALUE offset, VALUE whence)
{
	PGconn *conn = pg_get_pgconn(self);
	int lo_desc = NUM2INT(in_lo_desc);
	int ret;

	if((ret = lo_lseek(conn, lo_desc, NUM2INT(offset), NUM2INT(whence))) < 0) {
		rb_raise(rb_ePGerror, "lo_lseek failed");
	}

	return INT2FIX(ret);
}

/*
 * call-seq:
 *    conn.lo_tell( lo_desc ) -> Integer
 *
 * Returns the current position of the large object _lo_desc_.
 */
static VALUE
pgconn_lotell(VALUE self, VALUE in_lo_desc)
{
	int position;
	PGconn *conn = pg_get_pgconn(self);
	int lo_desc = NUM2INT(in_lo_desc);

	if((position = lo_tell(conn, lo_desc)) < 0)
		rb_raise(rb_ePGerror,"lo_tell failed");

	return INT2FIX(position);
}

/*
 * call-seq:
 *    conn.lo_truncate( lo_desc, len ) -> nil
 *
 * Truncates the large object _lo_desc_ to size _len_.
 */
static VALUE
pgconn_lotruncate(VALUE self, VALUE in_lo_desc, VALUE in_len)
{
	PGconn *conn = pg_get_pgconn(self);
	int lo_desc = NUM2INT(in_lo_desc);
	size_t len = NUM2INT(in_len);

	if(lo_truncate(conn,lo_desc,len) < 0)
		rb_raise(rb_ePGerror,"lo_truncate failed");

	return Qnil;
}

/*
 * call-seq:
 *    conn.lo_close( lo_desc ) -> nil
 *
 * Closes the postgres large object of _lo_desc_.
 */
static VALUE
pgconn_loclose(VALUE self, VALUE in_lo_desc)
{
	PGconn *conn = pg_get_pgconn(self);
	int lo_desc = NUM2INT(in_lo_desc);

	if(lo_close(conn,lo_desc) < 0)
		rb_raise(rb_ePGerror,"lo_close failed");

	return Qnil;
}

/*
 * call-seq:
 *    conn.lo_unlink( oid ) -> nil
 *
 * Unlinks (deletes) the postgres large object of _oid_.
 */
static VALUE
pgconn_lounlink(VALUE self, VALUE in_oid)
{
	PGconn *conn = pg_get_pgconn(self);
	Oid oid = NUM2UINT(in_oid);

	if(lo_unlink(conn,oid) < 0)
		rb_raise(rb_ePGerror,"lo_unlink failed");

	return Qnil;
}


#ifdef M17N_SUPPORTED

void
pgconn_set_internal_encoding_index( VALUE self )
{
	PGconn *conn = pg_get_pgconn(self);
	rb_encoding *enc = pg_conn_enc_get( conn );
	PG_ENCODING_SET_NOCHECK( self, rb_enc_to_index(enc));
}

/*
 * call-seq:
 *   conn.internal_encoding -> Encoding
 *
 * defined in Ruby 1.9 or later.
 *
 * Returns:
 * * an Encoding - client_encoding of the connection as a Ruby Encoding object.
 * * nil - the client_encoding is 'SQL_ASCII'
 */
static VALUE
pgconn_internal_encoding(VALUE self)
{
	PGconn *conn = pg_get_pgconn( self );
	rb_encoding *enc = pg_conn_enc_get( conn );

	if ( enc ) {
		return rb_enc_from_encoding( enc );
	} else {
		return Qnil;
	}
}

static VALUE pgconn_external_encoding(VALUE self);

/*
 * call-seq:
 *   conn.internal_encoding = value
 *
 * A wrapper of #set_client_encoding.
 * defined in Ruby 1.9 or later.
 *
 * +value+ can be one of:
 * * an Encoding
 * * a String - a name of Encoding
 * * +nil+ - sets the client_encoding to SQL_ASCII.
 */
static VALUE
pgconn_internal_encoding_set(VALUE self, VALUE enc)
{
	VALUE enc_inspect;
	if (NIL_P(enc)) {
		pgconn_set_client_encoding( self, rb_usascii_str_new_cstr("SQL_ASCII") );
		return enc;
	}
	else if ( TYPE(enc) == T_STRING && strcasecmp("JOHAB", StringValueCStr(enc)) == 0 ) {
		pgconn_set_client_encoding(self, rb_usascii_str_new_cstr("JOHAB"));
		return enc;
	}
	else {
		rb_encoding *rbenc = rb_to_encoding( enc );
		const char *name = pg_get_rb_encoding_as_pg_encoding( rbenc );

		if ( gvl_PQsetClientEncoding(pg_get_pgconn( self ), name) == -1 ) {
			VALUE server_encoding = pgconn_external_encoding( self );
			rb_raise( rb_eEncCompatError, "incompatible character encodings: %s and %s",
					  rb_enc_name(rb_to_encoding(server_encoding)), name );
		}
		pgconn_set_internal_encoding_index( self );
		return enc;
	}

	enc_inspect = rb_inspect(enc);
	rb_raise( rb_ePGerror, "unknown encoding: %s", StringValueCStr(enc_inspect) );

	return Qnil;
}



/*
 * call-seq:
 *   conn.external_encoding() -> Encoding
 *
 * Return the +server_encoding+ of the connected database as a Ruby Encoding object.
 * The <tt>SQL_ASCII</tt> encoding is mapped to to <tt>ASCII_8BIT</tt>.
 */
static VALUE
pgconn_external_encoding(VALUE self)
{
	t_pg_connection *this = pg_get_connection_safe( self );
	rb_encoding *enc = NULL;
	const char *pg_encname = NULL;

	/* Use cached value if found */
	if ( RTEST(this->external_encoding) ) return this->external_encoding;

	pg_encname = PQparameterStatus( this->pgconn, "server_encoding" );
	enc = pg_get_pg_encname_as_rb_encoding( pg_encname );
	this->external_encoding = rb_enc_from_encoding( enc );

	return this->external_encoding;
}


static VALUE
pgconn_set_client_encoding_async1( VALUE args )
{
	VALUE self = ((VALUE*)args)[0];
	VALUE encname = ((VALUE*)args)[1];
	VALUE query_format = rb_str_new_cstr("set client_encoding to '%s'");
	VALUE query = rb_funcall(query_format, rb_intern("%"), 1, encname);

	pgconn_async_exec(1, &query, self);
	return 0;
}


static VALUE
pgconn_set_client_encoding_async2( VALUE arg )
{
	UNUSED(arg);
	return 1;
}


static VALUE
pgconn_set_client_encoding_async( VALUE self, const char *encname )
{
	VALUE args[] = { self, rb_str_new_cstr(encname) };
	return rb_rescue(pgconn_set_client_encoding_async1, (VALUE)&args, pgconn_set_client_encoding_async2, Qnil);
}


/*
 * call-seq:
 *   conn.set_default_encoding() -> Encoding
 *
 * If Ruby has its Encoding.default_internal set, set PostgreSQL's client_encoding
 * to match. Returns the new Encoding, or +nil+ if the default internal encoding
 * wasn't set.
 */
static VALUE
pgconn_set_default_encoding( VALUE self )
{
	PGconn *conn = pg_get_pgconn( self );
	rb_encoding *enc;
	const char *encname;

	if (( enc = rb_default_internal_encoding() )) {
		encname = pg_get_rb_encoding_as_pg_encoding( enc );
		if ( pgconn_set_client_encoding_async(self, encname) != 0 )
			rb_warn( "Failed to set the default_internal encoding to %s: '%s'",
			         encname, PQerrorMessage(conn) );
		pgconn_set_internal_encoding_index( self );
		return rb_enc_from_encoding( enc );
	} else {
		pgconn_set_internal_encoding_index( self );
		return Qnil;
	}
}


#endif /* M17N_SUPPORTED */

/*
 * call-seq:
 *    res.type_map_for_queries = typemap
 *
 * Set the default TypeMap that is used for type casts of query bind parameters.
 *
 * +typemap+ must be a kind of PG::TypeMap .
 *
 */
static VALUE
pgconn_type_map_for_queries_set(VALUE self, VALUE typemap)
{
	t_pg_connection *this = pg_get_connection( self );

	if ( !rb_obj_is_kind_of(typemap, rb_cTypeMap) ) {
		rb_raise( rb_eTypeError, "wrong argument type %s (expected kind of PG::TypeMap)",
				rb_obj_classname( typemap ) );
	}
	Check_Type(typemap, T_DATA);
	this->type_map_for_queries = typemap;

	return typemap;
}

/*
 * call-seq:
 *    res.type_map_for_queries -> TypeMap
 *
 * Returns the default TypeMap that is currently set for type casts of query
 * bind parameters.
 *
 */
static VALUE
pgconn_type_map_for_queries_get(VALUE self)
{
	t_pg_connection *this = pg_get_connection( self );

	return this->type_map_for_queries;
}

/*
 * call-seq:
 *    res.type_map_for_results = typemap
 *
 * Set the default TypeMap that is used for type casts of result values.
 *
 * +typemap+ must be a kind of PG::TypeMap .
 *
 */
static VALUE
pgconn_type_map_for_results_set(VALUE self, VALUE typemap)
{
	t_pg_connection *this = pg_get_connection( self );

	if ( !rb_obj_is_kind_of(typemap, rb_cTypeMap) ) {
		rb_raise( rb_eTypeError, "wrong argument type %s (expected kind of PG::TypeMap)",
				rb_obj_classname( typemap ) );
	}
	Check_Type(typemap, T_DATA);
	this->type_map_for_results = typemap;

	return typemap;
}

/*
 * call-seq:
 *    res.type_map_for_results -> TypeMap
 *
 * Returns the default TypeMap that is currently set for type casts of result values.
 *
 */
static VALUE
pgconn_type_map_for_results_get(VALUE self)
{
	t_pg_connection *this = pg_get_connection( self );

	return this->type_map_for_results;
}


/*
 * call-seq:
 *    res.encoder_for_put_copy_data = encoder
 *
 * Set the default coder that is used for type casting of parameters
 * to #put_copy_data .
 *
 * +encoder+ can be:
 * * a kind of PG::Coder
 * * +nil+ - disable type encoding, data must be a String.
 *
 */
static VALUE
pgconn_encoder_for_put_copy_data_set(VALUE self, VALUE typemap)
{
	t_pg_connection *this = pg_get_connection( self );

	if( typemap != Qnil ){
		if ( !rb_obj_is_kind_of(typemap, rb_cPG_Coder) ) {
			rb_raise( rb_eTypeError, "wrong argument type %s (expected kind of PG::Coder)",
					rb_obj_classname( typemap ) );
		}
		Check_Type(typemap, T_DATA);
	}
	this->encoder_for_put_copy_data = typemap;

	return typemap;
}

/*
 * call-seq:
 *    res.encoder_for_put_copy_data -> PG::Coder
 *
 * Returns the default coder object that is currently set for type casting of parameters
 * to #put_copy_data .
 *
 * Returns either:
 * * a kind of PG::Coder
 * * +nil+ - type encoding is disabled, data must be a String.
 *
 */
static VALUE
pgconn_encoder_for_put_copy_data_get(VALUE self)
{
	t_pg_connection *this = pg_get_connection( self );

	return this->encoder_for_put_copy_data;
}

/*
 * call-seq:
 *    res.decoder_for_get_copy_data = decoder
 *
 * Set the default coder that is used for type casting of received data
 * by #get_copy_data .
 *
 * +decoder+ can be:
 * * a kind of PG::Coder
 * * +nil+ - disable type decoding, returned data will be a String.
 *
 */
static VALUE
pgconn_decoder_for_get_copy_data_set(VALUE self, VALUE typemap)
{
	t_pg_connection *this = pg_get_connection( self );

	if( typemap != Qnil ){
		if ( !rb_obj_is_kind_of(typemap, rb_cPG_Coder) ) {
			rb_raise( rb_eTypeError, "wrong argument type %s (expected kind of PG::Coder)",
					rb_obj_classname( typemap ) );
		}
		Check_Type(typemap, T_DATA);
	}
	this->decoder_for_get_copy_data = typemap;

	return typemap;
}

/*
 * call-seq:
 *    res.decoder_for_get_copy_data -> PG::Coder
 *
 * Returns the default coder object that is currently set for type casting of received
 * data by #get_copy_data .
 *
 * Returns either:
 * * a kind of PG::Coder
 * * +nil+ - type encoding is disabled, returned data will be a String.
 *
 */
static VALUE
pgconn_decoder_for_get_copy_data_get(VALUE self)
{
	t_pg_connection *this = pg_get_connection( self );

	return this->decoder_for_get_copy_data;
}


/*
 * Document-class: PG::Connection
 */
void
init_pg_connection()
{
	s_id_encode = rb_intern("encode");
	sym_type = ID2SYM(rb_intern("type"));
	sym_format = ID2SYM(rb_intern("format"));
	sym_value = ID2SYM(rb_intern("value"));

	rb_cPGconn = rb_define_class_under( rb_mPG, "Connection", rb_cObject );
	rb_include_module(rb_cPGconn, rb_mPGconstants);

	/******     PG::Connection CLASS METHODS     ******/
	rb_define_alloc_func( rb_cPGconn, pgconn_s_allocate );

	SINGLETON_ALIAS(rb_cPGconn, "connect", "new");
	SINGLETON_ALIAS(rb_cPGconn, "open", "new");
	SINGLETON_ALIAS(rb_cPGconn, "setdb", "new");
	SINGLETON_ALIAS(rb_cPGconn, "setdblogin", "new");
	rb_define_singleton_method(rb_cPGconn, "escape_string", pgconn_s_escape, 1);
	SINGLETON_ALIAS(rb_cPGconn, "escape", "escape_string");
	rb_define_singleton_method(rb_cPGconn, "escape_bytea", pgconn_s_escape_bytea, 1);
	rb_define_singleton_method(rb_cPGconn, "unescape_bytea", pgconn_s_unescape_bytea, 1);
	rb_define_singleton_method(rb_cPGconn, "encrypt_password", pgconn_s_encrypt_password, 2);
	rb_define_singleton_method(rb_cPGconn, "quote_ident", pgconn_s_quote_ident, 1);
	rb_define_singleton_method(rb_cPGconn, "connect_start", pgconn_s_connect_start, -1);
	rb_define_singleton_method(rb_cPGconn, "conndefaults", pgconn_s_conndefaults, 0);
#ifdef HAVE_PQPING
	rb_define_singleton_method(rb_cPGconn, "ping", pgconn_s_ping, -1);
#endif

	/******     PG::Connection INSTANCE METHODS: Connection Control     ******/
	rb_define_method(rb_cPGconn, "initialize", pgconn_init, -1);
	rb_define_method(rb_cPGconn, "connect_poll", pgconn_connect_poll, 0);
	rb_define_method(rb_cPGconn, "finish", pgconn_finish, 0);
	rb_define_method(rb_cPGconn, "finished?", pgconn_finished_p, 0);
	rb_define_method(rb_cPGconn, "reset", pgconn_reset, 0);
	rb_define_method(rb_cPGconn, "reset_start", pgconn_reset_start, 0);
	rb_define_method(rb_cPGconn, "reset_poll", pgconn_reset_poll, 0);
	rb_define_alias(rb_cPGconn, "close", "finish");

	/******     PG::Connection INSTANCE METHODS: Connection Status     ******/
	rb_define_method(rb_cPGconn, "db", pgconn_db, 0);
	rb_define_method(rb_cPGconn, "user", pgconn_user, 0);
	rb_define_method(rb_cPGconn, "pass", pgconn_pass, 0);
	rb_define_method(rb_cPGconn, "host", pgconn_host, 0);
	rb_define_method(rb_cPGconn, "port", pgconn_port, 0);
	rb_define_method(rb_cPGconn, "tty", pgconn_tty, 0);
#ifdef HAVE_PQCONNINFO
	rb_define_method(rb_cPGconn, "conninfo", pgconn_conninfo, 0);
#endif
	rb_define_method(rb_cPGconn, "options", pgconn_options, 0);
	rb_define_method(rb_cPGconn, "status", pgconn_status, 0);
	rb_define_method(rb_cPGconn, "transaction_status", pgconn_transaction_status, 0);
	rb_define_method(rb_cPGconn, "parameter_status", pgconn_parameter_status, 1);
	rb_define_method(rb_cPGconn, "protocol_version", pgconn_protocol_version, 0);
	rb_define_method(rb_cPGconn, "server_version", pgconn_server_version, 0);
	rb_define_method(rb_cPGconn, "error_message", pgconn_error_message, 0);
	rb_define_method(rb_cPGconn, "socket", pgconn_socket, 0);
#if !defined(_WIN32) || defined(HAVE_RB_W32_WRAP_IO_HANDLE)
	rb_define_method(rb_cPGconn, "socket_io", pgconn_socket_io, 0);
#endif
	rb_define_method(rb_cPGconn, "backend_pid", pgconn_backend_pid, 0);
	rb_define_method(rb_cPGconn, "connection_needs_password", pgconn_connection_needs_password, 0);
	rb_define_method(rb_cPGconn, "connection_used_password", pgconn_connection_used_password, 0);
	/* rb_define_method(rb_cPGconn, "getssl", pgconn_getssl, 0); */

	/******     PG::Connection INSTANCE METHODS: Command Execution     ******/
	rb_define_method(rb_cPGconn, "exec", pgconn_exec, -1);
	rb_define_alias(rb_cPGconn, "query", "exec");
	rb_define_method(rb_cPGconn, "exec_params", pgconn_exec_params, -1);
	rb_define_method(rb_cPGconn, "prepare", pgconn_prepare, -1);
	rb_define_method(rb_cPGconn, "exec_prepared", pgconn_exec_prepared, -1);
	rb_define_method(rb_cPGconn, "describe_prepared", pgconn_describe_prepared, 1);
	rb_define_method(rb_cPGconn, "describe_portal", pgconn_describe_portal, 1);
	rb_define_method(rb_cPGconn, "make_empty_pgresult", pgconn_make_empty_pgresult, 1);
	rb_define_method(rb_cPGconn, "escape_string", pgconn_s_escape, 1);
	rb_define_alias(rb_cPGconn, "escape", "escape_string");
#ifdef HAVE_PQESCAPELITERAL
	rb_define_method(rb_cPGconn, "escape_literal", pgconn_escape_literal, 1);
#endif
#ifdef HAVE_PQESCAPEIDENTIFIER
	rb_define_method(rb_cPGconn, "escape_identifier", pgconn_escape_identifier, 1);
#endif
	rb_define_method(rb_cPGconn, "escape_bytea", pgconn_s_escape_bytea, 1);
	rb_define_method(rb_cPGconn, "unescape_bytea", pgconn_s_unescape_bytea, 1);
#ifdef HAVE_PQSETSINGLEROWMODE
	rb_define_method(rb_cPGconn, "set_single_row_mode", pgconn_set_single_row_mode, 0);
#endif

	/******     PG::Connection INSTANCE METHODS: Asynchronous Command Processing     ******/
	rb_define_method(rb_cPGconn, "send_query", pgconn_send_query, -1);
	rb_define_method(rb_cPGconn, "send_prepare", pgconn_send_prepare, -1);
	rb_define_method(rb_cPGconn, "send_query_prepared", pgconn_send_query_prepared, -1);
	rb_define_method(rb_cPGconn, "send_describe_prepared", pgconn_send_describe_prepared, 1);
	rb_define_method(rb_cPGconn, "send_describe_portal", pgconn_send_describe_portal, 1);
	rb_define_method(rb_cPGconn, "get_result", pgconn_get_result, 0);
	rb_define_method(rb_cPGconn, "consume_input", pgconn_consume_input, 0);
	rb_define_method(rb_cPGconn, "is_busy", pgconn_is_busy, 0);
	rb_define_method(rb_cPGconn, "setnonblocking", pgconn_setnonblocking, 1);
	rb_define_method(rb_cPGconn, "isnonblocking", pgconn_isnonblocking, 0);
	rb_define_alias(rb_cPGconn, "nonblocking?", "isnonblocking");
	rb_define_method(rb_cPGconn, "flush", pgconn_flush, 0);

	/******     PG::Connection INSTANCE METHODS: Cancelling Queries in Progress     ******/
	rb_define_method(rb_cPGconn, "cancel", pgconn_cancel, 0);

	/******     PG::Connection INSTANCE METHODS: NOTIFY     ******/
	rb_define_method(rb_cPGconn, "notifies", pgconn_notifies, 0);

	/******     PG::Connection INSTANCE METHODS: COPY     ******/
	rb_define_method(rb_cPGconn, "put_copy_data", pgconn_put_copy_data, -1);
	rb_define_method(rb_cPGconn, "put_copy_end", pgconn_put_copy_end, -1);
	rb_define_method(rb_cPGconn, "get_copy_data", pgconn_get_copy_data, -1);

	/******     PG::Connection INSTANCE METHODS: Control Functions     ******/
	rb_define_method(rb_cPGconn, "set_error_verbosity", pgconn_set_error_verbosity, 1);
	rb_define_method(rb_cPGconn, "trace", pgconn_trace, 1);
	rb_define_method(rb_cPGconn, "untrace", pgconn_untrace, 0);

	/******     PG::Connection INSTANCE METHODS: Notice Processing     ******/
	rb_define_method(rb_cPGconn, "set_notice_receiver", pgconn_set_notice_receiver, 0);
	rb_define_method(rb_cPGconn, "set_notice_processor", pgconn_set_notice_processor, 0);

	/******     PG::Connection INSTANCE METHODS: Other    ******/
	rb_define_method(rb_cPGconn, "get_client_encoding", pgconn_get_client_encoding, 0);
	rb_define_method(rb_cPGconn, "set_client_encoding", pgconn_set_client_encoding, 1);
	rb_define_alias(rb_cPGconn, "client_encoding=", "set_client_encoding");
	rb_define_method(rb_cPGconn, "transaction", pgconn_transaction, 0);
	rb_define_method(rb_cPGconn, "block", pgconn_block, -1);
	rb_define_method(rb_cPGconn, "wait_for_notify", pgconn_wait_for_notify, -1);
	rb_define_alias(rb_cPGconn, "notifies_wait", "wait_for_notify");
	rb_define_method(rb_cPGconn, "quote_ident", pgconn_s_quote_ident, 1);
	rb_define_method(rb_cPGconn, "async_exec", pgconn_async_exec, -1);
	rb_define_alias(rb_cPGconn, "async_query", "async_exec");
	rb_define_method(rb_cPGconn, "get_last_result", pgconn_get_last_result, 0);

#ifdef HAVE_PQSSLATTRIBUTE
	rb_define_method(rb_cPGconn, "ssl_in_use?", pgconn_ssl_in_use, 0);
	rb_define_method(rb_cPGconn, "ssl_attribute", pgconn_ssl_attribute, 1);
	rb_define_method(rb_cPGconn, "ssl_attribute_names", pgconn_ssl_attribute_names, 0);
#endif

	/******     PG::Connection INSTANCE METHODS: Large Object Support     ******/
	rb_define_method(rb_cPGconn, "lo_creat", pgconn_locreat, -1);
	rb_define_alias(rb_cPGconn, "locreat", "lo_creat");
	rb_define_method(rb_cPGconn, "lo_create", pgconn_locreate, 1);
	rb_define_alias(rb_cPGconn, "locreate", "lo_create");
	rb_define_method(rb_cPGconn, "lo_import", pgconn_loimport, 1);
	rb_define_alias(rb_cPGconn, "loimport", "lo_import");
	rb_define_method(rb_cPGconn, "lo_export", pgconn_loexport, 2);
	rb_define_alias(rb_cPGconn, "loexport", "lo_export");
	rb_define_method(rb_cPGconn, "lo_open", pgconn_loopen, -1);
	rb_define_alias(rb_cPGconn, "loopen", "lo_open");
	rb_define_method(rb_cPGconn, "lo_write",pgconn_lowrite, 2);
	rb_define_alias(rb_cPGconn, "lowrite", "lo_write");
	rb_define_method(rb_cPGconn, "lo_read",pgconn_loread, 2);
	rb_define_alias(rb_cPGconn, "loread", "lo_read");
	rb_define_method(rb_cPGconn, "lo_lseek",pgconn_lolseek, 3);
	rb_define_alias(rb_cPGconn, "lolseek", "lo_lseek");
	rb_define_alias(rb_cPGconn, "lo_seek", "lo_lseek");
	rb_define_alias(rb_cPGconn, "loseek", "lo_lseek");
	rb_define_method(rb_cPGconn, "lo_tell",pgconn_lotell, 1);
	rb_define_alias(rb_cPGconn, "lotell", "lo_tell");
	rb_define_method(rb_cPGconn, "lo_truncate", pgconn_lotruncate, 2);
	rb_define_alias(rb_cPGconn, "lotruncate", "lo_truncate");
	rb_define_method(rb_cPGconn, "lo_close",pgconn_loclose, 1);
	rb_define_alias(rb_cPGconn, "loclose", "lo_close");
	rb_define_method(rb_cPGconn, "lo_unlink", pgconn_lounlink, 1);
	rb_define_alias(rb_cPGconn, "lounlink", "lo_unlink");

#ifdef M17N_SUPPORTED
	rb_define_method(rb_cPGconn, "internal_encoding", pgconn_internal_encoding, 0);
	rb_define_method(rb_cPGconn, "internal_encoding=", pgconn_internal_encoding_set, 1);
	rb_define_method(rb_cPGconn, "external_encoding", pgconn_external_encoding, 0);
	rb_define_method(rb_cPGconn, "set_default_encoding", pgconn_set_default_encoding, 0);
#endif /* M17N_SUPPORTED */

	rb_define_method(rb_cPGconn, "type_map_for_queries=", pgconn_type_map_for_queries_set, 1);
	rb_define_method(rb_cPGconn, "type_map_for_queries", pgconn_type_map_for_queries_get, 0);
	rb_define_method(rb_cPGconn, "type_map_for_results=", pgconn_type_map_for_results_set, 1);
	rb_define_method(rb_cPGconn, "type_map_for_results", pgconn_type_map_for_results_get, 0);
	rb_define_method(rb_cPGconn, "encoder_for_put_copy_data=", pgconn_encoder_for_put_copy_data_set, 1);
	rb_define_method(rb_cPGconn, "encoder_for_put_copy_data", pgconn_encoder_for_put_copy_data_get, 0);
	rb_define_method(rb_cPGconn, "decoder_for_get_copy_data=", pgconn_decoder_for_get_copy_data_set, 1);
	rb_define_method(rb_cPGconn, "decoder_for_get_copy_data", pgconn_decoder_for_get_copy_data_get, 0);
}


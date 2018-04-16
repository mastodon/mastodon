#!/usr/bin/env rspec
#encoding: utf-8

require_relative '../helpers'

require 'timeout'
require 'socket'
require 'pg'

describe PG::Connection do

	it "can create a connection option string from a Hash of options" do
		optstring = described_class.parse_connect_args(
			:host => 'pgsql.example.com',
			:dbname => 'db01',
			'sslmode' => 'require'
		  )

		expect( optstring ).to be_a( String )
		expect( optstring ).to match( /(^|\s)host='pgsql.example.com'/ )
		expect( optstring ).to match( /(^|\s)dbname='db01'/ )
		expect( optstring ).to match( /(^|\s)sslmode='require'/ )
	end

	it "can create a connection option string from positional parameters" do
		optstring = described_class.parse_connect_args( 'pgsql.example.com', nil, '-c geqo=off', nil,
		                                       'sales' )

		expect( optstring ).to be_a( String )
		expect( optstring ).to match( /(^|\s)host='pgsql.example.com'/ )
		expect( optstring ).to match( /(^|\s)dbname='sales'/ )
		expect( optstring ).to match( /(^|\s)options='-c geqo=off'/ )

		expect( optstring ).to_not match( /port=/ )
		expect( optstring ).to_not match( /tty=/ )
	end

	it "can create a connection option string from a mix of positional and hash parameters" do
		optstring = described_class.parse_connect_args( 'pgsql.example.com',
		                                       :dbname => 'licensing', :user => 'jrandom' )

		expect( optstring ).to be_a( String )
		expect( optstring ).to match( /(^|\s)host='pgsql.example.com'/ )
		expect( optstring ).to match( /(^|\s)dbname='licensing'/ )
		expect( optstring ).to match( /(^|\s)user='jrandom'/ )
	end

	it "can create a connection option string from an option string and a hash" do
		optstring = described_class.parse_connect_args( 'dbname=original', :user => 'jrandom' )

		expect( optstring ).to be_a( String )
		expect( optstring ).to match( /(^|\s)dbname=original/ )
		expect( optstring ).to match( /(^|\s)user='jrandom'/ )
	end

	it "escapes single quotes and backslashes in connection parameters" do
		expect(
			described_class.parse_connect_args( "DB 'browser' \\" )
		).to match( /host='DB \\'browser\\' \\\\'/ )

	end

	let(:uri) { 'postgresql://user:pass@pgsql.example.com:222/db01?sslmode=require' }

	it "can connect using a URI" do
		string = described_class.parse_connect_args( uri )

		expect( string ).to be_a( String )
		expect( string ).to match( %r{^postgresql://user:pass@pgsql.example.com:222/db01\?} )
		expect( string ).to match( %r{\?.*sslmode=require} )

		string = described_class.parse_connect_args( URI.parse(uri) )

		expect( string ).to be_a( String )
		expect( string ).to match( %r{^postgresql://user:pass@pgsql.example.com:222/db01\?} )
		expect( string ).to match( %r{\?.*sslmode=require} )
	end

	it "can create a connection URI from a URI and a hash" do
		string = described_class.parse_connect_args( uri, :connect_timeout => 2 )

		expect( string ).to be_a( String )
		expect( string ).to match( %r{^postgresql://user:pass@pgsql.example.com:222/db01\?} )
		expect( string ).to match( %r{\?.*sslmode=require} )
		expect( string ).to match( %r{\?.*connect_timeout=2} )

		string = described_class.parse_connect_args( uri,
			:user => 'a',
			:password => 'b',
			:host => 'localhost',
			:port => 555,
			:dbname => 'x' )

		expect( string ).to be_a( String )
		expect( string ).to match( %r{^postgresql://\?} )
		expect( string ).to match( %r{\?.*user=a} )
		expect( string ).to match( %r{\?.*password=b} )
		expect( string ).to match( %r{\?.*host=localhost} )
		expect( string ).to match( %r{\?.*port=555} )
		expect( string ).to match( %r{\?.*dbname=x} )
	end

	it "can create a connection URI with a non-standard domain socket directory" do
		string = described_class.parse_connect_args( 'postgresql://%2Fvar%2Flib%2Fpostgresql/dbname' )

		expect( string ).to be_a( String )
		expect( string ).to match( %r{^postgresql://%2Fvar%2Flib%2Fpostgresql/dbname} )

		string = described_class.
			parse_connect_args( 'postgresql:///dbname', :host => '/var/lib/postgresql' )

		expect( string ).to be_a( String )
		expect( string ).to match( %r{^postgresql:///dbname\?} )
		expect( string ).to match( %r{\?.*host=%2Fvar%2Flib%2Fpostgresql} )
	end

	it "connects with defaults if no connection parameters are given" do
		expect( described_class.parse_connect_args ).to eq( '' )
	end

	it "connects successfully with connection string" do
		tmpconn = described_class.connect( @conninfo )
		expect( tmpconn.status ).to eq( PG::CONNECTION_OK )
		tmpconn.finish
	end

	it "connects using 7 arguments converted to strings" do
		tmpconn = described_class.connect( 'localhost', @port, nil, nil, :test, nil, nil )
		expect( tmpconn.status ).to eq( PG::CONNECTION_OK )
		tmpconn.finish
	end

	it "connects using a hash of connection parameters" do
		tmpconn = described_class.connect(
			:host => 'localhost',
			:port => @port,
			:dbname => :test)
		expect( tmpconn.status ).to eq( PG::CONNECTION_OK )
		tmpconn.finish
	end

	it "connects using a hash of optional connection parameters", :postgresql_90 do
		tmpconn = described_class.connect(
			:host => 'localhost',
			:port => @port,
			:dbname => :test,
			:keepalives => 1)
		expect( tmpconn.status ).to eq( PG::CONNECTION_OK )
		tmpconn.finish
	end

	it "raises an exception when connecting with an invalid number of arguments" do
		expect {
			described_class.connect( 1, 2, 3, 4, 5, 6, 7, 'the-extra-arg' )
		}.to raise_error do |error|
			expect( error ).to be_an( ArgumentError )
			expect( error.message ).to match( /extra positional parameter/i )
			expect( error.message ).to match( /8/ )
			expect( error.message ).to match( /the-extra-arg/ )
		end
	end

	it "can connect asynchronously", :socket_io do
		tmpconn = described_class.connect_start( @conninfo )
		expect( tmpconn ).to be_a( described_class )
		socket = tmpconn.socket_io
		status = tmpconn.connect_poll

		while status != PG::PGRES_POLLING_OK
			if status == PG::PGRES_POLLING_READING
				select( [socket], [], [], 5.0 ) or
					raise "Asynchronous connection timed out!"

			elsif status == PG::PGRES_POLLING_WRITING
				select( [], [socket], [], 5.0 ) or
					raise "Asynchronous connection timed out!"
			end
			status = tmpconn.connect_poll
		end

		expect( tmpconn.status ).to eq( PG::CONNECTION_OK )
		tmpconn.finish
	end

	it "can connect asynchronously for the duration of a block", :socket_io do
		conn = nil

		described_class.connect_start(@conninfo) do |tmpconn|
			expect( tmpconn ).to be_a( described_class )
			conn = tmpconn
			socket = tmpconn.socket_io
			status = tmpconn.connect_poll

			while status != PG::PGRES_POLLING_OK
				if status == PG::PGRES_POLLING_READING
					if(not select([socket],[],[],5.0))
						raise "Asynchronous connection timed out!"
					end
				elsif(status == PG::PGRES_POLLING_WRITING)
					if(not select([],[socket],[],5.0))
						raise "Asynchronous connection timed out!"
					end
				end
				status = tmpconn.connect_poll
			end

			expect( tmpconn.status ).to eq( PG::CONNECTION_OK )
		end

		expect( conn ).to be_finished()
	end

	it "raises proper error when sending fails" do
		conn = described_class.connect_start( '127.0.0.1', 54320, "", "", "me", "xxxx", "somedb" )
		expect{ conn.exec 'SELECT 1' }.to raise_error(PG::UnableToSend, /no connection/)
	end

	it "doesn't leave stale server connections after finish" do
		described_class.connect(@conninfo).finish
		sleep 0.5
		res = @conn.exec(%[SELECT COUNT(*) AS n FROM pg_stat_activity
							WHERE usename IS NOT NULL])
		# there's still the global @conn, but should be no more
		expect( res[0]['n'] ).to eq( '1' )
	end

	it "can retrieve it's connection parameters for the established connection" do
		expect( @conn.db ).to eq( "test" )
		expect( @conn.user ).to be_a_kind_of( String )
		expect( @conn.pass ).to eq( "" )
		expect( @conn.port ).to eq( 54321 )
		expect( @conn.tty ).to eq( "" )
		expect( @conn.options ).to eq( "" )
	end
	it "can retrieve it's connection parameters for the established connection",
	    skip: RUBY_PLATFORM=~/x64-mingw/ ? "host segfaults on Windows-x64" : false do
		expect( @conn.host ).to eq( "localhost" )
	end

	EXPECTED_TRACE_OUTPUT = %{
		To backend> Msg Q
		To backend> "SELECT 1 AS one"
		To backend> Msg complete, length 21
		From backend> T
		From backend (#4)> 28
		From backend (#2)> 1
		From backend> "one"
		From backend (#4)> 0
		From backend (#2)> 0
		From backend (#4)> 23
		From backend (#2)> 4
		From backend (#4)> -1
		From backend (#2)> 0
		From backend> D
		From backend (#4)> 11
		From backend (#2)> 1
		From backend (#4)> 1
		From backend (1)> 1
		From backend> C
		From backend (#4)> 13
		From backend> "SELECT 1"
		From backend> Z
		From backend (#4)> 5
		From backend> Z
		From backend (#4)> 5
		From backend> T
		}.gsub( /^\t{2}/, '' ).lstrip

	it "trace and untrace client-server communication", :unix do
			# be careful to explicitly close files so that the
			# directory can be removed and we don't have to wait for
			# the GC to run.
			trace_file = TEST_DIRECTORY + "test_trace.out"
			trace_io = trace_file.open( 'w', 0600 )
			@conn.trace( trace_io )
			trace_io.close

			res = @conn.exec("SELECT 1 AS one")
			@conn.untrace

			res = @conn.exec("SELECT 2 AS two")

			trace_data = trace_file.read

			expected_trace_output = EXPECTED_TRACE_OUTPUT.dup
			# For PostgreSQL < 9.0, the output will be different:
			# -From backend (#4)> 13
			# -From backend> "SELECT 1"
			# +From backend (#4)> 11
			# +From backend> "SELECT"
			if @conn.server_version < 90000
				expected_trace_output.sub!( /From backend \(#4\)> 13/, 'From backend (#4)> 11' )
				expected_trace_output.sub!( /From backend> "SELECT 1"/, 'From backend> "SELECT"' )
			end

			expect( trace_data ).to eq( expected_trace_output )
		end

	it "allows a query to be cancelled" do
		error = false
		@conn.send_query("SELECT pg_sleep(1000)")
		@conn.cancel
		tmpres = @conn.get_result
		if(tmpres.result_status != PG::PGRES_TUPLES_OK)
			error = true
		end
		expect( error ).to eq( true )
	end

	it "can stop a thread that runs a blocking query with async_exec" do
		pending "this does not work on Rubinius" if RUBY_ENGINE=='rbx'

		start = Time.now
		t = Thread.new do
			@conn.async_exec( 'select pg_sleep(10)' )
		end
		sleep 0.1

		t.kill
		t.join
		expect( (Time.now - start) ).to be < 10
	end

	it "should work together with signal handlers", :unix do
		signal_received = false
		trap 'USR1' do
			signal_received = true
		end

		Thread.new do
			sleep 0.1
			Process.kill("USR1", Process.pid)
		end
		@conn.exec("select pg_sleep(0.3)")
		expect( signal_received ).to be_truthy

		signal_received = false
		Thread.new do
			sleep 0.1
			Process.kill("USR1", Process.pid)
		end
		@conn.async_exec("select pg_sleep(0.3)")
		expect( signal_received ).to be_truthy
	end


	it "automatically rolls back a transaction started with Connection#transaction if an exception " +
	   "is raised" do
		# abort the per-example transaction so we can test our own
		@conn.exec( 'ROLLBACK' )

		res = nil
		@conn.exec( "CREATE TABLE pie ( flavor TEXT )" )

		begin
			expect {
				res = @conn.transaction do
					@conn.exec( "INSERT INTO pie VALUES ('rhubarb'), ('cherry'), ('schizophrenia')" )
					raise "Oh noes! All pie is gone!"
				end
			}.to raise_exception( RuntimeError, /all pie is gone/i )

			res = @conn.exec( "SELECT * FROM pie" )
			expect( res.ntuples ).to eq( 0 )
		ensure
			@conn.exec( "DROP TABLE pie" )
		end
	end

	it "returns the block result from Connection#transaction" do
		# abort the per-example transaction so we can test our own
		@conn.exec( 'ROLLBACK' )

		res = @conn.transaction do
			"transaction result"
		end
		expect( res ).to eq( "transaction result" )
	end

	it "not read past the end of a large object" do
		@conn.transaction do
			oid = @conn.lo_create( 0 )
			fd = @conn.lo_open( oid, PG::INV_READ|PG::INV_WRITE )
			@conn.lo_write( fd, "foobar" )
			expect( @conn.lo_read( fd, 10 ) ).to be_nil()
			@conn.lo_lseek( fd, 0, PG::SEEK_SET )
			expect( @conn.lo_read( fd, 10 ) ).to eq( 'foobar' )
		end
	end


	it "supports parameters passed to #exec (backward compatibility)" do
		@conn.exec( "CREATE TABLE students ( name TEXT, age INTEGER )" )
		@conn.exec( "INSERT INTO students VALUES( $1, $2 )", ['Wally', 8] )
		@conn.exec( "INSERT INTO students VALUES( $1, $2 )", ['Sally', 6] )
		@conn.exec( "INSERT INTO students VALUES( $1, $2 )", ['Dorothy', 4] )

		res = @conn.exec( "SELECT name FROM students WHERE age >= $1", [6] )
		expect( res.values ).to eq( [ ['Wally'], ['Sally'] ] )
	end

	it "supports explicitly calling #exec_params" do
		@conn.exec( "CREATE TABLE students ( name TEXT, age INTEGER )" )
		@conn.exec( "INSERT INTO students VALUES( $1, $2 )", ['Wally', 8] )
		@conn.exec( "INSERT INTO students VALUES( $1, $2 )", ['Sally', 6] )
		@conn.exec( "INSERT INTO students VALUES( $1, $2 )", ['Dorothy', 4] )

		res = @conn.exec_params( "SELECT name FROM students WHERE age >= $1", [6] )
		expect( res.values ).to eq( [ ['Wally'], ['Sally'] ] )
	end

	it "supports hash form parameters for #exec_params" do
		hash_param_bin = { value: ["00ff"].pack("H*"), type: 17, format: 1 }
		hash_param_nil = { value: nil, type: 17, format: 1 }
		res = @conn.exec_params( "SELECT $1, $2",
					[ hash_param_bin, hash_param_nil ] )
		expect( res.values ).to eq( [["\\x00ff", nil]] )
		expect( result_typenames(res) ).to eq( ['bytea', 'bytea'] )
	end

	it "should work with arbitrary number of params" do
		begin
			3.step( 12, 0.2 ) do |exp|
				num_params = (2 ** exp).to_i
				sql = num_params.times.map{|n| "$#{n+1}::INT" }.join(",")
				params = num_params.times.to_a
				res = @conn.exec_params( "SELECT #{sql}", params )
				expect( res.nfields ).to eq( num_params )
				expect( res.values ).to eq( [num_params.times.map(&:to_s)] )
			end
		rescue PG::ProgramLimitExceeded
			# Stop silently if the server complains about too many params
		end
	end

	it "can wait for NOTIFY events" do
		@conn.exec( 'ROLLBACK' )
		@conn.exec( 'LISTEN woo' )

		t = Thread.new do
			begin
				conn = described_class.connect( @conninfo )
				sleep 1
				conn.async_exec( 'NOTIFY woo' )
			ensure
				conn.finish
			end
		end

		expect( @conn.wait_for_notify( 10 ) ).to eq( 'woo' )
		@conn.exec( 'UNLISTEN woo' )

		t.join
	end

	it "calls a block for NOTIFY events if one is given" do
		@conn.exec( 'ROLLBACK' )
		@conn.exec( 'LISTEN woo' )

		t = Thread.new do
			begin
				conn = described_class.connect( @conninfo )
				sleep 1
				conn.async_exec( 'NOTIFY woo' )
			ensure
				conn.finish
			end
		end

		eventpid = event = nil
		@conn.wait_for_notify( 10 ) {|*args| event, eventpid = args }
		expect( event ).to eq( 'woo' )
		expect( eventpid ).to be_an( Integer )

		@conn.exec( 'UNLISTEN woo' )

		t.join
	end

	it "doesn't collapse sequential notifications" do
		@conn.exec( 'ROLLBACK' )
		@conn.exec( 'LISTEN woo' )
		@conn.exec( 'LISTEN war' )
		@conn.exec( 'LISTEN woz' )

		begin
			conn = described_class.connect( @conninfo )
			conn.exec( 'NOTIFY woo' )
			conn.exec( 'NOTIFY war' )
			conn.exec( 'NOTIFY woz' )
		ensure
			conn.finish
		end

		channels = []
		3.times do
			channels << @conn.wait_for_notify( 2 )
		end

		expect( channels.size ).to eq( 3 )
		expect( channels ).to include( 'woo', 'war', 'woz' )

		@conn.exec( 'UNLISTEN woz' )
		@conn.exec( 'UNLISTEN war' )
		@conn.exec( 'UNLISTEN woo' )
	end

	it "returns notifications which are already in the queue before wait_for_notify is called " +
	   "without waiting for the socket to become readable" do
		@conn.exec( 'ROLLBACK' )
		@conn.exec( 'LISTEN woo' )

		begin
			conn = described_class.connect( @conninfo )
			conn.exec( 'NOTIFY woo' )
		ensure
			conn.finish
		end

		# Cause the notification to buffer, but not be read yet
		@conn.exec( 'SELECT 1' )

		expect( @conn.wait_for_notify( 10 ) ).to eq( 'woo' )
		@conn.exec( 'UNLISTEN woo' )
	end

	it "can receive notices while waiting for NOTIFY without exceeding the timeout", :postgresql_90 do
		notices = []
		@conn.set_notice_processor do |msg|
			notices << [msg, Time.now]
		end
		st = Time.now
		@conn.send_query "SELECT pg_sleep(0.5); do $$ BEGIN RAISE NOTICE 'woohoo'; END; $$ LANGUAGE plpgsql;"
		expect( @conn.wait_for_notify( 1 ) ).to be_nil
		expect( notices.first ).to_not be_nil
		et = Time.now
		expect( (et - notices.first[1]) ).to be >= 0.4
		expect( (et - st) ).to be >= 0.9
		expect( (et - st) ).to be < 1.4
	end

	it "yields the result if block is given to exec" do
		rval = @conn.exec( "select 1234::int as a union select 5678::int as a" ) do |result|
			values = []
			expect( result ).to be_kind_of( PG::Result )
			expect( result.ntuples ).to eq( 2 )
			result.each do |tuple|
				values << tuple['a']
			end
			values
		end

		expect( rval.size ).to eq( 2 )
		expect( rval ).to include( '5678', '1234' )
	end

	it "can process #copy_data output queries" do
		rows = []
		res2 = @conn.copy_data( "COPY (SELECT 1 UNION ALL SELECT 2) TO STDOUT" ) do |res|
			expect( res.result_status ).to eq( PG::PGRES_COPY_OUT )
			expect( res.nfields ).to eq( 1 )
			while row=@conn.get_copy_data
				rows << row
			end
		end
		expect( rows ).to eq( ["1\n", "2\n"] )
		expect( res2.result_status ).to eq( PG::PGRES_COMMAND_OK )
		expect( @conn ).to still_be_usable
	end

	it "can handle incomplete #copy_data output queries" do
		expect {
			@conn.copy_data( "COPY (SELECT 1 UNION ALL SELECT 2) TO STDOUT" ) do |res|
				@conn.get_copy_data
			end
		}.to raise_error(PG::NotAllCopyDataRetrieved, /Not all/)
		expect( @conn ).to still_be_usable
	end

	it "can handle client errors in #copy_data for output" do
		expect {
			@conn.copy_data( "COPY (SELECT 1 UNION ALL SELECT 2) TO STDOUT" ) do
				raise "boom"
			end
		}.to raise_error(RuntimeError, "boom")
		expect( @conn ).to still_be_usable
	end

	it "can handle server errors in #copy_data for output", :postgresql_90 do
		@conn.exec "ROLLBACK"
		@conn.transaction do
			@conn.exec( "CREATE FUNCTION errfunc() RETURNS int AS $$ BEGIN RAISE 'test-error'; END; $$ LANGUAGE plpgsql;" )
			expect {
				@conn.copy_data( "COPY (SELECT errfunc()) TO STDOUT" ) do |res|
					while @conn.get_copy_data
					end
				end
			}.to raise_error(PG::Error, /test-error/)
		end
		expect( @conn ).to still_be_usable
	end

	it "can process #copy_data input queries" do
		@conn.exec( "CREATE TEMP TABLE copytable (col1 TEXT)" )
		res2 = @conn.copy_data( "COPY copytable FROM STDOUT" ) do |res|
			expect( res.result_status ).to eq( PG::PGRES_COPY_IN )
			expect( res.nfields ).to eq( 1 )
			@conn.put_copy_data "1\n"
			@conn.put_copy_data "2\n"
		end
		expect( res2.result_status ).to eq( PG::PGRES_COMMAND_OK )

		expect( @conn ).to still_be_usable

		res = @conn.exec( "SELECT * FROM copytable ORDER BY col1" )
		expect( res.values ).to eq( [["1"], ["2"]] )
	end

	it "can handle client errors in #copy_data for input" do
		@conn.exec "ROLLBACK"
		@conn.transaction do
			@conn.exec( "CREATE TEMP TABLE copytable (col1 TEXT)" )
			expect {
				@conn.copy_data( "COPY copytable FROM STDOUT" ) do |res|
					raise "boom"
				end
			}.to raise_error(RuntimeError, "boom")
		end

		expect( @conn ).to still_be_usable
	end

	it "can handle server errors in #copy_data for input" do
		@conn.exec "ROLLBACK"
		@conn.transaction do
			@conn.exec( "CREATE TEMP TABLE copytable (col1 INT)" )
			expect {
				@conn.copy_data( "COPY copytable FROM STDOUT" ) do |res|
					@conn.put_copy_data "xyz\n"
				end
			}.to raise_error(PG::Error, /invalid input syntax for integer/)
		end
		expect( @conn ).to still_be_usable
	end

	it "gracefully handle SQL statements while in #copy_data for input" do
		@conn.exec "ROLLBACK"
		@conn.transaction do
			@conn.exec( "CREATE TEMP TABLE copytable (col1 INT)" )
			expect {
				@conn.copy_data( "COPY copytable FROM STDOUT" ) do |res|
					@conn.exec "SELECT 1"
				end
			}.to raise_error(PG::Error, /no COPY in progress/)
		end
		expect( @conn ).to still_be_usable
	end

	it "gracefully handle SQL statements while in #copy_data for output" do
		@conn.exec "ROLLBACK"
		@conn.transaction do
			expect {
				@conn.copy_data( "COPY (VALUES(1), (2)) TO STDOUT" ) do |res|
					@conn.exec "SELECT 3"
				end
			}.to raise_error(PG::Error, /no COPY in progress/)
		end
		expect( @conn ).to still_be_usable
	end

	it "should raise an error for non copy statements in #copy_data" do
		expect {
			@conn.copy_data( "SELECT 1" ){}
		}.to raise_error(ArgumentError, /no COPY/)

		expect( @conn ).to still_be_usable
	end

	it "correctly finishes COPY queries passed to #async_exec" do
		@conn.async_exec( "COPY (SELECT 1 UNION ALL SELECT 2) TO STDOUT" )

		results = []
		begin
			data = @conn.get_copy_data( true )
			if false == data
				@conn.block( 2.0 )
				data = @conn.get_copy_data( true )
			end
			results << data if data
		end until data.nil?

		expect( results.size ).to eq( 2 )
		expect( results ).to include( "1\n", "2\n" )
	end


	it "described_class#block shouldn't block a second thread" do
		start = Time.now
		t = Thread.new do
			@conn.send_query( "select pg_sleep(3)" )
			@conn.block
		end

		sleep 0.5
		expect( t ).to be_alive()
		@conn.cancel
		t.join
		expect( (Time.now - start) ).to be < 3
	end

	it "described_class#block should allow a timeout" do
		@conn.send_query( "select pg_sleep(1)" )

		start = Time.now
		@conn.block( 0.3 )
		finish = Time.now

		expect( (finish - start) ).to be_within( 0.2 ).of( 0.3 )
	end


	it "can encrypt a string given a password and username" do
		expect( described_class.encrypt_password("postgres", "postgres") ).to match( /\S+/ )
	end

	it "can return the default connection options" do
		expect( described_class.conndefaults ).to be_a( Array )
		expect( described_class.conndefaults ).to all( be_a(Hash) )
		expect( described_class.conndefaults[0] ).to include( :keyword, :label, :dispchar, :dispsize )
		expect( @conn.conndefaults ).to eq( described_class.conndefaults )
	end

	it "can return the default connection options as a Hash" do
		expect( described_class.conndefaults_hash ).to be_a( Hash )
		expect( described_class.conndefaults_hash ).to include( :user, :password, :dbname, :host, :port )
		expect( ['5432', '54321'] ).to include( described_class.conndefaults_hash[:port] )
		expect( @conn.conndefaults_hash ).to eq( described_class.conndefaults_hash )
	end

	it "can return the connection's connection options", :postgresql_93 do
		expect( @conn.conninfo ).to be_a( Array )
		expect( @conn.conninfo ).to all( be_a(Hash) )
		expect( @conn.conninfo[0] ).to include( :keyword, :label, :dispchar, :dispsize )
	end


	it "can return the connection's connection options as a Hash", :postgresql_93 do
		expect( @conn.conninfo_hash ).to be_a( Hash )
		expect( @conn.conninfo_hash ).to include( :user, :password, :connect_timeout, :dbname, :host )
		expect( @conn.conninfo_hash[:dbname] ).to eq( 'test' )
	end

	describe "connection information related to SSL" do

		it "can retrieve connection's ssl state", :postgresql_95 do
			expect( @conn.ssl_in_use? ).to be false
		end

		it "can retrieve connection's ssl attribute_names", :postgresql_95 do
			expect( @conn.ssl_attribute_names ).to be_a(Array)
		end

		it "can retrieve a single ssl connection attribute", :postgresql_95 do
			expect( @conn.ssl_attribute('dbname') ).to eq( nil )
		end

		it "can retrieve all connection's ssl attributes", :postgresql_95 do
			expect( @conn.ssl_attributes ).to be_a_kind_of( Hash )
		end
	end


	it "honors the connect_timeout connection parameter", :postgresql_93 do
		conn = PG.connect( port: @port, dbname: 'test', connect_timeout: 11 )
		begin
			expect( conn.conninfo_hash[:connect_timeout] ).to eq( "11" )
		ensure
			conn.finish
		end
	end


	it "raises an appropriate error if either of the required arguments for encrypt_password " +
	   "is not valid" do
		expect {
			described_class.encrypt_password( nil, nil )
		}.to raise_error( TypeError )
		expect {
			described_class.encrypt_password( "postgres", nil )
		}.to raise_error( TypeError )
		expect {
			described_class.encrypt_password( nil, "postgres" )
		}.to raise_error( TypeError )
	end


	it "allows fetching a column of values from a result by column number" do
		res = @conn.exec( 'VALUES (1,2),(2,3),(3,4)' )
		expect( res.column_values( 0 ) ).to eq( %w[1 2 3] )
		expect( res.column_values( 1 ) ).to eq( %w[2 3 4] )
	end


	it "allows fetching a column of values from a result by field name" do
		res = @conn.exec( 'VALUES (1,2),(2,3),(3,4)' )
		expect( res.field_values( 'column1' ) ).to eq( %w[1 2 3] )
		expect( res.field_values( 'column2' ) ).to eq( %w[2 3 4] )
	end


	it "raises an error if selecting an invalid column index" do
		res = @conn.exec( 'VALUES (1,2),(2,3),(3,4)' )
		expect {
			res.column_values( 20 )
		}.to raise_error( IndexError )
	end


	it "raises an error if selecting an invalid field name" do
		res = @conn.exec( 'VALUES (1,2),(2,3),(3,4)' )
		expect {
			res.field_values( 'hUUuurrg' )
		}.to raise_error( IndexError )
	end


	it "raises an error if column index is not a number" do
		res = @conn.exec( 'VALUES (1,2),(2,3),(3,4)' )
		expect {
			res.column_values( 'hUUuurrg' )
		}.to raise_error( TypeError )
	end


	it "can connect asynchronously", :socket_io do
		serv = TCPServer.new( '127.0.0.1', 54320 )
		conn = described_class.connect_start( '127.0.0.1', 54320, "", "", "me", "xxxx", "somedb" )
		expect( [PG::PGRES_POLLING_WRITING, PG::CONNECTION_OK] ).to include conn.connect_poll
		select( nil, [conn.socket_io], nil, 0.2 )
		serv.close
		if conn.connect_poll == PG::PGRES_POLLING_READING
			select( [conn.socket_io], nil, nil, 0.2 )
		end
		expect( conn.connect_poll ).to eq( PG::PGRES_POLLING_FAILED )
	end

	it "discards previous results (if any) before waiting on an #async_exec"

	it "calls the block if one is provided to #async_exec" do
		result = nil
		@conn.async_exec( "select 47 as one" ) do |pg_res|
			result = pg_res[0]
		end
		expect( result ).to eq( { 'one' => '47' } )
	end

	it "raises a rescue-able error if #finish is called twice", :without_transaction do
		conn = PG.connect( @conninfo )

		conn.finish
		expect { conn.finish }.to raise_error( PG::ConnectionBad, /connection is closed/i )
	end

	it "closes the IO fetched from #socket_io when the connection is closed", :without_transaction, :socket_io do
		conn = PG.connect( @conninfo )
		io = conn.socket_io
		conn.finish
		expect( io ).to be_closed()
		expect { conn.socket_io }.to raise_error( PG::ConnectionBad, /connection is closed/i )
	end

	it "closes the IO fetched from #socket_io when the connection is reset", :without_transaction, :socket_io do
		conn = PG.connect( @conninfo )
		io = conn.socket_io
		conn.reset
		expect( io ).to be_closed()
		expect( conn.socket_io ).to_not equal( io )
		conn.finish
	end

	it "block should raise ConnectionBad for a closed connection" do
		serv = TCPServer.new( '127.0.0.1', 54320 )
		conn = described_class.connect_start( '127.0.0.1', 54320, "", "", "me", "xxxx", "somedb" )
		while [PG::CONNECTION_STARTED, PG::CONNECTION_MADE].include?(conn.connect_poll)
			sleep 0.1
		end
		serv.close
		expect{ conn.block }.to raise_error(PG::ConnectionBad, /server closed the connection unexpectedly/)
		expect{ conn.block }.to raise_error(PG::ConnectionBad, /can't get socket descriptor/)
	end

	context "under PostgreSQL 9", :postgresql_90 do

		before( :each ) do
			pending "only works with a PostgreSQL >= 9.0 server" if @conn.server_version < 9_00_00
		end

		it "sets the fallback_application_name on new connections" do
			conn_string = PG::Connection.parse_connect_args( 'dbname=test' )

			conn_name = conn_string[ /application_name='(.*?)'/, 1 ]
			expect( conn_name ).to include( $0[0..10] )
			expect( conn_name ).to include( $0[-10..-1] )
			expect( conn_name.length ).to be <= 64
		end

		it "sets a shortened fallback_application_name on new connections" do
			old_0 = $0
			begin
				$0 = "/this/is/a/very/long/path/with/many/directories/to/our/beloved/ruby"
				conn_string = PG::Connection.parse_connect_args( 'dbname=test' )
				conn_name = conn_string[ /application_name='(.*?)'/, 1 ]
				expect( conn_name ).to include( $0[0..10] )
				expect( conn_name ).to include( $0[-10..-1] )
				expect( conn_name.length ).to be <= 64
			ensure
				$0 = old_0
			end
		end

		it "calls the block supplied to wait_for_notify with the notify payload if it accepts " +
		    "any number of arguments" do

			@conn.exec( 'ROLLBACK' )
			@conn.exec( 'LISTEN knees' )

			conn = described_class.connect( @conninfo )
			conn.exec( %Q{NOTIFY knees, 'skirt and boots'} )
			conn.finish

			event, pid, msg = nil
			@conn.wait_for_notify( 10 ) do |*args|
				event, pid, msg = *args
			end
			@conn.exec( 'UNLISTEN knees' )

			expect( event ).to eq( 'knees' )
			expect( pid ).to be_a_kind_of( Integer )
			expect( msg ).to eq( 'skirt and boots' )
		end

		it "accepts nil as the timeout in #wait_for_notify " do
			@conn.exec( 'ROLLBACK' )
			@conn.exec( 'LISTEN knees' )

			conn = described_class.connect( @conninfo )
			conn.exec( %Q{NOTIFY knees} )
			conn.finish

			event, pid = nil
			@conn.wait_for_notify( nil ) do |*args|
				event, pid = *args
			end
			@conn.exec( 'UNLISTEN knees' )

			expect( event ).to eq( 'knees' )
			expect( pid ).to be_a_kind_of( Integer )
		end

		it "sends nil as the payload if the notification wasn't given one" do
			@conn.exec( 'ROLLBACK' )
			@conn.exec( 'LISTEN knees' )

			conn = described_class.connect( @conninfo )
			conn.exec( %Q{NOTIFY knees} )
			conn.finish

			payload = :notnil
			@conn.wait_for_notify( nil ) do |*args|
				payload = args[ 2 ]
			end
			@conn.exec( 'UNLISTEN knees' )

			expect( payload ).to be_nil()
		end

		it "calls the block supplied to wait_for_notify with the notify payload if it accepts " +
		   "two arguments" do

			@conn.exec( 'ROLLBACK' )
			@conn.exec( 'LISTEN knees' )

			conn = described_class.connect( @conninfo )
			conn.exec( %Q{NOTIFY knees, 'skirt and boots'} )
			conn.finish

			event, pid, msg = nil
			@conn.wait_for_notify( 10 ) do |arg1, arg2|
				event, pid, msg = arg1, arg2
			end
			@conn.exec( 'UNLISTEN knees' )

			expect( event ).to eq( 'knees' )
			expect( pid ).to be_a_kind_of( Integer )
			expect( msg ).to be_nil()
		end

		it "calls the block supplied to wait_for_notify with the notify payload if it " +
		   "doesn't accept arguments" do

			@conn.exec( 'ROLLBACK' )
			@conn.exec( 'LISTEN knees' )

			conn = described_class.connect( @conninfo )
			conn.exec( %Q{NOTIFY knees, 'skirt and boots'} )
			conn.finish

			notification_received = false
			@conn.wait_for_notify( 10 ) do
				notification_received = true
			end
			@conn.exec( 'UNLISTEN knees' )

			expect( notification_received ).to be_truthy()
		end

		it "calls the block supplied to wait_for_notify with the notify payload if it accepts " +
		   "three arguments" do

			@conn.exec( 'ROLLBACK' )
			@conn.exec( 'LISTEN knees' )

			conn = described_class.connect( @conninfo )
			conn.exec( %Q{NOTIFY knees, 'skirt and boots'} )
			conn.finish

			event, pid, msg = nil
			@conn.wait_for_notify( 10 ) do |arg1, arg2, arg3|
				event, pid, msg = arg1, arg2, arg3
			end
			@conn.exec( 'UNLISTEN knees' )

			expect( event ).to eq( 'knees' )
			expect( pid ).to be_a_kind_of( Integer )
			expect( msg ).to eq( 'skirt and boots' )
		end

	end

	context "under PostgreSQL 9.1 client library", :postgresql_91, :without_transaction do

		it "pings successfully with connection string" do
			ping = described_class.ping(@conninfo)
			expect( ping ).to eq( PG::PQPING_OK )
		end

		it "pings using 7 arguments converted to strings" do
			ping = described_class.ping('localhost', @port, nil, nil, :test, nil, nil)
			expect( ping ).to eq( PG::PQPING_OK )
		end

		it "pings using a hash of connection parameters" do
			ping = described_class.ping(
				:host => 'localhost',
				:port => @port,
				:dbname => :test)
			expect( ping ).to eq( PG::PQPING_OK )
		end

		it "returns correct response when ping connection cannot be established" do
			ping = described_class.ping(
				:host => 'localhost',
				:port => 9999,
				:dbname => :test)
			expect( ping ).to eq( PG::PQPING_NO_RESPONSE )
		end

		it "returns correct response when ping connection arguments are wrong" do
			ping = described_class.ping('localhost', 'localhost', nil, nil, :test, nil, nil)
			expect( ping ).to eq( PG::PQPING_NO_ATTEMPT )
		end


	end

	context "under PostgreSQL 9.2 client library", :postgresql_92 do
		describe "set_single_row_mode" do

			it "raises an error when called at the wrong time" do
				expect {
					@conn.set_single_row_mode
				}.to raise_error(PG::Error)
			end

			it "should work in single row mode" do
				@conn.send_query( "SELECT generate_series(1,10)" )
				@conn.set_single_row_mode

				results = []
				loop do
					@conn.block
					res = @conn.get_result or break
					results << res
				end
				expect( results.length ).to eq( 11 )
				results[0..-2].each do |res|
					expect( res.result_status ).to eq( PG::PGRES_SINGLE_TUPLE )
					values = res.field_values('generate_series')
					expect( values.length ).to eq( 1 )
					expect( values.first.to_i ).to be > 0
				end
				expect( results.last.result_status ).to eq( PG::PGRES_TUPLES_OK )
				expect( results.last.ntuples ).to eq( 0 )
			end

			it "should receive rows before entire query is finished" do
				@conn.send_query( "SELECT generate_series(0,999), NULL UNION ALL SELECT 1000, pg_sleep(1);" )
				@conn.set_single_row_mode

				start_time = Time.now
				first_row_time = nil
				loop do
					res = @conn.get_result or break
					res.check
					first_row_time = Time.now unless first_row_time
				end
				expect( (Time.now - start_time) ).to be >= 0.9
				expect( (first_row_time - start_time) ).to be < 0.9
			end

			it "should receive rows before entire query fails" do
				@conn.exec( "CREATE FUNCTION errfunc() RETURNS int AS $$ BEGIN RAISE 'test-error'; END; $$ LANGUAGE plpgsql;" )
				@conn.send_query( "SELECT generate_series(0,999), NULL UNION ALL SELECT 1000, errfunc();" )
				@conn.set_single_row_mode

				first_result = nil
				expect do
					loop do
						res = @conn.get_result or break
						res.check
						first_result ||= res
					end
				end.to raise_error(PG::Error)
				expect( first_result.kind_of?(PG::Result) ).to be_truthy
				expect( first_result.result_status ).to eq( PG::PGRES_SINGLE_TUPLE )
			end
		end
	end

	context "multinationalization support", :ruby_19 do

		describe "rubyforge #22925: m17n support" do
			it "should return results in the same encoding as the client (iso-8859-1)" do
				out_string = nil
				@conn.transaction do |conn|
					conn.internal_encoding = 'iso8859-1'
					res = conn.exec("VALUES ('fantasia')", [], 0)
					out_string = res[0]['column1']
				end
				expect( out_string ).to eq( 'fantasia' )
				expect( out_string.encoding ).to eq( Encoding::ISO8859_1 )
			end

			it "should return results in the same encoding as the client (utf-8)" do
				out_string = nil
				@conn.transaction do |conn|
					conn.internal_encoding = 'utf-8'
					res = conn.exec("VALUES ('世界線航跡蔵')", [], 0)
					out_string = res[0]['column1']
				end
				expect( out_string ).to eq( '世界線航跡蔵' )
				expect( out_string.encoding ).to eq( Encoding::UTF_8 )
			end

			it "should return results in the same encoding as the client (EUC-JP)" do
				out_string = nil
				@conn.transaction do |conn|
					conn.internal_encoding = 'EUC-JP'
					stmt = "VALUES ('世界線航跡蔵')".encode('EUC-JP')
					res = conn.exec(stmt, [], 0)
					out_string = res[0]['column1']
				end
				expect( out_string ).to eq( '世界線航跡蔵'.encode('EUC-JP') )
				expect( out_string.encoding ).to eq( Encoding::EUC_JP )
			end

			it "returns the results in the correct encoding even if the client_encoding has " +
			   "changed since the results were fetched" do
				out_string = nil
				@conn.transaction do |conn|
					conn.internal_encoding = 'EUC-JP'
					stmt = "VALUES ('世界線航跡蔵')".encode('EUC-JP')
					res = conn.exec(stmt, [], 0)
					conn.internal_encoding = 'utf-8'
					out_string = res[0]['column1']
				end
				expect( out_string ).to eq( '世界線航跡蔵'.encode('EUC-JP') )
				expect( out_string.encoding ).to eq( Encoding::EUC_JP )
			end

			it "the connection should return ASCII-8BIT when it's set to SQL_ASCII" do
				@conn.exec "SET client_encoding TO SQL_ASCII"
				expect( @conn.internal_encoding ).to eq( Encoding::ASCII_8BIT )
			end

			it "uses the client encoding for escaped string" do
				original = "Möhre to\0 escape".encode( "utf-16be" )
				@conn.set_client_encoding( "euc_jp" )
				escaped  = @conn.escape( original )
				expect( escaped.encoding ).to eq( Encoding::EUC_JP )
				expect( escaped ).to eq( "Möhre to".encode(Encoding::EUC_JP) )
			end

			it "uses the client encoding for escaped literal", :postgresql_90 do
				original = "Möhre to\0 escape".encode( "utf-16be" )
				@conn.set_client_encoding( "euc_jp" )
				escaped  = @conn.escape_literal( original )
				expect( escaped.encoding ).to eq( Encoding::EUC_JP )
				expect( escaped ).to eq( "'Möhre to'".encode(Encoding::EUC_JP) )
			end

			it "uses the client encoding for escaped identifier", :postgresql_90 do
				original = "Möhre to\0 escape".encode( "utf-16le" )
				@conn.set_client_encoding( "euc_jp" )
				escaped  = @conn.escape_identifier( original )
				expect( escaped.encoding ).to eq( Encoding::EUC_JP )
				expect( escaped ).to eq( "\"Möhre to\"".encode(Encoding::EUC_JP) )
			end

			it "uses the client encoding for quote_ident" do
				original = "Möhre to\0 escape".encode( "utf-16le" )
				@conn.set_client_encoding( "euc_jp" )
				escaped  = @conn.quote_ident( original )
				expect( escaped.encoding ).to eq( Encoding::EUC_JP )
				expect( escaped ).to eq( "\"Möhre to\"".encode(Encoding::EUC_JP) )
			end

			it "uses the previous string encoding for escaped string" do
				original = "Möhre to\0 escape".encode( "iso-8859-1" )
				@conn.set_client_encoding( "euc_jp" )
				escaped  = described_class.escape( original )
				expect( escaped.encoding ).to eq( Encoding::ISO8859_1 )
				expect( escaped ).to eq( "Möhre to".encode(Encoding::ISO8859_1) )
			end

			it "uses the previous string encoding for quote_ident" do
				original = "Möhre to\0 escape".encode( "iso-8859-1" )
				@conn.set_client_encoding( "euc_jp" )
				escaped  = described_class.quote_ident( original )
				expect( escaped.encoding ).to eq( Encoding::ISO8859_1 )
				expect( escaped.encode ).to eq( "\"Möhre to\"".encode(Encoding::ISO8859_1) )
			end
		end

		describe "respect and convert character encoding of input strings" do
			before :each do
				@conn.internal_encoding = __ENCODING__
			end

			it "should convert query string and parameters to #exec_params" do
				r = @conn.exec_params("VALUES( $1, $2, $1=$2, 'grün')".encode("utf-16le"),
				                  ['grün'.encode('utf-16be'), 'grün'.encode('iso-8859-1')])
				expect( r.values ).to eq( [['grün', 'grün', 't', 'grün']] )
			end

			it "should convert query string and parameters to #async_exec" do
				r = @conn.async_exec("VALUES( $1, $2, $1=$2, 'grün')".encode("cp936"),
				                  ['grün'.encode('cp850'), 'grün'.encode('utf-16le')])
				expect( r.values ).to eq( [['grün', 'grün', 't', 'grün']] )
			end

			it "should convert query string to #exec" do
				r = @conn.exec("SELECT 'grün'".encode("utf-16be"))
				expect( r.values ).to eq( [['grün']] )
			end

			it "should convert query string to #async_exec" do
				r = @conn.async_exec("SELECT 'grün'".encode("utf-16le"))
				expect( r.values ).to eq( [['grün']] )
			end

			it "should convert strings and parameters to #prepare and #exec_prepared" do
				@conn.prepare("weiß1".encode("utf-16be"), "VALUES( $1, $2, $1=$2, 'grün')".encode("cp850"))
				r = @conn.exec_prepared("weiß1".encode("utf-32le"),
				                ['grün'.encode('cp936'), 'grün'.encode('utf-16le')])
				expect( r.values ).to eq( [['grün', 'grün', 't', 'grün']] )
			end

			it "should convert strings to #describe_prepared" do
				@conn.prepare("weiß2", "VALUES(123)")
				r = @conn.describe_prepared("weiß2".encode("utf-16be"))
				expect( r.nfields ).to eq( 1 )
			end

			it "should convert strings to #describe_portal" do
				@conn.exec "DECLARE cörsör CURSOR FOR VALUES(1,2,3)"
				r = @conn.describe_portal("cörsör".encode("utf-16le"))
				expect( r.nfields ).to eq( 3 )
			end

			it "should convert query string to #send_query" do
				@conn.send_query("VALUES('grün')".encode("utf-16be"))
				expect( @conn.get_last_result.values ).to eq( [['grün']] )
			end

			it "should convert query string and parameters to #send_query" do
				@conn.send_query("VALUES( $1, $2, $1=$2, 'grün')".encode("utf-16le"),
				                  ['grün'.encode('utf-32be'), 'grün'.encode('iso-8859-1')])
				expect( @conn.get_last_result.values ).to eq( [['grün', 'grün', 't', 'grün']] )
			end

			it "should convert strings and parameters to #send_prepare and #send_query_prepared" do
				@conn.send_prepare("weiß3".encode("iso-8859-1"), "VALUES( $1, $2, $1=$2, 'grün')".encode("utf-16be"))
				@conn.get_last_result
				@conn.send_query_prepared("weiß3".encode("utf-32le"),
				                ['grün'.encode('utf-16le'), 'grün'.encode('iso-8859-1')])
				expect( @conn.get_last_result.values ).to eq( [['grün', 'grün', 't', 'grün']] )
			end

			it "should convert strings to #send_describe_prepared" do
				@conn.prepare("weiß4", "VALUES(123)")
				@conn.send_describe_prepared("weiß4".encode("utf-16be"))
				expect( @conn.get_last_result.nfields ).to eq( 1 )
			end

			it "should convert strings to #send_describe_portal" do
				@conn.exec "DECLARE cörsör CURSOR FOR VALUES(1,2,3)"
				@conn.send_describe_portal("cörsör".encode("utf-16le"))
				expect( @conn.get_last_result.nfields ).to eq( 3 )
			end

			it "should convert error string to #put_copy_end" do
				@conn.exec( "CREATE TEMP TABLE copytable (col1 TEXT)" )
				@conn.exec( "COPY copytable FROM STDIN" )
				@conn.put_copy_end("grün".encode("utf-16be"))
				expect( @conn.get_result.error_message ).to match(/grün/)
				@conn.get_result
			end
		end

		it "can quote bigger strings with quote_ident" do
			original = "'01234567\"" * 100
			escaped = described_class.quote_ident( original + "\0afterzero" )
			expect( escaped ).to eq( "\"" + original.gsub("\"", "\"\"") + "\"" )
		end

		it "can quote Arrays with quote_ident" do
			original = "'01234567\""
			escaped = described_class.quote_ident( [original]*3 )
			expected = ["\"" + original.gsub("\"", "\"\"") + "\""] * 3
			expect( escaped ).to eq( expected.join(".") )
		end

		it "will raise a TypeError for invalid arguments to quote_ident" do
			expect{ described_class.quote_ident( nil ) }.to raise_error(TypeError)
			expect{ described_class.quote_ident( [nil] ) }.to raise_error(TypeError)
			expect{ described_class.quote_ident( [['a']] ) }.to raise_error(TypeError)
		end

		describe "Ruby 1.9.x default_internal encoding" do

			it "honors the Encoding.default_internal if it's set and the synchronous interface is used" do
				@conn.transaction do |txn_conn|
					txn_conn.internal_encoding = Encoding::ISO8859_1
					txn_conn.exec( "CREATE TABLE defaultinternaltest ( foo text )" )
					txn_conn.exec( "INSERT INTO defaultinternaltest VALUES ('Grün und Weiß')" )
				end

				begin
					prev_encoding = Encoding.default_internal
					Encoding.default_internal = Encoding::ISO8859_2

					conn = PG.connect( @conninfo )
					expect( conn.internal_encoding ).to eq( Encoding::ISO8859_2 )
					res = conn.exec( "SELECT foo FROM defaultinternaltest" )
					expect( res[0]['foo'].encoding ).to eq( Encoding::ISO8859_2 )
				ensure
					conn.exec( "DROP TABLE defaultinternaltest" )
					conn.finish if conn
					Encoding.default_internal = prev_encoding
				end
			end

			it "allows users of the async interface to set the client_encoding to the default_internal" do
				begin
					prev_encoding = Encoding.default_internal
					Encoding.default_internal = Encoding::KOI8_R

					@conn.set_default_encoding

					expect( @conn.internal_encoding ).to eq( Encoding::KOI8_R )
				ensure
					Encoding.default_internal = prev_encoding
				end
			end

		end


		it "encodes exception messages with the connection's encoding (#96)", :without_transaction do
			# Use a new connection so the client_encoding isn't set outside of this example
			conn = PG.connect( @conninfo )
			conn.client_encoding = 'iso-8859-15'

			conn.transaction do
				conn.exec "CREATE TABLE foo (bar TEXT)"

				begin
					query = "INSERT INTO foo VALUES ('Côte d'Ivoire')".encode( 'iso-8859-15' )
					conn.exec( query )
				rescue => err
					expect( err.message.encoding ).to eq( Encoding::ISO8859_15 )
				else
					fail "No exception raised?!"
				end
			end

			conn.finish if conn
		end

		it "handles clearing result in or after set_notice_receiver", :postgresql_90 do
			r = nil
			@conn.set_notice_receiver do |result|
				r = result
				expect( r.cleared? ).to eq(false)
			end
			@conn.exec "do $$ BEGIN RAISE NOTICE 'foo'; END; $$ LANGUAGE plpgsql;"
			sleep 0.2
			expect( r ).to be_a( PG::Result )
			expect( r.cleared? ).to eq(true)
			expect( r.autoclear? ).to eq(true)
			r.clear
			@conn.set_notice_receiver
		end

		it "receives properly encoded messages in the notice callbacks", :postgresql_90 do
			[:receiver, :processor].each do |kind|
				notices = []
				@conn.internal_encoding = 'utf-8'
				if kind == :processor
					@conn.set_notice_processor do |msg|
						notices << msg
					end
				else
					@conn.set_notice_receiver do |result|
						notices << result.error_message
					end
				end

				3.times do
					@conn.exec "do $$ BEGIN RAISE NOTICE '世界線航跡蔵'; END; $$ LANGUAGE plpgsql;"
				end

				expect( notices.length ).to eq( 3 )
				notices.each do |notice|
					expect( notice ).to match( /^NOTICE:.*世界線航跡蔵/ )
					expect( notice.encoding ).to eq( Encoding::UTF_8 )
				end
				@conn.set_notice_receiver
				@conn.set_notice_processor
			end
		end

		it "receives properly encoded text from wait_for_notify", :postgresql_90 do
			@conn.internal_encoding = 'utf-8'
			@conn.exec( 'ROLLBACK' )
			@conn.exec( 'LISTEN "Möhre"' )
			@conn.exec( %Q{NOTIFY "Möhre", '世界線航跡蔵'} )
			event, pid, msg = nil
			@conn.wait_for_notify( 10 ) do |*args|
				event, pid, msg = *args
			end
			@conn.exec( 'UNLISTEN "Möhre"' )

			expect( event ).to eq( "Möhre" )
			expect( event.encoding ).to eq( Encoding::UTF_8 )
			expect( msg ).to eq( '世界線航跡蔵' )
			expect( msg.encoding ).to eq( Encoding::UTF_8 )
		end

		it "returns properly encoded text from notifies", :postgresql_90 do
			@conn.internal_encoding = 'utf-8'
			@conn.exec( 'ROLLBACK' )
			@conn.exec( 'LISTEN "Möhre"' )
			@conn.exec( %Q{NOTIFY "Möhre", '世界線航跡蔵'} )
			@conn.exec( 'UNLISTEN "Möhre"' )

			notification = @conn.notifies
			expect( notification[:relname] ).to eq( "Möhre" )
			expect( notification[:relname].encoding ).to eq( Encoding::UTF_8 )
			expect( notification[:extra] ).to eq( '世界線航跡蔵' )
			expect( notification[:extra].encoding ).to eq( Encoding::UTF_8 )
			expect( notification[:be_pid] ).to be > 0
		end
	end

	context "OS thread support", :ruby_19 do
		it "Connection#exec shouldn't block a second thread" do
			t = Thread.new do
				@conn.exec( "select pg_sleep(1)" )
			end

			sleep 0.5
			expect( t ).to be_alive()
			t.join
		end

		it "Connection.new shouldn't block a second thread" do
			serv = nil
			t = Thread.new do
				serv = TCPServer.new( '127.0.0.1', 54320 )
				expect {
					described_class.new( '127.0.0.1', 54320, "", "", "me", "xxxx", "somedb" )
				}.to raise_error(PG::ConnectionBad, /server closed the connection unexpectedly/)
			end

			sleep 0.5
			expect( t ).to be_alive()
			serv.close
			t.join
		end
	end

	describe "type casting" do
		it "should raise an error on invalid param mapping" do
			expect{
				@conn.exec_params( "SELECT 1", [], nil, :invalid )
			}.to raise_error(TypeError)
		end

		it "should return nil if no type mapping is set" do
			expect( @conn.type_map_for_queries ).to be_kind_of(PG::TypeMapAllStrings)
			expect( @conn.type_map_for_results ).to be_kind_of(PG::TypeMapAllStrings)
		end

		it "shouldn't type map params unless requested" do
			expect{
				@conn.exec_params( "SELECT $1", [5] )
			}.to raise_error(PG::IndeterminateDatatype)
		end

		it "should raise an error on invalid encoder to put_copy_data" do
			expect{
				@conn.put_copy_data [1], :invalid
			}.to raise_error(TypeError)
		end

		it "can type cast parameters to put_copy_data with explicit encoder" do
			tm = PG::TypeMapByColumn.new [nil]
			row_encoder = PG::TextEncoder::CopyRow.new type_map: tm

			@conn.exec( "CREATE TEMP TABLE copytable (col1 TEXT)" )
			res2 = @conn.copy_data( "COPY copytable FROM STDOUT" ) do |res|
				@conn.put_copy_data [1], row_encoder
				@conn.put_copy_data ["2"], row_encoder
			end

			res2 = @conn.copy_data( "COPY copytable FROM STDOUT", row_encoder ) do |res|
				@conn.put_copy_data [3]
				@conn.put_copy_data ["4"]
			end

			res = @conn.exec( "SELECT * FROM copytable ORDER BY col1" )
			expect( res.values ).to eq( [["1"], ["2"], ["3"], ["4"]] )
		end

		context "with default query type map" do
			before :each do
				@conn2 = described_class.new(@conninfo)
				tm = PG::TypeMapByClass.new
				tm[Integer] = PG::TextEncoder::Integer.new oid: 20
				@conn2.type_map_for_queries = tm

				row_encoder = PG::TextEncoder::CopyRow.new type_map: tm
				@conn2.encoder_for_put_copy_data = row_encoder
			end
			after :each do
				@conn2.close
			end

			it "should respect a type mapping for params and it's OID and format code" do
				res = @conn2.exec_params( "SELECT $1", [5] )
				expect( res.values ).to eq( [["5"]] )
				expect( res.ftype(0) ).to eq( 20 )
			end

			it "should return the current type mapping" do
				expect( @conn2.type_map_for_queries ).to be_kind_of(PG::TypeMapByClass)
			end

			it "should work with arbitrary number of params in conjunction with type casting" do
				begin
					3.step( 12, 0.2 ) do |exp|
						num_params = (2 ** exp).to_i
						sql = num_params.times.map{|n| "$#{n+1}" }.join(",")
						params = num_params.times.to_a
						res = @conn2.exec_params( "SELECT #{sql}", params )
						expect( res.nfields ).to eq( num_params )
						expect( res.values ).to eq( [num_params.times.map(&:to_s)] )
					end
				rescue PG::ProgramLimitExceeded
					# Stop silently as soon the server complains about too many params
				end
			end

			it "can process #copy_data input queries with row encoder and respects character encoding" do
				@conn2.exec( "CREATE TEMP TABLE copytable (col1 TEXT)" )
				res2 = @conn2.copy_data( "COPY copytable FROM STDOUT" ) do |res|
					@conn2.put_copy_data [1]
					@conn2.put_copy_data ["Möhre".encode("utf-16le")]
				end

				res = @conn2.exec( "SELECT * FROM copytable ORDER BY col1" )
				expect( res.values ).to eq( [["1"], ["Möhre"]] )
			end
		end

		context "with default result type map" do
			before :each do
				@conn2 = described_class.new(@conninfo)
				tm = PG::TypeMapByOid.new
				tm.add_coder PG::TextDecoder::Integer.new oid: 23, format: 0
				@conn2.type_map_for_results = tm

				row_decoder = PG::TextDecoder::CopyRow.new
				@conn2.decoder_for_get_copy_data = row_decoder
			end
			after :each do
				@conn2.close
			end

			it "should respect a type mapping for result" do
				res = @conn2.exec_params( "SELECT $1::INT", ["5"] )
				expect( res.values ).to eq( [[5]] )
			end

			it "should return the current type mapping" do
				expect( @conn2.type_map_for_results ).to be_kind_of(PG::TypeMapByOid)
			end

			it "should work with arbitrary number of params in conjunction with type casting" do
				begin
					3.step( 12, 0.2 ) do |exp|
						num_params = (2 ** exp).to_i
						sql = num_params.times.map{|n| "$#{n+1}::INT" }.join(",")
						params = num_params.times.to_a
						res = @conn2.exec_params( "SELECT #{sql}", params )
						expect( res.nfields ).to eq( num_params )
						expect( res.values ).to eq( [num_params.times.to_a] )
					end
				rescue PG::ProgramLimitExceeded
					# Stop silently as soon the server complains about too many params
				end
			end

			it "can process #copy_data output with row decoder and respects character encoding" do
				@conn2.internal_encoding = Encoding::ISO8859_1
				rows = []
				res2 = @conn2.copy_data( "COPY (VALUES('1'), ('Möhre')) TO STDOUT".encode("utf-16le") ) do |res|
					while row=@conn2.get_copy_data
						rows << row
					end
				end
				expect( rows.last.last.encoding ).to eq( Encoding::ISO8859_1 )
				expect( rows ).to eq( [["1"], ["Möhre".encode("iso-8859-1")]] )
			end

			it "can type cast #copy_data output with explicit decoder" do
				tm = PG::TypeMapByColumn.new [PG::TextDecoder::Integer.new]
				row_decoder = PG::TextDecoder::CopyRow.new type_map: tm
				rows = []
				@conn.copy_data( "COPY (SELECT 1 UNION ALL SELECT 2) TO STDOUT", row_decoder ) do |res|
					while row=@conn.get_copy_data
						rows << row
					end
				end
				@conn.copy_data( "COPY (SELECT 3 UNION ALL SELECT 4) TO STDOUT" ) do |res|
					while row=@conn.get_copy_data( false, row_decoder )
						rows << row
					end
				end
				expect( rows ).to eq( [[1], [2], [3], [4]] )
			end
		end
	end
end

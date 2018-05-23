#!/usr/bin/env rspec
# encoding: utf-8

require_relative '../helpers'

require 'pg'


describe PG::Result do

	it "acts as an array of hashes" do
		res = @conn.exec("SELECT 1 AS a, 2 AS b")
		expect( res[0]['a'] ).to eq( '1' )
		expect( res[0]['b'] ).to eq( '2' )
	end

	it "yields a row as an array" do
		res = @conn.exec("SELECT 1 AS a, 2 AS b")
		list = []
		res.each_row { |r| list << r }
		expect( list ).to eq [['1', '2']]
	end

	it "yields a row as an Enumerator" do
		res = @conn.exec("SELECT 1 AS a, 2 AS b")
		e = res.each_row
		expect( e ).to be_a_kind_of(Enumerator)
		pending "Rubinius doesn't define RETURN_SIZED_ENUMERATOR()" if RUBY_ENGINE=='rbx'
		expect( e.size ).to eq( 1 )
		expect( e.to_a ).to eq [['1', '2']]
	end

	it "yields a row as an Enumerator of hashs" do
		res = @conn.exec("SELECT 1 AS a, 2 AS b")
		e = res.each
		expect( e ).to be_a_kind_of(Enumerator)
		pending "Rubinius doesn't define RETURN_SIZED_ENUMERATOR()" if RUBY_ENGINE=='rbx'
		expect( e.size ).to eq( 1 )
		expect( e.to_a ).to eq [{'a'=>'1', 'b'=>'2'}]
	end

	context "result streaming", :postgresql_92 do
		it "can iterate over all tuples in single row mode" do
			@conn.send_query( "SELECT generate_series(2,4) AS a; SELECT 1 AS b, generate_series(5,6) AS c" )
			@conn.set_single_row_mode
			expect(
				@conn.get_result.stream_each.to_a
			).to eq(
				[{'a'=>"2"}, {'a'=>"3"}, {'a'=>"4"}]
			)
			expect(
				@conn.get_result.enum_for(:stream_each).to_a
			).to eq(
				[{'b'=>"1", 'c'=>"5"}, {'b'=>"1", 'c'=>"6"}]
			)
			expect( @conn.get_result ).to be_nil
		end

		it "can iterate over all rows in single row mode" do
			@conn.send_query( "SELECT generate_series(2,4) AS a; SELECT 1 AS b, generate_series(5,6) AS c" )
			@conn.set_single_row_mode
			expect(
				@conn.get_result.enum_for(:stream_each_row).to_a
			).to eq(
				[["2"], ["3"], ["4"]]
			)
			expect(
				@conn.get_result.stream_each_row.to_a
			).to eq(
				[["1", "5"], ["1", "6"]]
			)
			expect( @conn.get_result ).to be_nil
		end

		it "complains when not in single row mode" do
			@conn.send_query( "SELECT generate_series(2,4)" )
			expect{
				@conn.get_result.stream_each_row.to_a
			}.to raise_error(PG::InvalidResultStatus, /not in single row mode/)
		end

		it "complains when intersected with get_result" do
			@conn.send_query( "SELECT 1" )
			@conn.set_single_row_mode
			expect{
				@conn.get_result.stream_each_row.each{ @conn.get_result }
			}.to raise_error(PG::NoResultError, /no result received/)
		end

		it "raises server errors" do
			@conn.send_query( "SELECT 0/0" )
			expect{
				@conn.get_result.stream_each_row.to_a
			}.to raise_error(PG::DivisionByZero)
		end
	end

	it "inserts nil AS NULL and return NULL as nil" do
		res = @conn.exec("SELECT $1::int AS n", [nil])
		expect( res[0]['n'] ).to be_nil()
	end

	it "encapsulates errors in a PG::Error object" do
		exception = nil
		begin
			@conn.exec( "SELECT * FROM nonexistant_table" )
		rescue PG::Error => err
			exception = err
		end

		result = exception.result

		expect( result ).to be_a( described_class() )
		expect( result.error_field(PG::PG_DIAG_SEVERITY) ).to eq( 'ERROR' )
		expect( result.error_field(PG::PG_DIAG_SQLSTATE) ).to eq( '42P01' )
		expect(
			result.error_field(PG::PG_DIAG_MESSAGE_PRIMARY)
		).to eq( 'relation "nonexistant_table" does not exist' )
		expect( result.error_field(PG::PG_DIAG_MESSAGE_DETAIL) ).to be_nil()
		expect( result.error_field(PG::PG_DIAG_MESSAGE_HINT) ).to be_nil()
		expect( result.error_field(PG::PG_DIAG_STATEMENT_POSITION) ).to eq( '15' )
		expect( result.error_field(PG::PG_DIAG_INTERNAL_POSITION) ).to be_nil()
		expect( result.error_field(PG::PG_DIAG_INTERNAL_QUERY) ).to be_nil()
		expect( result.error_field(PG::PG_DIAG_CONTEXT) ).to be_nil()
		expect(
			result.error_field(PG::PG_DIAG_SOURCE_FILE)
		).to match( /parse_relation\.c$|namespace\.c$/ )
		expect( result.error_field(PG::PG_DIAG_SOURCE_LINE) ).to match( /^\d+$/ )
		expect(
			result.error_field(PG::PG_DIAG_SOURCE_FUNCTION)
		).to match( /^parserOpenTable$|^RangeVarGetRelid$/ )
	end

	it "encapsulates database object names for integrity constraint violations", :postgresql_93 do
		@conn.exec( "CREATE TABLE integrity (id SERIAL PRIMARY KEY)" )
		exception = nil
		begin
			@conn.exec( "INSERT INTO integrity VALUES (NULL)" )
		rescue PG::Error => err
			exception = err
		end
		result = exception.result

		expect( result.error_field(PG::PG_DIAG_SCHEMA_NAME) ).to eq( 'public' )
		expect( result.error_field(PG::PG_DIAG_TABLE_NAME) ).to eq( 'integrity' )
		expect( result.error_field(PG::PG_DIAG_COLUMN_NAME) ).to eq( 'id' )
		expect( result.error_field(PG::PG_DIAG_DATATYPE_NAME) ).to be_nil
		expect( result.error_field(PG::PG_DIAG_CONSTRAINT_NAME) ).to be_nil
	end

	it "detects division by zero as SQLSTATE 22012" do
		sqlstate = nil
		begin
			res = @conn.exec("SELECT 1/0")
		rescue PG::Error => e
			sqlstate = e.result.result_error_field( PG::PG_DIAG_SQLSTATE ).to_i
		end
		expect( sqlstate ).to eq( 22012 )
	end

	it "returns the same bytes in binary format that are sent in binary format" do
		binary_file = File.join(Dir.pwd, 'spec/data', 'random_binary_data')
		bytes = File.open(binary_file, 'rb').read
		res = @conn.exec('VALUES ($1::bytea)',
			[ { :value => bytes, :format => 1 } ], 1)
		expect( res[0]['column1'] ).to eq( bytes )
		expect( res.getvalue(0,0) ).to eq( bytes )
		expect( res.values[0][0] ).to eq( bytes )
		expect( res.column_values(0)[0] ).to eq( bytes )
	end

	it "returns the same bytes in binary format that are sent as inline text" do
		binary_file = File.join(Dir.pwd, 'spec/data', 'random_binary_data')
		bytes = File.open(binary_file, 'rb').read
		@conn.exec("SET standard_conforming_strings=on")
		res = @conn.exec("VALUES ('#{PG::Connection.escape_bytea(bytes)}'::bytea)", [], 1)
		expect( res[0]['column1'] ).to eq( bytes )
		expect( res.getvalue(0,0) ).to eq( bytes )
		expect( res.values[0][0] ).to eq( bytes )
		expect( res.column_values(0)[0] ).to eq( bytes )
	end

	it "returns the same bytes in text format that are sent in binary format" do
		binary_file = File.join(Dir.pwd, 'spec/data', 'random_binary_data')
		bytes = File.open(binary_file, 'rb').read
		res = @conn.exec('VALUES ($1::bytea)',
			[ { :value => bytes, :format => 1 } ])
		expect( PG::Connection.unescape_bytea(res[0]['column1']) ).to eq( bytes )
	end

	it "returns the same bytes in text format that are sent as inline text" do
		binary_file = File.join(Dir.pwd, 'spec/data', 'random_binary_data')
		in_bytes = File.open(binary_file, 'rb').read

		out_bytes = nil
		@conn.exec("SET standard_conforming_strings=on")
		res = @conn.exec("VALUES ('#{PG::Connection.escape_bytea(in_bytes)}'::bytea)", [], 0)
		out_bytes = PG::Connection.unescape_bytea(res[0]['column1'])
		expect( out_bytes ).to eq( in_bytes )
	end

	it "returns the parameter type of the specified prepared statement parameter", :postgresql_92 do
		query = 'SELECT * FROM pg_stat_activity WHERE user = $1::name AND query = $2::text'
		@conn.prepare( 'queryfinder', query )
		res = @conn.describe_prepared( 'queryfinder' )

		expect(
			@conn.exec( 'SELECT format_type($1, -1)', [res.paramtype(0)] ).getvalue( 0, 0 )
		).to eq( 'name' )
		expect(
			@conn.exec( 'SELECT format_type($1, -1)', [res.paramtype(1)] ).getvalue( 0, 0 )
		).to eq( 'text' )
	end

	it "raises an exception when a negative index is given to #fformat" do
		res = @conn.exec('SELECT * FROM pg_stat_activity')
		expect {
			res.fformat( -1 )
		}.to raise_error( ArgumentError, /column number/i )
	end

	it "raises an exception when a negative index is given to #fmod" do
		res = @conn.exec('SELECT * FROM pg_stat_activity')
		expect {
			res.fmod( -1 )
		}.to raise_error( ArgumentError, /column number/i )
	end

	it "raises an exception when a negative index is given to #[]" do
		res = @conn.exec('SELECT * FROM pg_stat_activity')
		expect {
			res[ -1 ]
		}.to raise_error( IndexError, /-1 is out of range/i )
	end

	it "raises allow for conversion to an array of arrays" do
		@conn.exec( 'CREATE TABLE valuestest ( foo varchar(33) )' )
		@conn.exec( 'INSERT INTO valuestest ("foo") values (\'bar\')' )
		@conn.exec( 'INSERT INTO valuestest ("foo") values (\'bar2\')' )

		res = @conn.exec( 'SELECT * FROM valuestest' )
		expect( res.values ).to eq( [ ["bar"], ["bar2"] ] )
	end

	# PQfmod
	it "can return the type modifier for a result column" do
		@conn.exec( 'CREATE TABLE fmodtest ( foo varchar(33) )' )
		res = @conn.exec( 'SELECT * FROM fmodtest' )
		expect( res.fmod(0) ).to eq( 33 + 4 ) # Column length + varlena size (4)
	end

	it "raises an exception when an invalid index is passed to PG::Result#fmod" do
		@conn.exec( 'CREATE TABLE fmodtest ( foo varchar(33) )' )
		res = @conn.exec( 'SELECT * FROM fmodtest' )
		expect { res.fmod(1) }.to raise_error( ArgumentError )
	end

	it "raises an exception when an invalid (negative) index is passed to PG::Result#fmod" do
		@conn.exec( 'CREATE TABLE fmodtest ( foo varchar(33) )' )
		res = @conn.exec( 'SELECT * FROM fmodtest' )
		expect { res.fmod(-11) }.to raise_error( ArgumentError )
	end

	it "doesn't raise an exception when a valid index is passed to PG::Result#fmod for a" +
	   " column with no typemod" do
		@conn.exec( 'CREATE TABLE fmodtest ( foo text )' )
		res = @conn.exec( 'SELECT * FROM fmodtest' )
		expect( res.fmod(0) ).to eq( -1 )
	end

	# PQftable
	it "can return the oid of the table from which a result column was fetched" do
		@conn.exec( 'CREATE TABLE ftabletest ( foo text )' )
		res = @conn.exec( 'SELECT * FROM ftabletest' )

		expect( res.ftable(0) ).to be_nonzero()
	end

	it "raises an exception when an invalid index is passed to PG::Result#ftable" do
		@conn.exec( 'CREATE TABLE ftabletest ( foo text )' )
		res = @conn.exec( 'SELECT * FROM ftabletest' )

		expect { res.ftable(18) }.to raise_error( ArgumentError )
	end

	it "raises an exception when an invalid (negative) index is passed to PG::Result#ftable" do
		@conn.exec( 'CREATE TABLE ftabletest ( foo text )' )
		res = @conn.exec( 'SELECT * FROM ftabletest' )

		expect { res.ftable(-2) }.to raise_error( ArgumentError )
	end

	it "doesn't raise an exception when a valid index is passed to PG::Result#ftable for a " +
	   "column with no corresponding table" do
		@conn.exec( 'CREATE TABLE ftabletest ( foo text )' )
		res = @conn.exec( 'SELECT foo, LENGTH(foo) as length FROM ftabletest' )
		expect( res.ftable(1) ).to eq( PG::INVALID_OID )
	end

	# PQftablecol
	it "can return the column number (within its table) of a column in a result" do
		@conn.exec( 'CREATE TABLE ftablecoltest ( foo text, bar numeric )' )
		res = @conn.exec( 'SELECT * FROM ftablecoltest' )

		expect( res.ftablecol(0) ).to eq( 1 )
		expect( res.ftablecol(1) ).to eq( 2 )
	end

	it "raises an exception when an invalid index is passed to PG::Result#ftablecol" do
		@conn.exec( 'CREATE TABLE ftablecoltest ( foo text, bar numeric )' )
		res = @conn.exec( 'SELECT * FROM ftablecoltest' )

		expect { res.ftablecol(32) }.to raise_error( ArgumentError )
	end

	it "raises an exception when an invalid (negative) index is passed to PG::Result#ftablecol" do
		@conn.exec( 'CREATE TABLE ftablecoltest ( foo text, bar numeric )' )
		res = @conn.exec( 'SELECT * FROM ftablecoltest' )

		expect { res.ftablecol(-1) }.to raise_error( ArgumentError )
	end

	it "doesnn't raise an exception when a valid index is passed to PG::Result#ftablecol for a " +
	   "column with no corresponding table" do
		@conn.exec( 'CREATE TABLE ftablecoltest ( foo text )' )
		res = @conn.exec( 'SELECT foo, LENGTH(foo) as length FROM ftablecoltest' )
		expect( res.ftablecol(1) ).to eq( 0 )
	end

	it "can be manually checked for failed result status (async API)" do
		@conn.send_query( "SELECT * FROM nonexistant_table" )
		res = @conn.get_result
		expect {
			res.check
		}.to raise_error( PG::Error, /relation "nonexistant_table" does not exist/ )
	end

	it "can return the values of a single field" do
		res = @conn.exec( "SELECT 1 AS x, 'a' AS y UNION ALL SELECT 2, 'b'" )
		expect( res.field_values('x') ).to eq( ['1', '2'] )
		expect( res.field_values('y') ).to eq( ['a', 'b'] )
		expect{ res.field_values('') }.to raise_error(IndexError)
		expect{ res.field_values(:x) }.to raise_error(TypeError)
	end

	it "raises a proper exception for a nonexistant table" do
		expect {
			@conn.exec( "SELECT * FROM nonexistant_table" )
		}.to raise_error( PG::UndefinedTable, /relation "nonexistant_table" does not exist/ )
	end

	it "raises a more generic exception for an unknown SQLSTATE" do
		old_error = PG::ERROR_CLASSES.delete('42P01')
		begin
			expect {
				@conn.exec( "SELECT * FROM nonexistant_table" )
			}.to raise_error{|error|
				expect( error ).to be_an_instance_of(PG::SyntaxErrorOrAccessRuleViolation)
				expect( error.to_s ).to match(/relation "nonexistant_table" does not exist/)
			}
		ensure
			PG::ERROR_CLASSES['42P01'] = old_error
		end
	end

	it "raises a ServerError for an unknown SQLSTATE class" do
		old_error1 = PG::ERROR_CLASSES.delete('42P01')
		old_error2 = PG::ERROR_CLASSES.delete('42')
		begin
			expect {
				@conn.exec( "SELECT * FROM nonexistant_table" )
			}.to raise_error{|error|
				expect( error ).to be_an_instance_of(PG::ServerError)
				expect( error.to_s ).to match(/relation "nonexistant_table" does not exist/)
			}
		ensure
			PG::ERROR_CLASSES['42P01'] = old_error1
			PG::ERROR_CLASSES['42'] = old_error2
		end
	end

	it "raises a proper exception for a nonexistant schema" do
		expect {
			@conn.exec( "DROP SCHEMA nonexistant_schema" )
		}.to raise_error( PG::InvalidSchemaName, /schema "nonexistant_schema" does not exist/ )
	end

	it "the raised result is nil in case of a connection error" do
		c = PGconn.connect_start( '127.0.0.1', 54320, "", "", "me", "xxxx", "somedb" )
		expect {
			c.exec "select 1"
		}.to raise_error {|error|
			expect( error ).to be_an_instance_of(PG::UnableToSend)
			expect( error.result ).to eq( nil )
		}
	end

	it "does not clear the result itself" do
		r = @conn.exec "select 1"
		expect( r.autoclear? ).to eq(false)
		expect( r.cleared? ).to eq(false)
		r.clear
		expect( r.cleared? ).to eq(true)
	end

	it "can be inspected before and after clear" do
		r = @conn.exec "select 1"
		expect( r.inspect ).to match(/status=PGRES_TUPLES_OK/)
		r.clear
		expect( r.inspect ).to match(/cleared/)
	end

	context 'result value conversions with TypeMapByColumn' do
		let!(:textdec_int){ PG::TextDecoder::Integer.new name: 'INT4', oid: 23 }
		let!(:textdec_float){ PG::TextDecoder::Float.new name: 'FLOAT4', oid: 700 }

		it "should allow reading, assigning and diabling type conversions" do
			res = @conn.exec( "SELECT 123" )
			expect( res.type_map ).to be_kind_of(PG::TypeMapAllStrings)
			res.type_map = PG::TypeMapByColumn.new [textdec_int]
			expect( res.type_map ).to be_an_instance_of(PG::TypeMapByColumn)
			expect( res.type_map.coders ).to eq( [textdec_int] )
			res.type_map = PG::TypeMapByColumn.new [textdec_float]
			expect( res.type_map.coders ).to eq( [textdec_float] )
			res.type_map = PG::TypeMapAllStrings.new
			expect( res.type_map ).to be_kind_of(PG::TypeMapAllStrings)
		end

		it "should be applied to all value retrieving methods" do
			res = @conn.exec( "SELECT 123 as f" )
			res.type_map = PG::TypeMapByColumn.new [textdec_int]
			expect( res.values ).to eq( [[123]] )
			expect( res.getvalue(0,0) ).to eq( 123 )
			expect( res[0] ).to eq( {'f' => 123 } )
			expect( res.enum_for(:each_row).to_a ).to eq( [[123]] )
			expect( res.enum_for(:each).to_a ).to eq( [{'f' => 123}] )
			expect( res.column_values(0) ).to eq( [123] )
			expect( res.field_values('f') ).to eq( [123] )
		end

		it "should be usable for several querys" do
			colmap = PG::TypeMapByColumn.new [textdec_int]
			res = @conn.exec( "SELECT 123" )
			res.type_map = colmap
			expect( res.values ).to eq( [[123]] )
			res = @conn.exec( "SELECT 456" )
			res.type_map = colmap
			expect( res.values ).to eq( [[456]] )
		end

		it "shouldn't allow invalid type maps" do
			res = @conn.exec( "SELECT 1" )
			expect{ res.type_map = 1 }.to raise_error(TypeError)
		end
	end
end

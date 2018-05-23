#!/usr/bin/env rspec
# encoding: utf-8

require_relative '../helpers'

require 'pg'

describe 'Basic type mapping' do

	describe PG::BasicTypeMapForQueries do
		let!(:basic_type_mapping) do
			PG::BasicTypeMapForQueries.new @conn
		end

		#
		# Encoding Examples
		#

		it "should do basic param encoding", :ruby_19 do
			res = @conn.exec_params( "SELECT $1::int8,$2::float,$3,$4::TEXT",
				[1, 2.1, true, "b"], nil, basic_type_mapping )

			expect( res.values ).to eq( [
					[ "1", "2.1", "t", "b" ],
			] )

			expect( result_typenames(res) ).to eq( ['bigint', 'double precision', 'boolean', 'text'] )
		end

		it "should do array param encoding" do
			res = @conn.exec_params( "SELECT $1,$2,$3,$4", [
					[1, 2, 3], [[1, 2], [3, nil]],
					[1.11, 2.21],
					['/,"'.gsub("/", "\\"), nil, 'abcäöü'],
				], nil, basic_type_mapping )

			expect( res.values ).to eq( [[
					'{1,2,3}', '{{1,2},{3,NULL}}',
					'{1.11,2.21}',
					'{"//,/"",NULL,abcäöü}'.gsub("/", "\\"),
			]] )

			expect( result_typenames(res) ).to eq( ['bigint[]', 'bigint[]', 'double precision[]', 'text[]'] )
		end
	end



	describe PG::BasicTypeMapForResults do
		let!(:basic_type_mapping) do
			PG::BasicTypeMapForResults.new @conn
		end

		#
		# Decoding Examples
		#

		it "should do OID based type conversions", :ruby_19 do
			res = @conn.exec( "SELECT 1, 'a', 2.0::FLOAT, TRUE, '2013-06-30'::DATE, generate_series(4,5)" )
			expect( res.map_types!(basic_type_mapping).values ).to eq( [
					[ 1, 'a', 2.0, true, Date.new(2013,6,30), 4 ],
					[ 1, 'a', 2.0, true, Date.new(2013,6,30), 5 ],
			] )
		end

		#
		# Decoding Examples text+binary format converters
		#

		describe "connection wide type mapping" do
			before :each do
				@conn.type_map_for_results = basic_type_mapping
			end

			after :each do
				@conn.type_map_for_results = PG::TypeMapAllStrings.new
			end

			it "should do boolean type conversions" do
				[1, 0].each do |format|
					res = @conn.exec( "SELECT true::BOOLEAN, false::BOOLEAN, NULL::BOOLEAN", [], format )
					expect( res.values ).to eq( [[true, false, nil]] )
				end
			end

			it "should do binary type conversions" do
				[1, 0].each do |format|
					res = @conn.exec( "SELECT E'\\\\000\\\\377'::BYTEA", [], format )
					expect( res.values ).to eq( [[["00ff"].pack("H*")]] )
					expect( res.values[0][0].encoding ).to eq( Encoding::ASCII_8BIT ) if Object.const_defined? :Encoding
				end
			end

			it "should do integer type conversions" do
				[1, 0].each do |format|
					res = @conn.exec( "SELECT -8999::INT2, -899999999::INT4, -8999999999999999999::INT8", [], format )
					expect( res.values ).to eq( [[-8999, -899999999, -8999999999999999999]] )
				end
			end

			it "should do string type conversions" do
				@conn.internal_encoding = 'utf-8' if Object.const_defined? :Encoding
				[1, 0].each do |format|
					res = @conn.exec( "SELECT 'abcäöü'::TEXT", [], format )
					expect( res.values ).to eq( [['abcäöü']] )
					expect( res.values[0][0].encoding ).to eq( Encoding::UTF_8 ) if Object.const_defined? :Encoding
				end
			end

			it "should do float type conversions" do
				[1, 0].each do |format|
					res = @conn.exec( "SELECT -8.999e3::FLOAT4,
														8.999e10::FLOAT4,
														-8999999999e-99::FLOAT8,
														NULL::FLOAT4,
														'NaN'::FLOAT4,
														'Infinity'::FLOAT4,
														'-Infinity'::FLOAT4
													", [], format )
					expect( res.getvalue(0,0) ).to be_within(1e-2).of(-8.999e3)
					expect( res.getvalue(0,1) ).to be_within(1e5).of(8.999e10)
					expect( res.getvalue(0,2) ).to be_within(1e-109).of(-8999999999e-99)
					expect( res.getvalue(0,3) ).to be_nil
					expect( res.getvalue(0,4) ).to be_nan
					expect( res.getvalue(0,5) ).to eq( Float::INFINITY )
					expect( res.getvalue(0,6) ).to eq( -Float::INFINITY )
				end
			end

			it "should do datetime without time zone type conversions" do
				[0].each do |format|
					res = @conn.exec( "SELECT CAST('2013-12-31 23:58:59+02' AS TIMESTAMP WITHOUT TIME ZONE),
																		CAST('1913-12-31 23:58:59.123-03' AS TIMESTAMP WITHOUT TIME ZONE),
																		CAST('infinity' AS TIMESTAMP WITHOUT TIME ZONE),
																		CAST('-infinity' AS TIMESTAMP WITHOUT TIME ZONE)", [], format )
					expect( res.getvalue(0,0) ).to eq( Time.new(2013, 12, 31, 23, 58, 59) )
					expect( res.getvalue(0,1) ).to be_within(1e-3).of(Time.new(1913, 12, 31, 23, 58, 59.123))
					expect( res.getvalue(0,2) ).to eq( 'infinity' )
					expect( res.getvalue(0,3) ).to eq( '-infinity' )
				end
			end

			it "should do datetime with time zone type conversions" do
				[0].each do |format|
					res = @conn.exec( "SELECT CAST('2013-12-31 23:58:59+02' AS TIMESTAMP WITH TIME ZONE),
																		CAST('1913-12-31 23:58:59.123-03' AS TIMESTAMP WITH TIME ZONE),
																		CAST('infinity' AS TIMESTAMP WITH TIME ZONE),
																		CAST('-infinity' AS TIMESTAMP WITH TIME ZONE)", [], format )
					expect( res.getvalue(0,0) ).to eq( Time.new(2013, 12, 31, 23, 58, 59, "+02:00") )
					expect( res.getvalue(0,1) ).to be_within(1e-3).of(Time.new(1913, 12, 31, 23, 58, 59.123, "-03:00"))
					expect( res.getvalue(0,2) ).to eq( 'infinity' )
					expect( res.getvalue(0,3) ).to eq( '-infinity' )
				end
			end

			it "should do date type conversions" do
				[0].each do |format|
					res = @conn.exec( "SELECT CAST('2113-12-31' AS DATE),
																		CAST('1913-12-31' AS DATE),
																		CAST('infinity' AS DATE),
																		CAST('-infinity' AS DATE)", [], format )
					expect( res.getvalue(0,0) ).to eq( Date.new(2113, 12, 31) )
					expect( res.getvalue(0,1) ).to eq( Date.new(1913, 12, 31) )
					expect( res.getvalue(0,2) ).to eq( 'infinity' )
					expect( res.getvalue(0,3) ).to eq( '-infinity' )
				end
			end

			it "should do JSON conversions", :postgresql_94 do
				[0].each do |format|
					['JSON', 'JSONB'].each do |type|
						res = @conn.exec( "SELECT CAST('123' AS #{type}),
																			CAST('12.3' AS #{type}),
																			CAST('true' AS #{type}),
																			CAST('false' AS #{type}),
																			CAST('null' AS #{type}),
																			CAST('[1, \"a\", null]' AS #{type}),
																			CAST('{\"b\" : [2,3]}' AS #{type})", [], format )
						expect( res.getvalue(0,0) ).to eq( 123 )
						expect( res.getvalue(0,1) ).to be_within(0.1).of( 12.3 )
						expect( res.getvalue(0,2) ).to eq( true )
						expect( res.getvalue(0,3) ).to eq( false )
						expect( res.getvalue(0,4) ).to eq( nil )
						expect( res.getvalue(0,5) ).to eq( [1, "a", nil] )
						expect( res.getvalue(0,6) ).to eq( {"b" => [2, 3]} )
					end
				end
			end

			it "should do array type conversions" do
				[0].each do |format|
					res = @conn.exec( "SELECT CAST('{1,2,3}' AS INT2[]), CAST('{{1,2},{3,4}}' AS INT2[][]),
															CAST('{1,2,3}' AS INT4[]),
															CAST('{1,2,3}' AS INT8[]),
															CAST('{1,2,3}' AS TEXT[]),
															CAST('{1,2,3}' AS VARCHAR[]),
															CAST('{1,2,3}' AS FLOAT4[]),
															CAST('{1,2,3}' AS FLOAT8[])
														", [], format )
					expect( res.getvalue(0,0) ).to eq( [1,2,3] )
					expect( res.getvalue(0,1) ).to eq( [[1,2],[3,4]] )
					expect( res.getvalue(0,2) ).to eq( [1,2,3] )
					expect( res.getvalue(0,3) ).to eq( [1,2,3] )
					expect( res.getvalue(0,4) ).to eq( ['1','2','3'] )
					expect( res.getvalue(0,5) ).to eq( ['1','2','3'] )
					expect( res.getvalue(0,6) ).to eq( [1.0,2.0,3.0] )
					expect( res.getvalue(0,7) ).to eq( [1.0,2.0,3.0] )
				end
			end
		end

		context "with usage of result oids for copy decoder selection" do
			it "can type cast #copy_data output with explicit decoder" do
				@conn.exec( "CREATE TEMP TABLE copytable (t TEXT, i INT, ai INT[])" )
				@conn.exec( "INSERT INTO copytable VALUES ('a', 123, '{5,4,3}'), ('b', 234, '{2,3}')" )

				# Retrieve table OIDs per empty result.
				res = @conn.exec( "SELECT * FROM copytable LIMIT 0" )
				tm = basic_type_mapping.build_column_map( res )
				row_decoder = PG::TextDecoder::CopyRow.new type_map: tm

				rows = []
				@conn.copy_data( "COPY copytable TO STDOUT", row_decoder ) do |res|
					while row=@conn.get_copy_data
						rows << row
					end
				end
				expect( rows ).to eq( [['a', 123, [5,4,3]], ['b', 234, [2,3]]] )
			end
		end
	end


	describe PG::BasicTypeMapBasedOnResult do
		let!(:basic_type_mapping) do
			PG::BasicTypeMapBasedOnResult.new @conn
		end

		context "with usage of result oids for bind params encoder selection" do
			it "can type cast query params" do
				@conn.exec( "CREATE TEMP TABLE copytable (t TEXT, i INT, ai INT[])" )

				# Retrieve table OIDs per empty result.
				res = @conn.exec( "SELECT * FROM copytable LIMIT 0" )
				tm = basic_type_mapping.build_column_map( res )

				@conn.exec_params( "INSERT INTO copytable VALUES ($1, $2, $3)", ['a', 123, [5,4,3]], 0, tm )
				@conn.exec_params( "INSERT INTO copytable VALUES ($1, $2, $3)", ['b', 234, [2,3]], 0, tm )
				res = @conn.exec( "SELECT * FROM copytable" )
				expect( res.values ).to eq( [['a', '123', '{5,4,3}'], ['b', '234', '{2,3}']] )
			end

			it "can do JSON conversions", :postgresql_94 do
				['JSON', 'JSONB'].each do |type|
					sql = "SELECT CAST('123' AS #{type}),
						CAST('12.3' AS #{type}),
						CAST('true' AS #{type}),
						CAST('false' AS #{type}),
						CAST('null' AS #{type}),
						CAST('[1, \"a\", null]' AS #{type}),
						CAST('{\"b\" : [2,3]}' AS #{type})"

					tm = basic_type_mapping.build_column_map( @conn.exec( sql ) )
					expect( tm.coders.map(&:name) ).to eq( [type.downcase] * 7 )

					res = @conn.exec_params( "SELECT $1, $2, $3, $4, $5, $6, $7",
						[ 123,
							12.3,
							true,
							false,
							nil,
							[1, "a", nil],
							{"b" => [2, 3]},
						], 0, tm )

					expect( res.getvalue(0,0) ).to eq( "123" )
					expect( res.getvalue(0,1) ).to eq( "12.3" )
					expect( res.getvalue(0,2) ).to eq( "true" )
					expect( res.getvalue(0,3) ).to eq( "false" )
					expect( res.getvalue(0,4) ).to eq( nil )
					expect( res.getvalue(0,5).gsub(" ","") ).to eq( "[1,\"a\",null]" )
					expect( res.getvalue(0,6).gsub(" ","") ).to eq( "{\"b\":[2,3]}" )
				end
			end
		end

		context "with usage of result oids for copy encoder selection" do
			it "can type cast #copy_data input with explicit encoder" do
				@conn.exec( "CREATE TEMP TABLE copytable (t TEXT, i INT, ai INT[])" )

				# Retrieve table OIDs per empty result set.
				res = @conn.exec( "SELECT * FROM copytable LIMIT 0" )
				tm = basic_type_mapping.build_column_map( res )
				row_encoder = PG::TextEncoder::CopyRow.new type_map: tm

				@conn.copy_data( "COPY copytable FROM STDIN", row_encoder ) do |res|
					@conn.put_copy_data ['a', 123, [5,4,3]]
					@conn.put_copy_data ['b', 234, [2,3]]
				end
				res = @conn.exec( "SELECT * FROM copytable" )
				expect( res.values ).to eq( [['a', '123', '{5,4,3}'], ['b', '234', '{2,3}']] )
			end
		end
	end
end

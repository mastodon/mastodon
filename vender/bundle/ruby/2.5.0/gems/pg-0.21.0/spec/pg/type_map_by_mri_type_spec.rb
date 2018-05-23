#!/usr/bin/env rspec
# encoding: utf-8

require_relative '../helpers'

require 'pg'


describe PG::TypeMapByMriType do

	let!(:textenc_int){ PG::TextEncoder::Integer.new name: 'INT4', oid: 23 }
	let!(:textenc_float){ PG::TextEncoder::Float.new name: 'FLOAT8', oid: 701 }
	let!(:textenc_string){ PG::TextEncoder::String.new name: 'TEXT', oid: 25 }
	let!(:binaryenc_int){ PG::BinaryEncoder::Int8.new name: 'INT8', oid: 20, format: 1 }
	let!(:pass_through_type) do
		type = Class.new(PG::SimpleEncoder) do
			def encode(*v)
				v.inspect
			end
		end.new
		type.oid = 25
		type.format = 0
		type.name = 'pass_through'
		type
	end

	let!(:tm) do
		tm = PG::TypeMapByMriType.new
		tm['T_FIXNUM'] = binaryenc_int
		tm['T_FLOAT'] = textenc_float
		tm['T_SYMBOL'] = pass_through_type
		tm
	end

	let!(:derived_tm) do
		tm = Class.new(PG::TypeMapByMriType) do
			def array_type_map_for(value)
				PG::TextEncoder::Array.new name: '_INT4', oid: 1007, elements_type: PG::TextEncoder::Integer.new
			end
		end.new
		tm['T_FIXNUM'] = proc{|value| textenc_int }
		tm['T_REGEXP'] = proc{|value| :invalid }
		tm['T_ARRAY'] = :array_type_map_for
		tm
	end

	it "should retrieve all conversions" do
		expect( tm.coders ).to eq( {
			"T_FIXNUM" => binaryenc_int,
			"T_FLOAT" => textenc_float,
			"T_SYMBOL" => pass_through_type,
			"T_HASH" => nil,
			"T_ARRAY" => nil,
			"T_BIGNUM" => nil,
			"T_CLASS" => nil,
			"T_COMPLEX" => nil,
			"T_DATA" => nil,
			"T_FALSE" => nil,
			"T_FILE" => nil,
			"T_MODULE" => nil,
			"T_OBJECT" => nil,
			"T_RATIONAL" => nil,
			"T_REGEXP" => nil,
			"T_STRING" => nil,
			"T_STRUCT" => nil,
			"T_TRUE" => nil,
		} )
	end

	it "should retrieve particular conversions" do
		expect( tm['T_FIXNUM'] ).to eq(binaryenc_int)
		expect( tm['T_FLOAT'] ).to eq(textenc_float)
		expect( tm['T_BIGNUM'] ).to be_nil
		expect( derived_tm['T_REGEXP'] ).to be_kind_of(Proc)
		expect( derived_tm['T_ARRAY'] ).to eq(:array_type_map_for)
	end

	it "should allow deletion of coders" do
		tm['T_FIXNUM'] = nil
		expect( tm['T_FIXNUM'] ).to be_nil
	end

	it "should check MRI type key" do
		expect{ tm['NO_TYPE'] }.to raise_error(ArgumentError)
		expect{ tm[123] }.to raise_error(TypeError)
		expect{ tm['NO_TYPE'] = textenc_float }.to raise_error(ArgumentError)
		expect{ tm[123] = textenc_float }.to raise_error(TypeError)
	end

	it "forwards query param conversions to the #default_type_map" do
		tm1 = PG::TypeMapByColumn.new( [textenc_int, nil, nil] )

		tm2 = PG::TypeMapByMriType.new
		tm2['T_FIXNUM'] = PG::TextEncoder::Integer.new name: 'INT2', oid: 21
		tm2.default_type_map = tm1

		res = @conn.exec_params( "SELECT $1, $2, $3::TEXT", ['1', 2, 3], 0, tm2 )

		expect( res.ftype(0) ).to eq( 23 ) # tm1
		expect( res.ftype(1) ).to eq( 21 ) # tm2
		expect( res.getvalue(0,2) ).to eq( "3" ) # TypeMapAllStrings
	end

	#
	# Decoding Examples
	#

	it "should raise an error when used for results" do
		res = @conn.exec_params( "SELECT 1", [], 1 )
		expect{ res.type_map = tm }.to raise_error(NotImplementedError, /not suitable to map result values/)
	end

	#
	# Encoding Examples
	#

	it "should allow mixed type conversions" do
		res = @conn.exec_params( "SELECT $1, $2, $3", [5, 1.23, :TestSymbol], 0, tm )
		expect( res.values ).to eq([['5', '1.23', "[:TestSymbol, #{@conn.internal_encoding.inspect}]"]])
		expect( res.ftype(0) ).to eq(20)
	end

	it "should allow mixed type conversions with derived type map" do
		res = @conn.exec_params( "SELECT $1, $2", [6, [7]], 0, derived_tm )
		expect( res.values ).to eq([['6', '{7}']])
		expect( res.ftype(0) ).to eq(23)
		expect( res.ftype(1) ).to eq(1007)
	end

	it "should raise TypeError with derived type map" do
		expect{
			@conn.exec_params( "SELECT $1", [//], 0, derived_tm )
		}.to raise_error(TypeError, /argument 1/)
	end

end

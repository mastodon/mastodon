#!/usr/bin/env rspec
# encoding: utf-8

require_relative '../helpers'

require 'pg'


describe PG::TypeMap do
	let!(:tm){ PG::TypeMap.new }

	it "should raise an error when used for param type casts" do
		expect{
			@conn.exec_params( "SELECT $1", [5], 0, tm )
		}.to raise_error(NotImplementedError, /not suitable to map query params/)
	end

	it "should raise an error when used for result type casts" do
		res = @conn.exec( "SELECT 1" )
		expect{ res.map_types!(tm) }.to raise_error(NotImplementedError, /not suitable to map result values/)
	end
end

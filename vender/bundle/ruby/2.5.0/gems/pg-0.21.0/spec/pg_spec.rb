#!/usr/bin/env rspec
# encoding: utf-8

require_relative 'helpers'

require 'pg'

describe PG do

	it "knows what version of the libpq library is loaded", :postgresql_91 do
		expect( PG.library_version ).to be_an( Integer )
		expect( PG.library_version ).to be >= 90100
	end

	it "can select which of both security libraries to initialize" do
		# This setting does nothing here, because there is already a connection
		# to the server, at this point in time.
		PG.init_openssl(false, true)
		PG.init_openssl(1, 0)
	end

	it "can select whether security libraries to initialize" do
		# This setting does nothing here, because there is already a connection
		# to the server, at this point in time.
		PG.init_ssl(false)
		PG.init_ssl(1)
	end


	it "knows whether or not the library is threadsafe" do
		expect( PG ).to be_threadsafe()
	end

	it "does have hierarchical error classes" do
		expect( PG::UndefinedTable.ancestors[0,4] ).to eq([
				PG::UndefinedTable,
				PG::SyntaxErrorOrAccessRuleViolation,
				PG::ServerError,
		        PG::Error
		        ])

		expect( PG::InvalidSchemaName.ancestors[0,3] ).to eq([
				PG::InvalidSchemaName,
				PG::ServerError,
		        PG::Error
		        ])
	end

end


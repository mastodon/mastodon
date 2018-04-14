#!../../bin/rackup
# -*- ruby -*-

require '../testrequest'
run Rack::Lint.new(TestRequest.new)

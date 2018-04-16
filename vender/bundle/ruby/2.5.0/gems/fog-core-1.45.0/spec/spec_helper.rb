if ENV["COVERAGE"]
  require "coveralls"
  require "simplecov"

  SimpleCov.start do
    add_filter "/spec/"
  end
end

require "minitest/autorun"
require "minitest/spec"
require "minitest/stub_const"

$LOAD_PATH.unshift "lib"
require "fog/core"

Dir["spec/fake_app/**/*.rb"].each do |file|
  require File.join(File.dirname(__FILE__), "..", file)
end

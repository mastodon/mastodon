RUBY_1_8 = defined?(RUBY_VERSION) && RUBY_VERSION < '1.9'
JRUBY    = defined?(JRUBY_VERSION)

if RUBY_1_8 and not ENV['BUNDLE_GEMFILE']
  require 'rubygems'
  gem 'test-unit'
end

if ENV['COVERAGE'] && ENV['CI'].nil? && !RUBY_1_8
  require 'simplecov'
  SimpleCov.start { add_filter "/test|test_/" }
end

if ENV['CI'] && !RUBY_1_8
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start { add_filter "/test|test_" }
end

require 'test/unit'
require 'shoulda-context'
require 'mocha/setup'

unless ENV["NOTURN"] || RUBY_1_8
  require 'turn'

  if ENV['QUIET']
    Turn.config.format = :outline
    Turn.config.trace = 1
  end
end

require 'require-prof' if ENV["REQUIRE_PROF"]
require 'elasticsearch/api'
RequireProf.print_timing_infos if ENV["REQUIRE_PROF"]

if defined?(RUBY_VERSION) && RUBY_VERSION > '1.9'
  require 'elasticsearch/extensions/test/cluster'
  require 'elasticsearch/extensions/test/startup_shutdown'
  require 'elasticsearch/extensions/test/profiling' unless JRUBY
end

module Elasticsearch
  module Test
    class FakeClient
      include Elasticsearch::API

      def perform_request(method, path, params, body, headers={"Content-Type" => "application/json"})
        puts "PERFORMING REQUEST:", "--> #{method.to_s.upcase} #{path} #{params} #{body} #{headers}"
        FakeResponse.new(200, 'FAKE', {})
      end
    end

    FakeResponse = Struct.new(:status, :body, :headers) do
      def status
        values[0] || 200
      end
      def body
        values[1] || '{}'
      end
      def headers
        values[2] || {}
      end
    end

    class NotFound < StandardError; end
  end
end

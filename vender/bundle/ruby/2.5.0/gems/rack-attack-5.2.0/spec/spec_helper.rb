require "rubygems"
require "bundler/setup"

require "minitest/autorun"
require "minitest/pride"
require "rack/test"
require 'active_support'
require 'action_dispatch'

require "rack/attack"

begin
  require 'pry'
rescue LoadError
  #nothing to do here
end

if RUBY_ENGINE == "ruby"
  require "byebug"
end

class MiniTest::Spec

  include Rack::Test::Methods

  before do
    @_original_throttled_response = Rack::Attack.throttled_response
    @_original_blocklisted_response = Rack::Attack.blocklisted_response
  end

  after do
    Rack::Attack.clear!
    Rack::Attack.instance_variable_set(:@cache, nil)

    Rack::Attack.throttled_response = @_original_throttled_response
    Rack::Attack.blocklisted_response = @_original_blocklisted_response
  end

  def app
    Rack::Builder.new {
      # Use Rack::Lint to test that rack-attack is complying with the rack spec
      use Rack::Lint
      use Rack::Attack
      use Rack::Lint

      run lambda {|env| [200, {}, ['Hello World']]}
    }.to_app
  end

  def self.it_allows_ok_requests
    it "must allow ok requests" do
      get '/', {}, 'REMOTE_ADDR' => '127.0.0.1'
      last_response.status.must_equal 200
      last_response.body.must_equal 'Hello World'
    end
  end
end

class Minitest::SharedExamples < Module
  include Minitest::Spec::DSL
end

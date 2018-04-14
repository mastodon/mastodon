require 'rubygems'
require 'minitest/autorun'
require 'rack/cors'


describe Rack::Cors, 'DSL' do
  it 'should support explicit config object dsl mode' do
    cors = Rack::Cors.new(Proc.new {}) do |cfg|
      cfg.allow do |allow|
        allow.origins 'localhost:3000', '127.0.0.1:3000' do |source,env|
          source == "http://10.10.10.10:3000" &&
          env["USER_AGENT"] == "test-agent"
        end
        allow.resource '/get-only', :methods => :get
        allow.resource '/', :headers => :any
      end
    end
    resources = cors.send :all_resources

    resources.length.must_equal 1
    resources.first.allow_origin?('http://localhost:3000').must_equal true
    resources.first.allow_origin?('http://10.10.10.10:3000',{"USER_AGENT" => "test-agent" }).must_equal true
    resources.first.allow_origin?('http://10.10.10.10:3001',{"USER_AGENT" => "test-agent" }).wont_equal true
    resources.first.allow_origin?('http://10.10.10.10:3000',{"USER_AGENT" => "other-agent"}).wont_equal true
  end

  it 'should support implicit config object dsl mode' do
    cors = Rack::Cors.new(Proc.new {}) do
      allow do
        origins 'localhost:3000', '127.0.0.1:3000' do |source,env|
          source == "http://10.10.10.10:3000" &&
          env["USER_AGENT"] == "test-agent"
        end
        resource '/get-only', :methods => :get
        resource '/', :headers => :any
      end
    end
    resources = cors.send :all_resources

    resources.length.must_equal 1
    resources.first.allow_origin?('http://localhost:3000').must_equal true
    resources.first.allow_origin?('http://10.10.10.10:3000',{"USER_AGENT" => "test-agent" }).must_equal true
    resources.first.allow_origin?('http://10.10.10.10:3001',{"USER_AGENT" => "test-agent" }).wont_equal true
    resources.first.allow_origin?('http://10.10.10.10:3000',{"USER_AGENT" => "other-agent"}).wont_equal true
  end

  it 'should support "file://" origin' do
    cors = Rack::Cors.new(Proc.new {}) do
      allow do
        origins 'file://'
        resource '/', :headers => :any
      end
    end
    resources = cors.send :all_resources

    resources.first.allow_origin?('file://').must_equal true
  end
end

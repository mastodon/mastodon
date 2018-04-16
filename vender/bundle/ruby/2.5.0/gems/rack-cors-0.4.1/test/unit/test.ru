require 'rack/cors'

#use Rack::Cors, :debug => true, :logger => ::Logger.new(STDOUT) do
use Rack::Lint
use Rack::Cors do
  allow do
    origins 'localhost:3000',
            '127.0.0.1:3000',
            /http:\/\/192\.168\.0\.\d{1,3}(:\d+)?/,
            'file://',
            /http:\/\/(.*?)\.example\.com/

    resource '/get-only', :methods => :get
    resource '/', :headers => :any, :methods => :any
    resource '/options', :methods => :options
    resource '/single_header', :headers => 'x-domain-token'
    resource '/two_headers', :headers => %w{x-domain-token x-requested-with}
    resource '/expose_single_header', :expose => 'expose-test'
    resource '/expose_multiple_headers', :expose => %w{expose-test-1 expose-test-2}
    resource '/conditional', :methods => :get, :if => proc { |env| !!env['HTTP_X_OK'] }
    resource '/vary_test', :methods => :get, :vary => %w{ Origin Host }
    # resource '/file/at/*',
    #     :methods => [:get, :post, :put, :delete],
    #     :headers => :any,
    #     :max_age => 0
  end

  allow do
    origins do |source,env|
      source.end_with?("10.10.10.10:3000")
    end
    resource '/proc-origin'
  end

  allow do
    origins '*'
    resource '/public'
    resource '/public_without_credentials', :credentials => false
  end

  allow do
    origins 'mucho-grande.com'
    resource '/multi-allow-config', :max_age => 600
  end

  allow do
    origins '*'
    resource '/multi-allow-config', :max_age => 300, :credentials => false
  end
end

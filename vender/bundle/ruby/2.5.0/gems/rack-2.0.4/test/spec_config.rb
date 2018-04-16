require 'minitest/autorun'
require 'rack/builder'
require 'rack/config'
require 'rack/content_length'
require 'rack/lint'
require 'rack/mock'

describe Rack::Config do
  it "accept a block that modifies the environment" do
    app = Rack::Builder.new do
      use Rack::Lint
      use Rack::Config do |env|
        env['greeting'] = 'hello'
      end
      run lambda { |env|
        [200, {'Content-Type' => 'text/plain'}, [env['greeting'] || '']]
      }
    end

    response = Rack::MockRequest.new(app).get('/')
    response.body.must_equal 'hello'
  end
end

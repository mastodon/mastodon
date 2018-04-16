require 'minitest/autorun'
require 'rack/lint'
require 'rack/mock'
require 'rack/null_logger'

describe Rack::NullLogger do
  it "act as a noop logger" do
    app = lambda { |env|
      env['rack.logger'].warn "b00m"
      [200, {'Content-Type' => 'text/plain'}, ["Hello, World!"]]
    }

    logger = Rack::Lint.new(Rack::NullLogger.new(app))

    res = logger.call(Rack::MockRequest.env_for)
    res[0..1].must_equal [
      200, {'Content-Type' => 'text/plain'}
    ]
    res[2].to_enum.to_a.must_equal ["Hello, World!"]
  end
end

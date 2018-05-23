require 'minitest/autorun'
require 'rack/show_exceptions'
require 'rack/lint'
require 'rack/mock'

describe Rack::ShowExceptions do
  def show_exceptions(app)
    Rack::Lint.new Rack::ShowExceptions.new(app)
  end

  it "catches exceptions" do
    res = nil

    req = Rack::MockRequest.new(
      show_exceptions(
        lambda{|env| raise RuntimeError }
    ))

    res = req.get("/", "HTTP_ACCEPT" => "text/html")

    res.must_be :server_error?
    res.status.must_equal 500

    assert_match(res, /RuntimeError/)
    assert_match(res, /ShowExceptions/)
  end

  it "responds with HTML only to requests accepting HTML" do
    res = nil

    req = Rack::MockRequest.new(
      show_exceptions(
        lambda{|env| raise RuntimeError, "It was never supposed to work" }
    ))

    [
      # Serve text/html when the client accepts text/html
      ["text/html", ["/", {"HTTP_ACCEPT" => "text/html"}]],
      ["text/html", ["/", {"HTTP_ACCEPT" => "*/*"}]],
      # Serve text/plain when the client does not accept text/html
      ["text/plain", ["/"]],
      ["text/plain", ["/", {"HTTP_ACCEPT" => "application/json"}]]
    ].each do |exmime, rargs|
      res = req.get(*rargs)

      res.must_be :server_error?
      res.status.must_equal 500

      res.content_type.must_equal exmime

      res.body.must_include "RuntimeError"
      res.body.must_include "It was never supposed to work"

      if exmime == "text/html"
        res.body.must_include '</html>'
      else
        res.body.wont_include '</html>'
      end
    end
  end

  it "handles exceptions without a backtrace" do
    res = nil

    req = Rack::MockRequest.new(
      show_exceptions(
        lambda{|env| raise RuntimeError, "", [] }
      )
    )

    res = req.get("/", "HTTP_ACCEPT" => "text/html")

    res.must_be :server_error?
    res.status.must_equal 500

    assert_match(res, /RuntimeError/)
    assert_match(res, /ShowExceptions/)
    assert_match(res, /unknown location/)
  end
end

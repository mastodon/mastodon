require 'minitest/autorun'
require 'rack/mock'
require 'thread'
require File.expand_path('../testrequest', __FILE__)

Thread.abort_on_exception = true

describe Rack::Handler::WEBrick do
  include TestRequest::Helpers

  before do
  @server = WEBrick::HTTPServer.new(:Host => @host='127.0.0.1',
                                    :Port => @port=9202,
                                    :Logger => WEBrick::Log.new(nil, WEBrick::BasicLog::WARN),
                                    :AccessLog => [])
  @server.mount "/test", Rack::Handler::WEBrick,
    Rack::Lint.new(TestRequest.new)
  @thread = Thread.new { @server.start }
  trap(:INT) { @server.shutdown }
  @status_thread = Thread.new do
    seconds = 10
    wait_time = 0.1
    until is_running? || seconds <= 0
      seconds -= wait_time
      sleep wait_time
    end
    raise "Server never reached status 'Running'" unless is_running?
  end
  end

  def is_running?
    @server.status == :Running
  end

  it "respond" do
    GET("/test")
    status.must_equal 200
  end

  it "be a WEBrick" do
    GET("/test")
    status.must_equal 200
    response["SERVER_SOFTWARE"].must_match(/WEBrick/)
    response["HTTP_VERSION"].must_equal "HTTP/1.1"
    response["SERVER_PROTOCOL"].must_equal "HTTP/1.1"
    response["SERVER_PORT"].must_equal "9202"
    response["SERVER_NAME"].must_equal "127.0.0.1"
  end

  it "have rack headers" do
    GET("/test")
    response["rack.version"].must_equal [1,3]
    response["rack.multithread"].must_equal true
    assert_equal false, response["rack.multiprocess"]
    assert_equal false, response["rack.run_once"]
  end

  it "have CGI headers on GET" do
    GET("/test")
    response["REQUEST_METHOD"].must_equal "GET"
    response["SCRIPT_NAME"].must_equal "/test"
    response["REQUEST_PATH"].must_equal "/test"
    response["PATH_INFO"].must_equal ""
    response["QUERY_STRING"].must_equal ""
    response["test.postdata"].must_equal ""

    GET("/test/foo?quux=1")
    response["REQUEST_METHOD"].must_equal "GET"
    response["SCRIPT_NAME"].must_equal "/test"
    response["REQUEST_PATH"].must_equal "/test/foo"
    response["PATH_INFO"].must_equal "/foo"
    response["QUERY_STRING"].must_equal "quux=1"

    GET("/test/foo%25encoding?quux=1")
    response["REQUEST_METHOD"].must_equal "GET"
    response["SCRIPT_NAME"].must_equal "/test"
    response["REQUEST_PATH"].must_equal "/test/foo%25encoding"
    response["PATH_INFO"].must_equal "/foo%25encoding"
    response["QUERY_STRING"].must_equal "quux=1"
  end

  it "have CGI headers on POST" do
    POST("/test", {"rack-form-data" => "23"}, {'X-test-header' => '42'})
    status.must_equal 200
    response["REQUEST_METHOD"].must_equal "POST"
    response["SCRIPT_NAME"].must_equal "/test"
    response["REQUEST_PATH"].must_equal "/test"
    response["PATH_INFO"].must_equal ""
    response["QUERY_STRING"].must_equal ""
    response["HTTP_X_TEST_HEADER"].must_equal "42"
    response["test.postdata"].must_equal "rack-form-data=23"
  end

  it "support HTTP auth" do
    GET("/test", {:user => "ruth", :passwd => "secret"})
    response["HTTP_AUTHORIZATION"].must_equal "Basic cnV0aDpzZWNyZXQ="
  end

  it "set status" do
    GET("/test?secret")
    status.must_equal 403
    response["rack.url_scheme"].must_equal "http"
  end

  it "correctly set cookies" do
    @server.mount "/cookie-test", Rack::Handler::WEBrick,
    Rack::Lint.new(lambda { |req|
                     res = Rack::Response.new
                     res.set_cookie "one", "1"
                     res.set_cookie "two", "2"
                     res.finish
                   })

    Net::HTTP.start(@host, @port) { |http|
      res = http.get("/cookie-test")
      res.code.to_i.must_equal 200
      res.get_fields("set-cookie").must_equal ["one=1", "two=2"]
    }
  end

  it "provide a .run" do
    queue = Queue.new

    t = Thread.new do
      Rack::Handler::WEBrick.run(lambda {},
                                 {
                                   :Host => '127.0.0.1',
                                   :Port => 9210,
                                   :Logger => WEBrick::Log.new(nil, WEBrick::BasicLog::WARN),
                                   :AccessLog => []}) { |server|
        block_ran = true
        assert_kind_of WEBrick::HTTPServer, server
        queue.push(server)
      }
    end

    server = queue.pop
    server.shutdown
    t.join
  end

  it "return repeated headers" do
    @server.mount "/headers", Rack::Handler::WEBrick,
    Rack::Lint.new(lambda { |req|
        [
          401,
          { "Content-Type" => "text/plain",
            "WWW-Authenticate" => "Bar realm=X\nBaz realm=Y" },
          [""]
        ]
      })

    Net::HTTP.start(@host, @port) { |http|
      res = http.get("/headers")
      res.code.to_i.must_equal 401
      res["www-authenticate"].must_equal "Bar realm=X, Baz realm=Y"
    }
  end

  it "support Rack partial hijack" do
    io_lambda = lambda{ |io|
      5.times do
        io.write "David\r\n"
      end
      io.close
    }

    @server.mount "/partial", Rack::Handler::WEBrick,
    Rack::Lint.new(lambda{ |req|
      [
        200,
        [ [ "rack.hijack", io_lambda ] ],
        [""]
      ]
    })

    Net::HTTP.start(@host, @port){ |http|
      res = http.get("/partial")
      res.body.must_equal "David\r\nDavid\r\nDavid\r\nDavid\r\nDavid\r\n"
    }
  end

  it "produce correct HTTP semantics with and without app chunking" do
    @server.mount "/chunked", Rack::Handler::WEBrick,
    Rack::Lint.new(lambda{ |req|
      [
        200,
        {"Transfer-Encoding" => "chunked"},
        ["7\r\nchunked\r\n0\r\n\r\n"]
      ]
    })

    Net::HTTP.start(@host, @port){ |http|
      res = http.get("/chunked")
      res["Transfer-Encoding"].must_equal "chunked"
      res["Content-Length"].must_be_nil
      res.body.must_equal "chunked"
    }
  end

  after do
  @status_thread.join
  @server.shutdown
  @thread.join
  end
end

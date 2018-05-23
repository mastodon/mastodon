require 'minitest/autorun'
begin
require 'rack/handler/thin'
require File.expand_path('../testrequest', __FILE__)
require 'timeout'

describe Rack::Handler::Thin do
  include TestRequest::Helpers

  before do
    @app = Rack::Lint.new(TestRequest.new)
    @server = nil
    Thin::Logging.silent = true

    @thread = Thread.new do
      Rack::Handler::Thin.run(@app, :Host => @host='127.0.0.1', :Port => @port=9204, :tag => "tag") do |server|
        @server = server
      end
    end

    Thread.pass until @server && @server.running?
  end

  after do
    @server.stop!
    @thread.join
  end


  it "respond" do
    GET("/")
    response.wont_be :nil?
  end

  it "be a Thin" do
    GET("/")
    status.must_equal 200
    response["SERVER_SOFTWARE"].must_match(/thin/)
    response["HTTP_VERSION"].must_equal "HTTP/1.1"
    response["SERVER_PROTOCOL"].must_equal "HTTP/1.1"
    response["SERVER_PORT"].must_equal "9204"
    response["SERVER_NAME"].must_equal "127.0.0.1"
  end

  it "have rack headers" do
    GET("/")
    response["rack.version"].must_equal [1,0]
    response["rack.multithread"].must_equal false
    response["rack.multiprocess"].must_equal false
    response["rack.run_once"].must_equal false
  end

  it "have CGI headers on GET" do
    GET("/")
    response["REQUEST_METHOD"].must_equal "GET"
    response["REQUEST_PATH"].must_equal "/"
    response["PATH_INFO"].must_equal "/"
    response["QUERY_STRING"].must_equal ""
    response["test.postdata"].must_equal ""

    GET("/test/foo?quux=1")
    response["REQUEST_METHOD"].must_equal "GET"
    response["REQUEST_PATH"].must_equal "/test/foo"
    response["PATH_INFO"].must_equal "/test/foo"
    response["QUERY_STRING"].must_equal "quux=1"
  end

  it "have CGI headers on POST" do
    POST("/", {"rack-form-data" => "23"}, {'X-test-header' => '42'})
    status.must_equal 200
    response["REQUEST_METHOD"].must_equal "POST"
    response["REQUEST_PATH"].must_equal "/"
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

  it "set tag for server" do
    @server.tag.must_equal 'tag'
  end
end

rescue LoadError
  $stderr.puts "Skipping Rack::Handler::Thin tests (Thin is required). `gem install thin` and try again."
end

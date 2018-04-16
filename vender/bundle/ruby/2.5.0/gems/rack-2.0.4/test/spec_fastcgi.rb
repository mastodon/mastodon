require 'helper'

if defined? LIGHTTPD_PID

require File.expand_path('../testrequest', __FILE__)
require 'rack/handler/fastcgi'

describe Rack::Handler::FastCGI do
  include TestRequest::Helpers

  before do
    @host = '127.0.0.1'
    @port = 9203
  end

  it "respond" do
    sleep 1
    GET("/test")
    response.wont_be :nil?
  end

  it "respond via rackup server" do
    GET("/sample_rackup.ru")
    status.must_equal 200
  end

  it "be a lighttpd" do
    GET("/test.fcgi")
    status.must_equal 200
    response["SERVER_SOFTWARE"].must_match(/lighttpd/)
    response["HTTP_VERSION"].must_equal "HTTP/1.1"
    response["SERVER_PROTOCOL"].must_equal "HTTP/1.1"
    response["SERVER_PORT"].must_equal @port.to_s
    response["SERVER_NAME"].must_equal @host
  end

  it "have rack headers" do
    GET("/test.fcgi")
    response["rack.version"].must_equal [1,3]
    assert_equal false, response["rack.multithread"]
    assert_equal true, response["rack.multiprocess"]
    assert_equal false, response["rack.run_once"]
  end

  it "have CGI headers on GET" do
    GET("/test.fcgi")
    response["REQUEST_METHOD"].must_equal "GET"
    response["SCRIPT_NAME"].must_equal "/test.fcgi"
    response["REQUEST_PATH"].must_equal "/"
    response["PATH_INFO"].must_equal ""
    response["QUERY_STRING"].must_equal ""
    response["test.postdata"].must_equal ""

    GET("/test.fcgi/foo?quux=1")
    response["REQUEST_METHOD"].must_equal "GET"
    response["SCRIPT_NAME"].must_equal "/test.fcgi"
    response["REQUEST_PATH"].must_equal "/"
    response["PATH_INFO"].must_equal "/foo"
    response["QUERY_STRING"].must_equal "quux=1"
  end

  it "have CGI headers on POST" do
    POST("/test.fcgi", {"rack-form-data" => "23"}, {'X-test-header' => '42'})
    status.must_equal 200
    response["REQUEST_METHOD"].must_equal "POST"
    response["SCRIPT_NAME"].must_equal "/test.fcgi"
    response["REQUEST_PATH"].must_equal "/"
    response["QUERY_STRING"].must_equal ""
    response["HTTP_X_TEST_HEADER"].must_equal "42"
    response["test.postdata"].must_equal "rack-form-data=23"
  end

  it "support HTTP auth" do
    GET("/test.fcgi", {:user => "ruth", :passwd => "secret"})
    response["HTTP_AUTHORIZATION"].must_equal "Basic cnV0aDpzZWNyZXQ="
  end

  it "set status" do
    GET("/test.fcgi?secret")
    status.must_equal 403
    response["rack.url_scheme"].must_equal "http"
  end
end

end # if defined? LIGHTTPD_PID

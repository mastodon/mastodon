require 'minitest/autorun'
require 'rack'
require 'rack/cascade'
require 'rack/file'
require 'rack/lint'
require 'rack/urlmap'
require 'rack/mock'

describe Rack::Cascade do
  def cascade(*args)
    Rack::Lint.new Rack::Cascade.new(*args)
  end

  docroot = File.expand_path(File.dirname(__FILE__))
  app1 = Rack::File.new(docroot)

  app2 = Rack::URLMap.new("/crash" => lambda { |env| raise "boom" })

  app3 = Rack::URLMap.new("/foo" => lambda { |env|
                            [200, { "Content-Type" => "text/plain"}, [""]]})

  it "dispatch onward on 404 and 405 by default" do
    cascade = cascade([app1, app2, app3])
    Rack::MockRequest.new(cascade).get("/cgi/test").must_be :ok?
    Rack::MockRequest.new(cascade).get("/foo").must_be :ok?
    Rack::MockRequest.new(cascade).get("/toobad").must_be :not_found?
    Rack::MockRequest.new(cascade).get("/cgi/../..").must_be :client_error?

    # Put is not allowed by Rack::File so it'll 405.
    Rack::MockRequest.new(cascade).put("/foo").must_be :ok?
  end

  it "dispatch onward on whatever is passed" do
    cascade = cascade([app1, app2, app3], [404, 403])
    Rack::MockRequest.new(cascade).get("/cgi/../bla").must_be :not_found?
  end

  it "return 404 if empty" do
    Rack::MockRequest.new(cascade([])).get('/').must_be :not_found?
  end

  it "append new app" do
    cascade = Rack::Cascade.new([], [404, 403])
    Rack::MockRequest.new(cascade).get('/').must_be :not_found?
    cascade << app2
    Rack::MockRequest.new(cascade).get('/cgi/test').must_be :not_found?
    Rack::MockRequest.new(cascade).get('/cgi/../bla').must_be :not_found?
    cascade << app1
    Rack::MockRequest.new(cascade).get('/cgi/test').must_be :ok?
    Rack::MockRequest.new(cascade).get('/cgi/../..').must_be :client_error?
    Rack::MockRequest.new(cascade).get('/foo').must_be :not_found?
    cascade << app3
    Rack::MockRequest.new(cascade).get('/foo').must_be :ok?
  end

  it "close the body on cascade" do
    body = StringIO.new
    closer = lambda { |env| [404, {}, body] }
    cascade = Rack::Cascade.new([closer, app3], [404])
    Rack::MockRequest.new(cascade).get("/foo").must_be :ok?
    body.must_be :closed?
  end
end

require 'minitest/autorun'
require 'rack/file'
require 'rack/lint'
require 'rack/mock'

describe Rack::File do
  DOCROOT = File.expand_path(File.dirname(__FILE__)) unless defined? DOCROOT

  def file(*args)
    Rack::Lint.new Rack::File.new(*args)
  end

  it 'serves files with + in the file name' do
    Dir.mktmpdir do |dir|
      File.write File.join(dir, "you+me.txt"), "hello world"
      app = file(dir)
      env = Rack::MockRequest.env_for("/you+me.txt")
      status,_,body = app.call env

      assert_equal 200, status

      str = ''
      body.each { |x| str << x }
      assert_match "hello world", str
    end
  end

  it "serve files" do
    res = Rack::MockRequest.new(file(DOCROOT)).get("/cgi/test")

    res.must_be :ok?
    assert_match(res, /ruby/)
  end

  it "set Last-Modified header" do
    res = Rack::MockRequest.new(file(DOCROOT)).get("/cgi/test")

    path = File.join(DOCROOT, "/cgi/test")

    res.must_be :ok?
    res["Last-Modified"].must_equal File.mtime(path).httpdate
  end

  it "return 304 if file isn't modified since last serve" do
    path = File.join(DOCROOT, "/cgi/test")
    res = Rack::MockRequest.new(file(DOCROOT)).
      get("/cgi/test", 'HTTP_IF_MODIFIED_SINCE' => File.mtime(path).httpdate)

    res.status.must_equal 304
    res.body.must_be :empty?
  end

  it "return the file if it's modified since last serve" do
    path = File.join(DOCROOT, "/cgi/test")
    res = Rack::MockRequest.new(file(DOCROOT)).
      get("/cgi/test", 'HTTP_IF_MODIFIED_SINCE' => (File.mtime(path) - 100).httpdate)

    res.must_be :ok?
  end

  it "serve files with URL encoded filenames" do
    res = Rack::MockRequest.new(file(DOCROOT)).get("/cgi/%74%65%73%74") # "/cgi/test"

    res.must_be :ok?
    # res.must_match(/ruby/)    # nope
    # (/ruby/).must_match res   # This is wierd, but an oddity of minitest
    # assert_match(/ruby/, res) # nope
    assert_match(res, /ruby/)
  end

  it "serve uri with URL encoded null byte (%00) in filenames" do
    res = Rack::MockRequest.new(file(DOCROOT)).get("/cgi/test%00")
    res.must_be :bad_request?
  end

  it "allow safe directory traversal" do
    req = Rack::MockRequest.new(file(DOCROOT))

    res = req.get('/cgi/../cgi/test')
    res.must_be :successful?

    res = req.get('.')
    res.must_be :not_found?

    res = req.get("test/..")
    res.must_be :not_found?
  end

  it "not allow unsafe directory traversal" do
    req = Rack::MockRequest.new(file(DOCROOT))

    res = req.get("/../README.rdoc")
    res.must_be :client_error?

    res = req.get("../test/spec_file.rb")
    res.must_be :client_error?

    res = req.get("../README.rdoc")
    res.must_be :client_error?

    res.must_be :not_found?
  end

  it "allow files with .. in their name" do
    req = Rack::MockRequest.new(file(DOCROOT))
    res = req.get("/cgi/..test")
    res.must_be :not_found?

    res = req.get("/cgi/test..")
    res.must_be :not_found?

    res = req.get("/cgi../test..")
    res.must_be :not_found?
  end

  it "not allow unsafe directory traversal with encoded periods" do
    res = Rack::MockRequest.new(file(DOCROOT)).get("/%2E%2E/README")

    res.must_be :client_error?
    res.must_be :not_found?
  end

  it "allow safe directory traversal with encoded periods" do
    res = Rack::MockRequest.new(file(DOCROOT)).get("/cgi/%2E%2E/cgi/test")

    res.must_be :successful?
  end

  it "404 if it can't find the file" do
    res = Rack::MockRequest.new(file(DOCROOT)).get("/cgi/blubb")

    res.must_be :not_found?
  end

  it "detect SystemCallErrors" do
    res = Rack::MockRequest.new(file(DOCROOT)).get("/cgi")

    res.must_be :not_found?
  end

  it "return bodies that respond to #to_path" do
    env = Rack::MockRequest.env_for("/cgi/test")
    status, _, body = Rack::File.new(DOCROOT).call(env)

    path = File.join(DOCROOT, "/cgi/test")

    status.must_equal 200
    body.must_respond_to :to_path
    body.to_path.must_equal path
  end

  it "return correct byte range in body" do
    env = Rack::MockRequest.env_for("/cgi/test")
    env["HTTP_RANGE"] = "bytes=22-33"
    res = Rack::MockResponse.new(*file(DOCROOT).call(env))

    res.status.must_equal 206
    res["Content-Length"].must_equal "12"
    res["Content-Range"].must_equal "bytes 22-33/193"
    res.body.must_equal "-*- ruby -*-"
  end

  it "return error for unsatisfiable byte range" do
    env = Rack::MockRequest.env_for("/cgi/test")
    env["HTTP_RANGE"] = "bytes=1234-5678"
    res = Rack::MockResponse.new(*file(DOCROOT).call(env))

    res.status.must_equal 416
    res["Content-Range"].must_equal "bytes */193"
  end

  it "support custom http headers" do
    env = Rack::MockRequest.env_for("/cgi/test")
    status, heads, _ = file(DOCROOT, 'Cache-Control' => 'public, max-age=38',
     'Access-Control-Allow-Origin' => '*').call(env)

    status.must_equal 200
    heads['Cache-Control'].must_equal 'public, max-age=38'
    heads['Access-Control-Allow-Origin'].must_equal '*'
  end

  it "support not add custom http headers if none are supplied" do
    env = Rack::MockRequest.env_for("/cgi/test")
    status, heads, _ = file(DOCROOT).call(env)

    status.must_equal 200
    heads['Cache-Control'].must_be_nil
    heads['Access-Control-Allow-Origin'].must_be_nil
  end

  it "only support GET, HEAD, and OPTIONS requests" do
    req = Rack::MockRequest.new(file(DOCROOT))

    forbidden = %w[post put patch delete]
    forbidden.each do |method|
      res = req.send(method, "/cgi/test")
      res.must_be :client_error?
      res.must_be :method_not_allowed?
      res.headers['Allow'].split(/, */).sort.must_equal %w(GET HEAD OPTIONS)
    end

    allowed = %w[get head options]
    allowed.each do |method|
      res = req.send(method, "/cgi/test")
      res.must_be :successful?
    end
  end

  it "set Allow correctly for OPTIONS requests" do
    req = Rack::MockRequest.new(file(DOCROOT))
    res = req.options('/cgi/test')
    res.must_be :successful?
    res.headers['Allow'].wont_equal nil
    res.headers['Allow'].split(/, */).sort.must_equal %w(GET HEAD OPTIONS)
  end

  it "set Content-Length correctly for HEAD requests" do
    req = Rack::MockRequest.new(Rack::Lint.new(Rack::File.new(DOCROOT)))
    res = req.head "/cgi/test"
    res.must_be :successful?
    res['Content-Length'].must_equal "193"
  end

  it "default to a mime type of text/plain" do
    req = Rack::MockRequest.new(Rack::Lint.new(Rack::File.new(DOCROOT)))
    res = req.get "/cgi/test"
    res.must_be :successful?
    res['Content-Type'].must_equal "text/plain"
  end

  it "allow the default mime type to be set" do
    req = Rack::MockRequest.new(Rack::Lint.new(Rack::File.new(DOCROOT, nil, 'application/octet-stream')))
    res = req.get "/cgi/test"
    res.must_be :successful?
    res['Content-Type'].must_equal "application/octet-stream"
  end

  it "not set Content-Type if the mime type is not set" do
    req = Rack::MockRequest.new(Rack::Lint.new(Rack::File.new(DOCROOT, nil, nil)))
    res = req.get "/cgi/test"
    res.must_be :successful?
    res['Content-Type'].must_be_nil
  end

  it "return error when file not found for head request" do
    res = Rack::MockRequest.new(file(DOCROOT)).head("/cgi/missing")
    res.must_be :not_found?
    res.body.must_be :empty?
  end

  class MyFile < Rack::File
    def response_body
      "hello world"
    end
  end

  it "behaves gracefully if response_body is present" do
    file = Rack::Lint.new MyFile.new(DOCROOT)
    res  = Rack::MockRequest.new(file).get("/cgi/test")

    res.must_be :ok?
  end

end

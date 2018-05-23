require 'minitest/autorun'
require 'rack/directory'
require 'rack/lint'
require 'rack/mock'
require 'tempfile'
require 'fileutils'

describe Rack::Directory do
  DOCROOT = File.expand_path(File.dirname(__FILE__)) unless defined? DOCROOT
  FILE_CATCH = proc{|env| [200, {'Content-Type'=>'text/plain', "Content-Length" => "7"}, ['passed!']] }

  attr_reader :app

  def setup
    @app = Rack::Lint.new(Rack::Directory.new(DOCROOT, FILE_CATCH))
  end

  it 'serves directories with + in the name' do
    Dir.mktmpdir do |dir|
      plus_dir = "foo+bar"
      full_dir = File.join(dir, plus_dir)
      FileUtils.mkdir full_dir
      FileUtils.touch File.join(full_dir, "omg.txt")
      app = Rack::Directory.new(dir, FILE_CATCH)
      env = Rack::MockRequest.env_for("/#{plus_dir}/")
      status,_,body = app.call env

      assert_equal 200, status

      str = ''
      body.each { |x| str << x }
      assert_match "foo+bar", str
    end
  end

  it "serve directory indices" do
    res = Rack::MockRequest.new(Rack::Lint.new(app)).
      get("/cgi/")

    res.must_be :ok?
    assert_match(res, /<html><head>/)
  end

  it "pass to app if file found" do
    res = Rack::MockRequest.new(Rack::Lint.new(app)).
      get("/cgi/test")

    res.must_be :ok?
    assert_match(res, /passed!/)
  end

  it "serve uri with URL encoded filenames" do
    res = Rack::MockRequest.new(Rack::Lint.new(app)).
      get("/%63%67%69/") # "/cgi/test"

    res.must_be :ok?
    assert_match(res, /<html><head>/)

    res = Rack::MockRequest.new(Rack::Lint.new(app)).
      get("/cgi/%74%65%73%74") # "/cgi/test"

    res.must_be :ok?
    assert_match(res, /passed!/)
  end

  it "serve uri with URL encoded null byte (%00) in filenames" do
    res = Rack::MockRequest.new(Rack::Lint.new(app))
      .get("/cgi/test%00")

    res.must_be :bad_request?
  end

  it "not allow directory traversal" do
    res = Rack::MockRequest.new(Rack::Lint.new(app)).
      get("/cgi/../test")

    res.must_be :forbidden?

    res = Rack::MockRequest.new(Rack::Lint.new(app)).
      get("/cgi/%2E%2E/test")

    res.must_be :forbidden?
  end

  it "404 if it can't find the file" do
    res = Rack::MockRequest.new(Rack::Lint.new(app)).
      get("/cgi/blubb")

    res.must_be :not_found?
  end

  it "uri escape path parts" do # #265, properly escape file names
    mr = Rack::MockRequest.new(Rack::Lint.new(app))

    res = mr.get("/cgi/test%2bdirectory")

    res.must_be :ok?
    res.body.must_match(%r[/cgi/test\+directory/test\+file])

    res = mr.get("/cgi/test%2bdirectory/test%2bfile")
    res.must_be :ok?
  end

  it "correctly escape script name with spaces" do
    Dir.mktmpdir do |dir|
      space_dir = "foo bar"
      full_dir = File.join(dir, space_dir)
      FileUtils.mkdir full_dir
      FileUtils.touch File.join(full_dir, "omg omg.txt")
      app = Rack::Directory.new(dir, FILE_CATCH)
      env = Rack::MockRequest.env_for(Rack::Utils.escape_path("/#{space_dir}/"))
      status,_,body = app.call env

      assert_equal 200, status

      str = ''
      body.each { |x| str << x }
      assert_match "/foo%20bar/omg%20omg.txt", str
    end
  end

  it "correctly escape script name" do
    _app = app
    app2 = Rack::Builder.new do
      map '/script-path' do
        run _app
      end
    end

    mr = Rack::MockRequest.new(Rack::Lint.new(app2))

    res = mr.get("/script-path/cgi/test%2bdirectory")

    res.must_be :ok?
    res.body.must_match(%r[/script-path/cgi/test\+directory/test\+file])

    res = mr.get("/script-path/cgi/test+directory/test+file")
    res.must_be :ok?
  end

  it "return error when file not found for head request" do
    res = Rack::MockRequest.new(Rack::Lint.new(app)).
      head("/cgi/missing")

    res.must_be :not_found?
    res.body.must_be :empty?
  end
end

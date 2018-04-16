require 'minitest/autorun'
require 'rack/static'
require 'rack/lint'
require 'rack/mock'
require 'zlib'
require 'stringio'

class DummyApp
  def call(env)
    [200, {"Content-Type" => "text/plain"}, ["Hello World"]]
  end
end

describe Rack::Static do
  def static(app, *args)
    Rack::Lint.new Rack::Static.new(app, *args)
  end

  root = File.expand_path(File.dirname(__FILE__))

  OPTIONS = {:urls => ["/cgi"], :root => root}
  STATIC_OPTIONS = {:urls => [""], :root => "#{root}/static", :index => 'index.html'}
  HASH_OPTIONS = {:urls => {"/cgi/sekret" => 'cgi/test'}, :root => root}
  HASH_ROOT_OPTIONS = {:urls => {"/" => "static/foo.html"}, :root => root}
  GZIP_OPTIONS = {:urls => ["/cgi"], :root => root, :gzip=>true}

  before do
  @request = Rack::MockRequest.new(static(DummyApp.new, OPTIONS))
  @static_request = Rack::MockRequest.new(static(DummyApp.new, STATIC_OPTIONS))
  @hash_request = Rack::MockRequest.new(static(DummyApp.new, HASH_OPTIONS))
  @hash_root_request = Rack::MockRequest.new(static(DummyApp.new, HASH_ROOT_OPTIONS))
  @gzip_request = Rack::MockRequest.new(static(DummyApp.new, GZIP_OPTIONS))
  @header_request = Rack::MockRequest.new(static(DummyApp.new, HEADER_OPTIONS))
  end

  it "serves files" do
    res = @request.get("/cgi/test")
    res.must_be :ok?
    res.body.must_match(/ruby/)
  end

  it "404s if url root is known but it can't find the file" do
    res = @request.get("/cgi/foo")
    res.must_be :not_found?
  end

  it "calls down the chain if url root is not known" do
    res = @request.get("/something/else")
    res.must_be :ok?
    res.body.must_equal "Hello World"
  end

  it "calls index file when requesting root in the given folder" do
    res = @static_request.get("/")
    res.must_be :ok?
    res.body.must_match(/index!/)

    res = @static_request.get("/other/")
    res.must_be :not_found?

    res = @static_request.get("/another/")
    res.must_be :ok?
    res.body.must_match(/another index!/)
  end

  it "doesn't call index file if :index option was omitted" do
    res = @request.get("/")
    res.body.must_equal "Hello World"
  end

  it "serves hidden files" do
    res = @hash_request.get("/cgi/sekret")
    res.must_be :ok?
    res.body.must_match(/ruby/)
  end

  it "calls down the chain if the URI is not specified" do
    res = @hash_request.get("/something/else")
    res.must_be :ok?
    res.body.must_equal "Hello World"
  end

  it "allows the root URI to be configured via hash options" do
    res = @hash_root_request.get("/")
    res.must_be :ok?
    res.body.must_match(/foo.html!/)
  end

  it "serves gzipped files if client accepts gzip encoding and gzip files are present" do
    res = @gzip_request.get("/cgi/test", 'HTTP_ACCEPT_ENCODING'=>'deflate, gzip')
    res.must_be :ok?
    res.headers['Content-Encoding'].must_equal 'gzip'
    res.headers['Content-Type'].must_equal 'text/plain'
    Zlib::GzipReader.wrap(StringIO.new(res.body), &:read).must_match(/ruby/)
  end

  it "serves regular files if client accepts gzip encoding and gzip files are not present" do
    res = @gzip_request.get("/cgi/rackup_stub.rb", 'HTTP_ACCEPT_ENCODING'=>'deflate, gzip')
    res.must_be :ok?
    res.headers['Content-Encoding'].must_be_nil
    res.headers['Content-Type'].must_equal 'text/x-script.ruby'
    res.body.must_match(/ruby/)
  end

  it "serves regular files if client does not accept gzip encoding" do
    res = @gzip_request.get("/cgi/test")
    res.must_be :ok?
    res.headers['Content-Encoding'].must_be_nil
    res.headers['Content-Type'].must_equal 'text/plain'
    res.body.must_match(/ruby/)
  end

  it "supports serving fixed cache-control (legacy option)" do
    opts = OPTIONS.merge(:cache_control => 'public')
    request = Rack::MockRequest.new(static(DummyApp.new, opts))
    res = request.get("/cgi/test")
    res.must_be :ok?
    res.headers['Cache-Control'].must_equal 'public'
  end

  HEADER_OPTIONS = {:urls => ["/cgi"], :root => root, :header_rules => [
    [:all, {'Cache-Control' => 'public, max-age=100'}],
    [:fonts, {'Cache-Control' => 'public, max-age=200'}],
    [%w(png jpg), {'Cache-Control' => 'public, max-age=300'}],
    ['/cgi/assets/folder/', {'Cache-Control' => 'public, max-age=400'}],
    ['cgi/assets/javascripts', {'Cache-Control' => 'public, max-age=500'}],
    [/\.(css|erb)\z/, {'Cache-Control' => 'public, max-age=600'}]
  ]}

  it "supports header rule :all" do
    # Headers for all files via :all shortcut
    res = @header_request.get('/cgi/assets/index.html')
    res.must_be :ok?
    res.headers['Cache-Control'].must_equal 'public, max-age=100'
  end

  it "supports header rule :fonts" do
    # Headers for web fonts via :fonts shortcut
    res = @header_request.get('/cgi/assets/fonts/font.eot')
    res.must_be :ok?
    res.headers['Cache-Control'].must_equal 'public, max-age=200'
  end

  it "supports file extension header rules provided as an Array" do
    # Headers for file extensions via array
    res = @header_request.get('/cgi/assets/images/image.png')
    res.must_be :ok?
    res.headers['Cache-Control'].must_equal 'public, max-age=300'
  end

  it "supports folder rules provided as a String" do
    # Headers for files in folder via string
    res = @header_request.get('/cgi/assets/folder/test.js')
    res.must_be :ok?
    res.headers['Cache-Control'].must_equal 'public, max-age=400'
  end

  it "supports folder header rules provided as a String not starting with a slash" do
    res = @header_request.get('/cgi/assets/javascripts/app.js')
    res.must_be :ok?
    res.headers['Cache-Control'].must_equal 'public, max-age=500'
  end

  it "supports flexible header rules provided as Regexp" do
    # Flexible Headers via Regexp
    res = @header_request.get('/cgi/assets/stylesheets/app.css')
    res.must_be :ok?
    res.headers['Cache-Control'].must_equal 'public, max-age=600'
  end

  it "prioritizes header rules over fixed cache-control setting (legacy option)" do
    opts = OPTIONS.merge(
      :cache_control => 'public, max-age=24',
      :header_rules => [
        [:all, {'Cache-Control' => 'public, max-age=42'}]
      ])

    request = Rack::MockRequest.new(static(DummyApp.new, opts))
    res = request.get("/cgi/test")
    res.must_be :ok?
    res.headers['Cache-Control'].must_equal 'public, max-age=42'
  end

end

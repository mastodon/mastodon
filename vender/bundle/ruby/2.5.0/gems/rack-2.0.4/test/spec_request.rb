require 'minitest/autorun'
require 'stringio'
require 'cgi'
require 'rack/request'
require 'rack/mock'
require 'rack/multipart'
require 'securerandom'

class RackRequestTest < Minitest::Spec
  it "copies the env when duping" do
    req = make_request(Rack::MockRequest.env_for("http://example.com:8080/"))
    refute_same req.env, req.dup.env
  end

  it 'can check if something has been set' do
    req = make_request(Rack::MockRequest.env_for("http://example.com:8080/"))
    refute req.has_header?("FOO")
  end

  it "can get a key from the env" do
    req = make_request(Rack::MockRequest.env_for("http://example.com:8080/"))
    assert_equal "example.com", req.get_header("SERVER_NAME")
  end

  it 'can calculate the authority' do
    req = make_request(Rack::MockRequest.env_for("http://example.com:8080/"))
    assert_equal "example.com:8080", req.authority
  end

  it 'can calculate the authority without a port' do
    req = make_request(Rack::MockRequest.env_for("http://example.com/"))
    assert_equal "example.com:80", req.authority
  end

  it 'can calculate the authority without a port on ssl' do
    req = make_request(Rack::MockRequest.env_for("https://example.com/"))
    assert_equal "example.com:443", req.authority
  end

  it 'yields to the block if no value has been set' do
    req = make_request(Rack::MockRequest.env_for("http://example.com:8080/"))
    yielded = false
    req.fetch_header("FOO") do
      yielded = true
      req.set_header "FOO", 'bar'
    end

    assert yielded
    assert_equal "bar", req.get_header("FOO")
  end

  it 'can iterate over values' do
    req = make_request(Rack::MockRequest.env_for("http://example.com:8080/"))
    req.set_header 'foo', 'bar'
    hash = {}
    req.each_header do |k,v|
      hash[k] = v
    end
    assert_equal 'bar', hash['foo']
  end

  it 'can set values in the env' do
    req = make_request(Rack::MockRequest.env_for("http://example.com:8080/"))
    req.set_header("FOO", "BAR")
    assert_equal "BAR", req.get_header("FOO")
  end

  it 'can add to multivalued headers in the env' do
    req = make_request(Rack::MockRequest.env_for('http://example.com:8080/'))

    assert_equal '1', req.add_header('FOO', '1')
    assert_equal '1', req.get_header('FOO')

    assert_equal '1,2', req.add_header('FOO', '2')
    assert_equal '1,2', req.get_header('FOO')

    assert_equal '1,2', req.add_header('FOO', nil)
    assert_equal '1,2', req.get_header('FOO')
  end

  it 'can delete env values' do
    req = make_request(Rack::MockRequest.env_for("http://example.com:8080/"))
    req.set_header 'foo', 'bar'
    assert req.has_header? 'foo'
    req.delete_header 'foo'
    refute req.has_header? 'foo'
  end

  it "wrap the rack variables" do
    req = make_request(Rack::MockRequest.env_for("http://example.com:8080/"))

    req.body.must_respond_to :gets
    req.scheme.must_equal "http"
    req.request_method.must_equal "GET"

    req.must_be :get?
    req.wont_be :post?
    req.wont_be :put?
    req.wont_be :delete?
    req.wont_be :head?
    req.wont_be :patch?

    req.script_name.must_equal ""
    req.path_info.must_equal "/"
    req.query_string.must_equal ""

    req.host.must_equal "example.com"
    req.port.must_equal 8080

    req.content_length.must_equal "0"
    req.content_type.must_be_nil
  end

  it "figure out the correct host" do
    req = make_request \
      Rack::MockRequest.env_for("/", "HTTP_HOST" => "www2.example.org")
    req.host.must_equal "www2.example.org"

    req = make_request \
      Rack::MockRequest.env_for("/", "SERVER_NAME" => "example.org", "SERVER_PORT" => "9292")
    req.host.must_equal "example.org"

    req = make_request \
      Rack::MockRequest.env_for("/", "HTTP_HOST" => "localhost:81", "HTTP_X_FORWARDED_HOST" => "example.org:9292")
    req.host.must_equal "example.org"

    env = Rack::MockRequest.env_for("/", "SERVER_ADDR" => "192.168.1.1", "SERVER_PORT" => "9292")
    env.delete("SERVER_NAME")
    req = make_request(env)
    req.host.must_equal "192.168.1.1"

    env = Rack::MockRequest.env_for("/")
    env.delete("SERVER_NAME")
    req = make_request(env)
    req.host.must_equal ""
  end

  it "figure out the correct port" do
    req = make_request \
      Rack::MockRequest.env_for("/", "HTTP_HOST" => "www2.example.org")
    req.port.must_equal 80

    req = make_request \
      Rack::MockRequest.env_for("/", "HTTP_HOST" => "www2.example.org:81")
    req.port.must_equal 81

    req = make_request \
      Rack::MockRequest.env_for("/", "SERVER_NAME" => "example.org", "SERVER_PORT" => "9292")
    req.port.must_equal 9292

    req = make_request \
      Rack::MockRequest.env_for("/", "HTTP_HOST" => "localhost:81", "HTTP_X_FORWARDED_HOST" => "example.org:9292")
    req.port.must_equal 9292

    req = make_request \
      Rack::MockRequest.env_for("/", "HTTP_HOST" => "localhost:81", "HTTP_X_FORWARDED_HOST" => "example.org")
    req.port.must_equal 80

    req = make_request \
      Rack::MockRequest.env_for("/", "HTTP_HOST" => "localhost:81", "HTTP_X_FORWARDED_HOST" => "example.org", "HTTP_X_FORWARDED_SSL" => "on")
    req.port.must_equal 443

     req = make_request \
      Rack::MockRequest.env_for("/", "HTTP_HOST" => "localhost:81", "HTTP_X_FORWARDED_HOST" => "example.org", "HTTP_X_FORWARDED_PROTO" => "https")
    req.port.must_equal 443

    req = make_request \
      Rack::MockRequest.env_for("/", "HTTP_HOST" => "localhost:81", "HTTP_X_FORWARDED_HOST" => "example.org", "HTTP_X_FORWARDED_PORT" => "9393")
    req.port.must_equal 9393

    req = make_request \
      Rack::MockRequest.env_for("/", "HTTP_HOST" => "localhost:81", "HTTP_X_FORWARDED_HOST" => "example.org:9393", "SERVER_PORT" => "80")
    req.port.must_equal 9393

    req = make_request \
      Rack::MockRequest.env_for("/", "HTTP_HOST" => "localhost:81", "HTTP_X_FORWARDED_HOST" => "example.org", "SERVER_PORT" => "9393")
    req.port.must_equal 80

    req = make_request \
      Rack::MockRequest.env_for("/", "HTTP_HOST" => "localhost", "HTTP_X_FORWARDED_PROTO" => "https", "SERVER_PORT" => "80")
    req.port.must_equal 443

    req = make_request \
      Rack::MockRequest.env_for("/", "HTTP_HOST" => "localhost", "HTTP_X_FORWARDED_PROTO" => "https,https", "SERVER_PORT" => "80")
    req.port.must_equal 443
  end

  it "figure out the correct host with port" do
    req = make_request \
      Rack::MockRequest.env_for("/", "HTTP_HOST" => "www2.example.org")
    req.host_with_port.must_equal "www2.example.org"

    req = make_request \
      Rack::MockRequest.env_for("/", "HTTP_HOST" => "localhost:81")
    req.host_with_port.must_equal "localhost:81"

    req = make_request \
      Rack::MockRequest.env_for("/", "SERVER_NAME" => "example.org", "SERVER_PORT" => "9292")
    req.host_with_port.must_equal "example.org:9292"

    req = make_request \
      Rack::MockRequest.env_for("/", "HTTP_HOST" => "localhost:81", "HTTP_X_FORWARDED_HOST" => "example.org:9292")
    req.host_with_port.must_equal "example.org:9292"

    req = make_request \
      Rack::MockRequest.env_for("/", "HTTP_HOST" => "localhost:81", "HTTP_X_FORWARDED_HOST" => "example.org", "SERVER_PORT" => "9393")
    req.host_with_port.must_equal "example.org"
  end

  it "parse the query string" do
    req = make_request(Rack::MockRequest.env_for("/?foo=bar&quux=bla"))
    req.query_string.must_equal "foo=bar&quux=bla"
    req.GET.must_equal "foo" => "bar", "quux" => "bla"
    req.POST.must_be :empty?
    req.params.must_equal "foo" => "bar", "quux" => "bla"
  end

  it "not truncate query strings containing semi-colons #543 only in POST" do
    mr = Rack::MockRequest.env_for("/",
      "REQUEST_METHOD" => 'POST',
      :input => "foo=bar&quux=b;la")
    req = make_request mr
    req.query_string.must_equal ""
    req.GET.must_be :empty?
    req.POST.must_equal "foo" => "bar", "quux" => "b;la"
    req.params.must_equal req.GET.merge(req.POST)
  end

  it "should use the query_parser for query parsing" do
    c = Class.new(Rack::QueryParser::Params) do
      def initialize(*)
        super
        @params = Hash.new{|h,k| h[k.to_s] if k.is_a?(Symbol)}
      end
    end
    parser = Rack::QueryParser.new(c, 65536, 100)
    c = Class.new(Rack::Request) do
      define_method(:query_parser) do
        parser
      end
    end
    req = c.new(Rack::MockRequest.env_for("/?foo=bar&quux=bla"))
    req.GET[:foo].must_equal "bar"
    req.GET[:quux].must_equal "bla"
    req.params[:foo].must_equal "bar"
    req.params[:quux].must_equal "bla"
  end

  it "use semi-colons as separators for query strings in GET" do
    req = make_request(Rack::MockRequest.env_for("/?foo=bar&quux=b;la;wun=duh"))
    req.query_string.must_equal "foo=bar&quux=b;la;wun=duh"
    req.GET.must_equal "foo" => "bar", "quux" => "b", "la" => nil, "wun" => "duh"
    req.POST.must_be :empty?
    req.params.must_equal "foo" => "bar", "quux" => "b", "la" => nil, "wun" => "duh"
  end

  it "limit the keys from the GET query string" do
    env = Rack::MockRequest.env_for("/?foo=bar")

    old, Rack::Utils.key_space_limit = Rack::Utils.key_space_limit, 1
    begin
      req = make_request(env)
      lambda { req.GET }.must_raise RangeError
    ensure
      Rack::Utils.key_space_limit = old
    end
  end

  it "limit the key size per nested params hash" do
    nested_query = Rack::MockRequest.env_for("/?foo%5Bbar%5D%5Bbaz%5D%5Bqux%5D=1")
    plain_query  = Rack::MockRequest.env_for("/?foo_bar__baz__qux_=1")

    old, Rack::Utils.key_space_limit = Rack::Utils.key_space_limit, 3
    begin
      exp = {"foo"=>{"bar"=>{"baz"=>{"qux"=>"1"}}}}
      make_request(nested_query).GET.must_equal exp
      lambda { make_request(plain_query).GET  }.must_raise RangeError
    ensure
      Rack::Utils.key_space_limit = old
    end
  end

  it "not unify GET and POST when calling params" do
    mr = Rack::MockRequest.env_for("/?foo=quux",
      "REQUEST_METHOD" => 'POST',
      :input => "foo=bar&quux=bla"
    )
    req = make_request mr

    req.params

    req.GET.must_equal "foo" => "quux"
    req.POST.must_equal "foo" => "bar", "quux" => "bla"
    req.params.must_equal req.GET.merge(req.POST)
  end

  it "use the query_parser's params_class for multipart params" do
    c = Class.new(Rack::QueryParser::Params) do
      def initialize(*)
        super
        @params = Hash.new{|h,k| h[k.to_s] if k.is_a?(Symbol)}
      end
    end
    parser = Rack::QueryParser.new(c, 65536, 100)
    c = Class.new(Rack::Request) do
      define_method(:query_parser) do
        parser
      end
    end
    mr = Rack::MockRequest.env_for("/?foo=quux",
      "REQUEST_METHOD" => 'POST',
      :input => "foo=bar&quux=bla"
    )
    req = c.new mr

    req.params

    req.GET[:foo].must_equal "quux"
    req.POST[:foo].must_equal "bar"
    req.POST[:quux].must_equal "bla"
    req.params[:foo].must_equal "bar"
    req.params[:quux].must_equal "bla"
  end

  it "raise if input params has invalid %-encoding" do
    mr = Rack::MockRequest.env_for("/?foo=quux",
      "REQUEST_METHOD" => 'POST',
      :input => "a%=1"
    )
    req = make_request mr

    lambda { req.POST }.must_raise(Rack::Utils::InvalidParameterError).
      message.must_equal "invalid %-encoding (a%)"
  end

  it "raise if rack.input is missing" do
    req = make_request({})
    lambda { req.POST }.must_raise RuntimeError
  end

  it "parse POST data when method is POST and no Content-Type given" do
    req = make_request \
      Rack::MockRequest.env_for("/?foo=quux",
        "REQUEST_METHOD" => 'POST',
        :input => "foo=bar&quux=bla")
    req.content_type.must_be_nil
    req.media_type.must_be_nil
    req.query_string.must_equal "foo=quux"
    req.GET.must_equal "foo" => "quux"
    req.POST.must_equal "foo" => "bar", "quux" => "bla"
    req.params.must_equal "foo" => "bar", "quux" => "bla"
  end

  it "limit the keys from the POST form data" do
    env = Rack::MockRequest.env_for("",
            "REQUEST_METHOD" => 'POST',
            :input => "foo=bar&quux=bla")

    old, Rack::Utils.key_space_limit = Rack::Utils.key_space_limit, 1
    begin
      req = make_request(env)
      lambda { req.POST }.must_raise RangeError
    ensure
      Rack::Utils.key_space_limit = old
    end
  end

  it "parse POST data with explicit content type regardless of method" do
    req = make_request \
      Rack::MockRequest.env_for("/",
        "CONTENT_TYPE" => 'application/x-www-form-urlencoded;foo=bar',
        :input => "foo=bar&quux=bla")
    req.content_type.must_equal 'application/x-www-form-urlencoded;foo=bar'
    req.media_type.must_equal 'application/x-www-form-urlencoded'
    req.media_type_params['foo'].must_equal 'bar'
    req.POST.must_equal "foo" => "bar", "quux" => "bla"
    req.params.must_equal "foo" => "bar", "quux" => "bla"
  end

  it "not parse POST data when media type is not form-data" do
    req = make_request \
      Rack::MockRequest.env_for("/?foo=quux",
        "REQUEST_METHOD" => 'POST',
        "CONTENT_TYPE" => 'text/plain;charset=utf-8',
        :input => "foo=bar&quux=bla")
    req.content_type.must_equal 'text/plain;charset=utf-8'
    req.media_type.must_equal 'text/plain'
    req.media_type_params['charset'].must_equal 'utf-8'
    req.POST.must_be :empty?
    req.params.must_equal "foo" => "quux"
    req.body.read.must_equal "foo=bar&quux=bla"
  end

  it "parse POST data on PUT when media type is form-data" do
    req = make_request \
      Rack::MockRequest.env_for("/?foo=quux",
        "REQUEST_METHOD" => 'PUT',
        "CONTENT_TYPE" => 'application/x-www-form-urlencoded',
        :input => "foo=bar&quux=bla")
    req.POST.must_equal "foo" => "bar", "quux" => "bla"
    req.body.read.must_equal "foo=bar&quux=bla"
  end

  it "rewind input after parsing POST data" do
    input = StringIO.new("foo=bar&quux=bla")
    req = make_request \
      Rack::MockRequest.env_for("/",
        "CONTENT_TYPE" => 'application/x-www-form-urlencoded;foo=bar',
        :input => input)
    req.params.must_equal "foo" => "bar", "quux" => "bla"
    input.read.must_equal "foo=bar&quux=bla"
  end

  it "safely accepts POST requests with empty body" do
    mr = Rack::MockRequest.env_for("/",
      "REQUEST_METHOD" => "POST",
      "CONTENT_TYPE"   => "multipart/form-data, boundary=AaB03x",
      "CONTENT_LENGTH" => '0',
      :input => nil)

    req = make_request mr
    req.query_string.must_equal ""
    req.GET.must_be :empty?
    req.POST.must_be :empty?
    req.params.must_equal({})
  end

  it "clean up Safari's ajax POST body" do
    req = make_request \
      Rack::MockRequest.env_for("/",
        'REQUEST_METHOD' => 'POST', :input => "foo=bar&quux=bla\0")
    req.POST.must_equal "foo" => "bar", "quux" => "bla"
  end

  it "get value by key from params with #[]" do
    req = make_request \
      Rack::MockRequest.env_for("?foo=quux")
    req['foo'].must_equal 'quux'
    req[:foo].must_equal 'quux'
  end

  it "set value to key on params with #[]=" do
    req = make_request \
      Rack::MockRequest.env_for("?foo=duh")
    req['foo'].must_equal 'duh'
    req[:foo].must_equal 'duh'
    req.params.must_equal 'foo' => 'duh'

    if req.delegate?
      skip "delegate requests don't cache params, so mutations have no impact"
    end

    req['foo'] = 'bar'
    req.params.must_equal 'foo' => 'bar'
    req['foo'].must_equal 'bar'
    req[:foo].must_equal 'bar'

    req[:foo] = 'jaz'
    req.params.must_equal 'foo' => 'jaz'
    req['foo'].must_equal 'jaz'
    req[:foo].must_equal 'jaz'
  end

  it "return values for the keys in the order given from values_at" do
    req = make_request \
      Rack::MockRequest.env_for("?foo=baz&wun=der&bar=ful")
    req.values_at('foo').must_equal ['baz']
    req.values_at('foo', 'wun').must_equal ['baz', 'der']
    req.values_at('bar', 'foo', 'wun').must_equal ['ful', 'baz', 'der']
  end

  it "extract referrer correctly" do
    req = make_request \
      Rack::MockRequest.env_for("/", "HTTP_REFERER" => "/some/path")
    req.referer.must_equal "/some/path"

    req = make_request \
      Rack::MockRequest.env_for("/")
    req.referer.must_be_nil
  end

  it "extract user agent correctly" do
    req = make_request \
      Rack::MockRequest.env_for("/", "HTTP_USER_AGENT" => "Mozilla/4.0 (compatible)")
    req.user_agent.must_equal "Mozilla/4.0 (compatible)"

    req = make_request \
      Rack::MockRequest.env_for("/")
    req.user_agent.must_be_nil
  end

  it "treat missing content type as nil" do
    req = make_request \
      Rack::MockRequest.env_for("/")
    req.content_type.must_be_nil
  end

  it "treat empty content type as nil" do
    req = make_request \
      Rack::MockRequest.env_for("/", "CONTENT_TYPE" => "")
    req.content_type.must_be_nil
  end

  it "return nil media type for empty content type" do
    req = make_request \
      Rack::MockRequest.env_for("/", "CONTENT_TYPE" => "")
    req.media_type.must_be_nil
  end

  it "cache, but invalidates the cache" do
    req = make_request \
      Rack::MockRequest.env_for("/?foo=quux",
        "CONTENT_TYPE" => "application/x-www-form-urlencoded",
        :input => "foo=bar&quux=bla")
    req.GET.must_equal "foo" => "quux"
    req.GET.must_equal "foo" => "quux"
    req.set_header("QUERY_STRING", "bla=foo")
    req.GET.must_equal "bla" => "foo"
    req.GET.must_equal "bla" => "foo"

    req.POST.must_equal "foo" => "bar", "quux" => "bla"
    req.POST.must_equal "foo" => "bar", "quux" => "bla"
    req.set_header("rack.input", StringIO.new("foo=bla&quux=bar"))
    req.POST.must_equal "foo" => "bla", "quux" => "bar"
    req.POST.must_equal "foo" => "bla", "quux" => "bar"
  end

  it "figure out if called via XHR" do
    req = make_request(Rack::MockRequest.env_for(""))
    req.wont_be :xhr?

    req = make_request \
      Rack::MockRequest.env_for("", "HTTP_X_REQUESTED_WITH" => "XMLHttpRequest")
    req.must_be :xhr?
  end

  it "ssl detection" do
    request = make_request(Rack::MockRequest.env_for("/"))
    request.scheme.must_equal "http"
    request.wont_be :ssl?

    request = make_request(Rack::MockRequest.env_for("/", 'HTTPS' => 'on'))
    request.scheme.must_equal "https"
    request.must_be :ssl?

    request = make_request(Rack::MockRequest.env_for("/", 'rack.url_scheme' => 'https'))
    request.scheme.must_equal "https"
    request.must_be :ssl?

    request = make_request(Rack::MockRequest.env_for("/", 'HTTP_HOST' => 'www.example.org:8080'))
    request.scheme.must_equal "http"
    request.wont_be :ssl?

    request = make_request(Rack::MockRequest.env_for("/", 'HTTP_HOST' => 'www.example.org:8443', 'HTTPS' => 'on'))
    request.scheme.must_equal "https"
    request.must_be :ssl?

    request = make_request(Rack::MockRequest.env_for("/", 'HTTP_HOST' => 'www.example.org:8443', 'HTTP_X_FORWARDED_SSL' => 'on'))
    request.scheme.must_equal "https"
    request.must_be :ssl?

    request = make_request(Rack::MockRequest.env_for("/", 'HTTP_X_FORWARDED_SCHEME' => 'https'))
    request.scheme.must_equal "https"
    request.must_be :ssl?

    request = make_request(Rack::MockRequest.env_for("/", 'HTTP_X_FORWARDED_PROTO' => 'https'))
    request.scheme.must_equal "https"
    request.must_be :ssl?

    request = make_request(Rack::MockRequest.env_for("/", 'HTTP_X_FORWARDED_PROTO' => 'https, http, http'))
    request.scheme.must_equal "https"
    request.must_be :ssl?
  end

  it "parse cookies" do
    req = make_request \
      Rack::MockRequest.env_for("", "HTTP_COOKIE" => "foo=bar;quux=h&m")
    req.cookies.must_equal "foo" => "bar", "quux" => "h&m"
    req.cookies.must_equal "foo" => "bar", "quux" => "h&m"
    req.delete_header("HTTP_COOKIE")
    req.cookies.must_equal({})
  end

  it "always return the same hash object" do
    req = make_request \
      Rack::MockRequest.env_for("", "HTTP_COOKIE" => "foo=bar;quux=h&m")
    hash = req.cookies
    req.env.delete("HTTP_COOKIE")
    req.cookies.must_equal hash
    req.env["HTTP_COOKIE"] = "zoo=m"
    req.cookies.must_equal hash
  end

  it "modify the cookies hash in place" do
    req = make_request(Rack::MockRequest.env_for(""))
    req.cookies.must_equal({})
    req.cookies['foo'] = 'bar'
    req.cookies.must_equal 'foo' => 'bar'
  end

  it "not modify the params hash in place" do
    e = Rack::MockRequest.env_for("")
    req1 = make_request(e)
    if req1.delegate?
      skip "delegate requests don't cache params, so mutations have no impact"
    end
    req1.params.must_equal({})
    req1.params['foo'] = 'bar'
    req1.params.must_equal 'foo' => 'bar'
    req2 = make_request(e)
    req2.params.must_equal({})
  end

  it "modify params hash if param is in GET" do
    e = Rack::MockRequest.env_for("?foo=duh")
    req1 = make_request(e)
    req1.params.must_equal 'foo' => 'duh'
    req1.update_param 'foo', 'bar'
    req1.params.must_equal 'foo' => 'bar'
    req2 = make_request(e)
    req2.params.must_equal 'foo' => 'bar'
  end

  it "modify params hash if param is in POST" do
    e = Rack::MockRequest.env_for("", "REQUEST_METHOD" => 'POST', :input => 'foo=duh')
    req1 = make_request(e)
    req1.params.must_equal 'foo' => 'duh'
    req1.update_param 'foo', 'bar'
    req1.params.must_equal 'foo' => 'bar'
    req2 = make_request(e)
    req2.params.must_equal 'foo' => 'bar'
  end

  it "modify params hash, even if param didn't exist before" do
    e = Rack::MockRequest.env_for("")
    req1 = make_request(e)
    req1.params.must_equal({})
    req1.update_param 'foo', 'bar'
    req1.params.must_equal 'foo' => 'bar'
    req2 = make_request(e)
    req2.params.must_equal 'foo' => 'bar'
  end

  it "modify params hash by changing only GET" do
    e = Rack::MockRequest.env_for("?foo=duhget")
    req = make_request(e)
    req.GET.must_equal 'foo' => 'duhget'
    req.POST.must_equal({})
    req.update_param 'foo', 'bar'
    req.GET.must_equal 'foo' => 'bar'
    req.POST.must_equal({})
  end

  it "modify params hash by changing only POST" do
    e = Rack::MockRequest.env_for("", "REQUEST_METHOD" => 'POST', :input => "foo=duhpost")
    req = make_request(e)
    req.GET.must_equal({})
    req.POST.must_equal 'foo' => 'duhpost'
    req.update_param 'foo', 'bar'
    req.GET.must_equal({})
    req.POST.must_equal 'foo' => 'bar'
  end

  it "modify params hash, even if param is defined in both POST and GET" do
    e = Rack::MockRequest.env_for("?foo=duhget", "REQUEST_METHOD" => 'POST', :input => "foo=duhpost")
    req1 = make_request(e)
    req1.GET.must_equal 'foo' => 'duhget'
    req1.POST.must_equal 'foo' => 'duhpost'
    req1.params.must_equal 'foo' => 'duhpost'
    req1.update_param 'foo', 'bar'
    req1.GET.must_equal 'foo' => 'bar'
    req1.POST.must_equal 'foo' => 'bar'
    req1.params.must_equal 'foo' => 'bar'
    req2 = make_request(e)
    req2.GET.must_equal 'foo' => 'bar'
    req2.POST.must_equal 'foo' => 'bar'
    req2.params.must_equal 'foo' => 'bar'
    req2.params.must_equal 'foo' => 'bar'
  end

  it "allow deleting from params hash if param is in GET" do
    e = Rack::MockRequest.env_for("?foo=bar")
    req1 = make_request(e)
    req1.params.must_equal 'foo' => 'bar'
    req1.delete_param('foo').must_equal 'bar'
    req1.params.must_equal({})
    req2 = make_request(e)
    req2.params.must_equal({})
  end

  it "allow deleting from params hash if param is in POST" do
    e = Rack::MockRequest.env_for("", "REQUEST_METHOD" => 'POST', :input => 'foo=bar')
    req1 = make_request(e)
    req1.params.must_equal 'foo' => 'bar'
    req1.delete_param('foo').must_equal 'bar'
    req1.params.must_equal({})
    req2 = make_request(e)
    req2.params.must_equal({})
  end

  it "pass through non-uri escaped cookies as-is" do
    req = make_request Rack::MockRequest.env_for("", "HTTP_COOKIE" => "foo=%")
    req.cookies["foo"].must_equal "%"
  end

  it "parse cookies according to RFC 2109" do
    req = make_request \
      Rack::MockRequest.env_for('', 'HTTP_COOKIE' => 'foo=bar;foo=car')
    req.cookies.must_equal 'foo' => 'bar'
  end

  it 'parse cookies with quotes' do
    req = make_request Rack::MockRequest.env_for('', {
      'HTTP_COOKIE' => '$Version="1"; Customer="WILE_E_COYOTE"; $Path="/acme"; Part_Number="Rocket_Launcher_0001"; $Path="/acme"'
    })
    req.cookies.must_equal({
      '$Version'    => '"1"',
      'Customer'    => '"WILE_E_COYOTE"',
      '$Path'       => '"/acme"',
      'Part_Number' => '"Rocket_Launcher_0001"',
    })
  end

  it "provide setters" do
    req = make_request(e=Rack::MockRequest.env_for(""))
    req.script_name.must_equal ""
    req.script_name = "/foo"
    req.script_name.must_equal "/foo"
    e["SCRIPT_NAME"].must_equal "/foo"

    req.path_info.must_equal "/"
    req.path_info = "/foo"
    req.path_info.must_equal "/foo"
    e["PATH_INFO"].must_equal "/foo"
  end

  it "provide the original env" do
    req = make_request(e = Rack::MockRequest.env_for(""))
    req.env.must_equal e
  end

  it "restore the base URL" do
    make_request(Rack::MockRequest.env_for("")).base_url.
      must_equal "http://example.org"
    make_request(Rack::MockRequest.env_for("", "SCRIPT_NAME" => "/foo")).base_url.
      must_equal "http://example.org"
  end

  it "restore the URL" do
    make_request(Rack::MockRequest.env_for("")).url.
      must_equal "http://example.org/"
    make_request(Rack::MockRequest.env_for("", "SCRIPT_NAME" => "/foo")).url.
      must_equal "http://example.org/foo/"
    make_request(Rack::MockRequest.env_for("/foo")).url.
      must_equal "http://example.org/foo"
    make_request(Rack::MockRequest.env_for("?foo")).url.
      must_equal "http://example.org/?foo"
    make_request(Rack::MockRequest.env_for("http://example.org:8080/")).url.
      must_equal "http://example.org:8080/"
    make_request(Rack::MockRequest.env_for("https://example.org/")).url.
      must_equal "https://example.org/"
    make_request(Rack::MockRequest.env_for("coffee://example.org/")).url.
      must_equal "coffee://example.org/"
    make_request(Rack::MockRequest.env_for("coffee://example.org:443/")).url.
      must_equal "coffee://example.org:443/"
    make_request(Rack::MockRequest.env_for("https://example.com:8080/foo?foo")).url.
      must_equal "https://example.com:8080/foo?foo"
  end

  it "restore the full path" do
    make_request(Rack::MockRequest.env_for("")).fullpath.
      must_equal "/"
    make_request(Rack::MockRequest.env_for("", "SCRIPT_NAME" => "/foo")).fullpath.
      must_equal "/foo/"
    make_request(Rack::MockRequest.env_for("/foo")).fullpath.
      must_equal "/foo"
    make_request(Rack::MockRequest.env_for("?foo")).fullpath.
      must_equal "/?foo"
    make_request(Rack::MockRequest.env_for("http://example.org:8080/")).fullpath.
      must_equal "/"
    make_request(Rack::MockRequest.env_for("https://example.org/")).fullpath.
      must_equal "/"

    make_request(Rack::MockRequest.env_for("https://example.com:8080/foo?foo")).fullpath.
     must_equal "/foo?foo"
  end

  it "handle multiple media type parameters" do
    req = make_request \
      Rack::MockRequest.env_for("/",
        "CONTENT_TYPE" => 'text/plain; foo=BAR,baz=bizzle dizzle;BLING=bam;blong="boo";zump="zoo\"o";weird=lol"')
      req.wont_be :form_data?
      req.media_type_params.must_include 'foo'
      req.media_type_params['foo'].must_equal 'BAR'
      req.media_type_params.must_include 'baz'
      req.media_type_params['baz'].must_equal 'bizzle dizzle'
      req.media_type_params.wont_include 'BLING'
      req.media_type_params.must_include 'bling'
      req.media_type_params['bling'].must_equal 'bam'
      req.media_type_params['blong'].must_equal 'boo'
      req.media_type_params['zump'].must_equal 'zoo\"o'
      req.media_type_params['weird'].must_equal 'lol"'
  end

  it "parse with junk before boundary" do
    # Adapted from RFC 1867.
    input = <<EOF
blah blah\r
\r
--AaB03x\r
content-disposition: form-data; name="reply"\r
\r
yes\r
--AaB03x\r
content-disposition: form-data; name="fileupload"; filename="dj.jpg"\r
Content-Type: image/jpeg\r
Content-Transfer-Encoding: base64\r
\r
/9j/4AAQSkZJRgABAQAAAQABAAD//gA+Q1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkcg\r
--AaB03x--\r
EOF
    req = make_request Rack::MockRequest.env_for("/",
                      "CONTENT_TYPE" => "multipart/form-data, boundary=AaB03x",
                      "CONTENT_LENGTH" => input.size,
                      :input => input)

    req.POST.must_include "fileupload"
    req.POST.must_include "reply"

    req.must_be :form_data?
    req.content_length.must_equal input.size
    req.media_type.must_equal 'multipart/form-data'
    req.media_type_params.must_include 'boundary'
    req.media_type_params['boundary'].must_equal 'AaB03x'

    req.POST["reply"].must_equal "yes"

    f = req.POST["fileupload"]
    f.must_be_kind_of Hash
    f[:type].must_equal "image/jpeg"
    f[:filename].must_equal "dj.jpg"
    f.must_include :tempfile
    f[:tempfile].size.must_equal 76
  end

  it "not infinite loop with a malformed HTTP request" do
    # Adapted from RFC 1867.
    input = <<EOF
--AaB03x
content-disposition: form-data; name="reply"

yes
--AaB03x
content-disposition: form-data; name="fileupload"; filename="dj.jpg"
Content-Type: image/jpeg
Content-Transfer-Encoding: base64

/9j/4AAQSkZJRgABAQAAAQABAAD//gA+Q1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkcg
--AaB03x--
EOF
    req = make_request Rack::MockRequest.env_for("/",
                      "CONTENT_TYPE" => "multipart/form-data, boundary=AaB03x",
                      "CONTENT_LENGTH" => input.size,
                      :input => input)

    lambda{req.POST}.must_raise EOFError
  end


  it "parse multipart form data" do
    # Adapted from RFC 1867.
    input = <<EOF
--AaB03x\r
content-disposition: form-data; name="reply"\r
\r
yes\r
--AaB03x\r
content-disposition: form-data; name="fileupload"; filename="dj.jpg"\r
Content-Type: image/jpeg\r
Content-Transfer-Encoding: base64\r
\r
/9j/4AAQSkZJRgABAQAAAQABAAD//gA+Q1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkcg\r
--AaB03x--\r
EOF
    req = make_request Rack::MockRequest.env_for("/",
                      "CONTENT_TYPE" => "multipart/form-data, boundary=AaB03x",
                      "CONTENT_LENGTH" => input.size,
                      :input => input)

    req.POST.must_include "fileupload"
    req.POST.must_include "reply"

    req.must_be :form_data?
    req.content_length.must_equal input.size
    req.media_type.must_equal 'multipart/form-data'
    req.media_type_params.must_include 'boundary'
    req.media_type_params['boundary'].must_equal 'AaB03x'

    req.POST["reply"].must_equal "yes"

    f = req.POST["fileupload"]
    f.must_be_kind_of Hash
    f[:type].must_equal "image/jpeg"
    f[:filename].must_equal "dj.jpg"
    f.must_include :tempfile
    f[:tempfile].size.must_equal 76
  end

  it "MultipartPartLimitError when request has too many multipart parts if limit set" do
    begin
      data = 10000.times.map { "--AaB03x\r\nContent-Type: text/plain\r\nContent-Disposition: attachment; name=#{SecureRandom.hex(10)}; filename=#{SecureRandom.hex(10)}\r\n\r\ncontents\r\n" }.join("\r\n")
      data += "--AaB03x--\r"

      options = {
        "CONTENT_TYPE" => "multipart/form-data; boundary=AaB03x",
        "CONTENT_LENGTH" => data.length.to_s,
        :input => StringIO.new(data)
      }

      request = make_request Rack::MockRequest.env_for("/", options)
      lambda { request.POST }.must_raise Rack::Multipart::MultipartPartLimitError
    end
  end

  it 'closes tempfiles it created in the case of too many created' do
    begin
      data = 10000.times.map { "--AaB03x\r\nContent-Type: text/plain\r\nContent-Disposition: attachment; name=#{SecureRandom.hex(10)}; filename=#{SecureRandom.hex(10)}\r\n\r\ncontents\r\n" }.join("\r\n")
      data += "--AaB03x--\r"

      files = []
      options = {
        "CONTENT_TYPE" => "multipart/form-data; boundary=AaB03x",
        "CONTENT_LENGTH" => data.length.to_s,
        Rack::RACK_MULTIPART_TEMPFILE_FACTORY => lambda { |filename, content_type|
          file = Tempfile.new(["RackMultipart", ::File.extname(filename)])
          files << file
          file
        },
        :input => StringIO.new(data)
      }

      request = make_request Rack::MockRequest.env_for("/", options)
      assert_raises(Rack::Multipart::MultipartPartLimitError) do
        request.POST
      end
      refute_predicate files, :empty?
      files.each { |f| assert_predicate f, :closed? }
    end
  end

  it "parse big multipart form data" do
    input = <<EOF
--AaB03x\r
content-disposition: form-data; name="huge"; filename="huge"\r
\r
#{"x"*32768}\r
--AaB03x\r
content-disposition: form-data; name="mean"; filename="mean"\r
\r
--AaB03xha\r
--AaB03x--\r
EOF
    req = make_request Rack::MockRequest.env_for("/",
                      "CONTENT_TYPE" => "multipart/form-data, boundary=AaB03x",
                      "CONTENT_LENGTH" => input.size,
                      :input => input)

    req.POST["huge"][:tempfile].size.must_equal 32768
    req.POST["mean"][:tempfile].size.must_equal 10
    req.POST["mean"][:tempfile].read.must_equal "--AaB03xha"
  end

  it "record tempfiles from multipart form data in env[rack.tempfiles]" do
    input = <<EOF
--AaB03x\r
content-disposition: form-data; name="fileupload"; filename="foo.jpg"\r
Content-Type: image/jpeg\r
Content-Transfer-Encoding: base64\r
\r
/9j/4AAQSkZJRgABAQAAAQABAAD//gA+Q1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkcg\r
--AaB03x\r
content-disposition: form-data; name="fileupload"; filename="bar.jpg"\r
Content-Type: image/jpeg\r
Content-Transfer-Encoding: base64\r
\r
/9j/4AAQSkZJRgABAQAAAQABAAD//gA+Q1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkcg\r
--AaB03x--\r
EOF
    env = Rack::MockRequest.env_for("/",
                          "CONTENT_TYPE" => "multipart/form-data, boundary=AaB03x",
                          "CONTENT_LENGTH" => input.size,
                          :input => input)
    req = make_request(env)
    req.params
    env['rack.tempfiles'].size.must_equal 2
  end

  it "detect invalid multipart form data" do
    input = <<EOF
--AaB03x\r
content-disposition: form-data; name="huge"; filename="huge"\r
EOF
    req = make_request Rack::MockRequest.env_for("/",
                      "CONTENT_TYPE" => "multipart/form-data, boundary=AaB03x",
                      "CONTENT_LENGTH" => input.size,
                      :input => input)

    lambda { req.POST }.must_raise EOFError

    input = <<EOF
--AaB03x\r
content-disposition: form-data; name="huge"; filename="huge"\r
\r
foo\r
EOF
    req = make_request Rack::MockRequest.env_for("/",
                      "CONTENT_TYPE" => "multipart/form-data, boundary=AaB03x",
                      "CONTENT_LENGTH" => input.size,
                      :input => input)

    lambda { req.POST }.must_raise EOFError

    input = <<EOF
--AaB03x\r
content-disposition: form-data; name="huge"; filename="huge"\r
\r
foo\r
EOF
    req = make_request Rack::MockRequest.env_for("/",
                      "CONTENT_TYPE" => "multipart/form-data, boundary=AaB03x",
                      "CONTENT_LENGTH" => input.size,
                      :input => input)

    lambda { req.POST }.must_raise EOFError
  end

  it "consistently raise EOFError on bad multipart form data" do
    input = <<EOF
--AaB03x\r
content-disposition: form-data; name="huge"; filename="huge"\r
EOF
    req = make_request Rack::MockRequest.env_for("/",
                      "CONTENT_TYPE" => "multipart/form-data, boundary=AaB03x",
                      "CONTENT_LENGTH" => input.size,
                      :input => input)

    lambda { req.POST }.must_raise EOFError
    lambda { req.POST }.must_raise EOFError
  end

  it "correctly parse the part name from Content-Id header" do
    input = <<EOF
--AaB03x\r
Content-Type: text/xml; charset=utf-8\r
Content-Id: <soap-start>\r
Content-Transfer-Encoding: 7bit\r
\r
foo\r
--AaB03x--\r
EOF
    req = make_request Rack::MockRequest.env_for("/",
                      "CONTENT_TYPE" => "multipart/related, boundary=AaB03x",
                      "CONTENT_LENGTH" => input.size,
                      :input => input)

    req.params.keys.must_equal ["<soap-start>"]
  end

  it "not try to interpret binary as utf8" do
        input = <<EOF
--AaB03x\r
content-disposition: form-data; name="fileupload"; filename="junk.a"\r
content-type: application/octet-stream\r
\r
#{[0x36,0xCF,0x0A,0xF8].pack('c*')}\r
--AaB03x--\r
EOF

        req = make_request Rack::MockRequest.env_for("/",
                          "CONTENT_TYPE" => "multipart/form-data, boundary=AaB03x",
                          "CONTENT_LENGTH" => input.size,
                          :input => input)

    req.POST["fileupload"][:tempfile].size.must_equal 4
  end

  it "use form_hash when form_input is a Tempfile" do
    input = "{foo: 'bar'}"

    rack_input = Tempfile.new("rackspec")
    rack_input.write(input)
    rack_input.rewind

    req = make_request Rack::MockRequest.env_for("/",
                      "rack.request.form_hash" => {'foo' => 'bar'},
                      "rack.request.form_input" => rack_input,
                      :input => rack_input)

    req.POST.must_equal req.env['rack.request.form_hash']
  end

  it "conform to the Rack spec" do
    app = lambda { |env|
      content = make_request(env).POST["file"].inspect
      size = content.bytesize
      [200, {"Content-Type" => "text/html", "Content-Length" => size.to_s}, [content]]
    }

    input = <<EOF
--AaB03x\r
content-disposition: form-data; name="reply"\r
\r
yes\r
--AaB03x\r
content-disposition: form-data; name="fileupload"; filename="dj.jpg"\r
Content-Type: image/jpeg\r
Content-Transfer-Encoding: base64\r
\r
/9j/4AAQSkZJRgABAQAAAQABAAD//gA+Q1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkcg\r
--AaB03x--\r
EOF
    input.force_encoding(Encoding::ASCII_8BIT)
    res = Rack::MockRequest.new(Rack::Lint.new(app)).get "/",
      "CONTENT_TYPE" => "multipart/form-data, boundary=AaB03x",
      "CONTENT_LENGTH" => input.size.to_s, "rack.input" => StringIO.new(input)

    res.must_be :ok?
  end

  it "parse Accept-Encoding correctly" do
    parser = lambda do |x|
      make_request(Rack::MockRequest.env_for("", "HTTP_ACCEPT_ENCODING" => x)).accept_encoding
    end

    parser.call(nil).must_equal []

    parser.call("compress, gzip").must_equal [["compress", 1.0], ["gzip", 1.0]]
    parser.call("").must_equal []
    parser.call("*").must_equal [["*", 1.0]]
    parser.call("compress;q=0.5, gzip;q=1.0").must_equal [["compress", 0.5], ["gzip", 1.0]]
    parser.call("gzip;q=1.0, identity; q=0.5, *;q=0").must_equal [["gzip", 1.0], ["identity", 0.5], ["*", 0] ]

    parser.call("gzip ; q=0.9").must_equal [["gzip", 0.9]]
    parser.call("gzip ; deflate").must_equal [["gzip", 1.0]]
  end

  it "parse Accept-Language correctly" do
    parser = lambda do |x|
      make_request(Rack::MockRequest.env_for("", "HTTP_ACCEPT_LANGUAGE" => x)).accept_language
    end

    parser.call(nil).must_equal []

    parser.call("fr, en").must_equal [["fr", 1.0], ["en", 1.0]]
    parser.call("").must_equal []
    parser.call("*").must_equal [["*", 1.0]]
    parser.call("fr;q=0.5, en;q=1.0").must_equal [["fr", 0.5], ["en", 1.0]]
    parser.call("fr;q=1.0, en; q=0.5, *;q=0").must_equal [["fr", 1.0], ["en", 0.5], ["*", 0] ]

    parser.call("fr ; q=0.9").must_equal [["fr", 0.9]]
    parser.call("fr").must_equal [["fr", 1.0]]
  end

  def ip_app
    lambda { |env|
      request = make_request(env)
      response = Rack::Response.new
      response.write request.ip
      response.finish
    }
  end

  it 'provide ip information' do
    mock = Rack::MockRequest.new(Rack::Lint.new(ip_app))

    res = mock.get '/', 'REMOTE_ADDR' => '1.2.3.4'
    res.body.must_equal '1.2.3.4'

    res = mock.get '/', 'REMOTE_ADDR' => 'fe80::202:b3ff:fe1e:8329'
    res.body.must_equal 'fe80::202:b3ff:fe1e:8329'

    res = mock.get '/', 'REMOTE_ADDR' => '1.2.3.4,3.4.5.6'
    res.body.must_equal '1.2.3.4'
  end

  it 'deals with proxies' do
    mock = Rack::MockRequest.new(Rack::Lint.new(ip_app))

    res = mock.get '/',
      'REMOTE_ADDR' => '1.2.3.4',
      'HTTP_X_FORWARDED_FOR' => '3.4.5.6'
    res.body.must_equal '1.2.3.4'

    res = mock.get '/',
      'REMOTE_ADDR' => '1.2.3.4',
      'HTTP_X_FORWARDED_FOR' => 'unknown'
    res.body.must_equal '1.2.3.4'

    res = mock.get '/',
      'REMOTE_ADDR' => '127.0.0.1',
      'HTTP_X_FORWARDED_FOR' => '3.4.5.6'
    res.body.must_equal '3.4.5.6'

    res = mock.get '/', 'HTTP_X_FORWARDED_FOR' => 'unknown,3.4.5.6'
    res.body.must_equal '3.4.5.6'

    res = mock.get '/', 'HTTP_X_FORWARDED_FOR' => '192.168.0.1,3.4.5.6'
    res.body.must_equal '3.4.5.6'

    res = mock.get '/', 'HTTP_X_FORWARDED_FOR' => '10.0.0.1,3.4.5.6'
    res.body.must_equal '3.4.5.6'

    res = mock.get '/', 'HTTP_X_FORWARDED_FOR' => '10.0.0.1, 10.0.0.1, 3.4.5.6'
    res.body.must_equal '3.4.5.6'

    res = mock.get '/', 'HTTP_X_FORWARDED_FOR' => '127.0.0.1, 3.4.5.6'
    res.body.must_equal '3.4.5.6'

    res = mock.get '/', 'HTTP_X_FORWARDED_FOR' => 'unknown,192.168.0.1'
    res.body.must_equal 'unknown'

    res = mock.get '/', 'HTTP_X_FORWARDED_FOR' => 'other,unknown,192.168.0.1'
    res.body.must_equal 'unknown'

    res = mock.get '/', 'HTTP_X_FORWARDED_FOR' => 'unknown,localhost,192.168.0.1'
    res.body.must_equal 'unknown'

    res = mock.get '/', 'HTTP_X_FORWARDED_FOR' => '9.9.9.9, 3.4.5.6, 10.0.0.1, 172.31.4.4'
    res.body.must_equal '3.4.5.6'

    res = mock.get '/', 'HTTP_X_FORWARDED_FOR' => '::1,2620:0:1c00:0:812c:9583:754b:ca11'
    res.body.must_equal '2620:0:1c00:0:812c:9583:754b:ca11'

    res = mock.get '/', 'HTTP_X_FORWARDED_FOR' => '2620:0:1c00:0:812c:9583:754b:ca11,::1'
    res.body.must_equal '2620:0:1c00:0:812c:9583:754b:ca11'

    res = mock.get '/', 'HTTP_X_FORWARDED_FOR' => 'fd5b:982e:9130:247f:0000:0000:0000:0000,2620:0:1c00:0:812c:9583:754b:ca11'
    res.body.must_equal '2620:0:1c00:0:812c:9583:754b:ca11'

    res = mock.get '/', 'HTTP_X_FORWARDED_FOR' => '2620:0:1c00:0:812c:9583:754b:ca11,fd5b:982e:9130:247f:0000:0000:0000:0000'
    res.body.must_equal '2620:0:1c00:0:812c:9583:754b:ca11'

    res = mock.get '/',
      'HTTP_X_FORWARDED_FOR' => '1.1.1.1, 127.0.0.1',
      'HTTP_CLIENT_IP' => '1.1.1.1'
    res.body.must_equal '1.1.1.1'

    res = mock.get '/', 'HTTP_X_FORWARDED_FOR' => '8.8.8.8, 9.9.9.9'
    res.body.must_equal '9.9.9.9'

    res = mock.get '/', 'HTTP_X_FORWARDED_FOR' => '8.8.8.8, fe80::202:b3ff:fe1e:8329'
    res.body.must_equal 'fe80::202:b3ff:fe1e:8329'

    # Unix Sockets
    res = mock.get '/',
      'REMOTE_ADDR' => 'unix',
      'HTTP_X_FORWARDED_FOR' => '3.4.5.6'
    res.body.must_equal '3.4.5.6'

    res = mock.get '/',
      'REMOTE_ADDR' => 'unix:/tmp/foo',
      'HTTP_X_FORWARDED_FOR' => '3.4.5.6'
    res.body.must_equal '3.4.5.6'
  end

  it "not allow IP spoofing via Client-IP and X-Forwarded-For headers" do
    mock = Rack::MockRequest.new(Rack::Lint.new(ip_app))

    # IP Spoofing attempt:
    # Client sends          X-Forwarded-For: 6.6.6.6
    #                       Client-IP: 6.6.6.6
    # Load balancer adds    X-Forwarded-For: 2.2.2.3, 192.168.0.7
    # App receives:         X-Forwarded-For: 6.6.6.6
    #                       X-Forwarded-For: 2.2.2.3, 192.168.0.7
    #                       Client-IP: 6.6.6.6
    # Rack env:             HTTP_X_FORWARDED_FOR: '6.6.6.6, 2.2.2.3, 192.168.0.7'
    #                       HTTP_CLIENT_IP: '6.6.6.6'
    res = mock.get '/',
      'HTTP_X_FORWARDED_FOR' => '6.6.6.6, 2.2.2.3, 192.168.0.7',
      'HTTP_CLIENT_IP' => '6.6.6.6'
    res.body.must_equal '2.2.2.3'
  end

  it "regard local addresses as proxies" do
    req = make_request(Rack::MockRequest.env_for("/"))
    req.trusted_proxy?('127.0.0.1').must_equal 0
    req.trusted_proxy?('10.0.0.1').must_equal 0
    req.trusted_proxy?('172.16.0.1').must_equal 0
    req.trusted_proxy?('172.20.0.1').must_equal 0
    req.trusted_proxy?('172.30.0.1').must_equal 0
    req.trusted_proxy?('172.31.0.1').must_equal 0
    req.trusted_proxy?('192.168.0.1').must_equal 0
    req.trusted_proxy?('::1').must_equal 0
    req.trusted_proxy?('fd00::').must_equal 0
    req.trusted_proxy?('localhost').must_equal 0
    req.trusted_proxy?('unix').must_equal 0
    req.trusted_proxy?('unix:/tmp/sock').must_equal 0

    req.trusted_proxy?("unix.example.org").must_be_nil
    req.trusted_proxy?("example.org\n127.0.0.1").must_be_nil
    req.trusted_proxy?("127.0.0.1\nexample.org").must_be_nil
    req.trusted_proxy?("11.0.0.1").must_be_nil
    req.trusted_proxy?("172.15.0.1").must_be_nil
    req.trusted_proxy?("172.32.0.1").must_be_nil
    req.trusted_proxy?("2001:470:1f0b:18f8::1").must_be_nil
  end

  it "sets the default session to an empty hash" do
    req = make_request(Rack::MockRequest.env_for("http://example.com:8080/"))
    assert_equal Hash.new, req.session
  end

  class MyRequest < Rack::Request
    def params
      {:foo => "bar"}
    end
  end

  it "allow subclass request to be instantiated after parent request" do
    env = Rack::MockRequest.env_for("/?foo=bar")

    req1 = make_request(env)
    req1.GET.must_equal "foo" => "bar"
    req1.params.must_equal "foo" => "bar"

    req2 = MyRequest.new(env)
    req2.GET.must_equal "foo" => "bar"
    req2.params.must_equal :foo => "bar"
  end

  it "allow parent request to be instantiated after subclass request" do
    env = Rack::MockRequest.env_for("/?foo=bar")

    req1 = MyRequest.new(env)
    req1.GET.must_equal "foo" => "bar"
    req1.params.must_equal :foo => "bar"

    req2 = make_request(env)
    req2.GET.must_equal "foo" => "bar"
    req2.params.must_equal "foo" => "bar"
  end

  it "raise TypeError every time if request parameters are broken" do
    broken_query = Rack::MockRequest.env_for("/?foo%5B%5D=0&foo%5Bbar%5D=1")
    req = make_request(broken_query)
    lambda{req.GET}.must_raise TypeError
    lambda{req.params}.must_raise TypeError
  end

  (0x20...0x7E).collect { |a|
    b = a.chr
    c = CGI.escape(b)
    it "not strip '#{a}' => '#{c}' => '#{b}' escaped character from parameters when accessed as string" do
      url = "/?foo=#{c}bar#{c}"
      env = Rack::MockRequest.env_for(url)
      req2 = make_request(env)
      req2.GET.must_equal "foo" => "#{b}bar#{b}"
      req2.params.must_equal "foo" => "#{b}bar#{b}"
    end
  }

  class NonDelegate < Rack::Request
    def delegate?; false; end
  end

  def make_request(env)
    NonDelegate.new env
  end

  class TestProxyRequest < RackRequestTest
    class DelegateRequest
      include Rack::Request::Helpers
      extend Forwardable

      def_delegators :@req, :has_header?, :get_header, :fetch_header,
        :each_header, :set_header, :add_header, :delete_header

      def_delegators :@req, :[], :[]=, :values_at

      def initialize(req)
        @req = req
      end

      def delegate?; true; end

      def env; @req.env.dup; end
    end

    def make_request(env)
      DelegateRequest.new super(env)
    end
  end
end

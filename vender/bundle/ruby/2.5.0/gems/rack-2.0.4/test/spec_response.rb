require 'minitest/autorun'
require 'rack'
require 'rack/response'
require 'stringio'

describe Rack::Response do
  it 'has cache-control methods' do
    response = Rack::Response.new
    cc = 'foo'
    response.cache_control = cc
    assert_equal cc, response.cache_control
    assert_equal cc, response.to_a[2]['Cache-Control']
  end

  it 'has an etag method' do
    response = Rack::Response.new
    etag = 'foo'
    response.etag = etag
    assert_equal etag, response.etag
    assert_equal etag, response.to_a[2]['ETag']
  end

  it "have sensible default values" do
    response = Rack::Response.new
    status, header, body = response.finish
    status.must_equal 200
    header.must_equal({})
    body.each { |part|
      part.must_equal ""
    }

    response = Rack::Response.new
    status, header, body = *response
    status.must_equal 200
    header.must_equal({})
    body.each { |part|
      part.must_equal ""
    }
  end

  it "can be written to" do
    response = Rack::Response.new

    _, _, body = response.finish do
      response.write "foo"
      response.write "bar"
      response.write "baz"
    end

    parts = []
    body.each { |part| parts << part }

    parts.must_equal ["foo", "bar", "baz"]
  end

  it "can set and read headers" do
    response = Rack::Response.new
    response["Content-Type"].must_be_nil
    response["Content-Type"] = "text/plain"
    response["Content-Type"].must_equal "text/plain"
  end

  it "can override the initial Content-Type with a different case" do
    response = Rack::Response.new("", 200, "content-type" => "text/plain")
    response["Content-Type"].must_equal "text/plain"
  end

  it "can set cookies" do
    response = Rack::Response.new

    response.set_cookie "foo", "bar"
    response["Set-Cookie"].must_equal "foo=bar"
    response.set_cookie "foo2", "bar2"
    response["Set-Cookie"].must_equal ["foo=bar", "foo2=bar2"].join("\n")
    response.set_cookie "foo3", "bar3"
    response["Set-Cookie"].must_equal ["foo=bar", "foo2=bar2", "foo3=bar3"].join("\n")
  end

  it "can set cookies with the same name for multiple domains" do
    response = Rack::Response.new
    response.set_cookie "foo", {:value => "bar", :domain => "sample.example.com"}
    response.set_cookie "foo", {:value => "bar", :domain => ".example.com"}
    response["Set-Cookie"].must_equal ["foo=bar; domain=sample.example.com", "foo=bar; domain=.example.com"].join("\n")
  end

  it "formats the Cookie expiration date accordingly to RFC 6265" do
    response = Rack::Response.new

    response.set_cookie "foo", {:value => "bar", :expires => Time.now+10}
    response["Set-Cookie"].must_match(
      /expires=..., \d\d ... \d\d\d\d \d\d:\d\d:\d\d .../)
  end

  it "can set secure cookies" do
    response = Rack::Response.new
    response.set_cookie "foo", {:value => "bar", :secure => true}
    response["Set-Cookie"].must_equal "foo=bar; secure"
  end

  it "can set http only cookies" do
    response = Rack::Response.new
    response.set_cookie "foo", {:value => "bar", :httponly => true}
    response["Set-Cookie"].must_equal "foo=bar; HttpOnly"
  end

  it "can set http only cookies with :http_only" do
    response = Rack::Response.new
    response.set_cookie "foo", {:value => "bar", :http_only => true}
    response["Set-Cookie"].must_equal "foo=bar; HttpOnly"
  end

  it "can set prefers :httponly for http only cookie setting when :httponly and :http_only provided" do
    response = Rack::Response.new
    response.set_cookie "foo", {:value => "bar", :httponly => false, :http_only => true}
    response["Set-Cookie"].must_equal "foo=bar"
  end

  it "can set SameSite cookies with symbol value :lax" do
    response = Rack::Response.new
    response.set_cookie "foo", {:value => "bar", :same_site => :lax}
    response["Set-Cookie"].must_equal "foo=bar; SameSite=Lax"
  end

  it "can set SameSite cookies with symbol value :Lax" do
    response = Rack::Response.new
    response.set_cookie "foo", {:value => "bar", :same_site => :lax}
    response["Set-Cookie"].must_equal "foo=bar; SameSite=Lax"
  end

  it "can set SameSite cookies with string value 'Lax'" do
    response = Rack::Response.new
    response.set_cookie "foo", {:value => "bar", :same_site => "Lax"}
    response["Set-Cookie"].must_equal "foo=bar; SameSite=Lax"
  end

  it "can set SameSite cookies with boolean value true" do
    response = Rack::Response.new
    response.set_cookie "foo", {:value => "bar", :same_site => true}
    response["Set-Cookie"].must_equal "foo=bar; SameSite=Strict"
  end

  it "can set SameSite cookies with symbol value :strict" do
    response = Rack::Response.new
    response.set_cookie "foo", {:value => "bar", :same_site => :strict}
    response["Set-Cookie"].must_equal "foo=bar; SameSite=Strict"
  end

  it "can set SameSite cookies with symbol value :Strict" do
    response = Rack::Response.new
    response.set_cookie "foo", {:value => "bar", :same_site => :Strict}
    response["Set-Cookie"].must_equal "foo=bar; SameSite=Strict"
  end

  it "can set SameSite cookies with string value 'Strict'" do
    response = Rack::Response.new
    response.set_cookie "foo", {:value => "bar", :same_site => "Strict"}
    response["Set-Cookie"].must_equal "foo=bar; SameSite=Strict"
  end

  it "validates the SameSite option value" do
    response = Rack::Response.new
    lambda {
      response.set_cookie "foo", {:value => "bar", :same_site => "Foo"}
    }.must_raise(ArgumentError).
      message.must_match(/Invalid SameSite value: "Foo"/)
  end

  it "can set SameSite cookies with symbol value" do
    response = Rack::Response.new
    response.set_cookie "foo", {:value => "bar", :same_site => :Strict}
    response["Set-Cookie"].must_equal "foo=bar; SameSite=Strict"
  end

  [ nil, false ].each do |non_truthy|
    it "omits SameSite attribute given a #{non_truthy.inspect} value" do
      response = Rack::Response.new
      response.set_cookie "foo", {:value => "bar", :same_site => non_truthy}
      response["Set-Cookie"].must_equal "foo=bar"
    end
  end

  it "can delete cookies" do
    response = Rack::Response.new
    response.set_cookie "foo", "bar"
    response.set_cookie "foo2", "bar2"
    response.delete_cookie "foo"
    response["Set-Cookie"].must_equal [
      "foo2=bar2",
      "foo=; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000"
    ].join("\n")
  end

  it "can delete cookies with the same name from multiple domains" do
    response = Rack::Response.new
    response.set_cookie "foo", {:value => "bar", :domain => "sample.example.com"}
    response.set_cookie "foo", {:value => "bar", :domain => ".example.com"}
    response["Set-Cookie"].must_equal ["foo=bar; domain=sample.example.com", "foo=bar; domain=.example.com"].join("\n")
    response.delete_cookie "foo", :domain => ".example.com"
    response["Set-Cookie"].must_equal ["foo=bar; domain=sample.example.com", "foo=; domain=.example.com; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000"].join("\n")
    response.delete_cookie "foo", :domain => "sample.example.com"
    response["Set-Cookie"].must_equal ["foo=; domain=.example.com; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000",
                                         "foo=; domain=sample.example.com; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000"].join("\n")
  end

  it "can delete cookies with the same name with different paths" do
    response = Rack::Response.new
    response.set_cookie "foo", {:value => "bar", :path => "/"}
    response.set_cookie "foo", {:value => "bar", :path => "/path"}
    response["Set-Cookie"].must_equal ["foo=bar; path=/",
                                         "foo=bar; path=/path"].join("\n")

    response.delete_cookie "foo", :path => "/path"
    response["Set-Cookie"].must_equal ["foo=bar; path=/",
                                         "foo=; path=/path; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000"].join("\n")
  end

  it "can do redirects" do
    response = Rack::Response.new
    response.redirect "/foo"
    status, header, body = response.finish
    status.must_equal 302
    header["Location"].must_equal "/foo"

    response = Rack::Response.new
    response.redirect "/foo", 307
    status, header, body = response.finish

    status.must_equal 307
  end

  it "has a useful constructor" do
    r = Rack::Response.new("foo")
    status, header, body = r.finish
    str = ""; body.each { |part| str << part }
    str.must_equal "foo"

    r = Rack::Response.new(["foo", "bar"])
    status, header, body = r.finish
    str = ""; body.each { |part| str << part }
    str.must_equal "foobar"

    object_with_each = Object.new
    def object_with_each.each
      yield "foo"
      yield "bar"
    end
    r = Rack::Response.new(object_with_each)
    r.write "foo"
    status, header, body = r.finish
    str = ""; body.each { |part| str << part }
    str.must_equal "foobarfoo"

    r = Rack::Response.new([], 500)
    r.status.must_equal 500

    r = Rack::Response.new([], "200 OK")
    r.status.must_equal 200
  end

  it "has a constructor that can take a block" do
    r = Rack::Response.new { |res|
      res.status = 404
      res.write "foo"
    }
    status, _, body = r.finish
    str = ""; body.each { |part| str << part }
    str.must_equal "foo"
    status.must_equal 404
  end

  it "doesn't return invalid responses" do
    r = Rack::Response.new(["foo", "bar"], 204)
    _, header, body = r.finish
    str = ""; body.each { |part| str << part }
    str.must_be :empty?
    header["Content-Type"].must_be_nil
    header['Content-Length'].must_be_nil

    lambda {
      Rack::Response.new(Object.new)
    }.must_raise(TypeError).
      message.must_match(/stringable or iterable required/)
  end

  it "knows if it's empty" do
    r = Rack::Response.new
    r.must_be :empty?
    r.write "foo"
    r.wont_be :empty?

    r = Rack::Response.new
    r.must_be :empty?
    r.finish
    r.must_be :empty?

    r = Rack::Response.new
    r.must_be :empty?
    r.finish { }
    r.wont_be :empty?
  end

  it "provide access to the HTTP status" do
    res = Rack::Response.new
    res.status = 200
    res.must_be :successful?
    res.must_be :ok?

    res.status = 201
    res.must_be :successful?
    res.must_be :created?

    res.status = 202
    res.must_be :successful?
    res.must_be :accepted?

    res.status = 204
    res.must_be :successful?
    res.must_be :no_content?

    res.status = 301
    res.must_be :redirect?
    res.must_be :moved_permanently?

    res.status = 302
    res.must_be :redirect?

    res.status = 303
    res.must_be :redirect?

    res.status = 307
    res.must_be :redirect?

    res.status = 308
    res.must_be :redirect?

    res.status = 400
    res.wont_be :successful?
    res.must_be :client_error?
    res.must_be :bad_request?

    res.status = 401
    res.wont_be :successful?
    res.must_be :client_error?
    res.must_be :unauthorized?

    res.status = 404
    res.wont_be :successful?
    res.must_be :client_error?
    res.must_be :not_found?

    res.status = 405
    res.wont_be :successful?
    res.must_be :client_error?
    res.must_be :method_not_allowed?

    res.status = 412
    res.wont_be :successful?
    res.must_be :client_error?
    res.must_be :precondition_failed?

    res.status = 422
    res.wont_be :successful?
    res.must_be :client_error?
    res.must_be :unprocessable?

    res.status = 501
    res.wont_be :successful?
    res.must_be :server_error?
  end

  it "provide access to the HTTP headers" do
    res = Rack::Response.new
    res["Content-Type"] = "text/yaml"

    res.must_include "Content-Type"
    res.headers["Content-Type"].must_equal "text/yaml"
    res["Content-Type"].must_equal "text/yaml"
    res.content_type.must_equal "text/yaml"
    res.content_length.must_be_nil
    res.location.must_be_nil
  end

  it "does not add or change Content-Length when #finish()ing" do
    res = Rack::Response.new
    res.status = 200
    res.finish
    res.headers["Content-Length"].must_be_nil

    res = Rack::Response.new
    res.status = 200
    res.headers["Content-Length"] = "10"
    res.finish
    res.headers["Content-Length"].must_equal "10"
  end

  it "updates Content-Length when body appended to using #write" do
    res = Rack::Response.new
    res.status = 200
    res.headers["Content-Length"].must_be_nil
    res.write "Hi"
    res.headers["Content-Length"].must_equal "2"
    res.write " there"
    res.headers["Content-Length"].must_equal "8"
  end

  it "calls close on #body" do
    res = Rack::Response.new
    res.body = StringIO.new
    res.close
    res.body.must_be :closed?
  end

  it "calls close on #body when 204 or 304" do
    res = Rack::Response.new
    res.body = StringIO.new
    res.finish
    res.body.wont_be :closed?

    res.status = 204
    _, _, b = res.finish
    res.body.must_be :closed?
    b.wont_equal res.body

    res.body = StringIO.new
    res.status = 205
    _, _, b = res.finish
    res.body.wont_be :closed?
    b.wont_equal res.body

    res.body = StringIO.new
    res.status = 304
    _, _, b = res.finish
    res.body.must_be :closed?
    b.wont_equal res.body
  end

  it "wraps the body from #to_ary to prevent infinite loops" do
    res = Rack::Response.new
    res.finish.last.wont_respond_to(:to_ary)
    lambda { res.finish.last.to_ary }.must_raise NoMethodError
  end
end

describe Rack::Response, 'headers' do
  before do
    @response = Rack::Response.new([], 200, { 'Foo' => '1' })
  end

  it 'has_header?' do
    lambda { @response.has_header? nil }.must_raise NoMethodError

    @response.has_header?('Foo').must_equal true
    @response.has_header?('foo').must_equal true
  end

  it 'get_header' do
    lambda { @response.get_header nil }.must_raise NoMethodError

    @response.get_header('Foo').must_equal '1'
    @response.get_header('foo').must_equal '1'
  end

  it 'set_header' do
    lambda { @response.set_header nil, '1' }.must_raise NoMethodError

    @response.set_header('Foo', '2').must_equal '2'
    @response.has_header?('Foo').must_equal true
    @response.get_header('Foo').must_equal('2')

    @response.set_header('Foo', nil).must_be_nil
    @response.has_header?('Foo').must_equal true
    @response.get_header('Foo').must_be_nil
  end

  it 'add_header' do
    lambda { @response.add_header nil, '1' }.must_raise NoMethodError

    # Add a value to an existing header
    @response.add_header('Foo', '2').must_equal '1,2'
    @response.get_header('Foo').must_equal '1,2'

    # Add nil to an existing header
    @response.add_header('Foo', nil).must_equal '1,2'
    @response.get_header('Foo').must_equal '1,2'

    # Add nil to a nonexistent header
    @response.add_header('Bar', nil).must_be_nil
    @response.has_header?('Bar').must_equal false
    @response.get_header('Bar').must_be_nil

    # Add a value to a nonexistent header
    @response.add_header('Bar', '1').must_equal '1'
    @response.has_header?('Bar').must_equal true
    @response.get_header('Bar').must_equal '1'
  end

  it 'delete_header' do
    lambda { @response.delete_header nil }.must_raise NoMethodError

    @response.delete_header('Foo').must_equal '1'
    (!!@response.has_header?('Foo')).must_equal false

    @response.delete_header('Foo').must_be_nil
    @response.has_header?('Foo').must_equal false

    @response.set_header('Foo', 1)
    @response.delete_header('foo').must_equal 1
    @response.has_header?('Foo').must_equal false
  end
end

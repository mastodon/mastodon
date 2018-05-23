require 'minitest/autorun'
require 'rack/urlmap'
require 'rack/mock'

describe Rack::URLMap do
  it "dispatches paths correctly" do
    app = lambda { |env|
      [200, {
        'X-ScriptName' => env['SCRIPT_NAME'],
        'X-PathInfo' => env['PATH_INFO'],
        'Content-Type' => 'text/plain'
      }, [""]]
    }
    map = Rack::Lint.new(Rack::URLMap.new({
      'http://foo.org/bar' => app,
      '/foo' => app,
      '/foo/bar' => app
    }))

    res = Rack::MockRequest.new(map).get("/")
    res.must_be :not_found?

    res = Rack::MockRequest.new(map).get("/qux")
    res.must_be :not_found?

    res = Rack::MockRequest.new(map).get("/foo")
    res.must_be :ok?
    res["X-ScriptName"].must_equal "/foo"
    res["X-PathInfo"].must_equal ""

    res = Rack::MockRequest.new(map).get("/foo/")
    res.must_be :ok?
    res["X-ScriptName"].must_equal "/foo"
    res["X-PathInfo"].must_equal "/"

    res = Rack::MockRequest.new(map).get("/foo/bar")
    res.must_be :ok?
    res["X-ScriptName"].must_equal "/foo/bar"
    res["X-PathInfo"].must_equal ""

    res = Rack::MockRequest.new(map).get("/foo/bar/")
    res.must_be :ok?
    res["X-ScriptName"].must_equal "/foo/bar"
    res["X-PathInfo"].must_equal "/"

    res = Rack::MockRequest.new(map).get("/foo///bar//quux")
    res.status.must_equal 200
    res.must_be :ok?
    res["X-ScriptName"].must_equal "/foo/bar"
    res["X-PathInfo"].must_equal "//quux"

    res = Rack::MockRequest.new(map).get("/foo/quux", "SCRIPT_NAME" => "/bleh")
    res.must_be :ok?
    res["X-ScriptName"].must_equal "/bleh/foo"
    res["X-PathInfo"].must_equal "/quux"

    res = Rack::MockRequest.new(map).get("/bar", 'HTTP_HOST' => 'foo.org')
    res.must_be :ok?
    res["X-ScriptName"].must_equal "/bar"
    res["X-PathInfo"].must_be :empty?

    res = Rack::MockRequest.new(map).get("/bar/", 'HTTP_HOST' => 'foo.org')
    res.must_be :ok?
    res["X-ScriptName"].must_equal "/bar"
    res["X-PathInfo"].must_equal '/'
  end


  it "dispatches hosts correctly" do
    map = Rack::Lint.new(Rack::URLMap.new("http://foo.org/" => lambda { |env|
                             [200,
                              { "Content-Type" => "text/plain",
                                "X-Position" => "foo.org",
                                "X-Host" => env["HTTP_HOST"] || env["SERVER_NAME"],
                              }, [""]]},
                           "http://subdomain.foo.org/" => lambda { |env|
                             [200,
                              { "Content-Type" => "text/plain",
                                "X-Position" => "subdomain.foo.org",
                                "X-Host" => env["HTTP_HOST"] || env["SERVER_NAME"],
                              }, [""]]},
                           "http://bar.org/" => lambda { |env|
                             [200,
                              { "Content-Type" => "text/plain",
                                "X-Position" => "bar.org",
                                "X-Host" => env["HTTP_HOST"] || env["SERVER_NAME"],
                              }, [""]]},
                           "/" => lambda { |env|
                             [200,
                              { "Content-Type" => "text/plain",
                                "X-Position" => "default.org",
                                "X-Host" => env["HTTP_HOST"] || env["SERVER_NAME"],
                              }, [""]]}
                           ))

    res = Rack::MockRequest.new(map).get("/")
    res.must_be :ok?
    res["X-Position"].must_equal "default.org"

    res = Rack::MockRequest.new(map).get("/", "HTTP_HOST" => "bar.org")
    res.must_be :ok?
    res["X-Position"].must_equal "bar.org"

    res = Rack::MockRequest.new(map).get("/", "HTTP_HOST" => "foo.org")
    res.must_be :ok?
    res["X-Position"].must_equal "foo.org"

    res = Rack::MockRequest.new(map).get("/", "HTTP_HOST" => "subdomain.foo.org", "SERVER_NAME" => "foo.org")
    res.must_be :ok?
    res["X-Position"].must_equal "subdomain.foo.org"

    res = Rack::MockRequest.new(map).get("http://foo.org/")
    res.must_be :ok?
    res["X-Position"].must_equal "foo.org"

    res = Rack::MockRequest.new(map).get("/", "HTTP_HOST" => "example.org")
    res.must_be :ok?
    res["X-Position"].must_equal "default.org"

    res = Rack::MockRequest.new(map).get("/",
                                         "HTTP_HOST" => "example.org:9292",
                                         "SERVER_PORT" => "9292")
    res.must_be :ok?
    res["X-Position"].must_equal "default.org"
  end

  it "be nestable" do
    map = Rack::Lint.new(Rack::URLMap.new("/foo" =>
      Rack::URLMap.new("/bar" =>
        Rack::URLMap.new("/quux" =>  lambda { |env|
                           [200,
                            { "Content-Type" => "text/plain",
                              "X-Position" => "/foo/bar/quux",
                              "X-PathInfo" => env["PATH_INFO"],
                              "X-ScriptName" => env["SCRIPT_NAME"],
                            }, [""]]}
                         ))))

    res = Rack::MockRequest.new(map).get("/foo/bar")
    res.must_be :not_found?

    res = Rack::MockRequest.new(map).get("/foo/bar/quux")
    res.must_be :ok?
    res["X-Position"].must_equal "/foo/bar/quux"
    res["X-PathInfo"].must_equal ""
    res["X-ScriptName"].must_equal "/foo/bar/quux"
  end

  it "route root apps correctly" do
    map = Rack::Lint.new(Rack::URLMap.new("/" => lambda { |env|
                             [200,
                              { "Content-Type" => "text/plain",
                                "X-Position" => "root",
                                "X-PathInfo" => env["PATH_INFO"],
                                "X-ScriptName" => env["SCRIPT_NAME"]
                              }, [""]]},
                           "/foo" => lambda { |env|
                             [200,
                              { "Content-Type" => "text/plain",
                                "X-Position" => "foo",
                                "X-PathInfo" => env["PATH_INFO"],
                                "X-ScriptName" => env["SCRIPT_NAME"]
                              }, [""]]}
                           ))

    res = Rack::MockRequest.new(map).get("/foo/bar")
    res.must_be :ok?
    res["X-Position"].must_equal "foo"
    res["X-PathInfo"].must_equal "/bar"
    res["X-ScriptName"].must_equal "/foo"

    res = Rack::MockRequest.new(map).get("/foo")
    res.must_be :ok?
    res["X-Position"].must_equal "foo"
    res["X-PathInfo"].must_equal ""
    res["X-ScriptName"].must_equal "/foo"

    res = Rack::MockRequest.new(map).get("/bar")
    res.must_be :ok?
    res["X-Position"].must_equal "root"
    res["X-PathInfo"].must_equal "/bar"
    res["X-ScriptName"].must_equal ""

    res = Rack::MockRequest.new(map).get("")
    res.must_be :ok?
    res["X-Position"].must_equal "root"
    res["X-PathInfo"].must_equal "/"
    res["X-ScriptName"].must_equal ""
  end

  it "not squeeze slashes" do
    map = Rack::Lint.new(Rack::URLMap.new("/" => lambda { |env|
                             [200,
                              { "Content-Type" => "text/plain",
                                "X-Position" => "root",
                                "X-PathInfo" => env["PATH_INFO"],
                                "X-ScriptName" => env["SCRIPT_NAME"]
                              }, [""]]},
                           "/foo" => lambda { |env|
                             [200,
                              { "Content-Type" => "text/plain",
                                "X-Position" => "foo",
                                "X-PathInfo" => env["PATH_INFO"],
                                "X-ScriptName" => env["SCRIPT_NAME"]
                              }, [""]]}
                           ))

    res = Rack::MockRequest.new(map).get("/http://example.org/bar")
    res.must_be :ok?
    res["X-Position"].must_equal "root"
    res["X-PathInfo"].must_equal "/http://example.org/bar"
    res["X-ScriptName"].must_equal ""
  end

  it "not be case sensitive with hosts" do
    map = Rack::Lint.new(Rack::URLMap.new("http://example.org/" => lambda { |env|
                             [200,
                              { "Content-Type" => "text/plain",
                                "X-Position" => "root",
                                "X-PathInfo" => env["PATH_INFO"],
                                "X-ScriptName" => env["SCRIPT_NAME"]
                              }, [""]]}
                           ))

    res = Rack::MockRequest.new(map).get("http://example.org/")
    res.must_be :ok?
    res["X-Position"].must_equal "root"
    res["X-PathInfo"].must_equal "/"
    res["X-ScriptName"].must_equal ""

    res = Rack::MockRequest.new(map).get("http://EXAMPLE.ORG/")
    res.must_be :ok?
    res["X-Position"].must_equal "root"
    res["X-PathInfo"].must_equal "/"
    res["X-ScriptName"].must_equal ""
  end
end

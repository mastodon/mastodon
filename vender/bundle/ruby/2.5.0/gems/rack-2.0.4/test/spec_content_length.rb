require 'minitest/autorun'
require 'rack/content_length'
require 'rack/lint'
require 'rack/mock'

describe Rack::ContentLength do
  def content_length(app)
    Rack::Lint.new Rack::ContentLength.new(app)
  end

  def request
    Rack::MockRequest.env_for
  end

  it "set Content-Length on Array bodies if none is set" do
    app = lambda { |env| [200, {'Content-Type' => 'text/plain'}, ["Hello, World!"]] }
    response = content_length(app).call(request)
    response[1]['Content-Length'].must_equal '13'
  end

  it "not set Content-Length on variable length bodies" do
    body = lambda { "Hello World!" }
    def body.each ; yield call ; end

    app = lambda { |env| [200, {'Content-Type' => 'text/plain'}, body] }
    response = content_length(app).call(request)
    response[1]['Content-Length'].must_be_nil
  end

  it "not change Content-Length if it is already set" do
    app = lambda { |env| [200, {'Content-Type' => 'text/plain', 'Content-Length' => '1'}, "Hello, World!"] }
    response = content_length(app).call(request)
    response[1]['Content-Length'].must_equal '1'
  end

  it "not set Content-Length on 304 responses" do
    app = lambda { |env| [304, {}, []] }
    response = content_length(app).call(request)
    response[1]['Content-Length'].must_be_nil
  end

  it "not set Content-Length when Transfer-Encoding is chunked" do
    app = lambda { |env| [200, {'Content-Type' => 'text/plain', 'Transfer-Encoding' => 'chunked'}, []] }
    response = content_length(app).call(request)
    response[1]['Content-Length'].must_be_nil
  end

  # Using "Connection: close" for this is fairly contended. It might be useful
  # to have some other way to signal this.
  #
  # should "not force a Content-Length when Connection:close" do
  #   app = lambda { |env| [200, {'Connection' => 'close'}, []] }
  #   response = content_length(app).call({})
  #   response[1]['Content-Length'].must_be_nil
  # end

  it "close bodies that need to be closed" do
    body = Struct.new(:body) do
      attr_reader :closed
      def each; body.join; end
      def close; @closed = true; end
      def to_ary; end
    end.new(%w[one two three])

    app = lambda { |env| [200, {'Content-Type' => 'text/plain'}, body] }
    response = content_length(app).call(request)
    body.closed.must_be_nil
    response[2].close
    body.closed.must_equal true
  end

  it "support single-execute bodies" do
    body = Struct.new(:body) do
      def each
        yield body.shift until body.empty?
      end
      def to_ary; end
    end.new(%w[one two three])

    app = lambda { |env| [200, {'Content-Type' => 'text/plain'}, body] }
    response = content_length(app).call(request)
    expected = %w[one two three]
    response[1]['Content-Length'].must_equal expected.join.size.to_s
    response[2].to_enum.to_a.must_equal expected
  end
end

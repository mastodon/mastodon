require "test_helper"
require "rack/proxy"

class RackProxyTest < Test::Unit::TestCase
  class HostProxy < Rack::Proxy
    attr_accessor :host

    def rewrite_env(env)
      env["HTTP_HOST"] = self.host || 'www.trix.pl'
      env
    end
  end

  def app(opts = {})
    return @app ||= HostProxy.new(opts)
  end

  def test_http_streaming
    get "/"
    assert last_response.ok?
    assert_match(/Jacek Becela/, last_response.body)
  end

  def test_http_full_request
    app(:streaming => false)
    get "/"
    assert last_response.ok?
    assert_match(/Jacek Becela/, last_response.body)
  end

  def test_http_full_request_headers
    app(:streaming => false)
    app.host = 'www.google.com'
    get "/"
    assert !Array(last_response['Set-Cookie']).empty?, 'Google always sets a cookie, yo. Where my cookies at?!'
  end

  def test_https_streaming
    app.host = 'www.apple.com'
    get 'https://example.com'
    assert last_response.ok?
    assert_match(/(itunes|iphone|ipod|mac|ipad)/, last_response.body)
  end

  def test_https_streaming_tls
    app(:ssl_version => :TLSv1).host = 'www.apple.com'
    get 'https://example.com'
    assert last_response.ok?
    assert_match(/(itunes|iphone|ipod|mac|ipad)/, last_response.body)
  end

  def test_https_full_request
    app(:streaming => false).host = 'www.apple.com'
    get 'https://example.com'
    assert last_response.ok?
    assert_match(/(itunes|iphone|ipod|mac|ipad)/, last_response.body)
  end

  def test_https_full_request_tls
    app({:streaming => false, :ssl_version => :TLSv1}).host = 'www.apple.com'
    get 'https://example.com'
    assert last_response.ok?
    assert_match(/(itunes|iphone|ipod|mac|ipad)/, last_response.body)
  end

  def test_normalize_headers
    proxy_class = Rack::Proxy
    headers = { 'header_array' => ['first_entry'], 'header_non_array' => :entry }

    normalized_headers = proxy_class.send(:normalize_headers, headers)
    assert normalized_headers.instance_of?(Rack::Utils::HeaderHash)
    assert normalized_headers['header_array'] == 'first_entry'
    assert normalized_headers['header_non_array'] == :entry
  end

  def test_header_reconstruction
    proxy_class = Rack::Proxy

    header = proxy_class.send(:reconstruct_header_name, "HTTP_ABC")
    assert header == "ABC"

    header = proxy_class.send(:reconstruct_header_name, "HTTP_ABC_D")
    assert header == "ABC-D"
  end

  def test_extract_http_request_headers
    proxy_class = Rack::Proxy
    env = {
      'NOT-HTTP-HEADER' => 'test-value',
      'HTTP_ACCEPT' => 'text/html',
      'HTTP_CONNECTION' => nil,
      'HTTP_CONTENT_MD5' => 'deadbeef'
    }

    headers = proxy_class.extract_http_request_headers(env)
    assert headers.key?('ACCEPT')
    assert headers.key?('CONTENT-MD5')
    assert !headers.key?('CONNECTION')
    assert !headers.key?('NOT-HTTP-HEADER')
  end

  def test_duplicate_headers
    proxy_class = Rack::Proxy
    env = { 'Set-Cookie' => ["cookie1=foo", "cookie2=bar"] }

    headers = proxy_class.normalize_headers(env)
    assert headers['Set-Cookie'].include?('cookie1=foo'), "Include the first value"
    assert headers['Set-Cookie'].include?("\n"), "Join multiple cookies with newlines"
    assert headers['Set-Cookie'].include?('cookie2=bar'), "Include the second value"
  end


  def test_handles_missing_content_length
    assert_nothing_thrown do
      post "/", nil, "CONTENT_LENGTH" => nil
    end
  end

  def test_response_header_included_Hop_by_hop
    app({:streaming => true}).host = 'auth.goeasyship.com'
    get 'https://example.com/oauth2/token/info?access_token=123'
    assert !last_response.headers.key?('transfer-encoding')
  end
end

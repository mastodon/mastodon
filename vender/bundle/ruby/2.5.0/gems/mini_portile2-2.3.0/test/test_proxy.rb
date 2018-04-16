# Encoding: utf-8

require File.expand_path('../helper', __FILE__)
require 'socket'

class TestProxy < TestCase
  def with_dummy_proxy(username=nil, password=nil)
    gs = TCPServer.open('localhost', 0)
    th = Thread.new do
      s = gs.accept
      gs.close
      begin
        req = ''.dup
        while (l=s.gets) && !l.chomp.empty?
          req << l
        end
        req
      ensure
        s.close
      end
    end

    if username && password
      yield "http://#{ERB::Util.url_encode(username)}:#{ERB::Util.url_encode(password)}@localhost:#{gs.addr[1]}"
    else
      yield "http://localhost:#{gs.addr[1]}"
    end

    # Set timeout for reception of the request
    Thread.new do
      sleep 1
      th.kill
    end
    th.value
  end

  def setup
    # remove any download files
    FileUtils.rm_rf("port/archives")
  end

  def assert_proxy_auth(expected, request)
    if request =~ /^Proxy-Authorization: Basic (.*)/
      assert_equal 'user: @name:@12: üMp', $1.unpack("m")[0].force_encoding(__ENCODING__)
    else
      flunk "No authentication request"
    end
  end

  def test_http_proxy
    recipe = MiniPortile.new("test http_proxy", "1.0.0")
    recipe.files << "http://myserver/path/to/tar.gz"
    request = with_dummy_proxy do |url, thread|
      ENV['http_proxy'] = url
      recipe.download rescue RuntimeError
      ENV.delete('http_proxy')
    end
    assert_match(/GET http:\/\/myserver\/path\/to\/tar.gz/, request)
  end

  def test_http_proxy_with_basic_auth
    recipe = MiniPortile.new("test http_proxy", "1.0.0")
    recipe.files << "http://myserver/path/to/tar.gz"
    request = with_dummy_proxy('user: @name', '@12: üMp') do |url, thread|
      ENV['http_proxy'] = url
      recipe.download  rescue RuntimeError
      ENV.delete('http_proxy')
    end

    assert_match(/GET http:\/\/myserver\/path\/to\/tar.gz/, request)
    assert_proxy_auth 'user: @name:@12: üMp', request
  end

  def test_https_proxy
    recipe = MiniPortile.new("test https_proxy", "1.0.0")
    recipe.files << "https://myserver/path/to/tar.gz"
    request = with_dummy_proxy do |url, thread|
      ENV['https_proxy'] = url
      recipe.download  rescue RuntimeError
      ENV.delete('https_proxy')
    end
    assert_match(/CONNECT myserver:443/, request)
  end

  def test_https_proxy_with_basic_auth
    recipe = MiniPortile.new("test https_proxy", "1.0.0")
    recipe.files << "https://myserver/path/to/tar.gz"
    request = with_dummy_proxy('user: @name', '@12: üMp') do |url, thread|
      ENV['https_proxy'] = url
      recipe.download  rescue RuntimeError
      ENV.delete('https_proxy')
    end

    assert_match(/CONNECT myserver:443/, request)
    assert_proxy_auth 'user: @name:@12: üMp', request
  end

  def test_ftp_proxy
    recipe = MiniPortile.new("test ftp_proxy", "1.0.0")
    recipe.files << "ftp://myserver/path/to/tar.gz"
    request = with_dummy_proxy do |url, thread|
      ENV['ftp_proxy'] = url
      recipe.download  rescue RuntimeError
      ENV.delete('ftp_proxy')
    end
    assert_match(/GET ftp:\/\/myserver\/path\/to\/tar.gz/, request)
  end

  def test_ftp_proxy_with_basic_auth
    recipe = MiniPortile.new("test ftp_proxy", "1.0.0")
    recipe.files << "ftp://myserver/path/to/tar.gz"
    request = with_dummy_proxy('user: @name', '@12: üMp') do |url, thread|
      ENV['ftp_proxy'] = url
      recipe.download  rescue RuntimeError
      ENV.delete('ftp_proxy')
    end

    assert_match(/GET ftp:\/\/myserver\/path\/to\/tar.gz/, request)
    assert_proxy_auth 'user: @name:@12: üMp', request
  end
end

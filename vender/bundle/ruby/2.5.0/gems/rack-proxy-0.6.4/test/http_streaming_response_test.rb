require "test_helper"
require "rack/http_streaming_response"

class HttpStreamingResponseTest < Test::Unit::TestCase

  def setup
    host, req = "www.trix.pl", Net::HTTP::Get.new("/")
    @response = Rack::HttpStreamingResponse.new(req, host)
  end

  def test_streaming
    # Response status
    assert @response.code == 200
    assert @response.status == 200

    # Headers
    headers = @response.headers

    assert headers.size > 0

    assert headers["content-type"] == ["text/html;charset=utf-8"]
    assert headers["CoNtEnT-TyPe"] == headers["content-type"]
    assert headers["content-length"].first.to_i > 0

    # Body
    chunks = []
    @response.body.each do |chunk|
      chunks << chunk
    end

    assert chunks.size > 0
    chunks.each do |chunk|
      assert chunk.is_a?(String)
    end

  end

  def test_to_s
    assert_equal @response.headers["Content-Length"].first.to_i, @response.body.to_s.size
  end

  def test_to_s_called_twice
    body = @response.body
    assert_equal body.to_s, body.to_s
  end

end

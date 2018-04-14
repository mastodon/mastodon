Shindo.tests('Excon Decompress Middleware') do
  env_init

  with_server('good') do

    before do
      @connection ||= Excon.new(
        'http://127.0.0.1:9292/echo/content-encoded',
        :method => :post,
        :body => 'hello world',
        :middlewares => Excon.defaults[:middlewares] + [Excon::Middleware::Decompress]
      )
    end

    tests('gzip') do
      resp = nil

      tests('response body decompressed').returns('hello world') do
        resp = @connection.request(
          :headers => { 'Accept-Encoding' => 'gzip, deflate;q=0' }
        )
        resp[:body]
      end

      tests('server sent content-encoding').returns('gzip') do
        resp[:headers]['Content-Encoding-Sent']
      end

      tests('removes processed encoding from header').returns('') do
        resp[:headers]['Content-Encoding']
      end

      tests('empty response body').returns('') do
        resp = @connection.request(:body => '')
        resp[:body]
      end
    end

    tests('deflate') do
      resp = nil

      tests('response body decompressed').returns('hello world') do
        resp = @connection.request(
          :headers => { 'Accept-Encoding' => 'gzip;q=0, deflate' }
        )
        resp[:body]
      end

      tests('server sent content-encoding').returns('deflate') do
        resp[:headers]['Content-Encoding-Sent']
      end

      tests('removes processed encoding from header').returns('') do
        resp[:headers]['Content-Encoding']
      end
    end

    tests('with pre-encoding') do
      resp = nil

      tests('server sent content-encoding').returns('other, gzip') do
        resp = @connection.request(
          :headers => { 'Accept-Encoding' => 'gzip, deflate;q=0',
                        'Content-Encoding-Pre' => 'other' }
        )
        resp[:headers]['Content-Encoding-Sent']
      end

      tests('processed encoding removed from header').returns('other') do
        resp[:headers]['Content-Encoding']
      end

      tests('response body decompressed').returns('hello world') do
        resp[:body]
      end

    end

    tests('with post-encoding') do
      resp = nil

      tests('server sent content-encoding').returns('gzip, other') do
        resp = @connection.request(
          :headers => { 'Accept-Encoding' => 'gzip, deflate;q=0',
                        'Content-Encoding-Post' => 'other' }
        )
        resp[:headers]['Content-Encoding-Sent']
      end

      tests('unprocessed since last applied is unknown').returns('gzip, other') do
        resp[:headers]['Content-Encoding']
      end

      tests('response body still compressed').returns('hello world') do
        Zlib::GzipReader.new(StringIO.new(resp[:body])).read
      end

    end

    tests('with a :response_block') do
      captures = nil
      resp = nil

      tests('server sent content-encoding').returns('gzip') do
        captures = capture_response_block do |block|
          resp = @connection.request(
            :headers => { 'Accept-Encoding' => 'gzip'},
            :response_block => block
          )
        end
        resp[:headers]['Content-Encoding-Sent']
      end

      tests('unprocessed since :response_block was used').returns('gzip') do
        resp[:headers]['Content-Encoding']
      end

      tests(':response_block passed unprocessed data').returns('hello world') do
        body = captures.map {|capture| capture[0] }.join
        Zlib::GzipReader.new(StringIO.new(body)).read
      end

    end

    tests('adds Accept-Encoding if needed') do

      tests('without a :response_block').returns('deflate, gzip') do
        resp = Excon.post(
          'http://127.0.0.1:9292/echo/request',
          :body => 'hello world',
          :middlewares => Excon.defaults[:middlewares] +
                          [Excon::Middleware::Decompress]
        )
        request = Marshal.load(resp.body)
        request[:headers]['Accept-Encoding']
      end

      tests('with a :response_block').returns(nil) do
        captures = capture_response_block do |block|
          Excon.post(
            'http://127.0.0.1:9292/echo/request',
            :body => 'hello world',
            :response_block => block,
            :middlewares => Excon.defaults[:middlewares] +
                            [Excon::Middleware::Decompress]
          )
        end
        request = Marshal.load(captures.map {|capture| capture[0] }.join)
        request[:headers]['Accept-Encoding']
      end

    end

  end

  env_restore
end

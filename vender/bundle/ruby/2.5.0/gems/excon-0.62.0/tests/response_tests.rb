Shindo.tests('Excon Response Parsing') do
  env_init

  with_server('good') do

    tests('responses with chunked transfer-encoding') do

      tests('simple response').returns('hello world') do
        Excon.get('http://127.0.0.1:9292/chunked/simple').body
      end

      tests('with :response_block') do

        tests('simple response').
              returns([['hello ', nil, nil], ['world', nil, nil]]) do
          capture_response_block do |block|
            Excon.get('http://127.0.0.1:9292/chunked/simple',
                      :response_block => block,
                      :chunk_size => 5) # not used
          end
        end

        tests('simple response has empty body').returns('') do
          response_block = lambda { |_, _, _| }
          Excon.get('http://127.0.0.1:9292/chunked/simple', :response_block => response_block).body
        end

        tests('with expected response status').
              returns([['hello ', nil, nil], ['world', nil, nil]]) do
          capture_response_block do |block|
            Excon.get('http://127.0.0.1:9292/chunked/simple',
                      :response_block => block,
                      :expects => 200)
          end
        end

        tests('with unexpected response status').returns('hello world') do
          begin
            Excon.get('http://127.0.0.1:9292/chunked/simple',
                      :response_block => Proc.new { raise 'test failed' },
                      :expects => 500)
          rescue Excon::Errors::HTTPStatusError => err
            err.response[:body]
          end
        end

      end

      tests('merges trailers into headers').
          returns('one, two, three, four, five, six') do
        Excon.get('http://127.0.0.1:9292/chunked/trailers').headers['Test-Header']
      end

      tests("removes 'chunked' from Transfer-Encoding").returns(nil) do
        Excon.get('http://127.0.0.1:9292/chunked/simple').headers['Transfer-Encoding']
      end

    end

    tests('responses with content-length') do

      tests('simple response').returns('hello world') do
        Excon.get('http://127.0.0.1:9292/content-length/simple').body
      end

      tests('with :response_block') do

        tests('simple response').
              returns([['hello', 6, 11], [' worl', 1, 11], ['d', 0, 11]]) do
          capture_response_block do |block|
            Excon.get('http://127.0.0.1:9292/content-length/simple',
                      :response_block => block,
                      :chunk_size => 5)
          end
        end

        tests('simple response has empty body').returns('') do
          response_block = lambda { |_, _, _| }
          Excon.get('http://127.0.0.1:9292/content-length/simple', :response_block => response_block).body
        end

        tests('with expected response status').
              returns([['hello', 6, 11], [' worl', 1, 11], ['d', 0, 11]]) do
          capture_response_block do |block|
            Excon.get('http://127.0.0.1:9292/content-length/simple',
                      :response_block => block,
                      :chunk_size => 5,
                      :expects => 200)
          end
        end

        tests('with unexpected response status').returns('hello world') do
          begin
            Excon.get('http://127.0.0.1:9292/content-length/simple',
                      :response_block => Proc.new { raise 'test failed' },
                      :chunk_size => 5,
                      :expects => 500)
          rescue Excon::Errors::HTTPStatusError => err
            err.response[:body]
          end
        end

      end

    end

    tests('responses with unknown length') do

      tests('simple response').returns('hello world') do
        Excon.get('http://127.0.0.1:9292/unknown/simple').body
      end

      tests('with :response_block') do

        tests('simple response').
              returns([['hello', nil, nil], [' worl', nil, nil], ['d', nil, nil]]) do
          capture_response_block do |block|
            Excon.get('http://127.0.0.1:9292/unknown/simple',
                      :response_block => block,
                      :chunk_size => 5)
          end
        end

        tests('simple response has empty body').returns('') do
          response_block = lambda { |_, _, _| }
          Excon.get('http://127.0.0.1:9292/unknown/simple', :response_block => response_block).body
        end

        tests('with expected response status').
              returns([['hello', nil, nil], [' worl', nil, nil], ['d', nil, nil]]) do
          capture_response_block do |block|
            Excon.get('http://127.0.0.1:9292/unknown/simple',
                      :response_block => block,
                      :chunk_size => 5,
                      :expects => 200)
          end
        end

        tests('with unexpected response status').returns('hello world') do
          begin
            Excon.get('http://127.0.0.1:9292/unknown/simple',
                      :response_block => Proc.new { raise 'test failed' },
                      :chunk_size => 5,
                      :expects => 500)
          rescue Excon::Errors::HTTPStatusError => err
            err.response[:body]
          end
        end

      end

    end

    tests('cookies') do

      tests('parses cookies into array').returns(['one, two', 'three, four']) do
        resp = Excon.get('http://127.0.0.1:9292/unknown/cookies')
        resp[:cookies]
      end

    end

    tests('header continuation') do

      tests('proper continuation').returns('one, two, three, four, five, six') do
        resp = Excon.get('http://127.0.0.1:9292/unknown/header_continuation')
        resp.headers['Test-Header']
      end

      tests('malformed header').raises(Excon::Errors::SocketError) do
        Excon.get('http://127.0.0.1:9292/bad/malformed_header')
      end

      tests('malformed header continuation').raises(Excon::Errors::SocketError) do
        Excon.get('http://127.0.0.1:9292/bad/malformed_header_continuation')
      end

    end

    tests('status line parsing') do

      tests('proper status code').returns(404) do
        resp = Excon.get('http://127.0.0.1:9292/not-found')
        resp.status
      end

      tests('proper reason phrase').returns("Not Found") do
        resp = Excon.get('http://127.0.0.1:9292/not-found')
        resp.reason_phrase
      end

    end

  end

  env_restore
end

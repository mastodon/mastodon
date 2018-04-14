Shindo.tests('Excon query string variants') do
  with_rackup('query_string.ru') do
    connection = Excon.new('http://127.0.0.1:9292')

    tests(":query => {:foo => 'bar'}") do
      response = connection.request(:method => :get, :path => '/query', :query => {:foo => 'bar'})
      query_string = response.body[7..-1] # query string sent

      tests("query string sent").returns('foo=bar') do
        query_string
      end
    end

    tests(":query => {:foo => nil}") do
      response = connection.request(:method => :get, :path => '/query', :query => {:foo => nil})
      query_string = response.body[7..-1] # query string sent

      tests("query string sent").returns('foo') do
        query_string
      end
    end

    tests(":query => {:foo => 'bar', :me => nil}") do
      response = connection.request(:method => :get, :path => '/query', :query => {:foo => 'bar', :me => nil})
      query_string = response.body[7..-1] # query string sent

      test("query string sent includes 'foo=bar'") do
        query_string.split('&').include?('foo=bar')
      end

      test("query string sent includes 'me'") do
        query_string.split('&').include?('me')
      end
    end

    tests(":query => {:foo => 'bar', :me => 'too'}") do
      response = connection.request(:method => :get, :path => '/query', :query => {:foo => 'bar', :me => 'too'})
      query_string = response.body[7..-1] # query string sent

      test("query string sent includes 'foo=bar'") do
        query_string.split('&').include?('foo=bar')
      end

      test("query string sent includes 'me=too'") do
        query_string.split('&').include?('me=too')
      end
    end

    # You can use an atom or a string for the hash keys, what is shown here is emulating
    # the Rails and PHP style of serializing a query array with a square brackets suffix.
    tests(":query => {'foo[]' => ['bar', 'baz'], :me => 'too'}") do
      response = connection.request(:method => :get, :path => '/query', :query => {'foo[]' => ['bar', 'baz'], :me => 'too'})
      query_string = response.body[7..-1] # query string sent

      test("query string sent includes 'foo%5B%5D=bar'") do
        query_string.split('&').include?('foo%5B%5D=bar')
      end

      test("query string sent includes 'foo%5B%5D=baz'") do
        query_string.split('&').include?('foo%5B%5D=baz')
      end

      test("query string sent includes 'me=too'") do
        query_string.split('&').include?('me=too')
      end
    end

    tests(":query => {'foo%=#' => 'bar%=#'}") do
      response = connection.request(:method => :get, :path => '/query', :query => {'foo%=#' => 'bar%=#'})
      query_string = response.body[7..-1] # query string sent

      tests("query string sent").returns('foo%25%3D%23=bar%25%3D%23') do
        query_string
      end
    end

    tests(":query => {'foo%=#' => nil}") do
      response = connection.request(:method => :get, :path => '/query', :query => {'foo%=#' => nil})
      query_string = response.body[7..-1] # query string sent

      tests("query string sent").returns('foo%25%3D%23') do
        query_string
      end
    end

  end
end

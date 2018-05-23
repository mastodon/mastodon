Shindo.tests('Excon thread safety') do
  
  tests('thread_safe_sockets configuration') do
    tests('thread_safe_sockets default').returns(true) do
      connection = Excon.new('http://foo.com')
      connection.data[:thread_safe_sockets]
    end

    tests('with thread_safe_sockets set false').returns(false) do
      connection = Excon.new('http://foo.com', :thread_safe_sockets => false)
      connection.data[:thread_safe_sockets]
    end
  end

  with_rackup('thread_safety.ru') do
    connection = Excon.new('http://127.0.0.1:9292')

    long_thread = Thread.new {
      response = connection.request(:method => 'GET', :path => '/id/1/wait/2')
      Thread.current[:success] = response.body == '1'
    }

    short_thread = Thread.new {
      response = connection.request(:method => 'GET', :path => '/id/2/wait/1')
      Thread.current[:success] = response.body == '2'
    }

    test('long_thread') do
      long_thread.join
      short_thread.join

      long_thread[:success]
    end

    test('short_thread') do
      short_thread[:success]
    end
  end
end

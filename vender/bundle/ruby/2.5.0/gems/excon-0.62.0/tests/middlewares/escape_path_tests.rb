Shindo.tests('Excon Decompress Middleware') do
  env_init
  with_rackup('basic.ru') do
    tests('encoded uri passed to connection') do
      tests('GET /echo%20dirty').returns(200) do
        connection = Excon::Connection.new({
          :host             => '127.0.0.1',
          :hostname         => '127.0.0.1',
          :middlewares      => Excon.defaults[:middlewares] + [Excon::Middleware::EscapePath],
          :nonblock         => false,
          :port             => 9292,
          :scheme           => 'http',
          :ssl_verify_peer  => false
        })
        response = connection.request(:method => :get, :path => '/echo%20dirty')
        response[:status]
      end
    end

    tests('unencoded uri passed to connection') do
      tests('GET /echo dirty').returns(200) do
        connection = Excon::Connection.new({
          :host             => '127.0.0.1',
          :hostname         => '127.0.0.1',
          :middlewares      => Excon.defaults[:middlewares] + [Excon::Middleware::EscapePath],
          :nonblock         => false,
          :port             => 9292,
          :scheme           => 'http',
          :ssl_verify_peer  => false
        })
        response = connection.request(:method => :get, :path => '/echo dirty')
        response[:status]
      end
    end
  end
end

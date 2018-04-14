Shindo.tests('Pipelined Requests') do
  with_server('good') do

    tests('with default :persistent => true') do
      returns(%w{ 1 2 3 4 }, 'connection is persistent') do
        connection = Excon.new('http://127.0.0.1:9292', :persistent => true)

        ret = []
        ret << connection.requests([
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'}
        ]).map(&:body)
        ret << connection.requests([
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'}
        ]).map(&:body)
        ret.flatten
      end
    end

    tests('with default :persistent => false') do
      returns(%w{ 1 2 1 2 }, 'connection is persistent per call to #requests') do
        connection = Excon.new('http://127.0.0.1:9292', :persistent => false)

        ret = []
        ret << connection.requests([
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'}
        ]).map(&:body)
        ret << connection.requests([
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'}
        ]).map(&:body)
        ret.flatten
      end

    end

  end
end

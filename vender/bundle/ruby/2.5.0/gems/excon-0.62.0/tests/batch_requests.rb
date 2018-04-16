require 'shindo'

Shindo.tests('Batch Requests') do
  with_server('good') do
    tests('with batch request size 2') do
      returns(%w{ 1 2 1 2 }, 'batch request size 2') do
        connection = Excon.new('http://127.0.0.1:9292')

        ret = []
        ret << connection.batch_requests([
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'}
        ], 2).map(&:body)

        ret.flatten
      end
    end

    tests('peristent with batch request size 2') do
      returns(%w{ 1 2 3 4 }, 'persistent batch request size 2') do
        connection = Excon.new('http://127.0.0.1:9292', :persistent => true)

        ret = []
        ret << connection.batch_requests([
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'}
        ], 2).map(&:body)

        ret.flatten
      end
    end

    tests('with batch request size 3') do
      returns(%w{ 1 2 3 1 }, 'batch request size 3') do
        connection = Excon.new('http://127.0.0.1:9292')

        ret = []
        ret << connection.batch_requests([
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'}
        ], 3).map(&:body)

        ret.flatten
      end
    end

    tests('persistent with batch request size 3') do
      returns(%w{ 1 2 3 4 }, 'persistent batch request size 3') do
        connection = Excon.new('http://127.0.0.1:9292', :persistent => true)

        ret = []
        ret << connection.batch_requests([
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'}
        ], 3).map(&:body)

        ret.flatten
      end
    end

    tests('with batch request size 4') do
      returns(%w{ 1 2 3 4 }, 'batch request size 4') do
        connection = Excon.new('http://127.0.0.1:9292')

        ret = []
        ret << connection.batch_requests([
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'}
        ], 4).map(&:body)

        ret.flatten
      end
    end

    tests('persistent with batch request size 4') do
      returns(%w{ 1 2 3 4 }, 'persistent batch request size 4') do
        connection = Excon.new('http://127.0.0.1:9292', :persistent => true)

        ret = []
        ret << connection.batch_requests([
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'}
        ], 4).map(&:body)

        ret.flatten
      end
    end

    tests('with batch request size 8') do
      returns(%w{ 1 2 3 4 }, 'batch request size 8') do
        connection = Excon.new('http://127.0.0.1:9292')

        ret = []
        ret << connection.batch_requests([
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'}
        ], 8).map(&:body)

        ret.flatten
      end
    end

    tests('persistent with batch request size 8') do
      returns(%w{ 1 2 3 4 }, 'persistent batch request size 8') do
        connection = Excon.new('http://127.0.0.1:9292', :persistent => true)

        ret = []
        ret << connection.batch_requests([
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'},
          {:method => :get, :path => '/echo/request_count'}
        ], 8).map(&:body)

        ret.flatten
      end
    end
  end
end

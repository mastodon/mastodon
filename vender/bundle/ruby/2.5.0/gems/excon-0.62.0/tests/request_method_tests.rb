Shindo.tests('Excon request methods') do

  with_rackup('request_methods.ru') do

    tests 'one-offs' do

      tests('Excon.get').returns('GET') do
        Excon.get('http://localhost:9292').body
      end

      tests('Excon.post').returns('POST') do
        Excon.post('http://localhost:9292').body
      end

      tests('Excon.delete').returns('DELETE') do
        Excon.delete('http://localhost:9292').body
      end

    end

    tests 'with a connection object' do
      connection = nil

      tests('connection.get').returns('GET') do
        connection = Excon.new('http://localhost:9292')
        connection.get.body
      end

      tests('connection.post').returns('POST') do
        connection.post.body
      end

      tests('connection.delete').returns('DELETE') do
        connection.delete.body
      end

      tests('not modifies path argument').returns('path') do
        path = 'path'
        connection.get(:path => path)
        path
      end

    end

  end

end

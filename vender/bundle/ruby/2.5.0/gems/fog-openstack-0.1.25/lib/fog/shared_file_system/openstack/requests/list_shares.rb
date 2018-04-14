module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def list_shares(options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'shares',
            :query   => options
          )
        end
      end

      class Mock
        def list_shares(_options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = {'shares' => data[:shares]}
          response
        end
      end
    end
  end
end

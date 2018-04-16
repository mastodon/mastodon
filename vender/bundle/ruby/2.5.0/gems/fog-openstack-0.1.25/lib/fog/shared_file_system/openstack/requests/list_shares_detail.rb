module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def list_shares_detail(options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'shares/detail',
            :query   => options
          )
        end
      end

      class Mock
        def list_shares_detail(_options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = {'shares' => data[:shares_detail]}
          response
        end
      end
    end
  end
end

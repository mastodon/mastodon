module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def list_share_networks_detail(options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'share-networks/detail',
            :query   => options
          )
        end
      end

      class Mock
        def list_share_networks_detail(_options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = {'share_networks' => data[:share_networks_detail]}
          response
        end
      end
    end
  end
end

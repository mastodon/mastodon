module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def list_share_networks(options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'share-networks',
            :query   => options
          )
        end
      end

      class Mock
        def list_share_networks(_options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = {'share_networks' => data[:share_networks]}
          response
        end
      end
    end
  end
end

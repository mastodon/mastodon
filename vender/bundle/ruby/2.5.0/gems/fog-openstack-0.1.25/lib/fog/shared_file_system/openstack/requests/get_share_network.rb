module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def get_share_network(id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "share-networks/#{id}"
          )
        end
      end

      class Mock
        def get_share_network(id)
          response = Excon::Response.new
          response.status = 200
          share_net = data[:share_network_updated] || data[:share_networks].first
          share_net['id'] = id
          response.body = {'share_network' => share_net}
          response
        end
      end
    end
  end
end

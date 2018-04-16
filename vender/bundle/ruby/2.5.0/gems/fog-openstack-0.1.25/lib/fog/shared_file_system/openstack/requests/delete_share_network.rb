module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def delete_share_network(id)
          request(
            :expects => 202,
            :method  => 'DELETE',
            :path    => "share-networks/#{id}"
          )
        end
      end

      class Mock
        def delete_share_network(id)
          response = Excon::Response.new
          response.status = 202

          share_net       = data[:share_net_updated] || data[:share_networks_detail].first.dup
          share_net['id'] = id

          response.body = {'share_network' => share_net}
          response
        end
      end
    end
  end
end

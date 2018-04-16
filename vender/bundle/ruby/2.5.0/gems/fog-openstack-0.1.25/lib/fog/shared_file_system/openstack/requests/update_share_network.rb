module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def update_share_network(id, options = {})
          request(
            :body    => Fog::JSON.encode('share_network' => options),
            :expects => 200,
            :method  => 'PUT',
            :path    => "share-networks/#{id}"
          )
        end
      end

      class Mock
        def update_share_network(id, options = {})
          # stringify keys
          options = Hash[options.map { |k, v| [k.to_s, v] }]

          data[:share_net_updated]       = data[:share_networks_detail].first.merge(options)
          data[:share_net_updated]['id'] = id

          response = Excon::Response.new
          response.status = 200
          response.body = {'share_network' => data[:share_net_updated]}
          response
        end
      end
    end
  end
end

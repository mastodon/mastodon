module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def create_share_network(options = {})
          data = {}

          vanilla_options = [
            :name, :description, :neutron_net_id, :neutron_subnet_id, :nova_net_id
          ]

          vanilla_options.select { |o| options[o] }.each do |key|
            data[key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode('share_network' => data),
            :expects => 200,
            :method  => 'POST',
            :path    => 'share-networks'
          )
        end
      end

      class Mock
        def create_share_network(options = {})
          # stringify keys
          options = Hash[options.map { |k, v| [k.to_s, v] }]

          response = Excon::Response.new
          response.status = 200

          share_net = data[:share_networks_detail].first.dup

          response.body = {'share_networks' => share_net.merge(options)}
          response
        end
      end
    end
  end
end

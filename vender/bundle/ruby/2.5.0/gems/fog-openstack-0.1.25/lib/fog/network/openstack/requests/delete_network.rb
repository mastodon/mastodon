module Fog
  module Network
    class OpenStack
      class Real
        def delete_network(network_id)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "networks/#{network_id}"
          )
        end
      end

      class Mock
        def delete_network(network_id)
          response = Excon::Response.new
          if list_networks.body['networks'].map { |r| r['id'] }.include? network_id
            data[:networks].delete(network_id)
            response.status = 204
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end

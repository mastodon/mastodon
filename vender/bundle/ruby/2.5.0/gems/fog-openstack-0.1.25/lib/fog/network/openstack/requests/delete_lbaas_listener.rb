module Fog
  module Network
    class OpenStack
      class Real
        def delete_lbaas_listener(listener_id)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "lbaas/listeners/#{listener_id}"
          )
        end
      end

      class Mock
        def delete_lbaas_listener(listener_id)
          response = Excon::Response.new
          if list_lbaas_listeners.body['listsners'].map { |r| r['id'] }.include? listener_id
            data[:lbaas_listeners].delete(listener_id)
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

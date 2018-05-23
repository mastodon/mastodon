
module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def delete_zone_transfer_request(zone_transfer_request_id)
            request(
              :expects => 204,
              :method  => 'DELETE',
              :path    => "zones/tasks/transfer_requests/#{zone_transfer_request_id}"
            )
          end
        end

        class Mock
          def delete_zone_transfer_request(zone_transfer_request_id)
            response = Excon::Response.new
            response.status = 204
            response
          end
        end
      end
    end
  end
end


module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def get_zone_transfer_request(zone_transfer_request_id)
            request(
              :expects => 200,
              :method  => 'GET',
              :path    => "zones/tasks/transfer_requests/#{zone_transfer_request_id}"
            )
          end
        end

        class Mock
          def get_zone_transfer_request(zone_transfer_request_id)
            response = Excon::Response.new
            response.status = 200
            request = data[:zone_transfer_requests]["transfer_requests"].first
            request["id"] = zone_transfer_request_id
            response.body = request
            response
          end
        end
      end
    end
  end
end

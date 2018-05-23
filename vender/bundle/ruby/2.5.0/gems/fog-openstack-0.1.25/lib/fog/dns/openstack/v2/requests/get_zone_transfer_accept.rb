module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def get_zone_transfer_accept(zone_transfer_accept_id)
            request(
              :expects => 200,
              :method  => 'GET',
              :path    => "zones/tasks/transfer_requests/#{zone_transfer_accept_id}"
            )
          end
        end

        class Mock
          def get_zone_transfer_accept(zone_transfer_accept_id)
            response = Excon::Response.new
            response.status = 200
            accept = data[:zone_transfer_accepts]["transfer_accepts"].first
            accept["id"] = zone_transfer_accept_id
            response.body = accept
            response
          end
        end
      end
    end
  end
end

module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def list_zone_transfer_requests(options={})
            request(
              :expects => 200,
              :method  => 'GET',
              :path    => "zones/tasks/transfer_requests",
              :query   => options
            )
          end
        end

        class Mock
          def list_zone_transfer_requests(options={})
            response = Excon::Response.new
            response.status = 200
            response.body = data[:zone_transfer_requests]["transfer_requests"]
            response
          end
        end
      end
    end
  end
end

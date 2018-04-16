
module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def create_zone_transfer_request(zone_id, options = {})
            vanilla_options = [:target_project_id, :description, :project_id]
            data = vanilla_options.inject({}) do |result,option|
              result[option] = options[option] if options[option]
              result
            end

            request(
              :body    => Fog::JSON.encode(data),
              :expects => 201,
              :method  => 'POST',
              :path    => "zones/#{zone_id}/tasks/transfer_requests"
            )
          end
        end

        class Mock
          def create_zone_transfer_request(zone_id, options = {})
            response = Excon::Response.new
            response.status = 201
            response.body = data[:zone_transfer_requests]["transfer_requests"].first
            response
          end
        end
      end
    end
  end
end

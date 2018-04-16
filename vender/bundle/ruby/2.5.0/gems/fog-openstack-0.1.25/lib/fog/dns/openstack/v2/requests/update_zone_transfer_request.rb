module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def update_zone_transfer_request(zone_transfer_request_id,description,options={})
            vanilla_options = [:target_project_id]
            data = vanilla_options.inject({}) do |result,option|
              result[option] = options[option] if options[option]
              result
            end

            request(
              :expects => 200,
              :method  => 'PATCH',
              :path    => "zones/tasks/transfer_requests/#{zone_transfer_request_id}",
              :body    => Fog::JSON.encode(data)
            )
          end
        end

        class Mock
          def update_zone_transfer_request(zone_transfer_request_id,description,options={})
            response = Excon::Response.new
            response.status = 200
            request = data[:zone_transfer_requests]["transfer_requests"]
            request.id = zone_transfer_request_id
            request.description =description
            response.body = request
            response
          end
        end
      end
    end
  end
end

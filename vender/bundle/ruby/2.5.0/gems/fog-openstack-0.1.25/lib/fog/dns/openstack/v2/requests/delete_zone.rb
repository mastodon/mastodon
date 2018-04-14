module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def delete_zone(id, options = {})
            headers, _options = Fog::DNS::OpenStack::V2.setup_headers(options)
            request(
              :expects => 202,
              :method  => 'DELETE',
              :path    => "zones/#{id}",
              :headers => headers
            )
          end
        end

        class Mock
          def delete_zone(id, _options = {})
            response = Excon::Response.new
            response.status = 202

            zone                  = data[:zone_updated] || data[:zones].first.dup
            zone["id"]            = id
            zone["status"]        = "PENDING"
            zone["action"]        = "DELETE"
            zone["links"]["self"] = "https://127.0.0.1:9001/v2/zones/#{id}"

            response.body = zone
            response
          end
        end
      end
    end
  end
end

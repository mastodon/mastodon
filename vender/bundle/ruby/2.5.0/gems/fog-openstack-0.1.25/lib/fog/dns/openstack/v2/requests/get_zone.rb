module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def get_zone(id, options = {})
            headers, _options = Fog::DNS::OpenStack::V2.setup_headers(options)
            request(
              :expects => 200,
              :method  => 'GET',
              :path    => "zones/#{id}",
              :headers => headers
            )
          end
        end

        class Mock
          def get_zone(id, _options = {})
            response = Excon::Response.new
            response.status = 200
            zone = data[:zone_updated] || data[:zones].first
            zone["id"] = id
            response.body = zone
            response
          end
        end
      end
    end
  end
end

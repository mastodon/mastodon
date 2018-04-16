module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def update_zone(id, options = {})
            headers, options = Fog::DNS::OpenStack::V2.setup_headers(options)

            request(
              :body    => Fog::JSON.encode(options),
              :expects => 202,
              :method  => 'PATCH',
              :path    => "zones/#{id}",
              :headers => headers
            )
          end
        end

        class Mock
          def update_zone(id, options = {})
            # stringify keys
            options = Hash[options.map { |k, v| [k.to_s, v] }]

            data[:zone_updated]                  = data[:zones].first.merge(options)
            data[:zone_updated]["id"]            = id
            data[:zone_updated]["status"]        = "PENDING"
            data[:zone_updated]["action"]        = "UPDATE"
            data[:zone_updated]["links"]["self"] = "https://127.0.0.1:9001/v2/zones/#{id}"

            response = Excon::Response.new
            response.status = 202
            response.body = data[:zone_updated]
            response
          end
        end
      end
    end
  end
end

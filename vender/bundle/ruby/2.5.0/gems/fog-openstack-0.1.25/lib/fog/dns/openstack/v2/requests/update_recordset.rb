module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def update_recordset(zone_id, id, options = {})
            headers, options = Fog::DNS::OpenStack::V2.setup_headers(options)

            request(
              :body    => Fog::JSON.encode(options),
              :expects => 202,
              :method  => 'PUT',
              :path    => "zones/#{zone_id}/recordsets/#{id}",
              :headers => headers
            )
          end
        end

        class Mock
          def update_recordset(zone_id, id, options = {})
            # stringify keys
            options = Hash[options.map { |k, v| [k.to_s, v] }]

            data[:recordset_updated]                  = data[:recordsets]["recordsets"].first.merge(options)
            data[:recordset_updated]["zone_id"]       = zone_id
            data[:recordset_updated]["id"]            = id
            data[:recordset_updated]["status"]        = "PENDING"
            data[:recordset_updated]["action"]        = "UPDATE"
            data[:recordset_updated]["links"]["self"] = "https://127.0.0.1:9001/v2/zones/#{zone_id}/recordsets/#{id}"

            response = Excon::Response.new
            response.status = 202
            response.body = data[:recordset_updated]
            response
          end
        end
      end
    end
  end
end

module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def get_recordset(zone_id, id, options = {})
            headers, _options = Fog::DNS::OpenStack::V2.setup_headers(options)
            request(
              :expects => 200,
              :method  => 'GET',
              :path    => "zones/#{zone_id}/recordsets/#{id}",
              :headers => headers
            )
          end
        end

        class Mock
          def get_recordset(zone_id, id)
            response = Excon::Response.new
            response.status = 200

            recordset                  = data[:recordset_updated] || data[:recordsets]["recordsets"].first
            recordset["zone_id"]       = zone_id
            recordset["id"]            = id
            recordset["action"]        = "NONE"
            recordset["status"]        = "ACTIVE"
            recordset["links"]["self"] = "https://127.0.0.1:9001/v2/zones/#{zone_id}/recordsets/#{id}"

            response.body = recordset
            response
          end
        end
      end
    end
  end
end

module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def create_recordset(zone_id, name, type, records, options = {})
            data = {
              'name'    => name,
              'type'    => type,
              'records' => records
            }

            vanilla_options = [:ttl, :description]

            vanilla_options.select { |o| options[o] }.each do |key|
              data[key] = options[key]
            end

            request(
              :body    => Fog::JSON.encode(data),
              :expects => 202,
              :method  => 'POST',
              :path    => "zones/#{zone_id}/recordsets"
            )
          end
        end

        class Mock
          def create_recordset(zone_id, name, type, records, options = {})
            # stringify keys
            options = Hash[options.map { |k, v| [k.to_s, v] }]

            response = Excon::Response.new
            response.status = 202

            recordset = data[:recordsets]["recordsets"].first.dup
            recordset_id = recordset["id"]

            recordset["zone_id"]       = zone_id
            recordset["name"]          = name
            recordset["type"]          = type
            recordset["records"]       = records
            recordset["status"]        = "PENDING"
            recordset["action"]        = "CREATE"
            recordset["links"]["self"] = "https://127.0.0.1:9001/v2/zones/#{zone_id}/recordsets/#{recordset_id}"

            response.body = recordset.merge(options)
            response
          end
        end
      end
    end
  end
end

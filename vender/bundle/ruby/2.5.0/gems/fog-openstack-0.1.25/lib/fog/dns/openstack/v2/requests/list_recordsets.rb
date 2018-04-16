module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def list_recordsets(zone_id = nil, options = {})
            # for backward compatability: consider removing the zone_id param (breaking change)
            unless zone_id.nil?
              if zone_id.kind_of?(Hash)
                options = zone_id
                zone_id = nil
              else
                Fog::Logger.deprecation(
                  'Calling list_recordsets(zone_id) is deprecated, use .list_recordsets(zone_id: value) instead'
                )
              end
            end

            zone_id = options.delete(:zone_id) if zone_id.nil?
            path = zone_id.nil? ? 'recordsets' : "zones/#{zone_id}/recordsets"

            headers, options = Fog::DNS::OpenStack::V2.setup_headers(options)

            request(
              :expects => 200,
              :method  => 'GET',
              :path    => path,
              :query   => options,
              :headers => headers
            )
          end
        end

        class Mock
          def list_recordsets(zone_id = nil, options = {})
            if zone_id.kind_of?(Hash)
              options = zone_id
              zone_id = nil
            end
            zone_id = options.delete(:zone_id) if zone_id.nil?

            response = Excon::Response.new
            response.status = 200
            data[:recordsets]["recordsets"].each do |rs|
              rs["zone_id"] = zone_id unless zone_id.nil?
            end
            response.body = data[:recordsets]
            response
          end
        end
      end
    end
  end
end

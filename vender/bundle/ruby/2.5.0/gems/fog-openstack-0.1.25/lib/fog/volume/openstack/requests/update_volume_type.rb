module Fog
  module Volume
    class OpenStack
      module Real
        def update_volume_type(volume_type_id, options = {})
          data = {
            'volume_type' => {}
          }

          vanilla_options = [:name, :extra_specs]
          vanilla_options.select { |o| options[o] }.each do |key|
            data['volume_type'][key] = options[key]
          end
          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200, 202],
            :method  => 'PUT',
            :path    => "types/#{volume_type_id}"
          )
        end
      end

      module Mock
        def update_volume_type(_volume_type_id, _options = {})
          response = Excon::Response.new
          response.status = 202
          response.body = {
            "volume_type" => {
              "id"          => "6685584b-1eac-4da6-b5c3-555430cf68ff",
              "name"        => "vol-type-001",
              "extra_specs" => {
                "capabilities" => "gpu"
              }
            }
          }
          response
        end
      end
    end
  end
end

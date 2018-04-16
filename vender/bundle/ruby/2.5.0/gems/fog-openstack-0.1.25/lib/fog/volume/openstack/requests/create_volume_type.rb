module Fog
  module Volume
    class OpenStack
      module Real
        def create_volume_type(options = {})
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
            :method  => 'POST',
            :path    => "types"
          )
        end
      end

      module Mock
        def create_volume_type(_options = {})
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

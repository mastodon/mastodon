module Fog
  module Volume
    class OpenStack
      module Real
        def get_volume_type_details(volume_type_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "types/#{volume_type_id}"
          )
        end
      end

      module Mock
        def get_volume_type_details(_volume_type_id)
          response = Excon::Response.new
          response.status = 200
          response.body = {
            "volume_type" => {
              "id"          => "1",
              "name"        => "type 1",
              "extra_specs" => {
                "volume_backend_name" => "type 1 backend name"
              }
            }
          }
          response
        end
      end
    end
  end
end

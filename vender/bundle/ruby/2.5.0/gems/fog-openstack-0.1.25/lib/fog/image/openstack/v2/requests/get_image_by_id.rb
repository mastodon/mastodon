module Fog
  module Image
    class OpenStack
      class V2
        class Real
          def get_image_by_id(image_id)
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "images/#{image_id}"
            )
          end
        end # class Real

        class Mock
          def get_image_by_id(_image_id)
            response = Excon::Response.new
            response.status = [200][rand(2)]
            response.body = {
              "images" => [{
                "name"             => "mock-image-name",
                "size"             => 25165824,
                "disk_format"      => "ami",
                "container_format" => "ami",
                "id"               => "0e09fbd6-43c5-448a-83e9-0d3d05f9747e",
                "checksum"         => "2f81976cae15c16ef0010c51e3a6c163"
              }]
            }
            response
          end # def list_tenants
        end # class Mock
      end # class OpenStack
    end
  end # module Identity
end # module Fog

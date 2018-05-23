module Fog
  module Image
    class OpenStack
      class V2
        class Real
          def get_image(image_id)
            request(
              :expects => [200, 204],
              :method  => 'HEAD',
              :path    => "images/#{image_id}"
            )
          end
        end # class Real

        class Mock
          def get_image(_image_id)
            response = Excon::Response.new
            response.status = [200, 204][rand(2)]
            response.headers = {"X-Image-Meta-Is_public" => "True",
                               "X-Image-Meta-Min_disk" => "0",
                               "X-Image-Meta-Property-Ramdisk_id" => "b45aa128-cd36-4ad9-a026-1a1c2bfd8fdc",
                               "X-Image-Meta-Disk_format" => "ami",
                               "X-Image-Meta-Created_at" => "2012-02-21T07:32:26",
                               "X-Image-Meta-Container_format" => "ami",
                               "Etag" => "2f81976cae15c16ef0010c51e3a6c163",
                               "Location" => "http://192.168.27.100:9292/v1/images/0e09fbd6-43c5-448a-83e9-0d3d05f9747e",
                               "X-Image-Meta-Protected" => "False",
                               "Date" => "Fri, 24 Feb 2012 02:14:25 GMT",
                               "X-Image-Meta-Name" => "cirros-0.3.0-x86_64-blank",
                               "X-Image-Meta-Min_ram" => "0", "Content-Type" => "text/html; charset=UTF-8",
                               "X-Image-Meta-Updated_at" => "2012-02-21T07:32:29",
                               "X-Image-Meta-Property-Kernel_id" => "cd28951e-e1c2-4bc5-95d3-f0495abbcdc5",
                               "X-Image-Meta-Size" => "25165824",
                               "X-Image-Meta-Checksum" => "2f81976cae15c16ef0010c51e3a6c163",
                               "X-Image-Meta-Deleted" => "False",
                               "Content-Length" => "0",
                               "X-Image-Meta-Owner" => "ff528b20431645ebb5fa4b0a71ca002f",
                               "X-Image-Meta-Status" => "active",
                               "X-Image-Meta-Id" => "0e09fbd6-43c5-448a-83e9-0d3d05f9747e"}
            response.body = ""
            response
          end # def list_tenants
        end # class Mock
      end # class OpenStack
    end
  end # module Identity
end # module Fog

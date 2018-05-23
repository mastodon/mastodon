module Fog
  module Image
    class OpenStack
      class V1
        class Real
          def get_image_by_id(image_id)
            request(
              :expects => [200],
              :method  => 'HEAD',
              :path    => "images/#{image_id}"
            )
          end
        end # class Real

        class Mock
          def get_image_by_id(image_id)
            response = Excon::Response.new
            response.status = [200, 204][rand(2)]
            response.headers = {
              'X-Image-Meta-Checksum'         => '8a40c862b5735975d82605c1dd395796',
              'X-Image-Meta-Container_format' => 'aki',
              'X-Image-Meta-Created_at'       => '2016-01-06T03:22:20.000000',
              'X-Image-Meta-Deleted'          => 'False',
              'X-Image-Meta-Disk_format'      => 'aki',
              'X-Image-Meta-Id'               => image_id,
              'X-Image-Meta-Is_public'        => 'True',
              'X-Image-Meta-Min_disk'         => 0,
              'X-Image-Meta-Min_ram'          => 0,
              'X-Image-Meta-Name'             => 'cirros-0.3.4-x86_64-uec-kernel',
              'X-Image-Meta-Owner'            => '13cc6052265b41529e2fd0fc461fa8ef',
              'X-Image-Meta-Protected'        => 'False',
              'X-Image-Meta-Size'             => 4979632,
              'X-Image-Meta-Status'           => 'deactivated',
              'X-Image-Meta-Updated_at'       => '2016-02-25T03:02:05.000000',
              'X-Image-Meta-Property-foo'     => 'bar'
            }
            response.body = {}
            response
          end # def list_tenants
        end # class Mock
      end # class OpenStack
    end
  end # module Identity
end # module Fog

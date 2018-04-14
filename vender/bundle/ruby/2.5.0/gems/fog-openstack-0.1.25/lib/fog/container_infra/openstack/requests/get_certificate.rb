module Fog
  module ContainerInfra
    class OpenStack
      class Real
        def get_certificate(bay_uuid)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "certificates/#{cluster_uuid}"
          )
        end
      end

      class Mock
        def get_certificate(_bay_uuid)
          response = Excon::Response.new
          response.status = 200
            response.body = {
              "pem"      => "-----BEGIN CERTIFICATE-----\nMIICzDCCAbSgAwIBAgIQOOkVcEN7TNa9E80GoUs4xDANBgkqhkiG9w0BAQsFADAO\n-----END CERTIFICATE-----\n",
              "bay_uuid" => "0b4b766f-1500-44b3-9804-5a6e12fe6df4"
            }
          response
        end
      end
    end
  end
end

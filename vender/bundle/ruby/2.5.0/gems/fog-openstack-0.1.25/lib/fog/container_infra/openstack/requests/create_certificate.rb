module Fog
  module ContainerInfra
    class OpenStack
      class Real
        def create_certificate(params)
          request(
            :expects => [201, 200],
            :method  => 'POST',
            :path    => "certificates",
            :body    => Fog::JSON.encode(params)
          )
        end
      end

      class Mock
        def create_certificate(_params)
          response = Excon::Response.new
          response.status = 201
          response.body = {
            "pem"          => "-----BEGIN CERTIFICATE-----\nMIIDxDCCAqygAwIBAgIRALgUbIjdKUy8lqErJmCxVfkwDQYJKoZIhvcNAQELBQAw\n-----END CERTIFICATE-----\n",
            "bay_uuid"     => "0b4b766f-1500-44b3-9804-5a6e12fe6df4",
            "csr"          => "-----BEGIN CERTIFICATE REQUEST-----\nMIIEfzCCAmcCAQAwFDESMBAGA1UEAxMJWW91ciBOYW1lMIICIjANBgkqhkiG9w0B\n-----END CERTIFICATE REQUEST-----\n"
          }
          response
        end
      end
    end
  end
end

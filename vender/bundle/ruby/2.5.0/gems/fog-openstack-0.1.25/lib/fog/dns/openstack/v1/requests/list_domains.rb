module Fog
  module DNS
    class OpenStack
      class V1
        class Real
          def list_domains(options = {})
            request(
              :expects => 200,
              :method  => 'GET',
              :path    => 'domains',
              :query   => options
            )
          end
        end

        class Mock
          def list_domains(_options = {})
            response = Excon::Response.new
            response.status = 200
            response.body = {'domains' => data[:domains]}
            response
          end
        end
      end
    end
  end
end

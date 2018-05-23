module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def list_pools(options = {})
            headers, options = Fog::DNS::OpenStack::V2.setup_headers(options)

            request(
              :expects => 200,
              :method  => 'GET',
              :path    => 'pools',
              :query   => options,
              :headers => headers
            )
          end
        end

        class Mock
          def list_pools(_options = {})
            response = Excon::Response.new
            response.status = 200
            response.body = data[:pools]
            response
          end
        end
      end
    end
  end
end

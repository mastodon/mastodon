module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def get_pool(id, options = {})
            headers, _options = Fog::DNS::OpenStack::V2.setup_headers(options)
            request(
              :expects => 200,
              :method  => 'GET',
              :path    => "pools/#{id}",
              :headers => headers
            )
          end
        end

        class Mock
          def get_pool(id, _options = {})
            response = Excon::Response.new
            response.status = 200
            pool = data[:pool_updated] || data[:pools]['pools'].first
            pool['id'] = id
            response.body = pool
            response
          end
        end
      end
    end
  end
end

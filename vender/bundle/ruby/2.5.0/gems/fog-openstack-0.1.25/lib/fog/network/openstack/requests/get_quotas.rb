module Fog
  module Network
    class OpenStack
      class Real
        def get_quotas
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "/quotas"
          )
        end
      end

      class Mock
        def get_quotas
          response = Excon::Response.new
          response.status = 200
          response.body = {
            'quotas' => data[:quotas]
          }
          response
        end
      end
    end
  end
end

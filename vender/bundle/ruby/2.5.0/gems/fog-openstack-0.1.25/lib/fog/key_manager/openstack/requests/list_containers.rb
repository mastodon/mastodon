module Fog
  module KeyManager
    class OpenStack
      class Real
        def list_containers(options = {})
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => 'containers',
            :query   => options
          )
        end
      end

      class Mock
      end
    end
  end
end
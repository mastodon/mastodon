module Fog
  module KeyManager
    class OpenStack
      class Real
        def create_container(options)
          request(
            :body    => Fog::JSON.encode(options),
            :expects => [201],
            :method  => 'POST',
            :path    => 'containers'
          )
        end
      end

      class Mock
      end
    end
  end
end
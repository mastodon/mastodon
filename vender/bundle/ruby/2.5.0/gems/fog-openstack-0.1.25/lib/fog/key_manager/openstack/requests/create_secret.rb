module Fog
  module KeyManager
    class OpenStack
      class Real
        def create_secret(options)
          request(
            :body    => Fog::JSON.encode(options),
            :expects => [201],
            :method  => 'POST',
            :path    => 'secrets'
          )
        end
      end

      class Mock
      end
    end
  end
end
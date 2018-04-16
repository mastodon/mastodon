module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def token_authenticate(auth)
            request(
              :expects => [201],
              :method  => 'POST',
              :path    => "auth/tokens",
              :body    => Fog::JSON.encode(auth)
            )
          end
        end

        class Mock
        end
      end
    end
  end
end

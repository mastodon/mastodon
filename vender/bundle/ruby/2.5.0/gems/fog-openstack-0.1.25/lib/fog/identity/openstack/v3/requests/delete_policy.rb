module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def delete_policy(id)
            request(
              :expects => [204],
              :method  => 'DELETE',
              :path    => "policies/#{id}"
            )
          end
        end

        class Mock
        end
      end
    end
  end
end

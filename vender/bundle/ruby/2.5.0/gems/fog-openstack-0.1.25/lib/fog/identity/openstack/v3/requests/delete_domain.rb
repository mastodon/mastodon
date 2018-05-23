module Fog
  module Identity
    class OpenStack
      class V3
        class Real
          def delete_domain(id)
            request(
              :expects => [204],
              :method  => 'DELETE',
              :path    => "domains/#{id}"
            )
          end
        end

        class Mock
        end
      end
    end
  end
end

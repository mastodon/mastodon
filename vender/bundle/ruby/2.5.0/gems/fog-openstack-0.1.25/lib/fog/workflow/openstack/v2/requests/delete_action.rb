module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def delete_action(name)
            request(
              :expects => 204,
              :method  => "DELETE",
              :path    => "actions/#{URI.encode(name)}"
            )
          end
        end

        class Mock
          def delete_action(_name)
            response = Excon::Response.new
            response.status = 204
            response
          end
        end
      end
    end
  end
end

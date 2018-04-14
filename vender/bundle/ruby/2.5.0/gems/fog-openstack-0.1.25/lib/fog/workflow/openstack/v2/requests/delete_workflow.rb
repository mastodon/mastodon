module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def delete_workflow(identifier)
            request(
              :expects => 204,
              :method  => "DELETE",
              :path    => "workflows/#{identifier}"
            )
          end
        end

        class Mock
          def delete_workflow(_identifier)
            response = Excon::Response.new
            response.status = 204
            response
          end
        end
      end
    end
  end
end

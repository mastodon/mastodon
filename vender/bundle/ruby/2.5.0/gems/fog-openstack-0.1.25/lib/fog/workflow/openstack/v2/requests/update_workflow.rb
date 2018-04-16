module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def update_workflow(definition)
            body = Fog::JSON.encode(definition)
            request(
              :body    => body,
              :expects => 200,
              :method  => "PUT",
              :path    => "workflows"
            )
          end
        end

        class Mock
          def update_workflow(_definition)
            response = Excon::Response.new
            response.status = 200
            response.body = ""
            response
          end
        end
      end
    end
  end
end

module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def create_workflow(definition)
            body = Fog::JSON.encode(definition)
            request(
              :body    => body,
              :expects => 201,
              :method  => "POST",
              :path    => "workflows"
            )
          end
        end

        class Mock
          def create_workflow(_definition)
            response = Excon::Response.new
            response.status = 201
            response.body = ""
            response
          end
        end
      end
    end
  end
end

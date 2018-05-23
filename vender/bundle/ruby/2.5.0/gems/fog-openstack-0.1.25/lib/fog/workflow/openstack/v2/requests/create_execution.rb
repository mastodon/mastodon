module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def create_execution(workflow, input = {})
            data = {:workflow_name => workflow}
            data[:input] = Fog::JSON.encode(input) unless input.empty?
            body = Fog::JSON.encode(data)
            request(
              :body    => body,
              :expects => 201,
              :method  => "POST",
              :path    => "executions"
            )
          end
        end

        class Mock
          def create_execution(_workflow, _input = {})
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

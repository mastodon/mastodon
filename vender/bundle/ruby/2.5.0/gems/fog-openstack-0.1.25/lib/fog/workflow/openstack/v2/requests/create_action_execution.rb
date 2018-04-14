module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def create_action_execution(action, input = {}, params = {})
            data = {:name => action}
            data[:input] = Fog::JSON.encode(input) unless input.empty?
            data[:params] = Fog::JSON.encode(params) unless params.empty?
            body = Fog::JSON.encode(data)
            request(
              :body    => body,
              :expects => 201,
              :method  => "POST",
              :path    => "action_executions"
            )
          end
        end

        class Mock
          def create_action_execution(_action, _input = {}, _params = {})
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

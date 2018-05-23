module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def get_action_execution(execution_id)
            request(
              :expects => 200,
              :method  => "GET",
              :path    => "action_executions/#{execution_id}"
            )
          end
        end

        class Mock
          def get_action_execution(_execution_id)
            response = Excon::Response.new
            response.status = 200
            response.body = {"state" => "running", "id" => "1111"}
            response
          end
        end
      end
    end
  end
end

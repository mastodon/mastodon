module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def list_tasks(workflow_execution_id)
            request(
              :expects => 200,
              :method  => "GET",
              :path    => "executions/#{workflow_execution_id}/tasks"
            )
          end
        end

        class Mock
          def list_tasks(_workflow_execution_id)
            response = Excon::Response.new
            response.status = 200
            response.body = {"tasks" =>
                                        [{"name" => "task1", "description" => "d1"},
                                         {"name" => "task2", "description" => "d2"}]}
            response
          end
        end
      end
    end
  end
end

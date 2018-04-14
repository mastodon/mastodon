module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def rerun_task(task_ex_id)
            rerun_payload = {
              :id    => task_ex_id,
              :state => 'RUNNING',
              :reset => true
            }
            body = Fog::JSON.encode(rerun_payload)
            request(
              :body    => body,
              :expects => 200,
              :method  => "PUT",
              :path    => "tasks/#{task_ex_id}"
            )
          end
        end

        class Mock
          def update_action(_task_ex_id)
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

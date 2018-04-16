module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def create_cron_trigger(name,
                                  workflow_identifier,
                                  workflow_input = nil,
                                  workflow_params = nil,
                                  pattern = "* * * * *",
                                  first_time = nil,
                                  count = nil)
            data = {
              :name                 => name,
              :pattern              => pattern,
              :first_execution_time => first_time,
              :remaining_executions => count
            }
            if workflow_identifier
              data[:workflow_id] = workflow_identifier
            end
            if workflow_input
              data[:workflow_input] = Fog::JSON.encode(workflow_input)
            end
            if workflow_params
              data[:workflow_params] = Fog::JSON.encode(workflow_params)
            end
            body = Fog::JSON.encode(data)
            request(
              :body    => body,
              :expects => 201,
              :method  => "POST",
              :path    => "cron_triggers"
            )
          end
        end

        class Mock
          def create_cron_trigger(_name,
                                  _workflow_identifier,
                                  _workflow_input = nil,
                                  _workflow_params = nil,
                                  _pattern = nil,
                                  _first_time = nil,
                                  _count = nil)
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

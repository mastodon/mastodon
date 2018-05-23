module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def delete_action_execution(id)
            request(
              :expects => 204,
              :method  => "DELETE",
              :path    => "action_executions/#{id}"
            )
          end
        end

        class Mock
          def delete_action_execution(_id)
            response = Excon::Response.new
            response.status = 204
            response
          end
        end
      end
    end
  end
end

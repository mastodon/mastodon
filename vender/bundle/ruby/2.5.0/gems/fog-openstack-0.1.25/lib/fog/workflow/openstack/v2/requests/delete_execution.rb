module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def delete_execution(id)
            request(
              :expects => 204,
              :method  => "DELETE",
              :path    => "executions/#{id}"
            )
          end
        end

        class Mock
          def delete_execution(_id)
            response = Excon::Response.new
            response.status = 204
            response
          end
        end
      end
    end
  end
end

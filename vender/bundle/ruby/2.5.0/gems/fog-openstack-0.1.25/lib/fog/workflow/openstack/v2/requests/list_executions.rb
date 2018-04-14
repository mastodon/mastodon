module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def list_executions
            request(
              :expects => 200,
              :method  => "GET",
              :path    => "executions"
            )
          end
        end

        class Mock
          def list_executions
            response = Excon::Response.new
            response.status = 200
            response.body = {"executions" =>
                                             [{"state" => "ERROR", "id" => "1111"},
                                              {"state" => "RUNNING", "id" => "2222"}]}
            response
          end
        end
      end
    end
  end
end

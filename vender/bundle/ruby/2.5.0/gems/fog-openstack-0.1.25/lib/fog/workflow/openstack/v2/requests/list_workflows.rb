module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def list_workflows(params = {})
            body = Fog::JSON.encode(params)
            request(
              :body    => body,
              :expects => 200,
              :method  => "GET",
              :path    => "workflows"
            )
          end
        end

        class Mock
          def list_workflows(_params = {})
            response = Excon::Response.new
            response.status = 200
            response.body = {"workflows" =>
                                            [{"name" => "workflow1", "description" => "d1"},
                                             {"name" => "workflow2", "description" => "d2"}]}
            response
          end
        end
      end
    end
  end
end

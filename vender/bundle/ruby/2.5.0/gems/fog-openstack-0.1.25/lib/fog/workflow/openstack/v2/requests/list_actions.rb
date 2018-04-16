module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def list_actions(params = {})
            body = Fog::JSON.encode(params)
            request(
              :body    => body,
              :expects => 200,
              :method  => "GET",
              :path    => "actions"
            )
          end
        end

        class Mock
          def list_actions(_params = {})
            response = Excon::Response.new
            response.status = 200
            response.body = {"actions" =>
                                          [{"name" => "action1", "description" => "d1"},
                                           {"name" => "action2", "description" => "d2"}]}
            response
          end
        end
      end
    end
  end
end

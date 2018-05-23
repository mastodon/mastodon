module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def get_workflow(identifier)
            request(
              :expects => 200,
              :method  => "GET",
              :path    => "workflows/#{identifier}"
            )
          end
        end

        class Mock
          def get_workflow(_identifier)
            response = Excon::Response.new
            response.status = 200
            response.body = {"version"     => "2.0",
                             "name"        => "workflow1",
                             "description" => "d1"}
            response
          end
        end
      end
    end
  end
end

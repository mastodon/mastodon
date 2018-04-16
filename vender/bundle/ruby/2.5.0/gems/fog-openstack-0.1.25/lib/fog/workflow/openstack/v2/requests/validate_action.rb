module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def validate_action(definition)
            body = Fog::JSON.encode(definition)
            request(
              :body    => body,
              :expects => 200,
              :method  => "POST",
              :path    => "actions/validate"
            )
          end
        end

        class Mock
          def validate_action(_definition)
            response = Excon::Response.new
            response.status = 200
            response.body = "{\"valid\": true}"
            response
          end
        end
      end
    end
  end
end

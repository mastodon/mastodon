module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def update_environment(definition)
            unless definition["variables"].nil?
              definition["variables"] = Fog::JSON.encode(definition["variables"])
            end
            body = Fog::JSON.encode(definition)
            request(
              :body    => body,
              :expects => 200,
              :method  => "PUT",
              :path    => "environments"
            )
          end
        end

        class Mock
          def update_environment(_definition)
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

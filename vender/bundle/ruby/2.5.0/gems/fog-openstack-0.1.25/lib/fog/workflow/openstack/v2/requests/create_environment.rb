module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def create_environment(definition)
            unless definition["variables"].nil?
              definition["variables"] = Fog::JSON.encode(definition["variables"])
            end
            body = Fog::JSON.encode(definition)
            request(
              :body    => body,
              :expects => 201,
              :method  => "POST",
              :path    => "environments"
            )
          end
        end

        class Mock
          def create_environment(_definition)
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

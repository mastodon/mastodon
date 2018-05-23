module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def get_environment(name)
            request(
              :expects => 200,
              :method  => "GET",
              :path    => "environments/#{URI.encode(name)}"
            )
          end
        end

        class Mock
          def get_environment(_name)
            response = Excon::Response.new
            response.status = 200
            response.body = {"name"      => "environment1",
                             "variables" => {"var1" => "value1",
                                             "var2" => "value2"}}
            response
          end
        end
      end
    end
  end
end

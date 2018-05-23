module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def list_environments
            request(
              :expects => 200,
              :method  => "GET",
              :path    => "environments"
            )
          end
        end

        class Mock
          def list_environments
            response = Excon::Response.new
            response.status = 200
            response.body = {"environments" =>
                                               [{"name" => "environment1", "description" => "d1"},
                                                {"name" => "environment2", "description" => "d2"}]}
            response
          end
        end
      end
    end
  end
end

module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def list_services
            request(
              :expects => 200,
              :method  => "GET",
              :path    => "services"
            )
          end
        end

        class Mock
          def list_services
            response = Excon::Response.new
            response.status = 200
            response.body = {"services" =>
                                           [{"name" => "service1", "description" => "d1"},
                                            {"name" => "service2", "description" => "d2"}]}
            response
          end
        end
      end
    end
  end
end

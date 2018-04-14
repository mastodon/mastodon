module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def get_task(id)
            request(
              :expects => 200,
              :method  => "GET",
              :path    => "tasks/#{id}"
            )
          end
        end

        class Mock
          def get_task(_id)
            response = Excon::Response.new
            response.status = 200
            response.body = {"version" => "2.0",
                             "task1"   => {"id" => ['test_id']}}
            response
          end
        end
      end
    end
  end
end

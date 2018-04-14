module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def get_action(name)
            request(
              :expects => 200,
              :method  => "GET",
              :path    => "actions/#{URI.encode(name)}"
            )
          end
        end

        class Mock
          def get_action(_name)
            response = Excon::Response.new
            response.status = 200
            response.body = {"version" => "2.0",
                             "action1" => {"input" => ['test_id']}}
            response
          end
        end
      end
    end
  end
end

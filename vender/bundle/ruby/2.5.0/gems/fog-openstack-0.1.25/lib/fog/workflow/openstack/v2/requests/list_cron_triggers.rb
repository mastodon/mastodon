module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def list_cron_triggers
            request(
              :expects => 200,
              :method  => "GET",
              :path    => "cron_triggers"
            )
          end
        end

        class Mock
          def list_cron_triggers
            response = Excon::Response.new
            response.status = 200
            response.body = {"cron_triggers" =>
                                                [{"name" => "cron_trigger1", "description" => "d1"},
                                                 {"name" => "cron_trigger2", "description" => "d2"}]}
            response
          end
        end
      end
    end
  end
end

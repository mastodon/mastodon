module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def delete_cron_trigger(name)
            request(
              :expects => 204,
              :method  => "DELETE",
              :path    => "cron_triggers/#{URI.encode(name)}"
            )
          end
        end

        class Mock
          def delete_cron_trigger(_name)
            response = Excon::Response.new
            response.status = 204
            response
          end
        end
      end
    end
  end
end

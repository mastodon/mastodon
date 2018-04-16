module Fog
  module Introspection
    class OpenStack
      class Real
        def get_rules(rule_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "rules/#{rule_id}"
          )
        end
      end

      class Mock
        def get_rules(_rule_id)
          response = Excon::Response.new
          response.status = 200
          response.body = {"rules" => data[:rules].first}
          response
        end
      end
    end
  end
end

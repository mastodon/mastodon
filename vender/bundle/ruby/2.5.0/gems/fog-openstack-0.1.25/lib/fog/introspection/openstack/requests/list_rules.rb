module Fog
  module Introspection
    class OpenStack
      class Real
        def list_rules
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "rules"
          )
        end
      end

      class Mock
        def list_rules
          response = Excon::Response.new
          response.status = 200
          response.body = {"rules" => data[:rules].first}
          response
        end
      end
    end
  end
end

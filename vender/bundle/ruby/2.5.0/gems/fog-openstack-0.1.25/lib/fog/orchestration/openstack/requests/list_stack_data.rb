module Fog
  module Orchestration
    class OpenStack
      class Real
        def list_stack_data(options = {})
          request(
            :method  => 'GET',
            :path    => 'stacks',
            :expects => 200,
            :query   => options
          )
        end
      end

      class Mock
        def list_stack_data(_options = {})
          stacks = data[:stacks].values

          Excon::Response.new(
            :body   => {'stacks' => stacks},
            :status => 200
          )
        end
      end
    end
  end
end

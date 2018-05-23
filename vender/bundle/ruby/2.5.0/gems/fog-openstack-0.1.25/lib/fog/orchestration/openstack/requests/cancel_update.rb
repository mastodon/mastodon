# frozen_string_literal: true
module Fog
  module Orchestration
    class OpenStack
      class Real
        def cancel_update(stack)
          request(
            :expects => 200,
            :method  => 'POST',
            :path    => "stacks/#{stack.stack_name}/#{stack.id}/actions",
            :body    => Fog::JSON.encode('cancel_update' => nil)
          )
        end
      end

      class Mock
        def cancel_update(_)
          response = Excon::Response.new
          response.status = 200
          response.body = {}
          response
        end
      end
    end
  end
end

module Fog
  module Orchestration
    class OpenStack
      class Real
        def abandon_stack(stack)
          request(
            :expects => [200],
            :method  => 'DELETE',
            :path    => "stacks/#{stack.stack_name}/#{stack.id}/abandon"
          )
        end
      end
    end
  end
end

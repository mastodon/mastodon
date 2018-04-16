module Fog
  module Orchestration
    class OpenStack
      class Real
        def get_stack_template(stack)
          request(
            :method  => 'GET',
            :path    => "stacks/#{stack.stack_name}/#{stack.id}/template",
            :expects => 200
          )
        end
      end

      class Mock
        def get_stack_template(stack)
        end
      end
    end
  end
end

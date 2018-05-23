module Fog
  module Orchestration
    class OpenStack
      class Real
        # Delete a stack.
        #
        # @param [Stack] Stack to be deleted
        #
        # @return [Excon::Response]
        #
        # @see http://developer.openstack.org/api-ref-orchestration-v1.html

        def delete_stack(arg1, arg2 = nil)
          if arg1.kind_of?(Stack)
            # Normal use: delete_stack(stack)
            stack = arg1
            stack_name = stack.stack_name
            stack_id = stack.id
          else
            # Deprecated: delete_stack(stack_name, stack_id)
            Fog::Logger.deprecation("#delete_stack(stack_name, stack_id) is deprecated, use #delete_stack(stack) instead [light_black](#{caller.first})[/]")
            stack_name = arg1
            stack_id = arg2
          end

          request(
            :expects => 204,
            :path    => "stacks/#{stack_name}/#{stack_id}",
            :method  => 'DELETE'
          )
        end
      end

      class Mock
        def delete_stack(arg1, arg2 = nil)
          if arg1.kind_of?(Stack)
            # Normal use: delete_stack(stack)
            stack = arg1
            stack_name = stack.stack_name
            stack_id = stack.id
          else
            # Deprecated: delete_stack(stack_name, stack_id)
            Fog::Logger.deprecation("#delete_stack(stack_name, stack_id) is deprecated, use #delete_stack(stack) instead [light_black](#{caller.first})[/]")
            stack_name = arg1
            stack_id = arg2
          end

          data[:stacks].delete(stack_id)

          response = Excon::Response.new
          response.status = 204
          response.body = {}
          response
        end
      end
    end
  end
end

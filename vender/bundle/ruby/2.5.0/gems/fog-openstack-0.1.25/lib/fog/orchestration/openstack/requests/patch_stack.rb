module Fog
  module Orchestration
    class OpenStack
      class Real
        # patch a stack.
        #
        # @param [Fog::Orchestration::OpenStack::Stack] the stack to patch.
        # @param [Hash] options
        #   * :template [String] Structure containing the template body.
        #   or (one of the two Template parameters is required)
        #   * :template_url [String] URL of file containing the template body.
        #   * :parameters [Hash] Hash of providers to supply to template.
        #
        def patch_stack(stack, options = {})
          stack_name = stack.stack_name
          stack_id = stack.id

          request(
            :expects => 202,
            :path    => "stacks/#{stack_name}/#{stack_id}",
            :method  => 'PATCH',
            :body    => Fog::JSON.encode(options)
          )
        end
      end

      class Mock
        def patch_stack(_stack, _options = {})
          response = Excon::Response.new
          response.status = 202
          response.body = {}
          response
        end
      end
    end
  end
end

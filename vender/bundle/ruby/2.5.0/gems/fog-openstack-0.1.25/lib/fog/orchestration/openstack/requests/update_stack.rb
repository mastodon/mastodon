module Fog
  module Orchestration
    class OpenStack
      class Real
        # Update a stack.
        #
        # @param [Fog::Orchestration::OpenStack::Stack] the stack to update.
        # @param [Hash] options
        #   * :template [String] Structure containing the template body.
        #   or (one of the two Template parameters is required)
        #   * :template_url [String] URL of file containing the template body.
        #   * :parameters [Hash] Hash of providers to supply to template.
        #   * :files [Hash] Hash with files resources.
        #
        def update_stack(arg1, arg2 = nil, arg3 = nil)
          if arg1.kind_of?(Stack)
            # Normal use, update_stack(stack, options = {})
            stack = arg1
            stack_name = stack.stack_name
            stack_id = stack.id
            options = arg2.nil? ? {} : arg2
          else
            # Deprecated, update_stack(stack_id, stack_name, options = {})
            Fog::Logger.deprecation("#update_stack(stack_id, stack_name, options) is deprecated, use #update_stack(stack, options) instead [light_black](#{caller.first})[/]")
            stack_id = arg1
            stack_name = arg2
            options = {
              :stack_name => stack_name
            }.merge(arg3.nil? ? {} : arg3)
          end

          # Templates should always:
          #  - be strings
          #  - contain URI references instead of relative paths.
          # Passing :template_url may not work well with `get_file` and remote `type`:
          #  the python client implementation in shade retrieves from :template_uri
          #  and replaces it with :template.
          #  see https://github.com/openstack-infra/shade/blob/master/shade/openstackcloud.py#L1201
          #  see https://developer.openstack.org/api-ref/orchestration/v1/index.html#create-stack
          file_resolver = Util::RecursiveHotFileLoader.new(options[:template] || options[:template_url], options[:files])
          options[:template] = file_resolver.template
          options[:files] = file_resolver.files unless file_resolver.files.empty?

          request(
            :expects => 202,
            :path    => "stacks/#{stack_name}/#{stack_id}",
            :method  => 'PUT',
            :body    => Fog::JSON.encode(options)
          )
        end
      end

      class Mock
        def update_stack(arg1, arg2 = nil, arg3 = nil)
          if arg1.kind_of?(Stack)
            # Normal use, update_stack(stack, options = {})
            stack = arg1
            stack_name = stack.stack_name
            stack_id = stack.id
            options = arg2.nil? ? {} : arg2
          else
            # Deprecated, update_stack(stack_id, stack_name, options = {})
            Fog::Logger.deprecation("#update_stack(stack_id, stack_name, options) is deprecated, use #update_stack(stack, options) instead [light_black](#{caller.first})[/]")
            stack_id = arg1
            stack_name = arg2
            options = {
              :stack_name => stack_name
            }.merge(arg3.nil? ? {} : arg3)
          end

          if options.key?(:files)
            response.body['files'] = {'foo.sh' => 'hello'}
          end

          if options.key?(:template) || options.key?(:template_url)
            file_resolver = Util::RecursiveHotFileLoader.new(options[:template] || options[:template_url], options[:files])
            response.body['files'] = file_resolver.files unless file_resolver.files.empty?
          end

          response = Excon::Response.new
          response.status = 202
          response.body = {}
          response
        end
      end
    end
  end
end

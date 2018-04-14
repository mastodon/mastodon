module Fog
  module Orchestration
    class OpenStack
      class Real
        # Create a stack.
        #
        #
        # * options [Hash]:
        #   * :stack_name [String] Name of the stack to create.
        #   * :template [String] Structure containing the template body.
        #   or (one of the two Template parameters is required)
        #   * :template_url [String] URL of file containing the template body.
        #   * :files [Hash] Hash with files resources.
        #   * :disable_rollback [Boolean] Controls rollback on stack creation failure, defaults to false.
        #   * :parameters [Hash] Hash of providers to supply to template
        #   * :timeout_mins [Integer] Minutes to wait before status is set to CREATE_FAILED
        #
        # @see http://developer.openstack.org/api-ref-orchestration-v1.html

        def create_stack(arg1, arg2 = nil)
          if arg1.kind_of?(Hash)
            # Normal use: create_stack(options)
            options = arg1
          else
            # Deprecated: create_stack(stack_name, options = {})
            Fog::Logger.deprecation("#create_stack(stack_name, options) is deprecated, use #create_stack(options) instead [light_black](#{caller.first})[/]")
            options = {
              :stack_name => arg1
            }.merge(arg2.nil? ? {} : arg2)
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
            :expects => 201,
            :path    => 'stacks',
            :method  => 'POST',
            :body    => Fog::JSON.encode(options)
          )
        end
      end

      class Mock
        def create_stack(arg1, arg2 = nil)
          if arg1.kind_of?(Hash)
            # Normal use: create_stack(options)
            options = arg1
          else
            # Deprecated: create_stack(stack_name, options = {})
            Fog::Logger.deprecation("#create_stack(stack_name, options) is deprecated, use #create_stack(options) instead [light_black](#{caller.first})[/]")
            options = {
              :stack_name => arg1
            }.merge(arg2.nil? ? {} : arg2)
          end

          stack_id = Fog::Mock.random_hex(32)
          stack = data[:stacks][stack_id] = {
            'id'                  => stack_id,
            'stack_name'          => options[:stack_name],
            'links'               => [],
            'description'         => options[:description],
            'stack_status'        => 'CREATE_COMPLETE',
            'stack_status_reason' => 'Stack successfully created',
            'creation_time'       => Time.now,
            'updated_time'        => Time.now
          }

          response = Excon::Response.new
          response.status = 201
          response.body = {
            'id'    => stack_id,
            'links' => [{"href" => "http://localhost:8004/v1/fake_tenant_id/stacks/#{options[:stack_name]}/#{stack_id}", "rel" => "self"}]
          }

          if options.key?(:files)
            response.body['files'] = {'foo.sh' => 'hello'}
          end

          if options.key?(:template) || options.key?(:template_url)
            file_resolver = Util::RecursiveHotFileLoader.new(options[:template] || options[:template_url], options[:files])
            response.body['files'] = file_resolver.files unless file_resolver.files.empty?
          end

          response
        end
      end
    end
  end
end

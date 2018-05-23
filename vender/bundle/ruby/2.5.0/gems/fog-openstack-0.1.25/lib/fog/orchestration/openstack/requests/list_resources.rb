module Fog
  module Orchestration
    class OpenStack
      class Real
        def list_resources(options = {}, options_deprecated = {})
          if options.kind_of?(Hash)
            if !options.key?(:stack) && !(options.key?(:stack_name) && options.key?(:stack_id))
              raise(ArgumentError, "Missing required options keys: :stack or :stack_name and :stack_id, while calling "\
                                   " .list_resources(options)")
            end

            stack        = options.delete(:stack)
            stack_name   = options.delete(:stack_name)
            stack_name ||= stack.stack_name if stack && stack.respond_to?(:stack_name)
            stack_id     = options.delete(:stack_id)
            stack_id   ||=  stack.id if stack && stack.respond_to?(:id)
            path         = "stacks/#{stack_name}/#{stack_id}/resources"
            params       = options
          else
            Fog::Logger.deprecation('Calling OpenStack[:orchestration].list_resources(stack, options) is deprecated, '\
                                    ' call .list_resources(:stack => stack) or '\
                                    ' .list_resources(:stack_name => value, :stack_id => value) instead')
            path   = "stacks/#{options.stack_name}/#{options.id}/resources"
            params = options_deprecated
          end

          request(:method  => 'GET',
                  :path    => path,
                  :expects => 200,
                  :query   => params)
        end
      end

      class Mock
        def list_resources(_options = {}, _options_deprecated = {})
          resources = data[:resources].values

          Excon::Response.new(
            :body   => {'resources' => resources},
            :status => 200
          )
        end
      end
    end
  end
end

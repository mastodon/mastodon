module Fog
  module Orchestration
    class OpenStack
      class Real
        def list_events(options = {})
          if !options.key?(:stack) && !(options.key?(:stack_name) && options.key?(:stack_id))
            raise(ArgumentError, "Missing required options keys: :stack or :stack_name and :stack_id, while calling "\
                                 " .list_events(options)")
          end

          stack        = options.delete(:stack)
          stack_name   = options.delete(:stack_name)
          stack_name ||= stack.stack_name if stack && stack.respond_to?(:stack_name)
          stack_id     = options.delete(:stack_id)
          stack_id   ||= stack.id if stack && stack.respond_to?(:id)

          resource        = options.delete(:resource)
          resource_name   = options.delete(:resource_name)
          resource_name ||= resource.resource_name if resource && resource.respond_to?(:resource_name)

          path = if resource_name
                   "stacks/#{stack_name}/#{stack_id}/resources/#{resource_name}/events"
                 else
                   "stacks/#{stack_name}/#{stack_id}/events"
                 end

          request(:method  => 'GET',
                  :path    => path,
                  :expects => 200,
                  :query   => options)
        end
      end

      class Mock
        def list_events(_options = {})
          events = data[:events].values

          Excon::Response.new(
            :body   => {'events' => events},
            :status => 200
          )
        end
      end
    end
  end
end

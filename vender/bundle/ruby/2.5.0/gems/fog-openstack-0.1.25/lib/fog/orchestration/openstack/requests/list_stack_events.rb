module Fog
  module Orchestration
    class OpenStack
      class Real
        def list_stack_events(stack, options = {})
          Fog::Logger.deprecation('Calling OpenStack[:orchestration].list_stack_events(stack, options)'\
                                  ' is deprecated, call .list_events(:stack => stack) or '\
                                  ' .list_events(:stack_name => value, :stack_id => value) instead')

          uri = "stacks/#{stack.stack_name}/#{stack.id}/events"
          request(:method => 'GET', :path => uri, :expects => 200, :query => options)
        end
      end

      class Mock
        def list_stack_events(_stack, _options = {})
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

module Fog
  module Orchestration
    class OpenStack
      class Real
        def list_resource_events(stack, resource, options = {})
          Fog::Logger.deprecation('Calling OpenStack[:orchestration].list_resource_events(stack, resource, options)'\
                                  ' is deprecated, call .list_events(:stack => stack, :resource => resource) or '\
                                  ' .list_events(:stack_name => value, :stack_id => value, :resource_name => value)'\
                                  ' instead')

          uri = "stacks/#{stack.stack_name}/#{stack.id}/resources/#{resource.resource_name}/events"
          request(:method => 'GET', :path => uri, :expects => 200, :query => options)
        end
      end

      class Mock
        def list_resource_events(_stack, _resource, _options = {})
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

module Fog
  module Orchestration
    class OpenStack
      class Real
        def show_event_details(stack, resource, event_id)
          request(
            :method  => 'GET',
            :path    => "stacks/#{stack.stack_name}/#{stack.id}/resources/#{resource.resource_name}/events/#{event_id}",
            :expects => 200
          )
        end
      end

      class Mock
        def show_event_details(_stack, _event)
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

require 'fog/openstack/models/collection'
require 'fog/event/openstack/models/event'

module Fog
  module Event
    class OpenStack
      class Events < Fog::OpenStack::Collection
        model Fog::Event::OpenStack::Event

        def all(q = [])
          load_response(service.list_events(q))
        end

        def find_by_id(message_id)
          event = service.get_event(message_id).body
          new(event)
        rescue Fog::Event::OpenStack::NotFound
          nil
        end
      end
    end
  end
end

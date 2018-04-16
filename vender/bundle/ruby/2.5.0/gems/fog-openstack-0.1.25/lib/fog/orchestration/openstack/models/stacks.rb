require 'fog/openstack/models/collection'
require 'fog/orchestration/openstack/models/stack'

module Fog
  module Orchestration
    class OpenStack
      class Stacks < Fog::OpenStack::Collection
        model Fog::Orchestration::OpenStack::Stack

        def all(options = {})
          # TODO(lsmola) we can uncomment this when https://bugs.launchpad.net/heat/+bug/1468318 is fixed, till then
          # we will use non detailed list
          # data = service.list_stack_data_detailed(options).body['stacks']
          data = service.list_stack_data(options)
          load_response(data, 'stacks')
        end

        def summary(options = {})
          data = service.list_stack_data(options)
          load_response(data, 'stacks')
        end

        # Deprecated
        def find_by_id(id)
          Fog::Logger.deprecation("#find_by_id(id) is deprecated, use #get(name, id) instead [light_black](#{caller.first})[/]")
          find { |stack| stack.id == id }
        end

        def get(arg1, arg2 = nil)
          if arg2.nil?
            # Deprecated: get(id)
            Fog::Logger.deprecation("#get(id) is deprecated, use #get(name, id) instead [light_black](#{caller.first})[/]")
            return find_by_id(arg1)
          end

          # Normal use: get(name, id)
          name = arg1
          id = arg2
          data = service.show_stack_details(name, id).body['stack']
          new(data)
        rescue Fog::Compute::OpenStack::NotFound
          nil
        end

        def adopt(options = {})
          service.create_stack(options)
        end

        def create(options = {})
          service.create_stack(options).body['stack']
        end

        def preview(options = {})
          data = service.preview_stack(options).body['stack']
          new(data)
        end

        def build_info
          service.build_info.body
        end
      end
    end
  end
end

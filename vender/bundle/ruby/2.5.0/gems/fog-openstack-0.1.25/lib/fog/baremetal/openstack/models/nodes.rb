require 'fog/openstack/models/collection'
require 'fog/baremetal/openstack/models/node'

module Fog
  module Baremetal
    class OpenStack
      class Nodes < Fog::OpenStack::Collection
        model Fog::Baremetal::OpenStack::Node

        def all(options = {})
          load_response(service.list_nodes_detailed(options), 'nodes')
        end

        def summary(options = {})
          load_response(service.list_nodes(options), 'nodes')
        end

        def details(options = {})
          Fog::Logger.deprecation("Calling OpenStack[:baremetal].nodes.details will be removed, "\
                                  " call .nodes.all for detailed list.")
          load(service.list_nodes_detailed(options).body['nodes'])
        end

        def find_by_uuid(uuid)
          new(service.get_node(uuid).body)
        end
        alias get find_by_uuid

        def destroy(uuid)
          node = find_by_uuid(uuid)
          node.destroy
        end

        def method_missing(method_sym, *arguments, &block)
          if method_sym.to_s =~ /^find_by_(.*)$/
            load(service.list_nodes_detailed($1 => arguments.first).body['nodes'])
          else
            super
          end
        end
      end
    end
  end
end

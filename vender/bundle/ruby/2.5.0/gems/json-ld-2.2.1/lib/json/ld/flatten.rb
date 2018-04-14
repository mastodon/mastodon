# -*- encoding: utf-8 -*-
# frozen_string_literal: true
module JSON::LD
  module Flatten
    include Utils

    ##
    # This algorithm creates a JSON object node map holding an indexed representation of the graphs and nodes represented in the passed expanded document. All nodes that are not uniquely identified by an IRI get assigned a (new) blank node identifier. The resulting node map will have a member for every graph in the document whose value is another object with a member for every node represented in the document. The default graph is stored under the @default member, all other graphs are stored under their graph name.
    #
    # @param [Array, Hash] input
    #   Expanded JSON-LD input
    # @param [Hash] graphs A map of graph name to subjects
    # @param [String] graph
    #   The name of the currently active graph that the processor should use when processing.
    # @param [String] name
    #   The name assigned to the current input if it is a bnode
    # @param [Array] list
    #   List to append to, nil for none
    def create_node_map(input, graphs, graph: '@default', name: nil, list: nil)
      #log_debug("node_map") {"graph: #{graph}, input: #{input.inspect}, name: #{name}"}
      case input
      when Array
        # If input is an array, process each entry in input recursively by passing item for input, node map, active graph, active subject, active property, and list.
        input.map {|o| create_node_map(o, graphs, graph: graph, list: list)}
      when Hash
        type = input['@type']
        if value?(input)
          # Rename blanknode @type
          input['@type'] = namer.get_name(type) if type && blank_node?(type)
          list << input if list
        else
          # Input is a node definition

          # spec requires @type to be named first, so assign names early
          Array(type).each {|t| namer.get_name(t) if blank_node?(t)}

          # get name for subject
          if name.nil?
            name ||= input['@id']
            name = namer.get_name(name) if blank_node?(name)
          end

          # add subject reference to list
          list << {'@id' => name} if list

          # create new subject or merge into existing one
          subject = (graphs[graph] ||= {})[name] ||= {'@id' => name}

          input.keys.kw_sort.each do |property|
            objects = input[property]
            case property
            when '@id'
              # Skip
            when '@reverse'
              # handle reverse properties
              referenced_node, reverse_map = {'@id' => name}, objects
              reverse_map.each do |reverse_property, items|
                items.each do |item|
                  item_name = item['@id']
                  item_name = namer.get_name(item_name) if blank_node?(item_name)
                  create_node_map(item, graphs, graph: graph, name: item_name)
                  add_value(graphs[graph][item_name],
                            reverse_property,
                            referenced_node,
                            property_is_array: true,
                            allow_duplicate: false)
                end
              end
            when '@graph'
              graphs[name] ||= {}
              create_node_map(objects, graphs, graph: name)
            when /^@(?!type)/
              # copy non-@type keywords
              if property == '@index' && subject['@index']
                raise JsonLdError::ConflictingIndexes,
                      "Element already has index #{subject['@index']} dfferent from #{input['@index']}" if
                      subject['@index'] != input['@index']
                subject['@index'] = input.delete('@index')
              end
              subject[property] = objects
            else
              # if property is a bnode, assign it a new id
              property = namer.get_name(property) if blank_node?(property)

              add_value(subject, property, [], property_is_array: true) if objects.empty?

              objects.each do |o|
                o = namer.get_name(o) if property == '@type' && blank_node?(o)

                case
                when node?(o) || node_reference?(o)
                  id = o['@id']
                  id = namer.get_name(id) if blank_node?(id)

                  # add reference and recurse
                  add_value(subject, property, {'@id' => id}, property_is_array: true, allow_duplicate: false)
                  create_node_map(o, graphs, graph: graph, name: id)
                when list?(o)
                  olist = []
                  create_node_map(o['@list'], graphs, graph: graph, name: name, list: olist)
                  o = {'@list' => olist}
                  add_value(subject, property, o, property_is_array: true, allow_duplicate: true)
                else
                  # handle @value
                  create_node_map(o, graphs, graph: graph, name: name)
                  add_value(subject, property, o, property_is_array: true, allow_duplicate: false)
                end
              end
            end
          end
        end
      else
        # add non-object to list
        list << input if list
      end
    end

  private
    ##
    # Merge nodes from all graphs in the graph_map into a new node map
    #
    # @param [Hash{String => Hash}] graph_map
    # @return [Hash]
    def merge_node_map_graphs(graph_map)
      merged = {}
      graph_map.each do |name, node_map|
        node_map.each do |id, node|
          merged_node = (merged[id] ||= {'@id' => id})

          # Iterate over node properties
          node.each do |property, values|
            if property.start_with?('@')
              # Copy keywords
              merged_node[property] = node[property].dup
            else
              # Merge objects
              values.each do |value|
                add_value(merged_node, property, value.dup, property_is_array: true)
              end
            end
          end
        end
      end

      merged
    end
  end
end

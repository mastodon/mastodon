# -*- encoding: utf-8 -*-
# frozen_string_literal: true
require 'rdf'
require 'rdf/nquads'

module JSON::LD
  module ToRDF
    include Utils

    ##
    # @param [Hash{String => Object}] item
    # @param [RDF::Resource] graph_name
    # @yield statement
    # @yieldparam [RDF::Statement] statement
    # @return RDF::Resource the subject of this item
    def item_to_rdf(item, graph_name: nil, &block)
      # Just return value object as Term
      if value?(item)
        value, datatype = item.fetch('@value'), item.fetch('@type', nil)

        case value
        when TrueClass, FalseClass
          # If value is true or false, then set value its canonical lexical form as defined in the section Data Round Tripping. If datatype is null, set it to xsd:boolean.
          value = value.to_s
          datatype ||= RDF::XSD.boolean.to_s
        when Numeric
          # Otherwise, if value is a number, then set value to its canonical lexical form as defined in the section Data Round Tripping. If datatype is null, set it to either xsd:integer or xsd:double, depending on if the value contains a fractional and/or an exponential component.
          lit = RDF::Literal.new(value, canonicalize: true)
          value = lit.to_s
          datatype ||= lit.datatype
        else
          # Otherwise, if datatype is null, set it to xsd:string or xsd:langString, depending on if item has a @language key.
          datatype ||= item.has_key?('@language') ? RDF.langString : RDF::XSD.string
        end
        datatype = RDF::URI(datatype) if datatype && !datatype.is_a?(RDF::URI)
                  
        # Initialize literal as an RDF literal using value and datatype. If element has the key @language and datatype is xsd:string, then add the value associated with the @language key as the language of the object.
        language = item.fetch('@language', nil)
        return RDF::Literal.new(value, datatype: datatype, language: language)
      end

      subject = item['@id'] ? as_resource(item['@id']) : node
      #log_debug("item_to_rdf")  {"subject: #{subject.to_ntriples rescue 'malformed rdf'}"}
      item.each do |property, values|
        case property
        when '@type'
          # If property is @type, construct triple as an RDF Triple composed of id, rdf:type, and object from values where id and object are represented either as IRIs or Blank Nodes
          values.each do |v|
            object = as_resource(v)
            #log_debug("item_to_rdf")  {"type: #{object.to_ntriples rescue 'malformed rdf'}"}
            yield RDF::Statement(subject, RDF.type, object, graph_name: graph_name)
          end
        when '@graph'
          values = [values].compact unless values.is_a?(Array)
          values.each do |nd|
            item_to_rdf(nd, graph_name: subject, &block)
          end
        when '@reverse'
          raise "Huh?" unless values.is_a?(Hash)
          values.each do |prop, vv|
            predicate = as_resource(prop)
            #log_debug("item_to_rdf")  {"@reverse predicate: #{predicate.to_ntriples rescue 'malformed rdf'}"}
            # For each item in values
            vv.each do |v|
              if list?(v)
                #log_debug("item_to_rdf")  {"list: #{v.inspect}"}
                # If item is a list object, initialize list_results as an empty array, and object to the result of the List Conversion algorithm, passing the value associated with the @list key from item and list_results.
                object = parse_list(v['@list'], graph_name: graph_name, &block)

                # Append a triple composed of object, prediate, and object to results and add all triples from list_results to results.
                yield RDF::Statement(object, predicate, subject, graph_name: graph_name)
              else
                # Otherwise, item is a value object or a node definition. Generate object as the result of the Object Converstion algorithm passing item.
                object = item_to_rdf(v, graph_name: graph_name, &block)
                #log_debug("item_to_rdf")  {"subject: #{object.to_ntriples rescue 'malformed rdf'}"}
                # yield subject, prediate, and literal to results.
                yield RDF::Statement(object, predicate, subject, graph_name: graph_name)
              end
            end
          end
        when /^@/
          # Otherwise, if @type is any other keyword, skip to the next property-values pair
        else
          # Otherwise, property is an IRI or Blank Node identifier
          # Initialize predicate from  property as an IRI or Blank node
          predicate = as_resource(property)
          #log_debug("item_to_rdf")  {"predicate: #{predicate.to_ntriples rescue 'malformed rdf'}"}

          # For each item in values
          values.each do |v|
            if list?(v)
              #log_debug("item_to_rdf")  {"list: #{v.inspect}"}
              # If item is a list object, initialize list_results as an empty array, and object to the result of the List Conversion algorithm, passing the value associated with the @list key from item and list_results.
              object = parse_list(v['@list'], graph_name: graph_name, &block)

              # Append a triple composed of subject, prediate, and object to results and add all triples from list_results to results.
              yield RDF::Statement(subject, predicate, object, graph_name: graph_name)
            else
              # Otherwise, item is a value object or a node definition. Generate object as the result of the Object Converstion algorithm passing item.
              object = item_to_rdf(v, graph_name: graph_name, &block)
              #log_debug("item_to_rdf")  {"object: #{object.to_ntriples rescue 'malformed rdf'}"}
              # yield subject, prediate, and literal to results.
              yield RDF::Statement(subject, predicate, object, graph_name: graph_name)
            end
          end
        end
      end

      subject
    end

    ##
    # Parse a List
    #
    # @param [Array] list
    #   The Array to serialize as a list
    # @yield statement
    # @yieldparam [RDF::Resource] statement
    # @return [Array<RDF::Statement>]
    #   Statements for each item in the list
    def parse_list(list, graph_name: nil, &block)
      #log_debug('parse_list') {"list: #{list.inspect}"}

      last = list.pop
      result = first_bnode = last ? node : RDF.nil

      list.each do |list_item|
        # Set first to the result of the Object Converstion algorithm passing item.
        object = item_to_rdf(list_item, graph_name: graph_name, &block)
        yield RDF::Statement(first_bnode, RDF.first, object, graph_name: graph_name)
        rest_bnode = node
        yield RDF::Statement(first_bnode, RDF.rest, rest_bnode, graph_name: graph_name)
        first_bnode = rest_bnode
      end
      if last
        object = item_to_rdf(last, graph_name: graph_name, &block)
        yield RDF::Statement(first_bnode, RDF.first, object, graph_name: graph_name)
        yield RDF::Statement(first_bnode, RDF.rest, RDF.nil, graph_name: graph_name)
      end
      result
    end

    ##
    # Create a new named node using the sequence
    def node
      RDF::Node.new(namer.get_sym)
    end
  end
end

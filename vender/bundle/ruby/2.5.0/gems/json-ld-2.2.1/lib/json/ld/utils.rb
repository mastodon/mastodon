# -*- encoding: utf-8 -*-
# frozen_string_literal: true
module JSON::LD
  module Utils
    ##
    # Is value a node? A value is a node if
    # * it is a Hash
    # * it is not a @value, @set or @list
    # * it has more than 1 key or any key is not @id
    # @param [Object] value
    # @return [Boolean]
    def node?(value)
      value.is_a?(Hash) &&
        !(value.has_key?('@value') || value.has_key?('@list') || value.has_key?('@set')) &&
        (value.length > 1 || !value.has_key?('@id'))
    end

    ##
    # Is value a node reference?
    # @param [Object] value
    # @return [Boolean]
    def node_reference?(value)
      value.is_a?(Hash) && value.length == 1 && value.key?('@id')
    end

    ##
    # Is value a node or a node reference reference?
    # @param [Object] value
    # @return [Boolean]
    def node_or_ref?(value)
      value.is_a?(Hash) &&
        !(value.has_key?('@value') || value.has_key?('@list') || value.has_key?('@set'))
    end

    ##
    # Is value a blank node? Value is a blank node
    #
    # @param [Object] value
    # @return [Boolean]
    def blank_node?(value)
      case value
      when nil    then true
      when String then value.start_with?('_:')
      else
        (node?(value) || node_reference?(value)) && value.fetch('@id', '_:').start_with?('_:')
      end
    end

    ##
    # Is value an expaned @graph?
    #
    # Note: A value is a simple graph if all of these hold true:
    # 1. It is an object.
    # 2. It has an `@graph` key.
    # 3. It may have '@context', '@id' or '@index'
    #
    # @param [Object] value
    # @return [Boolean]
    def graph?(value)
      value.is_a?(Hash) && (value.keys - UTIL_GRAPH_KEYS) == ['@graph']
    end
    ##
    # Is value a simple @graph (lacking @id)?
    # @param [Object] value
    # @return [Boolean]
    def simple_graph?(value)
      graph?(value) && !value.has_key?('@id')
    end
    
    ##
    # Is value an expaned @list?
    #
    # @param [Object] value
    # @return [Boolean]
    def list?(value)
      value.is_a?(Hash) && value.has_key?('@list')
    end

    ##
    # Is value annotated?
    #
    # @param [Object] value
    # @return [Boolean]
    def index?(value)
      value.is_a?(Hash) && value.has_key?('@index')
    end

    ##
    # Is value literal?
    #
    # @param [Object] value
    # @return [Boolean]
    def value?(value)
      value.is_a?(Hash) && value.has_key?('@value')
    end

    ##
    # Represent an id as an IRI or Blank Node
    # @param [String] id
    # @param [RDF::URI] base (nil)
    # @return [RDF::Resource]
    def as_resource(id, base = nil)
      @nodes ||= {} # Re-use BNodes
      if id.start_with?('_:')
        (@nodes[id] ||= RDF::Node.new(namer.get_sym(id)))
      elsif base
        base.join(id)
      else
        RDF::URI(id)
      end
    end

    ##
    # Compares two JSON-LD values for equality. Two JSON-LD values will be
    # considered equal if:
    # 
    # 1. They are both primitives of the same type and value.
    # 2. They are both @values with the same @value, @type, @language,
    #   and @index, OR
    # 3. They both have @ids that are the same.
    # 
    # @param [Object] v1 the first value.
    # @param [Object] v2 the second value.
    # 
    # @return [Boolean] v1 and v2 are considered equal
    def compare_values(v1, v2)
      case
      when node_or_ref?(v1) && node_or_ref?(v2) then v1['@id'] && v1['@id'] == v2['@id']
      when value?(v1) && value?(v2)
        v1['@value'] == v2['@value'] &&
        v1['@type'] == v2['@type'] &&
        v1['@language'] == v2['@language'] &&
        v1['@index'] == v2['@index']
      else
        v1 == v2
      end
    end

    # Adds a value to a subject. If the value is an array, all values in the
    # array will be added.
    # 
    # @param [Hash] subject the hash to add the value to.
    # @param [String] property the property that relates the value to the subject.
    # @param [Object] value the value to add.
    # @param [Hash{Symbol => Object}] options
    # @option options [Boolean] :property_is_array
    #   true if the property is always (false)
    #   an array, false if not.
    # @option options [Boolean] :allow_duplicate (true)
    #   true to allow duplicates, false not to (uses
    #     a simple shallow comparison of subject ID or value).
    def add_value(subject, property, value, options = {})
      options = {property_is_array: false, allow_duplicate: true}.merge!(options)

      if value.is_a?(Array)
        subject[property] = [] if value.empty? && options[:property_is_array]
        value.each {|v| add_value(subject, property, v, options)}
      elsif subject[property]
        # check if subject already has value if duplicates not allowed
        _has_value = !options[:allow_duplicate] && has_value(subject, property, value)

        # make property an array if value not present or always an array
        if !subject[property].is_a?(Array) && (!_has_value || options[:property_is_array])
          subject[property] = [subject[property]]
        end
        subject[property] << value unless _has_value
      else
        subject[property] = options[:property_is_array] ? [value] : value
      end
    end

    # Returns True if the given subject has the given property.
    # 
    # @param subject the subject to check.
    # @param property the property to look for.
    # 
    # @return [Boolean] true if the subject has the given property, false if not.
    def has_property(subject, property)
      return false unless value = subject[property]
      !value.is_a?(Array) || !value.empty?
    end

    # Determines if the given value is a property of the given subject.
    # 
    # @param [Hash] subject the subject to check.
    # @param [String] property the property to check.
    # @param [Object] value the value to check.
    # 
    # @return [Boolean] true if the value exists, false if not.
    def has_value(subject, property, value)
      if has_property(subject, property)
        val = subject[property]
        is_list = list?(val)
        if val.is_a?(Array) || is_list
          val = val['@list'] if is_list
          val.any? {|v| compare_values(value, v)}
        elsif !val.is_a?(Array)
          compare_values(value, val)
        else
          false
        end
      else
        false
      end
    end

    private
    UTIL_GRAPH_KEYS = %w(@context @id @index).freeze

    # Merge the last value into an array based for the specified key if hash is not null and value is not already in that array
    def merge_value(hash, key, value)
      return unless hash
      values = hash[key] ||= []
      if key == '@list'
        values << value
      elsif list?(value)
        values << value
      elsif !values.include?(value)
        values << value
      end
    end

    # Merge values into compacted results, creating arrays if necessary
    def merge_compacted_value(hash, key, value)
      return unless hash
      case hash[key]
      when nil then hash[key] = value
      when Array
        if value.is_a?(Array)
          hash[key].concat(value)
        else
          hash[key] << value
        end
      else
        hash[key] = [hash[key]]
        if value.is_a?(Array)
          hash[key].concat(value)
        else
          hash[key] << value
        end
      end
    end
  end

  ##
  # Utility class for mapping old blank node identifiers, or unnamed blank
  # nodes to new identifiers
  class BlankNodeMapper < Hash
    ##
    # Just return a Blank Node based on `old`. Manufactures
    # a node if `old` is nil or empty
    # @param [String] old ("")
    # @return [String]
    def get_sym(old = "")
      old = RDF::Node.new.to_s if old.to_s.empty?
      old.to_s.sub(/_:/, '')
    end

    ##
    # Get a new mapped name for `old`
    #
    # @param [String] old ("")
    # @return [String]
    def get_name(old = "")
      "_:" + get_sym(old)
    end
  end

  class BlankNodeUniqer < BlankNodeMapper
    ##
    # Use the uniquely generated bnodes, rather than a sequence
    # @param [String] old ("")
    # @return [String]
    def get_sym(old = "")
      old = old.to_s.sub(/_:/, '')
      if old && self.has_key?(old)
        self[old]
      elsif !old.empty?
        self[old] = RDF::Node.new.to_unique_base[2..-1]
      else
        RDF::Node.new.to_unique_base[2..-1]
      end
    end
  end

  class BlankNodeNamer < BlankNodeMapper
    # @param [String] prefix
    def initialize(prefix)
      @prefix = prefix.to_s
      @num = 0
      super
    end

    ##
    # Get a new symbol mapped from `old`
    # @param [String] old ("")
    # @return [String]
    def get_sym(old = "")
      old = old.to_s.sub(/_:/, '')
      if !old.empty? && self.has_key?(old)
        self[old]
      elsif !old.empty?
        @num += 1
        #puts "allocate #{@prefix + (@num - 1).to_s} to #{old.inspect}"
        self[old] = @prefix + (@num - 1).to_s
      else
        # Not referenced, just return a new unique value
        @num += 1
        #puts "allocate #{@prefix + (@num - 1).to_s} to #{old.inspect}"
        @prefix + (@num - 1).to_s
      end
    end
  end
end

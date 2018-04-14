require 'base64'

module Aws
  module Xml
    class Builder

      include Seahorse::Model::Shapes

      def initialize(rules, options = {})
        @rules = rules
        @xml = options[:target] || []
        indent = options[:indent] || '  '
        pad = options[:pad] || ''
        @builder = DocBuilder.new(target:@xml, indent:indent, pad:pad)
      end

      def to_xml(params)
        structure(@rules.location_name, @rules, params)
        @xml.join
      end
      alias serialize to_xml

      private

      def structure(name, ref, values)
        if values.empty?
          node(name, ref)
        else
          node(name, ref, structure_attrs(ref, values)) do
            ref.shape.members.each do |member_name, member_ref|
              next if values[member_name].nil?
              next if xml_attribute?(member_ref)
              member(member_ref.location_name, member_ref, values[member_name])
            end
          end
        end
      end

      def structure_attrs(ref, values)
        ref.shape.members.inject({}) do |attrs, (member_name, member_ref)|
          if xml_attribute?(member_ref) && values.key?(member_name)
            attrs[member_ref.location_name] = values[member_name]
          end
          attrs
        end
      end

      def list(name, ref, values)
        if ref.shape.flattened
          values.each do |value|
            member(ref.shape.member.location_name || name, ref.shape.member, value)
          end
        else
          node(name, ref) do
            values.each do |value|
              mname = ref.shape.member.location_name || 'member'
              member(mname, ref.shape.member, value)
            end
          end
        end
      end

      def map(name, ref, hash)
        key_ref = ref.shape.key
        value_ref = ref.shape.value
        if ref.shape.flattened
          hash.each do |key, value|
            node(name, ref) do
              member(key_ref.location_name || 'key', key_ref, key)
              member(value_ref.location_name || 'value', value_ref, value)
            end
          end
        else
          node(name, ref) do
            hash.each do |key, value|
              node('entry', ref)  do
                member(key_ref.location_name || 'key', key_ref, key)
                member(value_ref.location_name || 'value', value_ref, value)
              end
            end
          end
        end
      end

      def member(name, ref, value)
        case ref.shape
        when StructureShape then structure(name, ref, value)
        when ListShape      then list(name, ref, value)
        when MapShape       then map(name, ref, value)
        when TimestampShape then node(name, ref, timestamp(value))
        when BlobShape      then node(name, ref, blob(value))
        else
          node(name, ref, value.to_s)
        end
      end

      def blob(value)
        value = value.read unless String === value
        Base64.strict_encode64(value)
      end

      def timestamp(value)
        value.utc.iso8601
      end

      # The `args` list may contain:
      #
      #   * [] - empty, no value or attributes
      #   * [value] - inline element, no attributes
      #   * [value, attributes_hash] - inline element with attributes
      #   * [attributes_hash] - self closing element with attributes
      #
      # Pass a block if you want to nest XML nodes inside.  When doing this,
      # you may *not* pass a value to the `args` list.
      #
      def node(name, ref, *args, &block)
        attrs = args.last.is_a?(Hash) ? args.pop : {}
        attrs = shape_attrs(ref).merge(attrs)
        args << attrs
        @builder.node(name, *args, &block)
      end

      def shape_attrs(ref)
        if xmlns = ref['xmlNamespace']
          if prefix = xmlns['prefix']
            { 'xmlns:' + prefix => xmlns['uri'] }
          else
            { 'xmlns' => xmlns['uri'] }
          end
        else
          {}
        end
      end

      def xml_attribute?(ref)
        !!ref['xmlAttribute']
      end

    end
  end
end

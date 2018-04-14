require 'base64'
require 'time'

module Aws
  module Json
    class Parser

      include Seahorse::Model::Shapes

      # @param [Seahorse::Model::ShapeRef] rules
      def initialize(rules)
        @rules = rules
      end

      # @param [String<JSON>] json
      def parse(json, target = nil)
        parse_ref(@rules, Json.load(json), target)
      end

      private

      def structure(ref, values, target = nil)
        shape = ref.shape
        target = ref.shape.struct_class.new if target.nil?
        values.each do |key, value|
          member_name, member_ref = shape.member_by_location_name(key)
          if member_ref
            target[member_name] = parse_ref(member_ref, value)
          end
        end
        target
      end

      def list(ref, values, target = nil)
        target = [] if target.nil?
        values.each do |value|
          target << parse_ref(ref.shape.member, value)
        end
        target
      end

      def map(ref, values, target = nil)
        target = {} if target.nil?
        values.each do |key, value|
          target[key] = parse_ref(ref.shape.value, value)
        end
        target
      end

      def parse_ref(ref, value, target = nil)
        if value.nil?
          nil
        else
          case ref.shape
          when StructureShape then structure(ref, value, target)
          when ListShape then list(ref, value, target)
          when MapShape then map(ref, value, target)
          when TimestampShape then time(value)
          when BlobShape then Base64.decode64(value)
          when BooleanShape then value.to_s == 'true'
          else value
          end
        end
      end

      # @param [String, Integer] value
      # @return [Time]
      def time(value)
        value.is_a?(Numeric) ? Time.at(value) : Time.parse(value)
      end

    end
  end
end

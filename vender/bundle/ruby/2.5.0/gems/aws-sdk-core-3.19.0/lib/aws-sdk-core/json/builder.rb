require 'base64'

module Aws
  module Json
    class Builder

      include Seahorse::Model::Shapes

      def initialize(rules)
        @rules = rules
      end

      def to_json(params)
        Json.dump(format(@rules, params))
      end
      alias serialize to_json

      private

      def structure(ref, values)
        shape = ref.shape
        values.each_pair.with_object({}) do |(key, value), data|
          if shape.member?(key) && !value.nil?
            member_ref = shape.member(key)
            member_name = member_ref.location_name || key
            data[member_name] = format(member_ref, value)
          end
        end
      end

      def list(ref, values)
        member_ref = ref.shape.member
        values.collect { |value| format(member_ref, value) }
      end

      def map(ref, values)
        value_ref = ref.shape.value
        values.each.with_object({}) do |(key, value), data|
          data[key] = format(value_ref, value)
        end
      end

      def format(ref, value)
        case ref.shape
        when StructureShape then structure(ref, value)
        when ListShape      then list(ref, value)
        when MapShape       then map(ref, value)
        when TimestampShape then timestamp(ref, value)
        when BlobShape      then encode(value)
        else value
        end
      end

      def encode(blob)
        Base64.strict_encode64(String === blob ? blob : blob.read)
      end

      def timestamp(ref, value)
        if ref['timestampFormat'] == 'iso8601'
          value.utc.iso8601
        else
          value.to_i
        end
      end

    end
  end
end

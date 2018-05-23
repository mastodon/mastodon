require 'base64'

module Aws
  module Query
    class ParamBuilder

      include Seahorse::Model::Shapes

      def initialize(param_list)
        @params = param_list
      end

      attr_reader :params

      def apply(ref, params)
        structure(ref, params, '')
      end

      private

      def structure(ref, values, prefix)
        shape = ref.shape
        values.each_pair do |name, value|
          next if value.nil?
          member_ref = shape.member(name)
          format(member_ref, value, prefix + query_name(member_ref))
        end
      end

      def list(ref, values, prefix)
        member_ref = ref.shape.member
        if values.empty?
          set(prefix, '')
          return
        end
        if flat?(ref)
          if name = query_name(member_ref)
            parts = prefix.split('.')
            parts.pop
            parts.push(name)
            prefix = parts.join('.')
          end
        else
          prefix += '.' + (member_ref.location_name || 'member')
        end
        values.each.with_index do |value, n|
          format(member_ref, value, "#{prefix}.#{n+1}")
        end
      end

      def map(ref, values, prefix)
        key_ref = ref.shape.key
        value_ref = ref.shape.value
        prefix += '.entry' unless flat?(ref)
        key_name = "%s.%d.#{query_name(key_ref, 'key')}"
        value_name  = "%s.%d.#{query_name(value_ref, 'value')}"
        values.each.with_index do |(key, value), n|
          format(key_ref, key, key_name % [prefix, n + 1])
          format(value_ref, value, value_name % [prefix, n + 1])
        end
      end

      def format(ref, value, prefix)
        case ref.shape
        when StructureShape then structure(ref, value, prefix + '.')
        when ListShape      then list(ref, value, prefix)
        when MapShape       then map(ref, value, prefix)
        when BlobShape      then set(prefix, blob(value))
        when TimestampShape then set(prefix, timestamp(value))
        else set(prefix, value.to_s)
        end
      end

      def query_name(ref, default = nil)
        ref.location_name || default
      end

      def set(name, value)
        params.set(name, value)
      end

      def flat?(ref)
        ref.shape.flattened
      end

      def timestamp(value)
        value.utc.iso8601
      end

      def blob(value)
        value = value.read unless String === value
        Base64.strict_encode64(value)
      end

    end
  end
end

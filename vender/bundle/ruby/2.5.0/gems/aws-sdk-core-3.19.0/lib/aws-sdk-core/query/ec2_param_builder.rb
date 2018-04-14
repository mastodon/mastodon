require 'base64'

module Aws
  module Query
    class EC2ParamBuilder

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
          unless value.nil?
            member_ref = shape.member(name)
            format(member_ref, value, prefix + query_name(member_ref))
          end
        end
      end

      def list(ref, values, prefix)
        if values.empty?
          set(prefix, '')
        else
          member_ref = ref.shape.member
          values.each.with_index do |value, n|
            format(member_ref, value, "#{prefix}.#{n+1}")
          end
        end
      end

      def format(ref, value, prefix)
        case ref.shape
        when StructureShape then structure(ref, value, prefix + '.')
        when ListShape      then list(ref, value, prefix)
        when MapShape       then raise NotImplementedError
        when BlobShape      then set(prefix, blob(value))
        when TimestampShape then set(prefix, timestamp(value))
        else
          set(prefix, value.to_s)
        end
      end

      def query_name(ref)
        ref['queryName'] || ucfirst(ref.location_name)
      end

      def set(name, value)
        params.set(name, value)
      end

      def ucfirst(str)
        str[0].upcase + str[1..-1]
      end

      def blob(value)
        value = value.read unless String === value
        Base64.strict_encode64(value)
      end

      def timestamp(value)
        value.utc.iso8601
      end

    end
  end
end

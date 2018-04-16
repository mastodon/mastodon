module Aws
  module Stubbing
    class DataApplicator

      include Seahorse::Model::Shapes

      # @param [Seahorse::Models::Shapes::ShapeRef] rules
      def initialize(rules)
        @rules = rules
      end

      # @param [Hash] data
      # @param [Structure] stub
      def apply_data(data, stub)
        apply_data_to_struct(@rules, data, stub)
      end

      private

      def apply_data_to_struct(ref, data, struct)
        data.each do |key, value|
          struct[key] = member_value(ref.shape.member(key), value)
        end
        struct
      end

      def member_value(ref, value)
        case ref.shape
        when StructureShape
          apply_data_to_struct(ref, value, ref.shape.struct_class.new)
        when ListShape
          value.inject([]) do |list, v|
            list << member_value(ref.shape.member, v)
          end
        when MapShape
          value.inject({}) do |map, (k,v)|
            map[k.to_s] = member_value(ref.shape.value, v)
            map
          end
        else
          value
        end
      end
    end
  end
end

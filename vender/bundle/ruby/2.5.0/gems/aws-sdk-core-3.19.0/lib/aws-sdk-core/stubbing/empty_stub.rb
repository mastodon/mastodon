module Aws
  module Stubbing
    class EmptyStub

      include Seahorse::Model::Shapes

      # @param [Seahorse::Models::Shapes::ShapeRef] rules
      def initialize(rules)
        @rules = rules
      end

      # @return [Structure]
      def stub
        if @rules
          stub_ref(@rules)
        else
          EmptyStructure.new
        end
      end

      private

      def stub_ref(ref, visited = [])
        if visited.include?(ref.shape)
          return nil
        else
          visited = visited + [ref.shape]
        end
        case ref.shape
        when StructureShape then stub_structure(ref, visited)
        when ListShape then []
        when MapShape then {}
        else stub_scalar(ref)
        end
      end

      def stub_structure(ref, visited)
        ref.shape.members.inject(ref.shape.struct_class.new) do |struct, (mname, mref)|
          struct[mname] = stub_ref(mref, visited)
          struct
        end
      end

      def stub_scalar(ref)
        case ref.shape
        when StringShape then ref.shape.name || 'string'
        when IntegerShape then 0
        when FloatShape then 0.0
        when BooleanShape then false
        when TimestampShape then Time.now
        else nil
        end
      end

    end
  end
end

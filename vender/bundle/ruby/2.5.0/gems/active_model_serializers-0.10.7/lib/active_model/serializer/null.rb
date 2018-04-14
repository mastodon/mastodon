module ActiveModel
  class Serializer
    class Null < Serializer
      def attributes(*)
        {}
      end

      def associations(*)
        {}
      end

      def serializable_hash(*)
        {}
      end
    end
  end
end

module ActiveModel
  class Serializer
    # @api private
    class BelongsToReflection < Reflection
      # @api private
      def foreign_key_on
        :self
      end
    end
  end
end

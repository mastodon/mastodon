module ActiveModel
  class Serializer
    class ErrorSerializer < ActiveModel::Serializer
      # @return [Hash<field_name,Array<error_message>>]
      def as_json
        object.errors.messages
      end

      def success?
        false
      end
    end
  end
end

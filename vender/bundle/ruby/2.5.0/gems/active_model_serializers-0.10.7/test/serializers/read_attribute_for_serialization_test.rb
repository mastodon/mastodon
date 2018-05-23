require 'test_helper'

module ActiveModel
  class Serializer
    class ReadAttributeForSerializationTest < ActiveSupport::TestCase
      # https://github.com/rails-api/active_model_serializers/issues/1653
      class Parent < ActiveModelSerializers::Model
        attributes :id
      end
      class Child < Parent
        attributes :name
      end
      class ParentSerializer < ActiveModel::Serializer
        attributes :$id

        define_method(:$id) do
          object.id
        end
      end
      class ChildSerializer < ParentSerializer
        attributes :name
      end

      def test_child_serializer_calls_dynamic_method_in_parent_serializer
        parent = ParentSerializer.new(Parent.new(id: 5))
        child  = ChildSerializer.new(Child.new(id: 6, name: 'Child'))
        assert_equal 5, parent.read_attribute_for_serialization(:$id)
        assert_equal 6, child.read_attribute_for_serialization(:$id)
      end

      # https://github.com/rails-api/active_model_serializers/issues/1658
      class ErrorResponse < ActiveModelSerializers::Model
        attributes :error
      end
      class ApplicationSerializer < ActiveModel::Serializer
        attributes :status

        def status
          object.try(:errors).blank? && object.try(:error).blank?
        end
      end
      class ErrorResponseSerializer < ApplicationSerializer
        attributes :error
      end
      class ErrorResponseWithSuperSerializer < ApplicationSerializer
        attributes :error

        def success
          super
        end
      end

      def test_child_serializer_with_error_attribute
        error = ErrorResponse.new(error: 'i have an error')
        serializer = ErrorResponseSerializer.new(error)
        serializer_with_super = ErrorResponseWithSuperSerializer.new(error)
        assert_equal false, serializer.read_attribute_for_serialization(:status)
        assert_equal false, serializer_with_super.read_attribute_for_serialization(:status)
      end

      def test_child_serializer_with_errors
        error = ErrorResponse.new
        error.errors.add(:invalid, 'i am not valid')
        serializer = ErrorResponseSerializer.new(error)
        serializer_with_super = ErrorResponseWithSuperSerializer.new(error)
        assert_equal false, serializer.read_attribute_for_serialization(:status)
        assert_equal false, serializer_with_super.read_attribute_for_serialization(:status)
      end

      def test_child_serializer_no_error_attribute_or_errors
        error = ErrorResponse.new
        serializer = ErrorResponseSerializer.new(error)
        serializer_with_super = ErrorResponseWithSuperSerializer.new(error)
        assert_equal true, serializer.read_attribute_for_serialization(:status)
        assert_equal true, serializer_with_super.read_attribute_for_serialization(:status)
      end
    end
  end
end

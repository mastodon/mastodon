require 'test_helper'

module ActiveModel
  class Serializer
    class AssociationMacrosTest < ActiveSupport::TestCase
      class AuthorSummarySerializer < ActiveModel::Serializer; end

      class AssociationsTestSerializer < Serializer
        belongs_to :author, serializer: AuthorSummarySerializer
        has_many :comments
        has_one :category
      end

      def before_setup
        @reflections = AssociationsTestSerializer._reflections.values
      end

      def test_has_one_defines_reflection
        has_one_reflection = HasOneReflection.new(:category, {})

        assert_includes(@reflections, has_one_reflection)
      end

      def test_has_many_defines_reflection
        has_many_reflection = HasManyReflection.new(:comments, {})

        assert_includes(@reflections, has_many_reflection)
      end

      def test_belongs_to_defines_reflection
        belongs_to_reflection = BelongsToReflection.new(:author, serializer: AuthorSummarySerializer)

        assert_includes(@reflections, belongs_to_reflection)
      end
    end
  end
end

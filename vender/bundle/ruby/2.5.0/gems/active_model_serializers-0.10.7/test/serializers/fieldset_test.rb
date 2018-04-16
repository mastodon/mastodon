require 'test_helper'

module ActiveModel
  class Serializer
    class FieldsetTest < ActiveSupport::TestCase
      def test_fieldset_with_hash
        fieldset = ActiveModel::Serializer::Fieldset.new('post' => %w(id title), 'comment' => ['body'])
        expected = { post: [:id, :title], comment: [:body] }

        assert_equal(expected, fieldset.fields)
      end
    end
  end
end

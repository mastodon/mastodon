require 'test_helper'

module ActiveModel
  class Serializer
    class OptionsTest < ActiveSupport::TestCase
      class ModelWithOptions < ActiveModelSerializers::Model
        attributes :name, :description
      end
      class ModelWithOptionsSerializer < ActiveModel::Serializer
        attributes :name, :description

        def arguments_passed_in?
          instance_options[:my_options] == :accessible
        end
      end

      setup do
        @model_with_options = ModelWithOptions.new(name: 'Name 1', description: 'Description 1')
      end

      def test_options_are_accessible
        model_with_options_serializer = ModelWithOptionsSerializer.new(@model_with_options, my_options: :accessible)
        assert model_with_options_serializer.arguments_passed_in?
      end

      def test_no_option_is_passed_in
        model_with_options_serializer = ModelWithOptionsSerializer.new(@model_with_options)
        refute model_with_options_serializer.arguments_passed_in?
      end
    end
  end
end

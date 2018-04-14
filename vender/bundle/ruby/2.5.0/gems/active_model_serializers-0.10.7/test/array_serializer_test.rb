require 'test_helper'
require_relative 'collection_serializer_test'

module ActiveModel
  class Serializer
    class ArraySerializerTest < CollectionSerializerTest
      extend Minitest::Assertions
      def self.run_one_method(*)
        _, stderr = capture_io do
          super
        end
        if stderr !~ /NOTE: ActiveModel::Serializer::ArraySerializer.new is deprecated/
          fail Minitest::Assertion, stderr
        end
      end

      def collection_serializer
        ArraySerializer
      end
    end
  end
end

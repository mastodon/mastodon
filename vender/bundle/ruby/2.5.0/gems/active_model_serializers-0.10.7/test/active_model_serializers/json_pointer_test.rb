require 'test_helper'

module ActiveModelSerializers
  class JsonPointerTest < ActiveSupport::TestCase
    def test_attribute_pointer
      attribute_name = 'title'
      pointer = ActiveModelSerializers::JsonPointer.new(:attribute, attribute_name)
      assert_equal '/data/attributes/title', pointer
    end

    def test_primary_data_pointer
      pointer = ActiveModelSerializers::JsonPointer.new(:primary_data)
      assert_equal '/data', pointer
    end

    def test_unknown_data_pointer
      assert_raises(TypeError) do
        ActiveModelSerializers::JsonPointer.new(:unknown)
      end
    end
  end
end

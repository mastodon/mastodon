require 'test_helper'

module ActiveModel
  class Serializer
    class RootTest < ActiveSupport::TestCase
      def setup
        @virtual_value = VirtualValue.new(id: 1)
      end

      def test_overwrite_root
        serializer = VirtualValueSerializer.new(@virtual_value, root: 'smth')
        assert_equal('smth', serializer.json_key)
      end

      def test_underscore_in_root
        serializer = VirtualValueSerializer.new(@virtual_value)
        assert_equal('virtual_value', serializer.json_key)
      end
    end
  end
end

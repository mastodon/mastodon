require 'test_helper'
require 'tilt/template'

module Tilt
  class TemplateMetadataTest < Minitest::Test
    class MyTemplate < Template
      metadata[:global] = 1
      self.default_mime_type = 'text/html'

      def prepare
      end

      def allows_script?
        true
      end
    end

    test "global metadata" do
      assert MyTemplate.metadata
      assert_equal 1, MyTemplate.metadata[:global]
    end

    test "instance metadata" do
      tmpl = MyTemplate.new { '' }
      assert_equal 1, tmpl.metadata[:global]
    end

    test "gracefully handles default_mime_type" do
      assert_equal 'text/html', MyTemplate.metadata[:mime_type]
    end

    test "still allows .default_mime_type" do
      assert_equal 'text/html', MyTemplate.default_mime_type
    end

    test "gracefully handles allows_script?" do
      tmpl = MyTemplate.new { '' }
      assert_equal true, tmpl.metadata[:allows_script]
    end
  end
end


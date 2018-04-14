require "helper"

module Nokogiri
  class TestSlop < Nokogiri::TestCase
    def test_description_tag
      doc = Nokogiri.Slop(<<-eoxml)
        <item>
          <title>foo</title>
          <description>this is the foo thing</description>
        </item>
      eoxml

      assert doc.item.respond_to?(:title)
      assert_equal 'foo', doc.item.title.text

      assert doc.item.respond_to?(:_description), 'should have description'
      assert_equal 'this is the foo thing', doc.item._description.text

      assert !doc.item.respond_to?(:foo)
      assert_raise(NoMethodError) { doc.item.foo }
    end
  end
end

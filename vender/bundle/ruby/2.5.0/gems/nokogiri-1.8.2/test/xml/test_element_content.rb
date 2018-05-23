require "helper"

module Nokogiri
  module XML
    class TestElementContent < Nokogiri::TestCase
      def setup
        super
        @xml = Nokogiri::XML(<<-eoxml)
<?xml version="1.0"?><?TEST-STYLE PIDATA?>
<!DOCTYPE staff SYSTEM "staff.dtd" [
   <!ELEMENT br EMPTY>
   <!ELEMENT div1 (head, (p | list | note)*, div2*)>
   <!ELEMENT div2 (tender:love)>
]>
<root/>
        eoxml
        @elements = @xml.internal_subset.children.find_all { |x|
          x.type == 15
        }
        @tree = @elements[1].content
      end

      def test_allowed_content_not_defined
        assert_nil @elements.first.content
      end

      def test_document
        assert @tree
        assert_equal @xml, @tree.document
      end

      def test_type
        assert_equal ElementContent::SEQ, @tree.type
      end

      def test_children
        assert_equal 2, @tree.children.length
      end

      def test_name
        assert_nil @tree.name
        assert_equal 'head', @tree.children.first.name
        assert_equal 'p', @tree.children[1].children.first.children.first.name
      end

      def test_occur
        assert_equal ElementContent::ONCE, @tree.occur
      end

      def test_prefix
        assert_nil @tree.prefix
        assert_equal 'tender', @elements[2].content.prefix
      end
    end
  end
end

require "helper"

class UnitTestApi < Loofah::TestCase

  HTML          = "<div>a</div>\n<div>b</div>"
  XML_FRAGMENT  = "<div>a</div>\n<div>b</div>"
  XML           = "<root>#{XML_FRAGMENT}</root>"

  describe "HTML" do
    it "creates documents" do
      doc = Loofah.document(HTML)
      assert_html_documentish doc
    end

    it "creates fragments" do
      doc = Loofah.fragment(HTML)
      assert_html_fragmentish doc
    end

    it "parses documents" do
      doc = Loofah::HTML::Document.parse(HTML)
      assert_html_documentish doc
    end

    it "parses document fragment" do
      doc = Loofah::HTML::DocumentFragment.parse(HTML)
      assert_html_fragmentish doc
    end

    it "scrubs documents" do
      doc = Loofah.document(HTML).scrub!(:strip)
      assert_html_documentish doc
    end

    it "scrubs fragments" do
      doc = Loofah.fragment(HTML).scrub!(:strip)
      assert_html_fragmentish doc
    end

    it "scrubs document nodes" do
      doc = Loofah.document(HTML)
      assert(node = doc.at_css("div"))
      node.scrub!(:strip)
    end

    it "scrubs fragment nodes" do
      doc = Loofah.fragment(HTML)
      assert(node = doc.at_css("div"))
      node.scrub!(:strip)
    end

    it "scrubs document nodesets" do
      doc = Loofah.document(HTML)
      assert(node_set = doc.css("div"))
      assert_instance_of Nokogiri::XML::NodeSet, node_set
      node_set.scrub!(:strip)
    end

    it "exposes serialize_root on HTML::DocumentFragment" do
      doc = Loofah.fragment(HTML)
      assert_equal HTML, doc.serialize_root.to_html
    end

    it "exposes serialize_root on HTML::Document" do
      doc = Loofah.document(HTML)
      assert_equal HTML, doc.serialize_root.children.to_html
    end
  end

  describe "XML" do
    it "creates documents" do
      doc = Loofah.xml_document(XML)
      assert_xml_documentish doc
    end

    it "creates fragments" do
      doc = Loofah.xml_fragment(XML_FRAGMENT)
      assert_xml_fragmentish doc
    end

    it "parses documents" do
      doc = Loofah::XML::Document.parse(XML)
      assert_xml_documentish doc
    end

    it "parses document fragments" do
      doc = Loofah::XML::DocumentFragment.parse(XML_FRAGMENT)
      assert_xml_fragmentish doc
    end

    it "scrubs documents" do
      scrubber = Loofah::Scrubber.new { |node| }
      doc = Loofah.xml_document(XML).scrub!(scrubber)
      assert_xml_documentish doc
    end

    it "scrubs fragments" do
      scrubber = Loofah::Scrubber.new { |node| }
      doc = Loofah.xml_fragment(XML_FRAGMENT).scrub!(scrubber)
      assert_xml_fragmentish doc
    end

    it "scrubs document nodes" do
      doc = Loofah.xml_document(XML)
      assert(node = doc.at_css("div"))
      node.scrub!(:strip)
    end

    it "scrubs fragment nodes" do
      doc = Loofah.xml_fragment(XML)
      assert(node = doc.at_css("div"))
      node.scrub!(:strip)
    end
  end

  private

  def assert_html_documentish(doc)
    assert_kind_of Nokogiri::HTML::Document, doc
    assert_kind_of Loofah::HTML::Document,   doc
    assert_equal HTML, doc.xpath("/html/body").inner_html
  end

  def assert_html_fragmentish(doc)
    assert_kind_of Nokogiri::HTML::DocumentFragment, doc
    assert_kind_of Loofah::HTML::DocumentFragment,   doc
    assert_equal HTML, doc.inner_html
  end

  def assert_xml_documentish(doc)
    assert_kind_of Nokogiri::XML::Document, doc
    assert_kind_of Loofah::XML::Document,   doc
    assert_equal XML, doc.root.to_xml
  end

  def assert_xml_fragmentish(doc)
    assert_kind_of Nokogiri::XML::DocumentFragment, doc
    assert_kind_of Loofah::XML::DocumentFragment,   doc
    assert_equal XML_FRAGMENT, doc.children.to_xml
  end

end

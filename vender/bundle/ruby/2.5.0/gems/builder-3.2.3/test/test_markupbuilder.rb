#!/usr/bin/env ruby

#--
# Portions copyright 2004 by Jim Weirich (jim@weirichhouse.org).
# Portions copyright 2005 by Sam Ruby (rubys@intertwingly.net).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#++

require 'helper'
require 'preload'
require 'builder'
require 'builder/xmlmarkup'

class TestMarkup < Builder::Test
  def setup
    @xml = Builder::XmlMarkup.new
  end

  def test_create
    assert_not_nil @xml
  end

  def test_simple
    @xml.simple
    assert_equal "<simple/>", @xml.target!
  end

  def test_value
    @xml.value("hi")
    assert_equal "<value>hi</value>", @xml.target!
  end

  def test_empty_value
    @xml.value("")
    assert_equal "<value></value>", @xml.target!
  end

  def test_nil_value
    @xml.value(nil)
    assert_equal "<value/>", @xml.target!
  end

  def test_no_value
    @xml.value()
    assert_equal "<value/>", @xml.target!
  end

  def test_nested
    @xml.outer { |x| x.inner("x") }
    assert_equal "<outer><inner>x</inner></outer>", @xml.target!
  end

  def test_attributes
    @xml.ref(:id => 12)
    assert_equal %{<ref id="12"/>}, @xml.target!
  end

  def test_single_quotes_for_attrs
    @xml = Builder::XmlMarkup.new(:quote => :single)
    @xml.ref(:id => 12)
    assert_equal %{<ref id='12'/>}, @xml.target!
  end

  def test_mixed_quotes_for_attrs
    @xml = Builder::XmlMarkup.new(:quote => :single)
    x = Builder::XmlMarkup.new(:target=>@xml, :quote => :double)
    @xml.ref(:id => 12) do
      x.link(:id => 13)
    end
    assert_equal %{<ref id='12'><link id="13"/></ref>}, @xml.target!
  end

  def test_string_attributes_are_escaped_by_default
    @xml.ref(:id => "H&R")
    assert_equal %{<ref id="H&amp;R"/>}, @xml.target!
  end

  def test_symbol_attributes_are_unescaped_by_default
    @xml.ref(:id => :"H&amp;R")
    assert_equal %{<ref id="H&amp;R"/>}, @xml.target!
  end

  def test_attributes_escaping_can_be_turned_on
    @xml = Builder::XmlMarkup.new
    @xml.ref(:id => "<H&R \"block\">")
    assert_equal %{<ref id="&lt;H&amp;R &quot;block&quot;&gt;"/>}, @xml.target!
  end

  def test_mixed_attribute_escaping_with_nested_builders
    x = Builder::XmlMarkup.new(:target=>@xml)
    @xml.ref(:id=>:"H&amp;R") {
      x.element(:tag=>"Long&Short")
    }
    assert_equal "<ref id=\"H&amp;R\"><element tag=\"Long&amp;Short\"/></ref>",
      @xml.target!
  end

  def test_multiple_attributes
    @xml.ref(:id => 12, :name => "bill")
    assert_match %r{^<ref( id="12"| name="bill"){2}/>$}, @xml.target!
  end

  def test_attributes_with_text
    @xml.a("link", :href=>"http://onestepback.org")
    assert_equal %{<a href="http://onestepback.org">link</a>}, @xml.target!
  end

  def test_attributes_with_newlines
    @xml.abbr("W3C", :title=>"World\nWide\rWeb\r\nConsortium")
    assert_equal %{<abbr title="World&#10;Wide&#13;Web&#13;&#10;Consortium">W3C</abbr>},
      @xml.target!
  end

  def test_complex
    @xml.body(:bg=>"#ffffff") { |x|
      x.title("T", :style=>"red")
    }
    assert_equal %{<body bg="#ffffff"><title style="red">T</title></body>}, @xml.target!
  end

  def test_funky_symbol
    @xml.tag!("non-ruby-token", :id=>1) { |x| x.ok }
    assert_equal %{<non-ruby-token id="1"><ok/></non-ruby-token>}, @xml.target!
  end

  def test_tag_can_handle_private_method
    @xml.tag!("loop", :id=>1) { |x| x.ok }
    assert_equal %{<loop id="1"><ok/></loop>}, @xml.target!
  end

  def test_no_explicit_marker
    @xml.p { |x| x.b("HI") }
    assert_equal "<p><b>HI</b></p>", @xml.target!
  end

  def test_reference_local_vars
    n = 3
    @xml.ol { |x| n.times { x.li(n) } }
    assert_equal "<ol><li>3</li><li>3</li><li>3</li></ol>", @xml.target!
  end

  def test_reference_methods
    @xml.title { |x| x.a { x.b(_name) } }
    assert_equal "<title><a><b>bob</b></a></title>", @xml.target!
  end

  def test_append_text
    @xml.p { |x| x.br; x.text! "HI" }
    assert_equal "<p><br/>HI</p>", @xml.target!
  end

  def test_ambiguous_markup
    ex = assert_raise(ArgumentError) {
      @xml.h1("data1") { b }
    }
    assert_match(/\btext\b/, ex.message)
    assert_match(/\bblock\b/, ex.message)
  end

  def test_capitalized_method
    @xml.P { |x| x.B("hi"); x.BR(); x.EM { x.text! "world" } }
    assert_equal "<P><B>hi</B><BR/><EM>world</EM></P>", @xml.target!
  end

  def test_escaping
    @xml.div { |x| x.text! "<hi>"; x.em("H&R Block") }
    assert_equal %{<div>&lt;hi&gt;<em>H&amp;R Block</em></div>}, @xml.target!
  end

  def test_nil
    b = Builder::XmlMarkup.new
    b.tag! "foo", nil
    assert_equal %{<foo/>}, b.target!
  end

  def test_nil_without_explicit_nil_handling
    b = Builder::XmlMarkup.new(:explicit_nil_handling => false)
    b.tag! "foo", nil
    assert_equal %{<foo/>}, b.target!
  end

  def test_nil_with_explicit_nil_handling
    b = Builder::XmlMarkup.new(:explicit_nil_handling => true)
    b.tag! "foo", nil
    assert_equal %{<foo nil="true"/>}, b.target!
  end

  def test_non_escaping
    @xml.div("ns:xml"=>:"&xml;") { |x| x << "<h&i>"; x.em("H&R Block") }
    assert_equal %{<div ns:xml="&xml;"><h&i><em>H&amp;R Block</em></div>}, @xml.target!
  end

  def test_return_value
    str = @xml.x("men")
    assert_equal @xml.target!, str
  end

  def test_stacked_builders
    b = Builder::XmlMarkup.new( :target => @xml )
    b.div { @xml.span { @xml.a("text", :href=>"ref") } }
    assert_equal "<div><span><a href=\"ref\">text</a></span></div>", @xml.target!
  end

  def _name
    "bob"
  end
end

class TestAttributeEscaping < Builder::Test

  def setup
    @xml = Builder::XmlMarkup.new
  end

  def test_element_gt
    @xml.title('1<2')
    assert_equal '<title>1&lt;2</title>', @xml.target!
  end

  def test_element_amp
    @xml.title('AT&T')
    assert_equal '<title>AT&amp;T</title>', @xml.target!
  end

  def test_element_amp2
    @xml.title('&amp;')
    assert_equal '<title>&amp;amp;</title>', @xml.target!
  end

  def test_attr_less
    @xml.a(:title => '2>1')
    assert_equal '<a title="2&gt;1"/>', @xml.target!
  end

  def test_attr_amp
    @xml.a(:title => 'AT&T')
    assert_equal '<a title="AT&amp;T"/>', @xml.target!
  end

  def test_attr_quot
    @xml.a(:title => '"x"')
    assert_equal '<a title="&quot;x&quot;"/>', @xml.target!
  end

end

class TestNameSpaces < Builder::Test
  def setup
    @xml = Builder::XmlMarkup.new(:indent=>2)
  end

  def test_simple_name_spaces
    @xml.rdf :RDF
    assert_equal "<rdf:RDF/>\n", @xml.target!
  end

  def test_long
    xml = Builder::XmlMarkup.new(:indent=>2)
    xml.instruct!
    xml.rdf :RDF,
      "xmlns:rdf" => :"&rdf;",
      "xmlns:rdfs" => :"&rdfs;",
      "xmlns:xsd" => :"&xsd;",
      "xmlns:owl" => :"&owl;" do
      xml.owl :Class, :'rdf:ID'=>'Bird' do
	xml.rdfs :label, 'bird'
	xml.rdfs :subClassOf do
	  xml.owl :Restriction do
	    xml.owl :onProperty, 'rdf:resource'=>'#wingspan'
	    xml.owl :maxCardinality,1,'rdf:datatype'=>'&xsd;nonNegativeInteger'
	  end
	end
      end
    end
    assert_match(/^<\?xml/, xml.target!)
    assert_match(/\n<rdf:RDF/m, xml.target!)
    assert_match(/xmlns:rdf="&rdf;"/m, xml.target!)
    assert_match(/<owl:Restriction>/m, xml.target!)
  end

  def test_ensure
    xml = Builder::XmlMarkup.new
    xml.html do
      xml.body do
       begin
         xml.p do
           raise Exception.new('boom')
         end
       rescue Exception => e
         xml.pre e
       end
      end
    end
    assert_match %r{<p>},  xml.target!
    assert_match %r{</p>}, xml.target!
  end
end

class TestDeclarations < Builder::Test
  def setup
    @xml = Builder::XmlMarkup.new(:indent=>2)
  end

  def test_declare
    @xml.declare! :element
    assert_equal "<!element>\n", @xml.target!
  end

  def test_bare_arg
    @xml.declare! :element, :arg
    assert_equal"<!element arg>\n", @xml.target!
  end

  def test_string_arg
    @xml.declare! :element, "string"
    assert_equal"<!element \"string\">\n", @xml.target!
  end

  def test_mixed_args
    @xml.declare! :element, :x, "y", :z, "-//OASIS//DTD DocBook XML//EN"
    assert_equal "<!element x \"y\" z \"-//OASIS//DTD DocBook XML//EN\">\n", @xml.target!
  end

  def test_nested_declarations
    @xml = Builder::XmlMarkup.new
    @xml.declare! :DOCTYPE, :chapter do |x|
      x.declare! :ELEMENT, :chapter, "(title,para+)".intern
    end
    assert_equal "<!DOCTYPE chapter [<!ELEMENT chapter (title,para+)>]>", @xml.target!
  end

  def test_nested_indented_declarations
    @xml.declare! :DOCTYPE, :chapter do |x|
      x.declare! :ELEMENT, :chapter, "(title,para+)".intern
    end
    assert_equal "<!DOCTYPE chapter [\n  <!ELEMENT chapter (title,para+)>\n]>\n", @xml.target!
  end

  def test_complex_declaration
    @xml.declare! :DOCTYPE, :chapter do |x|
      x.declare! :ELEMENT, :chapter, "(title,para+)".intern
      x.declare! :ELEMENT, :title, "(#PCDATA)".intern
      x.declare! :ELEMENT, :para, "(#PCDATA)".intern
    end
    expected = %{<!DOCTYPE chapter [
  <!ELEMENT chapter (title,para+)>
  <!ELEMENT title (#PCDATA)>
  <!ELEMENT para (#PCDATA)>
]>
}
    assert_equal expected, @xml.target!
  end
end


class TestSpecialMarkup < Builder::Test
  def setup
    @xml = Builder::XmlMarkup.new(:indent=>2)
  end

  def test_comment
    @xml.comment!("COMMENT")
    assert_equal "<!-- COMMENT -->\n", @xml.target!
  end

  def test_indented_comment
    @xml.p { @xml.comment! "OK" }
    assert_equal "<p>\n  <!-- OK -->\n</p>\n", @xml.target!
  end

  def test_instruct
    @xml.instruct! :abc, :version=>"0.9"
    assert_equal "<?abc version=\"0.9\"?>\n", @xml.target!
  end

  def test_indented_instruct
    @xml.p { @xml.instruct! :xml }
    assert_match %r{<p>\n  <\?xml version="1.0" encoding="UTF-8"\?>\n</p>\n},
      @xml.target!
  end

  def test_instruct_without_attributes
    @xml.instruct! :zz
    assert_equal "<?zz?>\n", @xml.target!
  end

  def test_xml_instruct
    @xml.instruct!
    assert_match(/^<\?xml version="1.0" encoding="UTF-8"\?>$/, @xml.target!)
  end

  def test_xml_instruct_with_overrides
    @xml.instruct! :xml, :encoding=>"UCS-2"
    assert_match(/^<\?xml version="1.0" encoding="UCS-2"\?>$/, @xml.target!)
  end

  def test_xml_instruct_with_standalong
    @xml.instruct! :xml, :encoding=>"UCS-2", :standalone=>"yes"
    assert_match(/^<\?xml version="1.0" encoding="UCS-2" standalone="yes"\?>$/, @xml.target!)
  end

  def test_no_blocks
    assert_raise(Builder::IllegalBlockError) do
      @xml.instruct! { |x| x.hi }
    end
    assert_raise(Builder::IllegalBlockError) do
      @xml.comment!(:element) { |x| x.hi }
    end
  end

  def test_cdata
    @xml.cdata!("TEST")
    assert_equal "<![CDATA[TEST]]>\n", @xml.target!
  end

  def test_cdata_with_ampersand
    @xml.cdata!("TEST&CHECK")
    assert_equal "<![CDATA[TEST&CHECK]]>\n", @xml.target!
  end

  def test_cdata_with_included_close
    @xml.cdata!("TEST]]>CHECK")
    assert_equal "<![CDATA[TEST]]]]><![CDATA[>CHECK]]>\n", @xml.target!
  end
end

class TestIndentedXmlMarkup < Builder::Test
  def setup
    @xml = Builder::XmlMarkup.new(:indent=>2)
  end

  def test_one_level
    @xml.ol { |x| x.li "text" }
    assert_equal "<ol>\n  <li>text</li>\n</ol>\n", @xml.target!
  end

  def test_two_levels
    @xml.p { |x|
      x.ol { x.li "text" }
      x.br
    }
    assert_equal "<p>\n  <ol>\n    <li>text</li>\n  </ol>\n  <br/>\n</p>\n", @xml.target!
  end

  def test_initial_level
    @xml = Builder::XmlMarkup.new(:indent=>2, :margin=>4)
    @xml.name { |x| x.first("Jim") }
    assert_equal "        <name>\n          <first>Jim</first>\n        </name>\n", @xml.target!
  end

  class TestUtfMarkup < Builder::Test
    if ! String.method_defined?(:encode)
      def setup
        @old_kcode = $KCODE
      end

      def teardown
        $KCODE = @old_kcode
      end

      def test_use_entities_if_no_encoding_is_given_and_kcode_is_none
        $KCODE = 'NONE'
        xml = Builder::XmlMarkup.new
        xml.p("\xE2\x80\x99")
        assert_match(%r(<p>&#8217;</p>), xml.target!) #
      end

      def test_use_entities_if_encoding_is_utf_but_kcode_is_not
        $KCODE = 'NONE'
        xml = Builder::XmlMarkup.new
        xml.instruct!(:xml, :encoding => 'UTF-8')
        xml.p("\xE2\x80\x99")
        assert_match(%r(<p>&#8217;</p>), xml.target!) #
      end
    else
      # change in behavior.  As there is no $KCODE anymore, the default
      # moves from "does not understand utf-8" to "supports utf-8".

      def test_use_entities_if_no_encoding_is_given_and_kcode_is_none
        xml = Builder::XmlMarkup.new
        xml.p("\xE2\x80\x99")
        assert_match("<p>\u2019</p>", xml.target!) #
      end

      def test_use_entities_if_encoding_is_utf_but_kcode_is_not
        xml = Builder::XmlMarkup.new
        xml.instruct!(:xml, :encoding => 'UTF-8')
        xml.p("\xE2\x80\x99")
        assert_match("<p>\u2019</p>", xml.target!) #
      end
    end

    def encode string, encoding
      if !String.method_defined?(:encode)
        $KCODE = encoding
        string
      elsif encoding == 'UTF8'
        string.force_encoding('UTF-8')
      else
        string
      end
    end

    def test_use_entities_if_kcode_is_utf_but_encoding_is_dummy_encoding
      xml = Builder::XmlMarkup.new
      xml.instruct!(:xml, :encoding => 'UTF-16')
      xml.p(encode("\xE2\x80\x99", 'UTF8'))
      assert_match(%r(<p>&#8217;</p>), xml.target!) #
    end

    def test_use_entities_if_kcode_is_utf_but_encoding_is_unsupported_encoding
      xml = Builder::XmlMarkup.new
      xml.instruct!(:xml, :encoding => 'UCS-2')
      xml.p(encode("\xE2\x80\x99", 'UTF8'))
      assert_match(%r(<p>&#8217;</p>), xml.target!) #
    end

    def test_use_utf8_if_encoding_defaults_and_kcode_is_utf8
      xml = Builder::XmlMarkup.new
      xml.p(encode("\xE2\x80\x99",'UTF8'))
      assert_equal encode("<p>\xE2\x80\x99</p>",'UTF8'), xml.target!
    end

    def test_use_utf8_if_both_encoding_and_kcode_are_utf8
      xml = Builder::XmlMarkup.new
      xml.instruct!(:xml, :encoding => 'UTF-8')
      xml.p(encode("\xE2\x80\x99",'UTF8'))
      assert_match encode("<p>\xE2\x80\x99</p>",'UTF8'), xml.target!
    end

    def test_use_utf8_if_both_encoding_and_kcode_are_utf8_with_lowercase
      xml = Builder::XmlMarkup.new
      xml.instruct!(:xml, :encoding => 'utf-8')
      xml.p(encode("\xE2\x80\x99",'UTF8'))
      assert_match encode("<p>\xE2\x80\x99</p>",'UTF8'), xml.target!
    end
  end

  class TestXmlEvents < Builder::Test
    def setup
      @handler = EventHandler.new
      @xe = Builder::XmlEvents.new(:target=>@handler)
    end

    def test_simple
      @xe.p
      assert_equal [:start, :p, nil], @handler.events.shift
      assert_equal [:end, :p], @handler.events.shift
    end

    def test_text
      @xe.p("HI")
      assert_equal [:start, :p, nil], @handler.events.shift
      assert_equal [:text, "HI"], @handler.events.shift
      assert_equal [:end, :p], @handler.events.shift
    end

    def test_attributes
      @xe.p("id"=>"2")
      ev = @handler.events.shift
      assert_equal [:start, :p], ev[0,2]
      assert_equal "2", ev[2]['id']
      assert_equal [:end, :p], @handler.events.shift
    end

    def test_indented
      @xml = Builder::XmlEvents.new(:indent=>2, :target=>@handler)
      @xml.p { |x| x.b("HI") }
      assert_equal [:start, :p, nil], @handler.events.shift
      assert_equal "\n  ", pop_text
      assert_equal [:start, :b, nil], @handler.events.shift
      assert_equal "HI", pop_text
      assert_equal [:end, :b], @handler.events.shift
      assert_equal "\n", pop_text
      assert_equal [:end, :p], @handler.events.shift
    end

    def pop_text
      result = ''
      while ! @handler.events.empty? && @handler.events[0][0] == :text
	result << @handler.events[0][1]
	@handler.events.shift
      end
      result
    end

    class EventHandler
      attr_reader :events
      def initialize
	@events = []
      end

      def start_tag(sym, attrs)
	@events << [:start, sym, attrs]
      end

      def end_tag(sym)
	@events << [:end, sym]
      end

      def text(txt)
	@events << [:text, txt]
      end
    end
  end

end

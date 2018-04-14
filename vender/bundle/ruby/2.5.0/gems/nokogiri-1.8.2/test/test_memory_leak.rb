require "helper"

class TestMemoryLeak < Nokogiri::TestCase
  def setup
    super
    @str = <<EOF
<!DOCTYPE HTML>
<html>
  <body>
    <br />
  </body>
</html>
EOF
  end

  if ENV['NOKOGIRI_GC'] # turning these off by default for now
    def test_dont_hurt_em_why
      content = File.open("#{File.dirname(__FILE__)}/files/dont_hurt_em_why.xml").read
      ndoc = Nokogiri::XML(content)
      2.times do
        ndoc.search('status text').first.inner_text
        ndoc.search('user name').first.inner_text
        GC.start
      end
    end

    class BadIO
      def read(*args)
        raise 'hell'
      end

      def write(*args)
        raise 'chickens'
      end
    end

    def test_for_mem_leak_on_io_callbacks
      io = File.open SNUGGLES_FILE
      Nokogiri::XML.parse(io)

      loop do
        Nokogiri::XML.parse(BadIO.new) rescue nil
        doc.write BadIO.new rescue nil
      end
    end

    def test_for_memory_leak
      begin
        #  we don't use Dike in any tests, but requiring it has side effects
        #  that can create memory leaks, and that's what we're testing for.
        require 'rubygems'
        require 'dike' # do not remove!

        count_start = count_object_space_documents
        xml_data = <<-EOS
        <test>
          <items>
            <item>abc</item>
            <item>1234</item>
            <item>Zzz</item>
          <items>
        </test>
        EOS
        20.times do
          doc = Nokogiri::XML(xml_data)
          doc.xpath("//item")
        end
        2.times { GC.start }
        count_end = count_object_space_documents
        assert((count_end - count_start) <= 2, "memory leak detected")
      rescue LoadError
        puts "\ndike is not installed, skipping memory leak test"
      end
    end

    def test_node_set_namespace_mem_leak
      xml = Nokogiri::XML "<foo></foo>"
      ctx = Nokogiri::XML::XPathContext.new(xml)
      loop do
        ctx.evaluate("//namespace::*")
      end
    end

    def test_leak_on_node_replace
      loop do
        doc = Nokogiri.XML("<root><foo /></root>")
        n = Nokogiri::XML::CDATA.new(doc, "bar")
        pivot = doc.root.children[0]
        pivot.replace(n)
      end
    end

    def test_sax_parser_context
      io = StringIO.new(@str)

      loop do
        Nokogiri::XML::SAX::ParserContext.new(@str)
        Nokogiri::XML::SAX::ParserContext.new(io)
        io.rewind

        Nokogiri::HTML::SAX::ParserContext.new(@str)
        Nokogiri::HTML::SAX::ParserContext.new(io)
        io.rewind
      end
    end

    class JumpingSaxHandler < Nokogiri::XML::SAX::Document
      def initialize(jumptag)
        @jumptag = jumptag
        super()
      end

      def start_element(name, attrs = [])
        throw @jumptag
      end
    end

    def test_jumping_sax_handler
      doc = JumpingSaxHandler.new(:foo)

      loop do
        catch(:foo) do
          Nokogiri::HTML::SAX::Parser.new(doc).parse(@str)
        end
      end
    end

    def test_in_context_parser_leak
      loop do 
        doc = Nokogiri::XML::Document.new
        fragment1 = Nokogiri::XML::DocumentFragment.new(doc, '<foo/>')
        node = fragment1.children[0]
        node.parse('<bar></bar>')
      end
    end

    def test_in_context_parser_leak_ii
      loop { Nokogiri::XML('<a/>').root.parse('<b/>') }
    end

    def test_leak_on_xpath_string_function
      doc = Nokogiri::XML(@str)
      loop do
        doc.xpath('name(//node())')
      end
    end
  end # if NOKOGIRI_GC

  private

  def count_object_space_documents
    count = 0
    ObjectSpace.each_object {|j| count += 1 if j.is_a?(Nokogiri::XML::Document) }
    count
  end
end

require "helper"

require 'nkf'

module Nokogiri
  module HTML
    class TestNode < Nokogiri::TestCase
      def setup
        super
        @html = Nokogiri::HTML(<<-eohtml)
        <html>
          <head></head>
          <body>
            <div class='baz'><a href="foo" class="bar">first</a></div>
          </body>
        </html>
        eohtml
      end

      def test_to_a
        assert_equal [['class', 'bar'], ['href', 'foo']],@html.at('a').to_a.sort
      end

      def test_attr
        node = @html.at('div.baz')
        assert_equal node['class'], node.attr('class')
      end

      def test_get_attribute
        element = @html.at('div')
        assert_equal 'baz', element.get_attribute('class')
        assert_equal 'baz', element['class']
        element['href'] = "javascript:alert(\"AGGA-KA-BOO!\")"
        assert_match(/%22AGGA-KA-BOO!%22/, element.to_html)
      end

      # The HTML parser ignores namespaces, so even properly declared namespaces
      # are treated as as undeclared and have to be accessed via prefix:tagname
      def test_ns_attribute
        html = '<i foo:bar="baz"></i>'
        doc = Nokogiri::HTML(html)
        assert_equal 'baz', (doc%'i')['foo:bar']
      end

      def test_css_path_round_trip
        doc = Nokogiri::HTML(File.read(HTML_FILE))
        %w{ #header small div[2] div.post body }.each do |css_sel|
          ele = doc.at css_sel
          assert_equal ele, doc.at(ele.css_path), ele.css_path
        end
      end

      def test_path_round_trip
        doc = Nokogiri::HTML(File.read(HTML_FILE))
        %w{ #header small div[2] div.post body }.each do |css_sel|
          ele = doc.at css_sel
          assert_equal ele, doc.at(ele.path), ele.path
        end
      end

      def test_append_with_document
        assert_raises(ArgumentError) do
          @html.root << Nokogiri::HTML::Document.new
        end
      end

      ###
      # Make sure a document that doesn't declare a meta encoding returns
      # nil.
      def test_meta_encoding
        assert_nil @html.meta_encoding
      end

      def test_description
        assert desc = @html.at('a.bar').description
        assert_equal 'a', desc.name
      end

      def test_ancestors_with_selector
        assert node = @html.at('a.bar').child
        assert list = node.ancestors('.baz')
        assert_equal 1, list.length
        assert_equal 'div', list.first.name
      end

      def test_matches_inside_fragment
        fragment = DocumentFragment.new @html
        fragment << XML::Node.new('a', @html)

        a = fragment.children.last
        assert a.matches?('a'), 'a should match'
      end

      def test_css_matches?
        assert node = @html.at('a.bar')
        assert node.matches?('a.bar')
      end

      def test_xpath_matches?
        assert node = @html.at('//a')
        assert node.matches?('//a')
      end

      def test_unlink_then_swap
        node = @html.at('a')
        node.unlink

        another_node = @html.at('div')
        assert another_node, 'should have a node'

        # This used to segv
        assert node.add_previous_sibling another_node
      end

      def test_swap
        @html.at('div').swap('<a href="foo">bar</a>')
        a_tag = @html.css('a').first
        assert_equal 'body', a_tag.parent.name
        assert_equal 0, @html.css('div').length
      end

      def test_swap_with_regex_characters
        @html.at('div').swap('<a href="foo">ba)r</a>')
        a_tag = @html.css('a').first
        assert_equal 'ba)r', a_tag.text
      end

      def test_attribute_decodes_entities
        node = @html.at('div')
        node['href'] = 'foo&bar'
        assert_equal 'foo&bar', node['href']
        node['href'] += '&baz'
        assert_equal 'foo&bar&baz', node['href']
      end

      def test_parse_config_option
        node = @html.at('div')
        options = nil
        node.parse("<div></div>") do |config|
          options = config
        end
        assert_equal Nokogiri::XML::ParseOptions::DEFAULT_HTML, options.to_i
      end

      def test_fragment_handler_does_not_regurge_on_invalid_attributes
        iframe = %Q{<iframe style="width: 0%; height: 0px" src="http://someurl" allowtransparency></iframe>}
        assert @html.at('div').fragment(iframe)
      end

      def test_fragment
        fragment = @html.fragment(<<-eohtml)
          hello
          <div class="foo">
            <p>bar</p>
          </div>
          world
        eohtml
        assert_match(/^hello/, fragment.inner_html.strip)
        assert_equal 3, fragment.children.length
        assert p_tag = fragment.css('p').first
        assert_equal 'div', p_tag.parent.name
        assert_equal 'foo', p_tag.parent['class']
      end

      def test_fragment_serialization
        fragment = Nokogiri::HTML.fragment("<div>foo</div>")
        assert_equal "<div>foo</div>", fragment.serialize.chomp
        assert_equal "<div>foo</div>", fragment.to_xml.chomp
        assert_equal "<div>foo</div>", fragment.inner_html
        assert_equal "<div>foo</div>", fragment.to_html
        assert_equal "<div>foo</div>", fragment.to_s
      end

      def test_to_html_does_not_contain_entities
        return unless defined?(NKF) # NKF is not implemented on Rubinius as of 2009-11-23
        html = NKF.nkf("-e --msdos", <<-EOH)
        <html><body>
        <p> test paragraph
        foo bar </p>
        </body></html>
        EOH
        nokogiri = Nokogiri::HTML.parse(html)

        if RUBY_PLATFORM =~ /java/
          # NKF linebreak modes are not supported as of jruby 1.2
          # see http://jira.codehaus.org/browse/JRUBY-3602 for status
          assert_equal "<p>testparagraph\nfoobar</p>",
            nokogiri.at("p").to_html.gsub(/ /, '')
        else
          assert_equal "<p>testparagraph\r\nfoobar</p>",
            nokogiri.at("p").to_html.gsub(/ /, '')
        end
      end
    end

    def test_GH_1042
      file = File.join(ASSETS_DIR, 'GH_1042.html');
      html = Nokogiri::HTML(File.read(file))
      table = html.xpath("//table")[1]
      trs = table.xpath("tr").drop(1)

      # the jruby inplementation of drop uses dup() on the IRubyObject (which
      # is NOT the same dup() method on the ruby Object) which produces a
      # shallow clone. a shallow of valid XMLNode triggers several
      # NullPointerException on inspect() since loads of invariants
      # are not set. the fix for GH1042 ensures a proper working clone.
      assert_nothing_raised do
        trs.inspect
      end
    end
  end
end

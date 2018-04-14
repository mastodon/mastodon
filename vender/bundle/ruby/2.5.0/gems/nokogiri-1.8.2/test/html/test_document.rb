require "helper"

module Nokogiri
  module HTML
    class TestDocument < Nokogiri::TestCase
      def setup
        super
        @html = Nokogiri::HTML.parse(File.read(HTML_FILE))
      end

      def test_nil_css
        # Behavior is undefined but shouldn't break
        assert @html.css(nil)
        assert @html.xpath(nil)
      end

      def test_does_not_fail_with_illformatted_html
        doc = Nokogiri::HTML('"</html>";'.dup.force_encoding(Encoding::BINARY))
        assert_not_nil doc
      end

      def test_exceptions_remove_newlines
        errors = @html.errors
        assert errors.length > 0, 'has errors'
        errors.each do |error|
          assert_equal(error.to_s.chomp, error.to_s)
        end
      end

      def test_fragment
        fragment = @html.fragment
        assert_equal 0, fragment.children.length
      end

      def test_document_takes_config_block
        options = nil
        Nokogiri::HTML(File.read(HTML_FILE), HTML_FILE) do |cfg|
          options = cfg
          options.nonet.nowarning.dtdattr
        end
        assert options.nonet?
        assert options.nowarning?
        assert options.dtdattr?
      end

      def test_parse_takes_config_block
        options = nil
        Nokogiri::HTML.parse(File.read(HTML_FILE), HTML_FILE) do |cfg|
          options = cfg
          options.nonet.nowarning.dtdattr
        end
        assert options.nonet?
        assert options.nowarning?
        assert options.dtdattr?
      end

      def test_subclass
        klass = Class.new(Nokogiri::HTML::Document)
        doc = klass.new
        assert_instance_of klass, doc
      end

      def test_subclass_initialize
        klass = Class.new(Nokogiri::HTML::Document) do
          attr_accessor :initialized_with

          def initialize(*args)
            @initialized_with = args
          end
        end
        doc = klass.new("uri", "external_id", 1)
        assert_equal ["uri", "external_id", 1], doc.initialized_with
      end

      def test_subclass_dup
        klass = Class.new(Nokogiri::HTML::Document)
        doc = klass.new.dup
        assert_instance_of klass, doc
      end

      def test_subclass_parse
        klass = Class.new(Nokogiri::HTML::Document)
        doc = klass.parse(File.read(HTML_FILE))
        assert_equal @html.to_s, doc.to_s
        assert_instance_of klass, doc
      end

      def test_document_parse_method
        html = Nokogiri::HTML::Document.parse(File.read(HTML_FILE))
        assert_equal @html.to_s, html.to_s
      end

      def test_document_parse_method_with_url
        require 'open-uri'
        begin
          html = open('https://www.yahoo.com').read
        rescue Exception => e
          skip("This test needs the internet. Skips if no internet available. (#{e})")
        end
        doc = Nokogiri::HTML html ,"http:/foobar.foobar/", 'UTF-8'
        refute_empty doc.to_s, "Document should not be empty"
      end

      ###
      # Nokogiri::HTML returns an empty Document when given a blank string GH#11
      def test_empty_string_returns_empty_doc
        doc = Nokogiri::HTML('')
        assert_instance_of Nokogiri::HTML::Document, doc
        assert_nil doc.root
      end

      unless Nokogiri.uses_libxml? && %w[2 6] === LIBXML_VERSION.split('.')[0..1]
        # FIXME: this is a hack around broken libxml versions
        def test_to_xhtml_with_indent
          doc = Nokogiri::HTML('<html><body><a>foo</a></body></html>')
          doc = Nokogiri::HTML(doc.to_xhtml(:indent => 2))
          assert_indent 2, doc
        end

        def test_write_to_xhtml_with_indent
          io = StringIO.new
          doc = Nokogiri::HTML('<html><body><a>foo</a></body></html>')
          doc.write_xhtml_to io, :indent => 5
          io.rewind
          doc = Nokogiri::HTML(io.read)
          assert_indent 5, doc
        end
      end

      def test_swap_should_not_exist
        assert_raises(NoMethodError) {
          @html.swap
        }
      end

      def test_namespace_should_not_exist
        assert_raises(NoMethodError) {
          @html.namespace
        }
      end

      def test_meta_encoding
        assert_equal 'UTF-8', @html.meta_encoding
      end

      def test_meta_encoding_is_strict_about_http_equiv
        doc = Nokogiri::HTML(<<-eohtml)
<html>
  <head>
    <meta http-equiv="X-Content-Type" content="text/html; charset=Shift_JIS">
  </head>
  <body>
    foo
  </body>
</html>
        eohtml
        assert_nil doc.meta_encoding
      end

      def test_meta_encoding_handles_malformed_content_charset
        doc = Nokogiri::HTML(<<EOHTML)
<html>
  <head>
    <meta http-equiv="Content-type" content="text/html; utf-8" />
  </head>
  <body>
    foo
  </body>
</html>
EOHTML
        assert_nil doc.meta_encoding
      end

      def test_meta_encoding_checks_charset
        doc = Nokogiri::HTML(<<-eohtml)
<html>
  <head>
    <meta charset="UTF-8">
  </head>
  <body>
    foo
  </body>
</html>
        eohtml
        assert_equal 'UTF-8', doc.meta_encoding
      end

      def test_meta_encoding=
        @html.meta_encoding = 'EUC-JP'
        assert_equal 'EUC-JP', @html.meta_encoding
      end

      def test_title
        assert_equal 'Tender Lovemaking  ', @html.title
        doc = Nokogiri::HTML('<html><body>foo</body></html>')
        assert_nil doc.title
      end

      def test_title=()
        doc = Nokogiri::HTML(<<eohtml)
<html>
  <head>
    <title>old</title>
  </head>
  <body>
    foo
  </body>
</html>
eohtml
        doc.title = 'new'
        assert_equal 1, doc.css('title').size
        assert_equal 'new', doc.title

        doc = Nokogiri::HTML(<<eohtml)
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head>
  <body>
    foo
  </body>
</html>
eohtml
        doc.title = 'new'
        assert_equal 'new', doc.title
        title = doc.at('/html/head/title')
        assert_not_nil title
        assert_equal 'new', title.text
        assert_equal(-1, doc.at('meta[@http-equiv]') <=> title)

        doc = Nokogiri::HTML(<<eohtml)
<html>
  <body>
    foo
  </body>
</html>
eohtml
        doc.title = 'new'
        assert_equal 'new', doc.title
        # <head> may or may not be added
        title = doc.at('/html//title')
        assert_not_nil title
        assert_equal 'new', title.text
        assert_equal(-1, title <=> doc.at('body'))

        doc = Nokogiri::HTML(<<eohtml)
<html>
  <meta charset="UTF-8">
  <body>
    foo
  </body>
</html>
eohtml
        doc.title = 'new'
        assert_equal 'new', doc.title
        assert_equal(-1, doc.at('meta[@charset]') <=> doc.at('title'))
        assert_equal(-1, doc.at('title') <=> doc.at('body'))

        doc = Nokogiri::HTML('<!DOCTYPE html><p>hello')
        doc.title = 'new'
        assert_equal 'new', doc.title
        assert_instance_of Nokogiri::XML::DTD, doc.children.first
        assert_equal(-1, doc.at('title') <=> doc.at('p'))

        doc = Nokogiri::HTML('')
        doc.title = 'new'
        assert_equal 'new', doc.title
        assert_equal 'new', doc.at('/html/head/title/text()').to_s
      end

      def test_meta_encoding_without_head
        encoding = 'EUC-JP'
        html = Nokogiri::HTML('<html><body>foo</body></html>', nil, encoding)

        assert_nil html.meta_encoding

        html.meta_encoding = encoding
        assert_equal encoding, html.meta_encoding

        meta = html.at('/html/head/meta[@http-equiv and boolean(@content)]')
        assert meta, 'meta is in head'

        assert meta.at('./parent::head/following-sibling::body'), 'meta is before body'
      end

      def test_html5_meta_encoding_without_head
        encoding = 'EUC-JP'
        html = Nokogiri::HTML('<!DOCTYPE html><html><body>foo</body></html>', nil, encoding)

        assert_nil html.meta_encoding

        html.meta_encoding = encoding
        assert_equal encoding, html.meta_encoding

        meta = html.at('/html/head/meta[@charset]')
        assert meta, 'meta is in head'

        assert meta.at('./parent::head/following-sibling::body'), 'meta is before body'
      end

      def test_meta_encoding_with_empty_content_type
        html = Nokogiri::HTML(<<-eohtml)
<html>
  <head>
    <meta http-equiv="Content-Type" content="">
  </head>
  <body>
    foo
  </body>
</html>
        eohtml
        assert_nil html.meta_encoding

        html = Nokogiri::HTML(<<-eohtml)
<html>
  <head>
    <meta http-equiv="Content-Type">
  </head>
  <body>
    foo
  </body>
</html>
        eohtml
        assert_nil html.meta_encoding
      end

      def test_root_node_parent_is_document
        parent = @html.root.parent
        assert_equal @html, parent
        assert_instance_of Nokogiri::HTML::Document, parent
      end

      def test_parse_handles_nil_gracefully
        @doc = Nokogiri::HTML::Document.parse(nil)
        assert_instance_of Nokogiri::HTML::Document, @doc
      end

      def test_parse_empty_document
        doc = Nokogiri::HTML("\n")
        assert_equal 0, doc.css('a').length
        assert_equal 0, doc.xpath('//a').length
        assert_equal 0, doc.search('//a').length
      end

      def test_HTML_function
        html = Nokogiri::HTML(File.read(HTML_FILE))
        assert html.html?
      end

      def test_parse_io
        assert File.open(HTML_FILE, 'rb') { |f|
          Document.read_io(f, nil, 'UTF-8',
                           XML::ParseOptions::NOERROR | XML::ParseOptions::NOWARNING
                          )
        }
      end

      def test_parse_temp_file
        temp_html_file = Tempfile.new("TEMP_HTML_FILE")
        File.open(HTML_FILE, 'rb') { |f| temp_html_file.write f.read }
        temp_html_file.close
        temp_html_file.open
        assert_equal Nokogiri::HTML.parse(File.read(HTML_FILE)).xpath('//div/a').length,
          Nokogiri::HTML.parse(temp_html_file).xpath('//div/a').length
      end

      def test_to_xhtml
        assert_match 'XHTML', @html.to_xhtml
        assert_match 'XHTML', @html.to_xhtml(:encoding => 'UTF-8')
        assert_match 'UTF-8', @html.to_xhtml(:encoding => 'UTF-8')
      end

      def test_no_xml_header
        html = Nokogiri::HTML(<<-eohtml)
        <html>
        </html>
        eohtml
        assert html.to_html.length > 0, 'html length is too short'
        assert_no_match(/^<\?xml/, html.to_html)
      end

      def test_document_has_error
        html = Nokogiri::HTML(<<-eohtml)
        <html>
          <body>
            <div awesome="asdf>
              <p>inside div tag</p>
            </div>
            <p>outside div tag</p>
          </body>
        </html>
        eohtml
        assert html.errors.length > 0
      end

      def test_relative_css
        html = Nokogiri::HTML(<<-eohtml)
        <html>
          <body>
            <div>
              <p>inside div tag</p>
            </div>
            <p>outside div tag</p>
          </body>
        </html>
        eohtml
        set = html.search('div').search('p')
        assert_equal(1, set.length)
        assert_equal('inside div tag', set.first.inner_text)
      end

      def test_multi_css
        html = Nokogiri::HTML(<<-eohtml)
        <html>
          <body>
            <div>
              <p>p tag</p>
              <a>a tag</a>
            </div>
          </body>
        </html>
        eohtml
        set = html.css('p, a')
        assert_equal(2, set.length)
        assert_equal ['a tag', 'p tag'].sort, set.map(&:content).sort
      end

      def test_inner_text
        html = Nokogiri::HTML(<<-eohtml)
        <html>
          <body>
            <div>
              <p>
                Hello world!
              </p>
            </div>
          </body>
        </html>
        eohtml
        node = html.xpath('//div').first
        assert_equal('Hello world!', node.inner_text.strip)
      end

      def test_doc_type
        html = Nokogiri::HTML(<<-eohtml)
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
          <html xmlns="http://www.w3.org/1999/xhtml">
            <body>
              <p>Rainbow Dash</p>
            </body>
          </html>
        eohtml
        assert_equal "html", html.internal_subset.name
        assert_equal "-//W3C//DTD XHTML 1.1//EN", html.internal_subset.external_id
        assert_equal "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd", html.internal_subset.system_id
        assert_equal "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">", html.to_s[0,97]
      end

      def test_content_size
        html = Nokogiri::HTML("<div>\n</div>")
        assert_equal 1, html.content.size
        assert_equal 1, html.content.split("").size
        assert_equal "\n", html.content
      end

      def test_find_by_xpath
        found = @html.xpath('//div/a')
        assert_equal 3, found.length
      end

      def test_find_by_css
        found = @html.css('div > a')
        assert_equal 3, found.length
      end

      def test_find_by_css_with_square_brackets
        found = @html.css("div[@id='header'] > h1")
        found = @html.css("div[@id='header'] h1") # this blows up on commit 6fa0f6d329d9dbf1cc21c0ac72f7e627bb4c05fc
        assert_equal 1, found.length
      end

      def test_find_by_css_with_escaped_characters
        found_without_escape = @html.css("div[@id='abc.123']")
        found_by_id = @html.css('#abc\.123')
        found_by_class = @html.css('.special\.character')
        assert_equal 1, found_without_escape.length
        assert_equal found_by_id, found_without_escape
        assert_equal found_by_class, found_without_escape
      end

      def test_find_with_function
        assert @html.css("div:awesome() h1", Class.new {
          def awesome divs
            [divs.first]
          end
        }.new)
      end

      def test_dup_shallow
        found = @html.search('//div/a').first
        dup = found.dup(0)
        assert dup
        assert_equal '', dup.content
      end

      def test_search_can_handle_xpath_and_css
        found = @html.search('//div/a', 'div > p')
        length = @html.xpath('//div/a').length +
          @html.css('div > p').length
        assert_equal length, found.length
      end

      def test_dup_document
        assert dup = @html.dup
        assert_not_equal dup, @html
        assert @html.html?
        assert_instance_of Nokogiri::HTML::Document, dup
        assert dup.html?, 'duplicate should be html'
        assert_equal @html.to_s, dup.to_s
      end

      def test_dup_document_shallow
        assert dup = @html.dup(0)
        assert_not_equal dup, @html
      end

      def test_dup
        found = @html.search('//div/a').first
        dup = found.dup
        assert dup
        assert_equal found.content, dup.content
        assert_equal found.document, dup.document
      end

      def test_inner_html
        html = Nokogiri::HTML <<-EOHTML
        <html>
          <body>
            <div>
              <p>
                Hello world!
              </p>
            </div>
          </body>
        </html>
        EOHTML
        node = html.xpath("//div").first
        assert_equal("<p>Helloworld!</p>", node.inner_html.gsub(%r{\s}, ""))
      end

      def test_round_trip
        doc = Nokogiri::HTML(@html.inner_html)
        assert_equal @html.root.to_html, doc.root.to_html
      end

      def test_fragment_contains_text_node
        fragment = Nokogiri::HTML.fragment('fooo')
        assert_equal 1, fragment.children.length
        assert_equal 'fooo', fragment.inner_text
      end

      def test_fragment_includes_two_tags
        assert_equal 2, Nokogiri::HTML.fragment("<br/><hr/>").children.length
      end

      def test_relative_css_finder
        doc = Nokogiri::HTML(<<-eohtml)
          <html>
            <body>
              <div class="red">
                <p>
                  inside red
                </p>
              </div>
              <div class="green">
                <p>
                  inside green
                </p>
              </div>
            </body>
          </html>
        eohtml
        red_divs = doc.css('div.red')
        assert_equal 1, red_divs.length
        p_tags = red_divs.first.css('p')
        assert_equal 1, p_tags.length
        assert_equal 'inside red', p_tags.first.text.strip
      end

      def test_find_classes
        doc = Nokogiri::HTML(<<-eohtml)
          <html>
            <body>
              <p class="red">RED</p>
              <p class="awesome red">RED</p>
              <p class="notred">GREEN</p>
              <p class="green notred">GREEN</p>
            </body>
          </html>
        eohtml
        list = doc.css('.red')
        assert_equal 2, list.length
        assert_equal %w{ RED RED }, list.map(&:text)
      end

      def test_parse_can_take_io
        html = nil
        File.open(HTML_FILE, 'rb') { |f|
          html = Nokogiri::HTML(f)
        }
        assert html.html?
      end

      def test_html?
        assert !@html.xml?
        assert @html.html?
      end

      def test_serialize
        assert @html.serialize
        assert @html.to_html
      end

      def test_empty_document
        # empty document should return "" #699
        assert_equal "", Nokogiri::HTML.parse(nil).text
        assert_equal "", Nokogiri::HTML.parse("").text
      end

      def test_capturing_nonparse_errors_during_document_clone
        # see https://github.com/sparklemotion/nokogiri/issues/1196 for background
        original = Nokogiri::HTML.parse("<div id='unique'></div><div id='unique'></div>")
        original_errors = original.errors.dup

        copy = original.dup
        assert_equal original_errors, copy.errors
      end

      def test_capturing_nonparse_errors_during_node_copy_between_docs
        # Errors should be emitted while parsing only, and should not change when moving nodes.
        doc1 = Nokogiri::HTML("<html><body><diva id='unique'>one</diva></body></html>")
        doc2 = Nokogiri::HTML("<html><body><dive id='unique'>two</dive></body></html>")
        node1 = doc1.at_css("#unique")
        node2 = doc2.at_css("#unique")
        original_errors1 = doc1.errors.dup
        original_errors2 = doc2.errors.dup
        assert original_errors1.any?{|e| e.to_s =~ /Tag diva invalid/ }, "it should complain about the tag name"
        assert original_errors2.any?{|e| e.to_s =~ /Tag dive invalid/ }, "it should complain about the tag name"

        node1.add_child node2

        assert_equal original_errors1, doc1.errors
        assert_equal original_errors2, doc2.errors
      end

      def test_silencing_nonparse_errors_during_attribute_insertion_1262
        # see https://github.com/sparklemotion/nokogiri/issues/1262
        #
        # libxml2 emits a warning when this happens; the JRuby
        # implementation does not. so rather than capture the error in
        # doc.errors in a platform-dependent way, I'm opting to have
        # the error silenced.
        #
        # So this test doesn't look meaningful, but we want to avoid
        # having `ID unique-issue-1262 already defined` emitted to
        # stderr when running the test suite.
        #
        doc = Nokogiri::HTML::Document.new
        Nokogiri::XML::Element.new("div", doc).set_attribute('id', 'unique-issue-1262')
        Nokogiri::XML::Element.new("div", doc).set_attribute('id', 'unique-issue-1262')
        assert_equal 0, doc.errors.length
      end

      it "skips encoding for script tags" do
        html = Nokogiri::HTML <<-EOHTML
        <html>
          <head>
            <script>var isGreater = 4 > 5;</script>
          </head>
          <body></body>
        </html>
        EOHTML
        node = html.xpath("//script").first
        assert_equal("var isGreater = 4 > 5;", node.inner_html)
      end

      it "skips encoding for style tags" do
        html = Nokogiri::HTML <<-EOHTML
        <html>
          <head>
            <style>tr > div { display:block; }</style>
          </head>
          <body></body>
        </html>
        EOHTML
        node = html.xpath("//style").first
        assert_equal("tr > div { display:block; }", node.inner_html)
      end

      it "does not fail when converting to_html using explicit encoding" do
        html_fragment=<<-eos
  <img width="16" height="16" src="images/icon.gif" border="0" alt="Inactive hide details for &quot;User&quot; ---19/05/2015 12:55:29---Provvediamo subito nell&#8217;integrare">
        eos
        doc = Nokogiri::HTML(html_fragment, nil, 'ISO-8859-1')
        html = doc.to_html
        assert html.index("src=\"images/icon.gif\"")
        assert_equal 'ISO-8859-1', html.encoding.name
      end

    end
  end
end

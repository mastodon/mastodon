$:.unshift('lib')
$:.unshift('ext/nokogumboc')

gem 'minitest'

require 'nokogumbo'
require 'minitest/autorun'

class TestNokogumbo < Minitest::Test
  def test_element_text
    doc = Nokogiri::HTML5(buffer)
    assert_equal "content", doc.at('span').text
  end

  def test_element_cdata_textarea
    doc = Nokogiri::HTML5(buffer)
    assert_equal "foo<x>bar", doc.at('textarea').text.strip
  end

  def test_element_cdata_script
    doc = Nokogiri::HTML5.fragment(buffer)
    assert_equal true, doc.document.html?
    assert_equal "<script> if (a < b) alert(1) </script>", doc.at('script').to_s
  end

  def test_attr_value
    doc = Nokogiri::HTML5(buffer)
    assert_equal "utf-8", doc.at('meta')['charset']
  end

  def test_comment
    doc = Nokogiri::HTML5(buffer)
    assert_equal " test comment ", doc.xpath('//comment()').text
  end

  def test_unknown_element
    doc = Nokogiri::HTML5(buffer)
    assert_equal "main", doc.at('main').name
  end

  def test_IO
    require 'stringio'
    doc = Nokogiri::HTML5(StringIO.new(buffer))
    assert_equal 'textarea', doc.at('form').element_children.first.name
  end

  def test_nil
    doc = Nokogiri::HTML5(nil)
    assert_equal 1, doc.search('body').count
  end

  if ''.respond_to? 'encoding'
    def test_macroman_encoding
      mac="<span>\xCA</span>".force_encoding('macroman')
      doc = Nokogiri::HTML5(mac)
      assert_equal '<span>&#xA0;</span>', doc.at('span').to_xml
    end

    def test_iso8859_encoding
      iso8859="<span>Se\xF1or</span>".force_encoding(Encoding::ASCII_8BIT)
      doc = Nokogiri::HTML5(iso8859)
      assert_equal '<span>Se&#xF1;or</span>', doc.at('span').to_xml
    end

    def test_charset_encoding
      utf8="<meta charset='utf-8'><span>Se\xC3\xB1or</span>".
        force_encoding(Encoding::ASCII_8BIT)
      doc = Nokogiri::HTML5(utf8)
      assert_equal '<span>Se&#xF1;or</span>', doc.at('span').to_xml
    end

    def test_bogus_encoding
      bogus="<meta charset='bogus'><span>Se\xF1or</span>".
        force_encoding(Encoding::ASCII_8BIT)
      doc = Nokogiri::HTML5(bogus)
      assert_equal '<span>Se&#xF1;or</span>', doc.at('span').to_xml
    end
  end

  def test_html5_doctype
    doc = Nokogiri::HTML5.parse("<!DOCTYPE html><html></html>")
    assert_match /<!DOCTYPE html>/, doc.to_html
  end

  def test_fragment_head
    doc = Nokogiri::HTML5.fragment(buffer[/<head>(.*?)<\/head>/m, 1])
    assert_equal "hello world", doc.xpath('title').text
    assert_equal "utf-8", doc.xpath('meta').first['charset']
  end

  def test_fragment_body
    doc = Nokogiri::HTML5.fragment(buffer[/<body>(.*?)<\/body>/m, 1])
    assert_equal '<span>content</span>', doc.xpath('main/span').to_xml
    assert_equal " test comment ", doc.xpath('comment()').text
  end

  def test_xlink_attribute
    source = <<-EOF.gsub(/^ {6}/, '')
      <svg xmlns="http://www.w3.org/2000/svg">
        <a xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#s1"/>
      </svg>
    EOF
    doc = Nokogiri::HTML5.fragment(source)
    a = doc.at('a')
    assert_equal ["xlink:href", "xmlns:xlink"], a.attributes.keys.sort
  end

  def test_template
    source = <<-EOF.gsub(/^ {6}/, '')
      <template id="productrow">
        <tr>
          <td class="record"></td>
          <td></td>
        </tr>
      </template>
    EOF
    doc = Nokogiri::HTML5.fragment(source)
    template = doc.at('template')
    assert_equal "productrow", template['id']
    assert_equal "record", template.at('td')['class']
  end

  def test_root_comments
    doc = Nokogiri::HTML5("<!DOCTYPE html><!-- start --><html></html><!-- -->")
    assert_equal ["html", "comment", "html", "comment"], doc.children.map(&:name)
  end

  def test_parse_errors
    doc = Nokogiri::HTML5("<!DOCTYPE html><html><!-- -- --></a>", max_parse_errors: 10)
    assert_equal doc.errors.length, 2
    doc = Nokogiri::HTML5("<!DOCTYPE html><html>", max_parse_errors: 10)
    assert_empty doc.errors
  end

  def test_max_parse_errors
    # This document contains 2 parse errors, but we force limit to 1.
    doc = Nokogiri::HTML5("<!DOCTYPE html><html><!-- -- --></a>", max_parse_errors: 1)
    assert_equal 1, doc.errors.length
    doc = Nokogiri::HTML5("<!DOCTYPE html><html>", max_parse_errors: 1)
    assert_empty doc.errors
  end

  def test_default_max_parse_errors
    # This document contains 200 parse errors, but default limit is 0.
    doc = Nokogiri::HTML5("<!DOCTYPE html><html>" + "</p>" * 200)
    assert_equal 0, doc.errors.length
  end

  def test_parse_fragment_errors
    doc = Nokogiri::HTML5.fragment("<\r\n", max_parse_errors: 10)
    refute_empty doc.errors
  end

  def test_fragment_max_parse_errors
    # This fragment contains 3 parse errors, but we force limit to 1.
    doc = Nokogiri::HTML5.fragment("<!-- -- --></a>", max_parse_errors: 1)
    assert_equal 1, doc.errors.length
  end

  def test_fragment_default_max_parse_errors
    # This fragment contains 201 parse errors, but default limit is 0.
    doc = Nokogiri::HTML5.fragment("</p>" * 200)
    assert_equal 0, doc.errors.length
  end

private

  def buffer
    <<-EOF.gsub(/^      /, '')
      <html>
        <head>
          <meta charset="utf-8"/>
          <title>hello world</title>
          <script> if (a < b) alert(1) </script>
        </head>
        <body>
          <h1>hello world</h1>
          <main>
            <span>content</span>
          </main>
          <!-- test comment -->
          <form>
            <textarea>foo<x>bar</textarea>
          </form>
        </body>
      </html>
    EOF
  end

end

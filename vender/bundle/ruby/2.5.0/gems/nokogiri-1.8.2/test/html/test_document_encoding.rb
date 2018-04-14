# -*- coding: utf-8 -*-
require "helper"

module Nokogiri
  module HTML
    class TestDocumentEncoding < Nokogiri::TestCase
      def test_encoding
        doc = Nokogiri::HTML File.open(SHIFT_JIS_HTML, 'rb')

        hello = "こんにちは"

        assert_match doc.encoding, doc.to_html
        assert_match hello.encode('Shift_JIS'), doc.to_html
        assert_equal 'Shift_JIS', doc.to_html.encoding.name

        assert_match hello, doc.to_html(:encoding => 'UTF-8')
        assert_match 'UTF-8', doc.to_html(:encoding => 'UTF-8')
        assert_match 'UTF-8', doc.to_html(:encoding => 'UTF-8').encoding.name
      end

      def test_encoding_without_charset
        doc = Nokogiri::HTML File.open(SHIFT_JIS_NO_CHARSET, 'r:cp932:cp932').read

        hello = "こんにちは"

        assert_match hello, doc.content
        assert_match hello, doc.to_html(:encoding => 'UTF-8')
        assert_match 'UTF-8', doc.to_html(:encoding => 'UTF-8').encoding.name
      end

      def test_default_to_encoding_from_string
        bad_charset = <<-eohtml
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=charset=UTF-8">
</head>
<body>
  <a href="http://tenderlovemaking.com/">blah!</a>
</body>
</html>
        eohtml
        doc = Nokogiri::HTML(bad_charset)
        assert_equal bad_charset.encoding.name, doc.encoding

        doc = Nokogiri.parse(bad_charset)
        assert_equal bad_charset.encoding.name, doc.encoding
      end

      def test_encoding_non_utf8
        orig = '日本語が上手です'
        bin = Encoding::ASCII_8BIT
        [Encoding::Shift_JIS, Encoding::EUC_JP].each do |enc|
          html = <<-eohtml.encode(enc)
<html>
<meta http-equiv="Content-Type" content="text/html; charset=#{enc.name}">
<title xml:lang="ja">#{orig}</title></html>
          eohtml
          text = Nokogiri::HTML.parse(html).at('title').inner_text
          assert_equal(
            orig.encode(enc).force_encoding(bin),
            text.encode(enc).force_encoding(bin)
          )
        end
      end

      def test_encoding_with_a_bad_name
        bad_charset = <<-eohtml
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=charset=UTF-8">
</head>
<body>
  <a href="http://tenderlovemaking.com/">blah!</a>
</body>
</html>
        eohtml
        doc = Nokogiri::HTML(bad_charset, nil, 'askldjfhalsdfjhlkasdfjh')
        assert_equal ['http://tenderlovemaking.com/'],
          doc.css('a').map { |a| a['href'] }
      end

      def test_empty_doc_encoding
        encoding = 'US-ASCII'
        assert_equal encoding, Nokogiri::HTML.parse(nil, nil, encoding).encoding
      end
    end

    class TestDocumentEncodingDetection < Nokogiri::TestCase
      def binread(file)
        IO.binread(file)
      end

      def binopen(file)
        File.open(file, 'rb')
      end

      def test_document_html_noencoding
        from_stream = Nokogiri::HTML(binopen(NOENCODING_FILE))
        from_string = Nokogiri::HTML(binread(NOENCODING_FILE))

        assert_equal from_string.to_s.size, from_stream.to_s.size
      end

      def test_document_html_charset
        html = Nokogiri::HTML(binopen(METACHARSET_FILE))
        assert_equal 'iso-2022-jp', html.encoding
        assert_equal 'たこ焼き仮面', html.title
      end

      def test_document_xhtml_enc
        [ENCODING_XHTML_FILE, ENCODING_HTML_FILE].each { |file|
          doc_from_string_enc = Nokogiri::HTML(binread(file), nil, 'Shift_JIS')
          ary_from_string_enc = doc_from_string_enc.xpath('//p/text()').map(&:text)

          doc_from_string = Nokogiri::HTML(binread(file))
          ary_from_string = doc_from_string.xpath('//p/text()').map(&:text)

          doc_from_file_enc = Nokogiri::HTML(binopen(file), nil, 'Shift_JIS')
          ary_from_file_enc = doc_from_file_enc.xpath('//p/text()').map(&:text)

          doc_from_file = Nokogiri::HTML(binopen(file))
          ary_from_file = doc_from_file.xpath('//p/text()').map(&:text)

          title = 'たこ焼き仮面'

          assert_equal(title, doc_from_string_enc.at('//title/text()').text)
          assert_equal(title, doc_from_string.at('//title/text()').text)
          assert_equal(title, doc_from_file_enc.at('//title/text()').text)
          assert_equal(title, doc_from_file.at('//title/text()').text)

          evil = (0..72).map { |i| '超' * i + '悪い事を構想中。' }

          assert_equal(evil, ary_from_string_enc)
          assert_equal(evil, ary_from_string)
          assert_equal(evil, ary_from_file_enc)
          assert_equal(evil, ary_from_file)
        }
      end
    end
  end
end

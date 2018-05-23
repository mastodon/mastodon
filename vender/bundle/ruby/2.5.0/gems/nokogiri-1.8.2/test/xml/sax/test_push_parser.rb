# -*- coding: utf-8 -*-

require "helper"

module Nokogiri
  module XML
    module SAX
      class TestPushParser < Nokogiri::SAX::TestCase
        def setup
          super
          @parser = XML::SAX::PushParser.new(Doc.new)
        end

        def test_exception
          assert_raises(SyntaxError) do
            @parser << "<foo /><foo />"
          end

          assert_raises(SyntaxError) do
            @parser << nil
          end
        end

        def test_end_document_called
          @parser.<<(<<-eoxml)
            <p id="asdfasdf">
              <!-- This is a comment -->
              Paragraph 1
            </p>
          eoxml
          assert ! @parser.document.end_document_called
          @parser.finish
          assert @parser.document.end_document_called
        end

        def test_start_element
          @parser.<<(<<-eoxml)
            <p id="asdfasdf">
          eoxml

          assert_equal [["p", [["id", "asdfasdf"]]]],
            @parser.document.start_elements

          @parser.<<(<<-eoxml)
              <!-- This is a comment -->
              Paragraph 1
            </p>
          eoxml
          assert_equal [' This is a comment '], @parser.document.comments
          @parser.finish
        end

        def test_start_element_with_namespaces
          @parser.<<(<<-eoxml)
            <p xmlns:foo="http://foo.example.com/">
          eoxml

          assert_equal [["p", [["xmlns:foo", "http://foo.example.com/"]]]],
            @parser.document.start_elements

          @parser.<<(<<-eoxml)
              <!-- This is a comment -->
              Paragraph 1
            </p>
          eoxml
          assert_equal [' This is a comment '], @parser.document.comments
          @parser.finish
        end

        def test_start_element_ns
          @parser.<<(<<-eoxml)
            <stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' version='1.0' size='large'></stream:stream>
          eoxml

          assert_equal 1, @parser.document.start_elements_namespace.length
          el = @parser.document.start_elements_namespace.first

          assert_equal 'stream', el.first
          assert_equal 2, el[1].length
          assert_equal [['version', '1.0'], ['size', 'large']],
            el[1].map { |x| [x.localname, x.value] }

          assert_equal 'stream', el[2]
          assert_equal 'http://etherx.jabber.org/streams', el[3]
          @parser.finish
        end

        def test_end_element_ns
          @parser.<<(<<-eoxml)
            <stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' version='1.0'></stream:stream>
          eoxml

          assert_equal [['stream', 'stream', 'http://etherx.jabber.org/streams']],
            @parser.document.end_elements_namespace
          @parser.finish
        end

        def test_chevron_partial_xml
          @parser.<<(<<-eoxml)
            <p id="asdfasdf">
          eoxml

          @parser.<<(<<-eoxml)
              <!-- This is a comment -->
              Paragraph 1
            </p>
          eoxml
          assert_equal [' This is a comment '], @parser.document.comments
          @parser.finish
        end

        def test_chevron
          @parser.<<(<<-eoxml)
            <p id="asdfasdf">
              <!-- This is a comment -->
              Paragraph 1
            </p>
          eoxml
          @parser.finish
          assert_equal [' This is a comment '], @parser.document.comments
        end

        def test_default_options
          assert_equal 0, @parser.options
        end

        def test_recover
          @parser.options |= XML::ParseOptions::RECOVER
          @parser.<<(<<-eoxml)
            <p>
              Foo
              <bar>
              Bar
            </p>
          eoxml
          @parser.finish
          assert(@parser.document.errors.size >= 1)
          assert_equal [["p", []], ["bar", []]], @parser.document.start_elements
          assert_equal "FooBar", @parser.document.data.map { |x|
            x.gsub(/\s/, '')
          }.join
        end

        def test_broken_encoding
          skip("ultra hard to fix for pure Java version") if Nokogiri.jruby?
          @parser.options |= XML::ParseOptions::RECOVER
          # This is ISO_8859-1:
          @parser.<< "<?xml version='1.0' encoding='UTF-8'?><r>Gau\337</r>"
          @parser.finish
          assert(@parser.document.errors.size >= 1)
          assert_equal "Gau\337", @parser.document.data.join
          assert_equal [["r"]], @parser.document.end_elements
        end

        def test_replace_entities_attribute_behavior
          if Nokogiri.uses_libxml?
            # initially false
            assert_equal false, @parser.replace_entities

            # can be set to true
            @parser.replace_entities = true
            assert_equal true, @parser.replace_entities

            # can be set to false
            @parser.replace_entities = false
            assert_equal false, @parser.replace_entities
          else
            # initially true
            assert_equal true, @parser.replace_entities

            # ignore attempts to set to false
            @parser.replace_entities = false # TODO: should we raise an exception here?
            assert_equal true, @parser.replace_entities
          end
        end

        def test_untouched_entities
          skip("entities are always replaced in pure Java version") if Nokogiri.jruby?
          @parser.<<(<<-eoxml)
            <p id="asdf&amp;asdf">
              <!-- This is a comment -->
              Paragraph 1 &amp; 2
            </p>
          eoxml
          @parser.finish
          assert_equal [["p", [["id", "asdf&#38;asdf"]]]], @parser.document.start_elements
          assert_equal "Paragraph 1 & 2", @parser.document.data.join.strip
        end

        def test_replaced_entities
          @parser.replace_entities = true
          @parser.<<(<<-eoxml)
            <p id="asdf&amp;asdf">
              <!-- This is a comment -->
              Paragraph 1 &amp; 2
            </p>
          eoxml
          @parser.finish
          assert_equal [["p", [["id", "asdf&asdf"]]]], @parser.document.start_elements
          assert_equal "Paragraph 1 & 2", @parser.document.data.join.strip
        end
      end
    end
  end
end

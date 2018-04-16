# -*- coding: utf-8 -*-
require "helper"

module Nokogiri
  module XML
    module SAX
      class TestParserText < Nokogiri::SAX::TestCase
        def setup
          super
          @doc    = DocWithOrderedItems.new
          @parser = XML::SAX::Parser.new @doc
        end

        def test_texts_order
          xml = <<-eoxml
<?xml version="1.0" ?>
<root>
  text 0
  <p>
    text 1
    <span>text 2</span>
    text 3
  </p>

  text 4
  <!--
  text 5
  -->

  <p>
    <!-- text 6 -->
    <span><!-- text 7 --></span>
    <!-- text 8 -->
  </p>

  <!-- text 9 -->
  <![CDATA[ text 10 ]]>

  <p>
    <![CDATA[ text 11 ]]>
    <span><![CDATA[ text 12 ]]></span>
    <![CDATA[ text 13 ]]>
  </p>
</root>
          eoxml

          @parser.parse xml
          items = @doc.items.get_root_content "root"
          items = items.select_methods [
            :start_element, :end_element,
            :characters, :comment, :cdata_block
          ]
          items.strip_text! [:characters, :comment, :cdata_block]

          assert_equal [
            [:characters, 'text 0'],

            [:start_element, 'p', []],
            [:characters, 'text 1'],

            [:start_element, 'span', []],
            [:characters, 'text 2'],
            [:end_element, 'span'],

            [:characters, 'text 3'],
            [:end_element, 'p'],

            [:characters, 'text 4'],
            [:comment, 'text 5'],
            [:characters, ''],

            [:start_element, 'p', []],
            [:characters, ''],
            [:comment, 'text 6'],
            [:characters, ''],

            [:start_element, 'span', []],
            [:comment, 'text 7'],
            [:end_element, 'span'],
            [:characters, ''],

            [:comment, 'text 8'],
            [:characters, ''],
            [:end_element, 'p'],
            [:characters, ''],

            [:comment, 'text 9'],
            [:characters, ''],
            [:cdata_block, 'text 10'],
            [:characters, ''],

            [:start_element, 'p', []],
            [:characters, ''],
            [:cdata_block, 'text 11'],
            [:characters, ''],

            [:start_element, 'span', []],
            [:cdata_block, 'text 12'],
            [:end_element, 'span'],
            [:characters, ''],

            [:cdata_block, 'text 13'],
            [:characters, ''],

            [:end_element, 'p'],
            [:characters, '']
          ], items

          nil
        end

        def text_whitespace
          xml = <<-eoxml
<?xml version="1.0" ?>
<root>
  <p>
    <span></span>
    <span> </span>
    <span>

    </span>
  </p>
  <p>
    <!---->
    <!-- -->
    <!--

    -->
  </p>
  <p>
    <![CDATA[]]>
    <![CDATA[ ]]>
    <![CDATA[

    ]]>
  </p>
</root>
          eoxml

          @parser.parse xml
          items = @doc.items.get_root_content "root"
          items = items.select_methods [
            :start_element, :end_element,
            :characters, :comment, :cdata_block
          ]
          items.strip_text! [:characters, :comment, :cdata_block]

          assert_equal [
            [:characters, ''],
            [:start_element, 'p', []],

            [:characters, ''],
            [:start_element, 'span', []],
            [:end_element, 'span'],
            [:characters, ''],

            [:start_element, 'span', []],
            [:characters, ''],
            [:end_element, 'span'],
            [:characters, ''],

            [:start_element, 'span', []],
            [:characters, ''],
            [:end_element, 'span'],
            [:characters, ''],

            [:end_element, 'p'],
            [:characters, ''],

            [:start_element, 'p', []],
            [:characters, ''],

            [:comment, ''],
            [:characters, ''],
            [:comment, ''],
            [:characters, ''],
            [:comment, ''],
            [:characters, ''],

            [:end_element, 'p'],
            [:characters, ''],

            [:start_element, 'p', []],
            [:characters, ''],

            [:cdata_block, ''],
            [:characters, ''],
            [:cdata_block, ''],
            [:characters, ''],
            [:cdata_block, ''],
            [:characters, ''],

            [:end_element, 'p'],
            [:characters, '']
          ], items

          nil
        end
      end
    end
  end
end

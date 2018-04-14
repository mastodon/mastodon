# -*- coding: utf-8 -*-
require "helper"

module Nokogiri
  module HTML
    module SAX
      class TestParserText < Nokogiri::SAX::TestCase
        def setup
          super
          @doc    = DocWithOrderedItems.new
          @parser = HTML::SAX::Parser.new @doc
        end

        def test_texts_order
          html = <<-eohtml
            <!DOCTYPE html>
            <html>
              <head></head>
              <body>
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
              </body>
            </html>
          eohtml

          @parser.parse html
          items = @doc.items.get_root_content "body"
          items = items.select_methods [
            :start_element, :end_element,
            :characters, :comment
          ]
          items.strip_text! [:characters, :comment]

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
            [:characters, '']
          ], items

          nil
        end

        def text_whitespace
          html = <<-eohtml
            <!DOCTYPE html>
            <html>
              <head></head>
              <body>
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
              </body>
            </html>
          eohtml

          @parser.parse html
          items = @doc.items.get_root_content "body"
          items = items.select_methods [
            :start_element, :end_element,
            :characters, :comment
          ]
          items.strip_text! [:characters, :comment]

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
            [:characters, '']
          ], items

          nil
        end
      end
    end
  end
end

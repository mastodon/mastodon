# -*- encoding: utf-8 -*-

require "helper"

module Nokogiri
  module XSLT
    class TestCustomFunctions < Nokogiri::TestCase
      def setup
        super
        @xml = Nokogiri.XML(<<-EOXML)
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1 plus MathML 2.0//EN"
 "http://www.w3.org/TR/MathML2/dtd/xhtml-math11-f.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
  <head>
    <meta http-equiv="Content-type" content="application/xhtml+xml"/>
    <title>Foo</title>
  </head>
  <body>
    <h1>Foo</h1>
    <p>Lorem ipsum.</p>
  </body>
</html>
EOXML
      end

      def test_function
        skip("Pure Java version doesn't support this feature.") if !Nokogiri.uses_libxml?
        foo = Class.new do
          def capitalize nodes
            nodes.first.content.upcase
          end
        end

        XSLT.register "http://e.org/functions", foo

        xsl = Nokogiri.XSLT(<<-EOXSL)
<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:f="http://e.org/functions"
  extension-element-prefixes="f">

  <xsl:template match="text()">
    <xsl:copy-of select="f:capitalize(.)"/>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      <xsl:apply-imports/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
EOXSL
        result = xsl.transform @xml
        assert_match(/FOO/, result.css('title').first.text)
      end


      def test_function_arguments
        skip("Pure Java version doesn't support this feature.") if !Nokogiri.uses_libxml?
        foo = Class.new do
          include MiniTest::Assertions
          # Minitest 5 uses `self.assertions` in `assert()` which is not
          # defined in the Minitest::Assertions module :-(
          attr_writer :assertions
          def assertions; @assertions ||= 0; end

          def multiarg *args
            assert_equal ["abc", "xyz"], args
            args.first
          end

          def numericarg arg
            assert_equal 42, arg
            arg
          end
        end

        xsl = Nokogiri.XSLT(<<-EOXSL, "http://e.org/functions" => foo)
<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:f="http://e.org/functions"
  extension-element-prefixes="f">

  <xsl:template match="text()">
    <xsl:copy-of select="f:multiarg('abc', 'xyz')"/>
    <xsl:copy-of select="f:numericarg(42)"/>
  </xsl:template>
</xsl:stylesheet>
EOXSL

        xsl.transform @xml
      end


      def test_function_XSLT
        skip("Pure Java version doesn't support this feature.") if !Nokogiri.uses_libxml?
        foo = Class.new do
          def america nodes
            nodes.first.content.upcase
          end
        end

        xsl = Nokogiri.XSLT(<<-EOXSL, "http://e.org/functions" => foo)
<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:f="http://e.org/functions"
  extension-element-prefixes="f">

  <xsl:template match="text()">
    <xsl:copy-of select="f:america(.)"/>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      <xsl:apply-imports/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
EOXSL
        result = xsl.transform @xml
        assert_match(/FOO/, result.css('title').first.text)
      end
    end
  end
end

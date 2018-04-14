require "helper"

module Nokogiri
  module XSLT
    class TestExceptionHandling < Nokogiri::TestCase
      def test_java_exception_handling
        skip('This test is for Java only') if Nokogiri.uses_libxml?

        xml = Nokogiri.XML(<<-EOXML)
<foo>
  <bar/>
</foo>
EOXML

        xsl = Nokogiri.XSLT(<<-EOXSL)
<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="/">
    <a/>
    <b/>
  </xsl:template>
</xsl:stylesheet>
EOXSL

        begin
          xsl.transform xml
          fail('It should not get here')
        rescue RuntimeError => e
          assert_match(/Can't have more than one root/, e.to_s, 'The exception message does not contain the expected information')
        end
      end

    end
  end
end

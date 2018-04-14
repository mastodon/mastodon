<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:func="http://exslt.org/functions"
				xmlns:my="urn:my-functions"
                xmlns:date="http://exslt.org/dates-and-times"
                xmlns:math="http://exslt.org/math"
				extension-element-prefixes="func date"
                >

  <xsl:param name="p1"/>
  <xsl:param name="p2"/>
  <xsl:param name="p3"/>
  <xsl:param name="p4"/>

  <xsl:template match="/">
     <root>
        <function><xsl:value-of select="my:func()"/></function>
        <date><xsl:value-of select="date:date()"/></date>
        <max><xsl:value-of select="math:max(//max/value)"/></max>
        <params>
           <p1><xsl:value-of select="$p1"/></p1>
           <p2><xsl:value-of select="$p2"/></p2>
           <p3><xsl:value-of select="$p3"/></p3>
           <p4><xsl:value-of select="$p4"/></p4>
        </params>
     </root>
  </xsl:template>

  <func:function name="my:func">
	<func:result select="'func-result'"/>
  </func:function>

</xsl:stylesheet>

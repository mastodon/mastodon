<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:param name="title"/>

<xsl:template match="/">
  <html>
  <body>
    <h1><xsl:value-of select="$title"/></h1>
    <table border="1">
    <tr bgcolor="#9acd32">
      <th align="left">Employee ID</th>
      <th align="left">Name</th>
      <th align="left">Position</th>
      <th align="left">Salary</th>
    </tr>
    <xsl:for-each select="staff/employee">
    <tr>
      <td><xsl:value-of select="employeeId"/></td>
      <td><xsl:value-of select="name"/></td>
      <td><xsl:value-of select="position"/></td>
      <td><xsl:value-of select="salary"/></td>
    </tr>
    </xsl:for-each>
    </table>
  </body>
  </html>
</xsl:template>

</xsl:stylesheet>

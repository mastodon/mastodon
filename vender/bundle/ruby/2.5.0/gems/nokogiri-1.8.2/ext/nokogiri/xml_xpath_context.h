#ifndef NOKOGIRI_XML_XPATH_CONTEXT
#define NOKOGIRI_XML_XPATH_CONTEXT

#include <nokogiri.h>

void init_xml_xpath_context();
void Nokogiri_marshal_xpath_funcall_and_return_values(xmlXPathParserContextPtr ctx, int nargs, VALUE handler, const char* function_name) ;

extern VALUE cNokogiriXmlXpathContext;
#endif

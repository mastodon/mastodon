#ifndef NOKOGIRI_XML_NAMESPACE
#define NOKOGIRI_XML_NAMESPACE

#include <nokogiri.h>

void init_xml_namespace();

extern VALUE cNokogiriXmlNamespace ;

VALUE Nokogiri_wrap_xml_namespace(xmlDocPtr doc, xmlNsPtr node) ;
VALUE Nokogiri_wrap_xml_namespace2(VALUE document, xmlNsPtr node) ;

#endif

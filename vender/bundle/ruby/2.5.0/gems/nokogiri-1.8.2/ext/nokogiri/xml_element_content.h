#ifndef NOKOGIRI_XML_ELEMENT_CONTENT
#define NOKOGIRI_XML_ELEMENT_CONTENT

#include <nokogiri.h>


VALUE Nokogiri_wrap_element_content(VALUE doc, xmlElementContentPtr element);
void init_xml_element_content();

#endif

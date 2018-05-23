#ifndef NOKOGIRI_XML_NODE
#define NOKOGIRI_XML_NODE

#include <nokogiri.h>

void init_xml_node();

extern VALUE cNokogiriXmlNode ;
extern VALUE cNokogiriXmlElement ;

VALUE Nokogiri_wrap_xml_node(VALUE klass, xmlNodePtr node) ;
void Nokogiri_xml_node_properties(xmlNodePtr node, VALUE attr_hash) ;
#endif

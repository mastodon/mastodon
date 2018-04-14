#ifndef NOKOGIRI_XML_NODE_SET
#define NOKOGIRI_XML_NODE_SET

#include <nokogiri.h>
void init_xml_node_set();

extern VALUE cNokogiriXmlNodeSet ;
VALUE Nokogiri_wrap_xml_node_set(xmlNodeSetPtr node_set, VALUE document) ;
VALUE Nokogiri_wrap_xml_node_set_node(xmlNodePtr node, VALUE node_set) ;
VALUE Nokogiri_wrap_xml_node_set_namespace(xmlNsPtr node, VALUE node_set) ;
int Nokogiri_namespace_eh(xmlNodePtr node) ;

#endif

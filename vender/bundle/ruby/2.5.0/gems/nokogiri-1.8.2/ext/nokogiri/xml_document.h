#ifndef NOKOGIRI_XML_DOCUMENT
#define NOKOGIRI_XML_DOCUMENT

#include <nokogiri.h>

struct _nokogiriTuple {
  VALUE         doc;
  st_table     *unlinkedNodes;
  VALUE         node_cache;
};
typedef struct _nokogiriTuple nokogiriTuple;
typedef nokogiriTuple * nokogiriTuplePtr;

void init_xml_document();
VALUE Nokogiri_wrap_xml_document(VALUE klass, xmlDocPtr doc);

#define DOC_RUBY_OBJECT_TEST(x) ((nokogiriTuplePtr)(x->_private))
#define DOC_RUBY_OBJECT(x) (((nokogiriTuplePtr)(x->_private))->doc)
#define DOC_UNLINKED_NODE_HASH(x) (((nokogiriTuplePtr)(x->_private))->unlinkedNodes)
#define DOC_NODE_CACHE(x) (((nokogiriTuplePtr)(x->_private))->node_cache)

extern VALUE cNokogiriXmlDocument ;
#endif

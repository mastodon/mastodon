#ifndef NOKOGIRI_XML_SAX_PARSER
#define NOKOGIRI_XML_SAX_PARSER

#include <nokogiri.h>

void init_xml_sax_parser();

extern VALUE cNokogiriXmlSaxParser ;

typedef struct _nokogiriSAXTuple {
  xmlParserCtxtPtr  ctxt;
  VALUE             self;
} nokogiriSAXTuple;

typedef nokogiriSAXTuple * nokogiriSAXTuplePtr;

#define NOKOGIRI_SAX_SELF(_ctxt) \
  ((nokogiriSAXTuplePtr)(_ctxt))->self

#define NOKOGIRI_SAX_CTXT(_ctxt) \
  ((nokogiriSAXTuplePtr)(_ctxt))->ctxt

#define NOKOGIRI_SAX_TUPLE_NEW(_ctxt, _self) \
  nokogiri_sax_tuple_new(_ctxt, _self)

static inline nokogiriSAXTuplePtr
nokogiri_sax_tuple_new(xmlParserCtxtPtr ctxt, VALUE self)
{
  nokogiriSAXTuplePtr tuple = malloc(sizeof(nokogiriSAXTuple));
  tuple->self = self;
  tuple->ctxt = ctxt;
  return tuple;
}

#define NOKOGIRI_SAX_TUPLE_DESTROY(_tuple) \
  free(_tuple) \

#endif


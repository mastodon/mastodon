#include <nokogiri.h>

VALUE mNokogiri ;
VALUE mNokogiriXml ;
VALUE mNokogiriHtml ;
VALUE mNokogiriXslt ;
VALUE mNokogiriXmlSax ;
VALUE mNokogiriHtmlSax ;

#ifdef USE_INCLUDED_VASPRINTF
/*
 * I srsly hate windows.  it doesn't have vasprintf.
 * Thank you Geoffroy Couprie for this implementation of vasprintf!
 */
int vasprintf (char **strp, const char *fmt, va_list ap)
{
  /* Mingw32/64 have a broken vsnprintf implementation that fails when
   * using a zero-byte limit in order to retrieve the required size for malloc.
   * So we use a one byte buffer instead.
   */
  char tmp[1];
  int len = vsnprintf (tmp, 1, fmt, ap) + 1;
  char *res = (char *)malloc((unsigned int)len);
  if (res == NULL)
      return -1;
  *strp = res;
  return vsnprintf(res, (unsigned int)len, fmt, ap);
}
#endif

void vasprintf_free (void *p)
{
  free(p);
}

#ifdef HAVE_RUBY_UTIL_H
#include "ruby/util.h"
#else
#include "util.h"
#endif

void nokogiri_root_node(xmlNodePtr node)
{
  xmlDocPtr doc;
  nokogiriTuplePtr tuple;

  doc = node->doc;
  if (doc->type == XML_DOCUMENT_FRAG_NODE) doc = doc->doc;
  tuple = (nokogiriTuplePtr)doc->_private;
  st_insert(tuple->unlinkedNodes, (st_data_t)node, (st_data_t)node);
}

void nokogiri_root_nsdef(xmlNsPtr ns, xmlDocPtr doc)
{
  nokogiriTuplePtr tuple;

  if (doc->type == XML_DOCUMENT_FRAG_NODE) doc = doc->doc;
  tuple = (nokogiriTuplePtr)doc->_private;
  st_insert(tuple->unlinkedNodes, (st_data_t)ns, (st_data_t)ns);
}

void Init_nokogiri()
{
  xmlMemSetup(
      (xmlFreeFunc)ruby_xfree,
      (xmlMallocFunc)ruby_xmalloc,
      (xmlReallocFunc)ruby_xrealloc,
      ruby_strdup
  );

  mNokogiri         = rb_define_module("Nokogiri");
  mNokogiriXml      = rb_define_module_under(mNokogiri, "XML");
  mNokogiriHtml     = rb_define_module_under(mNokogiri, "HTML");
  mNokogiriXslt     = rb_define_module_under(mNokogiri, "XSLT");
  mNokogiriXmlSax   = rb_define_module_under(mNokogiriXml, "SAX");
  mNokogiriHtmlSax  = rb_define_module_under(mNokogiriHtml, "SAX");

  rb_const_set( mNokogiri,
                rb_intern("LIBXML_VERSION"),
                NOKOGIRI_STR_NEW2(LIBXML_DOTTED_VERSION)
              );
  rb_const_set( mNokogiri,
                rb_intern("LIBXML_PARSER_VERSION"),
                NOKOGIRI_STR_NEW2(xmlParserVersion)
              );

#ifdef NOKOGIRI_USE_PACKAGED_LIBRARIES
  rb_const_set(mNokogiri, rb_intern("NOKOGIRI_USE_PACKAGED_LIBRARIES"), Qtrue);
  rb_const_set(mNokogiri, rb_intern("NOKOGIRI_LIBXML2_PATH"), NOKOGIRI_STR_NEW2(NOKOGIRI_LIBXML2_PATH));
  rb_const_set(mNokogiri, rb_intern("NOKOGIRI_LIBXSLT_PATH"), NOKOGIRI_STR_NEW2(NOKOGIRI_LIBXSLT_PATH));
  rb_const_set(mNokogiri, rb_intern("NOKOGIRI_LIBXML2_PATCHES"), rb_str_split(NOKOGIRI_STR_NEW2(NOKOGIRI_LIBXML2_PATCHES), " "));
  rb_const_set(mNokogiri, rb_intern("NOKOGIRI_LIBXSLT_PATCHES"), rb_str_split(NOKOGIRI_STR_NEW2(NOKOGIRI_LIBXSLT_PATCHES), " "));
#else
  rb_const_set(mNokogiri, rb_intern("NOKOGIRI_USE_PACKAGED_LIBRARIES"), Qfalse);
  rb_const_set(mNokogiri, rb_intern("NOKOGIRI_LIBXML2_PATH"), Qnil);
  rb_const_set(mNokogiri, rb_intern("NOKOGIRI_LIBXSLT_PATH"), Qnil);
  rb_const_set(mNokogiri, rb_intern("NOKOGIRI_LIBXML2_PATCHES"), Qnil);
  rb_const_set(mNokogiri, rb_intern("NOKOGIRI_LIBXSLT_PATCHES"), Qnil);
#endif

#ifdef LIBXML_ICONV_ENABLED
  rb_const_set(mNokogiri, rb_intern("LIBXML_ICONV_ENABLED"), Qtrue);
#else
  rb_const_set(mNokogiri, rb_intern("LIBXML_ICONV_ENABLED"), Qfalse);
#endif

  xmlInitParser();

  init_xml_document();
  init_html_document();
  init_xml_node();
  init_xml_document_fragment();
  init_xml_text();
  init_xml_cdata();
  init_xml_processing_instruction();
  init_xml_attr();
  init_xml_entity_reference();
  init_xml_comment();
  init_xml_node_set();
  init_xml_xpath_context();
  init_xml_sax_parser_context();
  init_xml_sax_parser();
  init_xml_sax_push_parser();
  init_xml_reader();
  init_xml_dtd();
  init_xml_element_content();
  init_xml_attribute_decl();
  init_xml_element_decl();
  init_xml_entity_decl();
  init_xml_namespace();
  init_html_sax_parser_context();
  init_html_sax_push_parser();
  init_xslt_stylesheet();
  init_xml_syntax_error();
  init_html_entity_lookup();
  init_html_element_description();
  init_xml_schema();
  init_xml_relax_ng();
  init_nokogiri_io();
  init_xml_encoding_handler();
}

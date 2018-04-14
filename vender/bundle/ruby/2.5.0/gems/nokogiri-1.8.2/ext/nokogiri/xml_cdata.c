#include <xml_cdata.h>

/*
 * call-seq:
 *  new(document, content)
 *
 * Create a new CDATA element on the +document+ with +content+
 *
 * If +content+ cannot be implicitly converted to a string, this method will
 * raise a TypeError exception.
 */
static VALUE new(int argc, VALUE *argv, VALUE klass)
{
  xmlDocPtr xml_doc;
  xmlNodePtr node;
  VALUE doc;
  VALUE content;
  VALUE rest;
  VALUE rb_node;
  const xmlChar *content_str;
  int content_str_len;

  rb_scan_args(argc, argv, "2*", &doc, &content, &rest);

  Data_Get_Struct(doc, xmlDoc, xml_doc);

  content_str = NIL_P(content) ? NULL : (const xmlChar *)StringValueCStr(content);
  content_str_len = (content_str == NULL) ? 0 : strlen(content_str);

  node = xmlNewCDataBlock(xml_doc->doc, content_str, content_str_len);

  nokogiri_root_node(node);

  rb_node = Nokogiri_wrap_xml_node(klass, node);
  rb_obj_call_init(rb_node, argc, argv);

  if(rb_block_given_p()) { rb_yield(rb_node); }

  return rb_node;
}

VALUE cNokogiriXmlCData;
void init_xml_cdata()
{
  VALUE nokogiri = rb_define_module("Nokogiri");
  VALUE xml = rb_define_module_under(nokogiri, "XML");
  VALUE node = rb_define_class_under(xml, "Node", rb_cObject);
  VALUE char_data = rb_define_class_under(xml, "CharacterData", node);
  VALUE text = rb_define_class_under(xml, "Text", char_data);

  /*
   * CData represents a CData node in an xml document.
   */
  VALUE klass = rb_define_class_under(xml, "CDATA", text);


  cNokogiriXmlCData = klass;

  rb_define_singleton_method(klass, "new", new, -1);
}

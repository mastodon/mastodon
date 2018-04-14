#include <xml_entity_reference.h>

/*
 * call-seq:
 *  new(document, content)
 *
 * Create a new EntityReference element on the +document+ with +name+
 */
static VALUE new(int argc, VALUE *argv, VALUE klass)
{
  xmlDocPtr xml_doc;
  xmlNodePtr node;
  VALUE document;
  VALUE name;
  VALUE rest;
  VALUE rb_node;

  rb_scan_args(argc, argv, "2*", &document, &name, &rest);

  Data_Get_Struct(document, xmlDoc, xml_doc);

  node = xmlNewReference(
      xml_doc,
      (const xmlChar *)StringValueCStr(name)
  );

  nokogiri_root_node(node);

  rb_node = Nokogiri_wrap_xml_node(klass, node);
  rb_obj_call_init(rb_node, argc, argv);

  if(rb_block_given_p()) rb_yield(rb_node);

  return rb_node;
}

VALUE cNokogiriXmlEntityReference;
void init_xml_entity_reference()
{
  VALUE nokogiri = rb_define_module("Nokogiri");
  VALUE xml = rb_define_module_under(nokogiri, "XML");
  VALUE node = rb_define_class_under(xml, "Node", rb_cObject);

  /*
   * EntityReference represents an EntityReference node in an xml document.
   */
  VALUE klass = rb_define_class_under(xml, "EntityReference", node);

  cNokogiriXmlEntityReference = klass;

  rb_define_singleton_method(klass, "new", new, -1);
}

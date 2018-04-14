#include <xml_element_decl.h>

static ID id_document;

/*
 * call-seq:
 *  element_type
 *
 * The element_type
 */
static VALUE element_type(VALUE self)
{
  xmlElementPtr node;
  Data_Get_Struct(self, xmlElement, node);
  return INT2NUM((long)node->etype);
}

/*
 * call-seq:
 *  content
 *
 * The allowed content for this ElementDecl
 */
static VALUE content(VALUE self)
{
  xmlElementPtr node;
  Data_Get_Struct(self, xmlElement, node);

  if(!node->content) return Qnil;

  return Nokogiri_wrap_element_content(
      rb_funcall(self, id_document, 0),
      node->content
  );
}

/*
 * call-seq:
 *  prefix
 *
 * The namespace prefix for this ElementDecl
 */
static VALUE prefix(VALUE self)
{
  xmlElementPtr node;
  Data_Get_Struct(self, xmlElement, node);

  if(!node->prefix) return Qnil;

  return NOKOGIRI_STR_NEW2(node->prefix);
}

VALUE cNokogiriXmlElementDecl;

void init_xml_element_decl()
{
  VALUE nokogiri = rb_define_module("Nokogiri");
  VALUE xml = rb_define_module_under(nokogiri, "XML");
  VALUE node = rb_define_class_under(xml, "Node", rb_cObject);
  VALUE klass = rb_define_class_under(xml, "ElementDecl", node);

  cNokogiriXmlElementDecl = klass;

  rb_define_method(klass, "element_type", element_type, 0);
  rb_define_method(klass, "content", content, 0);
  rb_define_method(klass, "prefix", prefix, 0);

  id_document = rb_intern("document");
}

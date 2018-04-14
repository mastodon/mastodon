#include <xml_attribute_decl.h>

/*
 * call-seq:
 *  attribute_type
 *
 * The attribute_type for this AttributeDecl
 */
static VALUE attribute_type(VALUE self)
{
  xmlAttributePtr node;
  Data_Get_Struct(self, xmlAttribute, node);
  return INT2NUM((long)node->atype);
}

/*
 * call-seq:
 *  default
 *
 * The default value
 */
static VALUE default_value(VALUE self)
{
  xmlAttributePtr node;
  Data_Get_Struct(self, xmlAttribute, node);

  if(node->defaultValue) return NOKOGIRI_STR_NEW2(node->defaultValue);
  return Qnil;
}

/*
 * call-seq:
 *  enumeration
 *
 * An enumeration of possible values
 */
static VALUE enumeration(VALUE self)
{
  xmlAttributePtr node;
  xmlEnumerationPtr enm;
  VALUE list;

  Data_Get_Struct(self, xmlAttribute, node);

  list = rb_ary_new();
  enm = node->tree;

  while(enm) {
    rb_ary_push(list, NOKOGIRI_STR_NEW2(enm->name));
    enm = enm->next;
  }

  return list;
}

VALUE cNokogiriXmlAttributeDecl;

void init_xml_attribute_decl()
{
  VALUE nokogiri = rb_define_module("Nokogiri");
  VALUE xml = rb_define_module_under(nokogiri, "XML");
  VALUE node = rb_define_class_under(xml, "Node", rb_cObject);
  VALUE klass = rb_define_class_under(xml, "AttributeDecl", node);

  cNokogiriXmlAttributeDecl = klass;

  rb_define_method(klass, "attribute_type", attribute_type, 0);
  rb_define_method(klass, "default", default_value, 0);
  rb_define_method(klass, "enumeration", enumeration, 0);
}

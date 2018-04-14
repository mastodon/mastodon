#include <xml_element_content.h>

VALUE cNokogiriXmlElementContent;

/*
 * call-seq:
 *  name
 *
 * Get the require element +name+
 */
static VALUE get_name(VALUE self)
{
  xmlElementContentPtr elem;
  Data_Get_Struct(self, xmlElementContent, elem);

  if(!elem->name) return Qnil;
  return NOKOGIRI_STR_NEW2(elem->name);
}

/*
 * call-seq:
 *  type
 *
 * Get the element content +type+.  Possible values are PCDATA, ELEMENT, SEQ,
 * or OR.
 */
static VALUE get_type(VALUE self)
{
  xmlElementContentPtr elem;
  Data_Get_Struct(self, xmlElementContent, elem);

  return INT2NUM((long)elem->type);
}

/*
 * call-seq:
 *  c1
 *
 * Get the first child.
 */
static VALUE get_c1(VALUE self)
{
  xmlElementContentPtr elem;
  Data_Get_Struct(self, xmlElementContent, elem);

  if(!elem->c1) return Qnil;
  return Nokogiri_wrap_element_content(rb_iv_get(self, "@document"), elem->c1);
}

/*
 * call-seq:
 *  c2
 *
 * Get the first child.
 */
static VALUE get_c2(VALUE self)
{
  xmlElementContentPtr elem;
  Data_Get_Struct(self, xmlElementContent, elem);

  if(!elem->c2) return Qnil;
  return Nokogiri_wrap_element_content(rb_iv_get(self, "@document"), elem->c2);
}

/*
 * call-seq:
 *  occur
 *
 * Get the element content +occur+ flag.  Possible values are ONCE, OPT, MULT
 * or PLUS.
 */
static VALUE get_occur(VALUE self)
{
  xmlElementContentPtr elem;
  Data_Get_Struct(self, xmlElementContent, elem);

  return INT2NUM((long)elem->ocur);
}

/*
 * call-seq:
 *  prefix
 *
 * Get the element content namespace +prefix+.
 */
static VALUE get_prefix(VALUE self)
{
  xmlElementContentPtr elem;
  Data_Get_Struct(self, xmlElementContent, elem);

  if(!elem->prefix) return Qnil;

  return NOKOGIRI_STR_NEW2(elem->prefix);
}

VALUE Nokogiri_wrap_element_content(VALUE doc, xmlElementContentPtr element)
{
  VALUE elem = Data_Wrap_Struct(cNokogiriXmlElementContent, 0, 0, element);

  /* Setting the document is necessary so that this does not get GC'd until */
  /* the document is GC'd */
  rb_iv_set(elem, "@document", doc);

  return elem;
}

void init_xml_element_content()
{
  VALUE nokogiri = rb_define_module("Nokogiri");
  VALUE xml = rb_define_module_under(nokogiri, "XML");

  VALUE klass = rb_define_class_under(xml, "ElementContent", rb_cObject);

  cNokogiriXmlElementContent = klass;

  rb_define_method(klass, "name", get_name, 0);
  rb_define_method(klass, "type", get_type, 0);
  rb_define_method(klass, "occur", get_occur, 0);
  rb_define_method(klass, "prefix", get_prefix, 0);

  rb_define_private_method(klass, "c1", get_c1, 0);
  rb_define_private_method(klass, "c2", get_c2, 0);
}

#include <html_element_description.h>

/*
 * call-seq:
 *  required_attributes
 *
 * A list of required attributes for this element
 */
static VALUE required_attributes(VALUE self)
{
  htmlElemDesc * description;
  VALUE list;
  int i;

  Data_Get_Struct(self, htmlElemDesc, description);

  list = rb_ary_new();

  if(NULL == description->attrs_req) return list;

  for(i = 0; description->attrs_depr[i]; i++) {
    rb_ary_push(list, NOKOGIRI_STR_NEW2(description->attrs_req[i]));
  }

  return list;
}

/*
 * call-seq:
 *  deprecated_attributes
 *
 * A list of deprecated attributes for this element
 */
static VALUE deprecated_attributes(VALUE self)
{
  htmlElemDesc * description;
  VALUE list;
  int i;

  Data_Get_Struct(self, htmlElemDesc, description);

  list = rb_ary_new();

  if(NULL == description->attrs_depr) return list;

  for(i = 0; description->attrs_depr[i]; i++) {
    rb_ary_push(list, NOKOGIRI_STR_NEW2(description->attrs_depr[i]));
  }

  return list;
}

/*
 * call-seq:
 *  optional_attributes
 *
 * A list of optional attributes for this element
 */
static VALUE optional_attributes(VALUE self)
{
  htmlElemDesc * description;
  VALUE list;
  int i;

  Data_Get_Struct(self, htmlElemDesc, description);

  list = rb_ary_new();

  if(NULL == description->attrs_opt) return list;

  for(i = 0; description->attrs_opt[i]; i++) {
    rb_ary_push(list, NOKOGIRI_STR_NEW2(description->attrs_opt[i]));
  }

  return list;
}

/*
 * call-seq:
 *  default_sub_element
 *
 * The default sub element for this element
 */
static VALUE default_sub_element(VALUE self)
{
  htmlElemDesc * description;
  Data_Get_Struct(self, htmlElemDesc, description);

  if (description->defaultsubelt)
    return NOKOGIRI_STR_NEW2(description->defaultsubelt);

  return Qnil;
}

/*
 * call-seq:
 *  sub_elements
 *
 * A list of allowed sub elements for this element.
 */
static VALUE sub_elements(VALUE self)
{
  htmlElemDesc * description;
  VALUE list;
  int i;

  Data_Get_Struct(self, htmlElemDesc, description);

  list = rb_ary_new();

  if(NULL == description->subelts) return list;

  for(i = 0; description->subelts[i]; i++) {
    rb_ary_push(list, NOKOGIRI_STR_NEW2(description->subelts[i]));
  }

  return list;
}

/*
 * call-seq:
 *  description
 *
 * The description for this element
 */
static VALUE description(VALUE self)
{
  htmlElemDesc * description;
  Data_Get_Struct(self, htmlElemDesc, description);

  return NOKOGIRI_STR_NEW2(description->desc);
}

/*
 * call-seq:
 *  inline?
 *
 * Is this element an inline element?
 */
static VALUE inline_eh(VALUE self)
{
  htmlElemDesc * description;
  Data_Get_Struct(self, htmlElemDesc, description);

  if(description->isinline) return Qtrue;
  return Qfalse;
}

/*
 * call-seq:
 *  deprecated?
 *
 * Is this element deprecated?
 */
static VALUE deprecated_eh(VALUE self)
{
  htmlElemDesc * description;
  Data_Get_Struct(self, htmlElemDesc, description);

  if(description->depr) return Qtrue;
  return Qfalse;
}

/*
 * call-seq:
 *  empty?
 *
 * Is this an empty element?
 */
static VALUE empty_eh(VALUE self)
{
  htmlElemDesc * description;
  Data_Get_Struct(self, htmlElemDesc, description);

  if(description->empty) return Qtrue;
  return Qfalse;
}

/*
 * call-seq:
 *  save_end_tag?
 *
 * Should the end tag be saved?
 */
static VALUE save_end_tag_eh(VALUE self)
{
  htmlElemDesc * description;
  Data_Get_Struct(self, htmlElemDesc, description);

  if(description->saveEndTag) return Qtrue;
  return Qfalse;
}

/*
 * call-seq:
 *  implied_end_tag?
 *
 * Can the end tag be implied for this tag?
 */
static VALUE implied_end_tag_eh(VALUE self)
{
  htmlElemDesc * description;
  Data_Get_Struct(self, htmlElemDesc, description);

  if(description->endTag) return Qtrue;
  return Qfalse;
}

/*
 * call-seq:
 *  implied_start_tag?
 *
 * Can the start tag be implied for this tag?
 */
static VALUE implied_start_tag_eh(VALUE self)
{
  htmlElemDesc * description;
  Data_Get_Struct(self, htmlElemDesc, description);

  if(description->startTag) return Qtrue;
  return Qfalse;
}

/*
 * call-seq:
 *  name
 *
 * Get the tag name for this ElemementDescription
 */
static VALUE name(VALUE self)
{
  htmlElemDesc * description;
  Data_Get_Struct(self, htmlElemDesc, description);

  if(NULL == description->name) return Qnil;
  return NOKOGIRI_STR_NEW2(description->name);
}

/*
 * call-seq:
 *  [](tag_name)
 *
 * Get ElemementDescription for +tag_name+
 */
static VALUE get_description(VALUE klass, VALUE tag_name)
{
  const htmlElemDesc * description = htmlTagLookup(
      (const xmlChar *)StringValueCStr(tag_name)
  );

  if(NULL == description) return Qnil;
  return Data_Wrap_Struct(klass, 0, 0, (void *)description);
}

VALUE cNokogiriHtmlElementDescription ;
void init_html_element_description()
{
  VALUE nokogiri = rb_define_module("Nokogiri");
  VALUE html     = rb_define_module_under(nokogiri, "HTML");
  VALUE klass    = rb_define_class_under(html, "ElementDescription",rb_cObject);

  cNokogiriHtmlElementDescription = klass;

  rb_define_singleton_method(klass, "[]", get_description, 1);

  rb_define_method(klass, "name", name, 0);
  rb_define_method(klass, "implied_start_tag?", implied_start_tag_eh, 0);
  rb_define_method(klass, "implied_end_tag?", implied_end_tag_eh, 0);
  rb_define_method(klass, "save_end_tag?", save_end_tag_eh, 0);
  rb_define_method(klass, "empty?", empty_eh, 0);
  rb_define_method(klass, "deprecated?", deprecated_eh, 0);
  rb_define_method(klass, "inline?", inline_eh, 0);
  rb_define_method(klass, "description", description, 0);
  rb_define_method(klass, "sub_elements", sub_elements, 0);
  rb_define_method(klass, "default_sub_element", default_sub_element, 0);
  rb_define_method(klass, "optional_attributes", optional_attributes, 0);
  rb_define_method(klass, "deprecated_attributes", deprecated_attributes, 0);
  rb_define_method(klass, "required_attributes", required_attributes, 0);
}

#include <xml_encoding_handler.h>

/*
 * call-seq: Nokogiri::EncodingHandler.[](name)
 *
 * Get the encoding handler for +name+
 */
static VALUE get(VALUE klass, VALUE key)
{
  xmlCharEncodingHandlerPtr handler;

  handler = xmlFindCharEncodingHandler(StringValueCStr(key));
  if(handler)
    return Data_Wrap_Struct(klass, NULL, NULL, handler);

  return Qnil;
}

/*
 * call-seq: Nokogiri::EncodingHandler.delete(name)
 *
 * Delete the encoding alias named +name+
 */
static VALUE delete(VALUE klass, VALUE name)
{
  if(xmlDelEncodingAlias(StringValueCStr(name))) return Qnil;

  return Qtrue;
}

/*
 * call-seq: Nokogiri::EncodingHandler.alias(from, to)
 *
 * Alias encoding handler with name +from+ to name +to+
 */
static VALUE alias(VALUE klass, VALUE from, VALUE to)
{
  xmlAddEncodingAlias(StringValueCStr(from), StringValueCStr(to));

  return to;
}

/*
 * call-seq: Nokogiri::EncodingHandler.clear_aliases!
 *
 * Remove all encoding aliases.
 */
static VALUE clear_aliases(VALUE klass)
{
  xmlCleanupEncodingAliases();

  return klass;
}

/*
 * call-seq: name
 *
 * Get the name of this EncodingHandler
 */
static VALUE name(VALUE self)
{
  xmlCharEncodingHandlerPtr handler;

  Data_Get_Struct(self, xmlCharEncodingHandler, handler);

  return NOKOGIRI_STR_NEW2(handler->name);
}

void init_xml_encoding_handler()
{
  VALUE nokogiri = rb_define_module("Nokogiri");
  VALUE klass = rb_define_class_under(nokogiri, "EncodingHandler", rb_cObject);

  rb_define_singleton_method(klass, "[]", get, 1);
  rb_define_singleton_method(klass, "delete", delete, 1);
  rb_define_singleton_method(klass, "alias", alias, 2);
  rb_define_singleton_method(klass, "clear_aliases!", clear_aliases, 0);
  rb_define_method(klass, "name", name, 0);
}

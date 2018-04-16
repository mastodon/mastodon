#include <xml_sax_push_parser.h>

static void deallocate(xmlParserCtxtPtr ctx)
{
  NOKOGIRI_DEBUG_START(ctx);
  if (ctx != NULL) {
    NOKOGIRI_SAX_TUPLE_DESTROY(ctx->userData);
    xmlFreeParserCtxt(ctx);
  }
  NOKOGIRI_DEBUG_END(ctx);
}

static VALUE allocate(VALUE klass)
{
  return Data_Wrap_Struct(klass, NULL, deallocate, NULL);
}

/*
 * call-seq:
 *  native_write(chunk, last_chunk)
 *
 * Write +chunk+ to PushParser. +last_chunk+ triggers the end_document handle
 */
static VALUE native_write(VALUE self, VALUE _chunk, VALUE _last_chunk)
{
  xmlParserCtxtPtr ctx;
  const char * chunk  = NULL;
  int size            = 0;


  Data_Get_Struct(self, xmlParserCtxt, ctx);

  if (Qnil != _chunk) {
    chunk = StringValuePtr(_chunk);
    size = (int)RSTRING_LEN(_chunk);
  }

  if (xmlParseChunk(ctx, chunk, size, Qtrue == _last_chunk ? 1 : 0)) {
    if (!(ctx->options & XML_PARSE_RECOVER)) {
      xmlErrorPtr e = xmlCtxtGetLastError(ctx);
      Nokogiri_error_raise(NULL, e);
    }
  }

  return self;
}

/*
 * call-seq:
 *  initialize_native(xml_sax, filename)
 *
 * Initialize the push parser with +xml_sax+ using +filename+
 */
static VALUE initialize_native(VALUE self, VALUE _xml_sax, VALUE _filename)
{
  xmlSAXHandlerPtr sax;
  const char * filename = NULL;
  xmlParserCtxtPtr ctx;

  Data_Get_Struct(_xml_sax, xmlSAXHandler, sax);

  if (_filename != Qnil) { filename = StringValueCStr(_filename); }

  ctx = xmlCreatePushParserCtxt(
          sax,
          NULL,
          NULL,
          0,
          filename
        );
  if (ctx == NULL) {
    rb_raise(rb_eRuntimeError, "Could not create a parser context");
  }

  ctx->userData = NOKOGIRI_SAX_TUPLE_NEW(ctx, self);

  ctx->sax2 = 1;
  DATA_PTR(self) = ctx;
  return self;
}

static VALUE get_options(VALUE self)
{
  xmlParserCtxtPtr ctx;
  Data_Get_Struct(self, xmlParserCtxt, ctx);

  return INT2NUM(ctx->options);
}

static VALUE set_options(VALUE self, VALUE options)
{
  xmlParserCtxtPtr ctx;
  Data_Get_Struct(self, xmlParserCtxt, ctx);

  if (xmlCtxtUseOptions(ctx, (int)NUM2INT(options)) != 0) {
    rb_raise(rb_eRuntimeError, "Cannot set XML parser context options");
  }

  return Qnil;
}

/*
 * call-seq:
 *  replace_entities
 *
 * Should this parser replace entities?  &amp; will get converted to '&' if
 * set to true
 */
static VALUE get_replace_entities(VALUE self)
{
  xmlParserCtxtPtr ctx;
  Data_Get_Struct(self, xmlParserCtxt, ctx);

  if (0 == ctx->replaceEntities) {
    return Qfalse;
  } else {
    return Qtrue;
  }
}

/*
 * call-seq:
 *  replace_entities=(boolean)
 *
 * Should this parser replace entities?  &amp; will get converted to '&' if
 * set to true
 */
static VALUE set_replace_entities(VALUE self, VALUE value)
{
  xmlParserCtxtPtr ctx;
  Data_Get_Struct(self, xmlParserCtxt, ctx);

  if (Qfalse == value) {
    ctx->replaceEntities = 0;
  } else {
    ctx->replaceEntities = 1;
  }

  return value;
}

VALUE cNokogiriXmlSaxPushParser ;
void init_xml_sax_push_parser()
{
  VALUE nokogiri = rb_define_module("Nokogiri");
  VALUE xml = rb_define_module_under(nokogiri, "XML");
  VALUE sax = rb_define_module_under(xml, "SAX");
  VALUE klass = rb_define_class_under(sax, "PushParser", rb_cObject);

  cNokogiriXmlSaxPushParser = klass;

  rb_define_alloc_func(klass, allocate);
  rb_define_private_method(klass, "initialize_native", initialize_native, 2);
  rb_define_private_method(klass, "native_write", native_write, 2);
  rb_define_method(klass, "options", get_options, 0);
  rb_define_method(klass, "options=", set_options, 1);
  rb_define_method(klass, "replace_entities", get_replace_entities, 0);
  rb_define_method(klass, "replace_entities=", set_replace_entities, 1);
}

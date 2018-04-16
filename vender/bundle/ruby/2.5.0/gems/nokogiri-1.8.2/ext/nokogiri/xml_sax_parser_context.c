#include <xml_sax_parser_context.h>

VALUE cNokogiriXmlSaxParserContext ;

static void deallocate(xmlParserCtxtPtr ctxt)
{
  NOKOGIRI_DEBUG_START(handler);

  ctxt->sax = NULL;

  xmlFreeParserCtxt(ctxt);

  NOKOGIRI_DEBUG_END(handler);
}

/*
 * call-seq:
 *  parse_io(io, encoding)
 *
 * Parse +io+ object with +encoding+
 */
static VALUE
parse_io(VALUE klass, VALUE io, VALUE encoding)
{
    xmlParserCtxtPtr ctxt;
    xmlCharEncoding enc = (xmlCharEncoding)NUM2INT(encoding);

    ctxt = xmlCreateIOParserCtxt(NULL, NULL,
				 (xmlInputReadCallback)io_read_callback,
				 (xmlInputCloseCallback)io_close_callback,
				 (void *)io, enc);
    if (ctxt->sax) {
	xmlFree(ctxt->sax);
	ctxt->sax = NULL;
    }

    return Data_Wrap_Struct(klass, NULL, deallocate, ctxt);
}

/*
 * call-seq:
 *  parse_file(filename)
 *
 * Parse file given +filename+
 */
static VALUE parse_file(VALUE klass, VALUE filename)
{
  xmlParserCtxtPtr ctxt = xmlCreateFileParserCtxt(StringValueCStr(filename));
  return Data_Wrap_Struct(klass, NULL, deallocate, ctxt);
}

/*
 * call-seq:
 *  parse_memory(data)
 *
 * Parse the XML stored in memory in +data+
 */
static VALUE
parse_memory(VALUE klass, VALUE data)
{
    xmlParserCtxtPtr ctxt;

    if (NIL_P(data))
	rb_raise(rb_eArgError, "data cannot be nil");
    if (!(int)RSTRING_LEN(data))
	rb_raise(rb_eRuntimeError, "data cannot be empty");

    ctxt = xmlCreateMemoryParserCtxt(StringValuePtr(data),
				     (int)RSTRING_LEN(data));
    if (ctxt->sax) {
	xmlFree(ctxt->sax);
	ctxt->sax = NULL;
    }

    return Data_Wrap_Struct(klass, NULL, deallocate, ctxt);
}

static VALUE
parse_doc(VALUE ctxt_val)
{
    xmlParserCtxtPtr ctxt = (xmlParserCtxtPtr)ctxt_val;
    xmlParseDocument(ctxt);
    return Qnil;
}

static VALUE
parse_doc_finalize(VALUE ctxt_val)
{
    xmlParserCtxtPtr ctxt = (xmlParserCtxtPtr)ctxt_val;

    if (NULL != ctxt->myDoc)
	xmlFreeDoc(ctxt->myDoc);

    NOKOGIRI_SAX_TUPLE_DESTROY(ctxt->userData);
    return Qnil;
}

/*
 * call-seq:
 *  parse_with(sax_handler)
 *
 * Use +sax_handler+ and parse the current document
 */
static VALUE
parse_with(VALUE self, VALUE sax_handler)
{
    xmlParserCtxtPtr ctxt;
    xmlSAXHandlerPtr sax;

    if (!rb_obj_is_kind_of(sax_handler, cNokogiriXmlSaxParser))
	rb_raise(rb_eArgError, "argument must be a Nokogiri::XML::SAX::Parser");

    Data_Get_Struct(self, xmlParserCtxt, ctxt);
    Data_Get_Struct(sax_handler, xmlSAXHandler, sax);

    /* Free the sax handler since we'll assign our own */
    if (ctxt->sax && ctxt->sax != (xmlSAXHandlerPtr)&xmlDefaultSAXHandler)
	xmlFree(ctxt->sax);

    ctxt->sax = sax;
    ctxt->userData = (void *)NOKOGIRI_SAX_TUPLE_NEW(ctxt, sax_handler);

    rb_ensure(parse_doc, (VALUE)ctxt, parse_doc_finalize, (VALUE)ctxt);

    return Qnil;
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
  xmlParserCtxtPtr ctxt;
  Data_Get_Struct(self, xmlParserCtxt, ctxt);

  if(Qfalse == value)
    ctxt->replaceEntities = 0;
  else
    ctxt->replaceEntities = 1;

  return value;
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
  xmlParserCtxtPtr ctxt;
  Data_Get_Struct(self, xmlParserCtxt, ctxt);

  if(0 == ctxt->replaceEntities)
    return Qfalse;
  else
    return Qtrue;
}

/*
 * call-seq: line
 *
 * Get the current line the parser context is processing.
 */
static VALUE line(VALUE self)
{
  xmlParserCtxtPtr ctxt;
  xmlParserInputPtr io;

  Data_Get_Struct(self, xmlParserCtxt, ctxt);

  io = ctxt->input;
  if(io)
    return INT2NUM(io->line);

  return Qnil;
}

/*
 * call-seq: column
 *
 * Get the current column the parser context is processing.
 */
static VALUE column(VALUE self)
{
  xmlParserCtxtPtr ctxt;
  xmlParserInputPtr io;

  Data_Get_Struct(self, xmlParserCtxt, ctxt);

  io = ctxt->input;
  if(io)
    return INT2NUM(io->col);

  return Qnil;
}

/*
 * call-seq:
 *  recovery=(boolean)
 *
 * Should this parser recover from structural errors? It will not stop processing
 * file on structural errors if set to true
 */
static VALUE set_recovery(VALUE self, VALUE value)
{
  xmlParserCtxtPtr ctxt;
  Data_Get_Struct(self, xmlParserCtxt, ctxt);

  if(value == Qfalse)
    ctxt->recovery = 0;
  else
    ctxt->recovery = 1;

  return value;
}

/*
 * call-seq:
 *  recovery
 *
 * Should this parser recover from structural errors? It will not stop processing
 * file on structural errors if set to true
 */
static VALUE get_recovery(VALUE self)
{
  xmlParserCtxtPtr ctxt;
  Data_Get_Struct(self, xmlParserCtxt, ctxt);

  if(ctxt->recovery == 0)
    return Qfalse;
  else
    return Qtrue;
}

void init_xml_sax_parser_context()
{
  VALUE nokogiri  = rb_define_module("Nokogiri");
  VALUE xml       = rb_define_module_under(nokogiri, "XML");
  VALUE sax       = rb_define_module_under(xml, "SAX");
  VALUE klass     = rb_define_class_under(sax, "ParserContext", rb_cObject);

  cNokogiriXmlSaxParserContext = klass;

  rb_define_singleton_method(klass, "io", parse_io, 2);
  rb_define_singleton_method(klass, "memory", parse_memory, 1);
  rb_define_singleton_method(klass, "file", parse_file, 1);

  rb_define_method(klass, "parse_with", parse_with, 1);
  rb_define_method(klass, "replace_entities=", set_replace_entities, 1);
  rb_define_method(klass, "replace_entities", get_replace_entities, 0);
  rb_define_method(klass, "recovery=", set_recovery, 1);
  rb_define_method(klass, "recovery", get_recovery, 0);
  rb_define_method(klass, "line", line, 0);
  rb_define_method(klass, "column", column, 0);
}

#include <html_sax_parser_context.h>

VALUE cNokogiriHtmlSaxParserContext ;

static void deallocate(xmlParserCtxtPtr ctxt)
{
  NOKOGIRI_DEBUG_START(handler);

  ctxt->sax = NULL;

  htmlFreeParserCtxt(ctxt);

  NOKOGIRI_DEBUG_END(handler);
}

static VALUE
parse_memory(VALUE klass, VALUE data, VALUE encoding)
{
    htmlParserCtxtPtr ctxt;

    if (NIL_P(data))
	rb_raise(rb_eArgError, "data cannot be nil");
    if (!(int)RSTRING_LEN(data))
	rb_raise(rb_eRuntimeError, "data cannot be empty");

    ctxt = htmlCreateMemoryParserCtxt(StringValuePtr(data),
				      (int)RSTRING_LEN(data));
    if (ctxt->sax) {
	xmlFree(ctxt->sax);
	ctxt->sax = NULL;
    }

    if (RTEST(encoding)) {
	xmlCharEncodingHandlerPtr enc = xmlFindCharEncodingHandler(StringValueCStr(encoding));
	if (enc != NULL) {
	    xmlSwitchToEncoding(ctxt, enc);
	    if (ctxt->errNo == XML_ERR_UNSUPPORTED_ENCODING) {
		rb_raise(rb_eRuntimeError, "Unsupported encoding %s",
			 StringValueCStr(encoding));
	    }
	}
    }

    return Data_Wrap_Struct(klass, NULL, deallocate, ctxt);
}

static VALUE parse_file(VALUE klass, VALUE filename, VALUE encoding)
{
  htmlParserCtxtPtr ctxt = htmlCreateFileParserCtxt(
      StringValueCStr(filename),
      StringValueCStr(encoding)
  );
  return Data_Wrap_Struct(klass, NULL, deallocate, ctxt);
}

static VALUE
parse_doc(VALUE ctxt_val)
{
    htmlParserCtxtPtr ctxt = (htmlParserCtxtPtr)ctxt_val;
    htmlParseDocument(ctxt);
    return Qnil;
}

static VALUE
parse_doc_finalize(VALUE ctxt_val)
{
    htmlParserCtxtPtr ctxt = (htmlParserCtxtPtr)ctxt_val;

    if (ctxt->myDoc)
	xmlFreeDoc(ctxt->myDoc);

    NOKOGIRI_SAX_TUPLE_DESTROY(ctxt->userData);
    return Qnil;
}

static VALUE
parse_with(VALUE self, VALUE sax_handler)
{
    htmlParserCtxtPtr ctxt;
    htmlSAXHandlerPtr sax;

    if (!rb_obj_is_kind_of(sax_handler, cNokogiriXmlSaxParser))
	rb_raise(rb_eArgError, "argument must be a Nokogiri::XML::SAX::Parser");

    Data_Get_Struct(self, htmlParserCtxt, ctxt);
    Data_Get_Struct(sax_handler, htmlSAXHandler, sax);

    /* Free the sax handler since we'll assign our own */
    if (ctxt->sax && ctxt->sax != (xmlSAXHandlerPtr)&xmlDefaultSAXHandler)
	xmlFree(ctxt->sax);

    ctxt->sax = sax;
    ctxt->userData = (void *)NOKOGIRI_SAX_TUPLE_NEW(ctxt, sax_handler);

    rb_ensure(parse_doc, (VALUE)ctxt, parse_doc_finalize, (VALUE)ctxt);

    return self;
}

void init_html_sax_parser_context()
{
  VALUE nokogiri  = rb_define_module("Nokogiri");
  VALUE xml       = rb_define_module_under(nokogiri, "XML");
  VALUE html      = rb_define_module_under(nokogiri, "HTML");
  VALUE sax       = rb_define_module_under(xml, "SAX");
  VALUE hsax      = rb_define_module_under(html, "SAX");
  VALUE pc        = rb_define_class_under(sax, "ParserContext", rb_cObject);
  VALUE klass     = rb_define_class_under(hsax, "ParserContext", pc);

  cNokogiriHtmlSaxParserContext = klass;

  rb_define_singleton_method(klass, "memory", parse_memory, 2);
  rb_define_singleton_method(klass, "file", parse_file, 2);

  rb_define_method(klass, "parse_with", parse_with, 1);
}

#include <html_document.h>

static ID id_encoding_found;

/*
 * call-seq:
 *  new
 *
 * Create a new document
 */
static VALUE new(int argc, VALUE *argv, VALUE klass)
{
  VALUE uri, external_id, rest, rb_doc;
  htmlDocPtr doc;

  rb_scan_args(argc, argv, "0*", &rest);
  uri         = rb_ary_entry(rest, (long)0);
  external_id = rb_ary_entry(rest, (long)1);

  doc = htmlNewDoc(
      RTEST(uri) ? (const xmlChar *)StringValueCStr(uri) : NULL,
      RTEST(external_id) ? (const xmlChar *)StringValueCStr(external_id) : NULL
  );
  rb_doc = Nokogiri_wrap_xml_document(klass, doc);
  rb_obj_call_init(rb_doc, argc, argv);
  return rb_doc ;
}

/*
 * call-seq:
 *  read_io(io, url, encoding, options)
 *
 * Read the HTML document from +io+ with given +url+, +encoding+,
 * and +options+.  See Nokogiri::HTML.parse
 */
static VALUE read_io( VALUE klass,
                      VALUE io,
                      VALUE url,
                      VALUE encoding,
                      VALUE options )
{
  const char * c_url    = NIL_P(url)      ? NULL : StringValueCStr(url);
  const char * c_enc    = NIL_P(encoding) ? NULL : StringValueCStr(encoding);
  VALUE error_list      = rb_ary_new();
  VALUE document;
  htmlDocPtr doc;

  xmlResetLastError();
  xmlSetStructuredErrorFunc((void *)error_list, Nokogiri_error_array_pusher);

  doc = htmlReadIO(
      io_read_callback,
      io_close_callback,
      (void *)io,
      c_url,
      c_enc,
      (int)NUM2INT(options)
  );
  xmlSetStructuredErrorFunc(NULL, NULL);

  /*
   * If EncodingFound has occurred in EncodingReader, make sure to do
   * a cleanup and propagate the error.
   */
  if (rb_respond_to(io, id_encoding_found)) {
    VALUE encoding_found = rb_funcall(io, id_encoding_found, 0);
    if (!NIL_P(encoding_found)) {
      xmlFreeDoc(doc);
      rb_exc_raise(encoding_found);
    }
  }

  if(doc == NULL) {
    xmlErrorPtr error;

    xmlFreeDoc(doc);

    error = xmlGetLastError();
    if(error)
      rb_exc_raise(Nokogiri_wrap_xml_syntax_error(error));
    else
      rb_raise(rb_eRuntimeError, "Could not parse document");

    return Qnil;
  }

  document = Nokogiri_wrap_xml_document(klass, doc);
  rb_iv_set(document, "@errors", error_list);
  return document;
}

/*
 * call-seq:
 *  read_memory(string, url, encoding, options)
 *
 * Read the HTML document contained in +string+ with given +url+, +encoding+,
 * and +options+.  See Nokogiri::HTML.parse
 */
static VALUE read_memory( VALUE klass,
                          VALUE string,
                          VALUE url,
                          VALUE encoding,
                          VALUE options )
{
  const char * c_buffer = StringValuePtr(string);
  const char * c_url    = NIL_P(url)      ? NULL : StringValueCStr(url);
  const char * c_enc    = NIL_P(encoding) ? NULL : StringValueCStr(encoding);
  int len               = (int)RSTRING_LEN(string);
  VALUE error_list      = rb_ary_new();
  VALUE document;
  htmlDocPtr doc;

  xmlResetLastError();
  xmlSetStructuredErrorFunc((void *)error_list, Nokogiri_error_array_pusher);

  doc = htmlReadMemory(c_buffer, len, c_url, c_enc, (int)NUM2INT(options));
  xmlSetStructuredErrorFunc(NULL, NULL);

  if(doc == NULL) {
    xmlErrorPtr error;

    xmlFreeDoc(doc);

    error = xmlGetLastError();
    if(error)
      rb_exc_raise(Nokogiri_wrap_xml_syntax_error(error));
    else
      rb_raise(rb_eRuntimeError, "Could not parse document");

    return Qnil;
  }

  document = Nokogiri_wrap_xml_document(klass, doc);
  rb_iv_set(document, "@errors", error_list);
  return document;
}

/*
 * call-seq:
 *  type
 *
 * The type for this document
 */
static VALUE type(VALUE self)
{
  htmlDocPtr doc;
  Data_Get_Struct(self, xmlDoc, doc);
  return INT2NUM((long)doc->type);
}

VALUE cNokogiriHtmlDocument ;
void init_html_document()
{
  VALUE nokogiri  = rb_define_module("Nokogiri");
  VALUE html      = rb_define_module_under(nokogiri, "HTML");
  VALUE xml       = rb_define_module_under(nokogiri, "XML");
  VALUE node      = rb_define_class_under(xml, "Node", rb_cObject);
  VALUE xml_doc   = rb_define_class_under(xml, "Document", node);
  VALUE klass     = rb_define_class_under(html, "Document", xml_doc);

  cNokogiriHtmlDocument = klass;

  rb_define_singleton_method(klass, "read_memory", read_memory, 4);
  rb_define_singleton_method(klass, "read_io", read_io, 4);
  rb_define_singleton_method(klass, "new", new, -1);

  rb_define_method(klass, "type", type, 0);

  id_encoding_found = rb_intern("encoding_found");
}

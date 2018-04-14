#include <xslt_stylesheet.h>

#include <libxslt/xsltInternals.h>
#include <libxslt/xsltutils.h>
#include <libxslt/transform.h>
#include <libexslt/exslt.h>

VALUE xslt;

int vasprintf (char **strp, const char *fmt, va_list ap);
void vasprintf_free (void *p);

static void mark(nokogiriXsltStylesheetTuple *wrapper)
{
  rb_gc_mark(wrapper->func_instances);
}

static void dealloc(nokogiriXsltStylesheetTuple *wrapper)
{
    xsltStylesheetPtr doc = wrapper->ss;

    NOKOGIRI_DEBUG_START(doc);
    xsltFreeStylesheet(doc); /* commented out for now. */
    NOKOGIRI_DEBUG_END(doc);

    free(wrapper);
}

static void xslt_generic_error_handler(void * ctx, const char *msg, ...)
{
  char * message;

  va_list args;
  va_start(args, msg);
  vasprintf(&message, msg, args);
  va_end(args);

  rb_str_cat2((VALUE)ctx, message);

  vasprintf_free(message);
}

VALUE Nokogiri_wrap_xslt_stylesheet(xsltStylesheetPtr ss)
{
  VALUE self;
  nokogiriXsltStylesheetTuple *wrapper;

  self = Data_Make_Struct(cNokogiriXsltStylesheet, nokogiriXsltStylesheetTuple,
                          mark, dealloc, wrapper);

  ss->_private = (void *)self;
  wrapper->ss = ss;
  wrapper->func_instances = rb_ary_new();

  return self;
}

/*
 * call-seq:
 *   parse_stylesheet_doc(document)
 *
 * Parse a stylesheet from +document+.
 */
static VALUE parse_stylesheet_doc(VALUE klass, VALUE xmldocobj)
{
    xmlDocPtr xml, xml_cpy;
    VALUE errstr, exception;
    xsltStylesheetPtr ss ;
    Data_Get_Struct(xmldocobj, xmlDoc, xml);
    exsltRegisterAll();

    errstr = rb_str_new(0, 0);
    xsltSetGenericErrorFunc((void *)errstr, xslt_generic_error_handler);

    xml_cpy = xmlCopyDoc(xml, 1); /* 1 => recursive */
    ss = xsltParseStylesheetDoc(xml_cpy);

    xsltSetGenericErrorFunc(NULL, NULL);

    if (!ss) {
	xmlFreeDoc(xml_cpy);
	exception = rb_exc_new3(rb_eRuntimeError, errstr);
	rb_exc_raise(exception);
    }

    return Nokogiri_wrap_xslt_stylesheet(ss);
}


/*
 * call-seq:
 *   serialize(document)
 *
 * Serialize +document+ to an xml string.
 */
static VALUE serialize(VALUE self, VALUE xmlobj)
{
    xmlDocPtr xml ;
    nokogiriXsltStylesheetTuple *wrapper;
    xmlChar* doc_ptr ;
    int doc_len ;
    VALUE rval ;

    Data_Get_Struct(xmlobj, xmlDoc, xml);
    Data_Get_Struct(self, nokogiriXsltStylesheetTuple, wrapper);
    xsltSaveResultToString(&doc_ptr, &doc_len, xml, wrapper->ss);
    rval = NOKOGIRI_STR_NEW(doc_ptr, doc_len);
    xmlFree(doc_ptr);
    return rval ;
}

static void swallow_superfluous_xml_errors(void * userdata, xmlErrorPtr error, ...)
{
}

/*
 *  call-seq:
 *    transform(document, params = [])
 *
 *  Apply an XSLT stylesheet to an XML::Document.
 *  +params+ is an array of strings used as XSLT parameters.
 *  returns Nokogiri::XML::Document
 *
 *  Example:
 *
 *    doc   = Nokogiri::XML(File.read(ARGV[0]))
 *    xslt  = Nokogiri::XSLT(File.read(ARGV[1]))
 *    puts xslt.transform(doc, ['key', 'value'])
 *
 */
static VALUE transform(int argc, VALUE* argv, VALUE self)
{
    VALUE xmldoc, paramobj, errstr, exception ;
    xmlDocPtr xml ;
    xmlDocPtr result ;
    nokogiriXsltStylesheetTuple *wrapper;
    const char** params ;
    long param_len, j ;
    int parse_error_occurred ;

    rb_scan_args(argc, argv, "11", &xmldoc, &paramobj);
    if (NIL_P(paramobj)) { paramobj = rb_ary_new2(0L) ; }
    if (!rb_obj_is_kind_of(xmldoc, cNokogiriXmlDocument))
      rb_raise(rb_eArgError, "argument must be a Nokogiri::XML::Document");

    /* handle hashes as arguments. */
    if(T_HASH == TYPE(paramobj)) {
      paramobj = rb_funcall(paramobj, rb_intern("to_a"), 0);
      paramobj = rb_funcall(paramobj, rb_intern("flatten"), 0);
    }

    Check_Type(paramobj, T_ARRAY);

    Data_Get_Struct(xmldoc, xmlDoc, xml);
    Data_Get_Struct(self, nokogiriXsltStylesheetTuple, wrapper);

    param_len = RARRAY_LEN(paramobj);
    params = calloc((size_t)param_len+1, sizeof(char*));
    for (j = 0 ; j < param_len ; j++) {
      VALUE entry = rb_ary_entry(paramobj, j);
      const char * ptr = StringValueCStr(entry);
      params[j] = ptr;
    }
    params[param_len] = 0 ;

    errstr = rb_str_new(0, 0);
    xsltSetGenericErrorFunc((void *)errstr, xslt_generic_error_handler);
    xmlSetGenericErrorFunc(NULL, (xmlGenericErrorFunc)&swallow_superfluous_xml_errors);

    result = xsltApplyStylesheet(wrapper->ss, xml, params);
    free(params);

    xsltSetGenericErrorFunc(NULL, NULL);
    xmlSetGenericErrorFunc(NULL, NULL);

    parse_error_occurred = (Qfalse == rb_funcall(errstr, rb_intern("empty?"), 0));

    if (parse_error_occurred) {
      exception = rb_exc_new3(rb_eRuntimeError, errstr);
      rb_exc_raise(exception);
    }

    return Nokogiri_wrap_xml_document((VALUE)0, result) ;
}

static void method_caller(xmlXPathParserContextPtr ctxt, int nargs)
{
    VALUE handler;
    const char *function_name;
    xsltTransformContextPtr transform;
    const xmlChar *functionURI;

    transform = xsltXPathGetTransformContext(ctxt);
    functionURI = ctxt->context->functionURI;
    handler = (VALUE)xsltGetExtData(transform, functionURI);
    function_name = (const char*)(ctxt->context->function);

    Nokogiri_marshal_xpath_funcall_and_return_values(ctxt, nargs, handler, (const char*)function_name);
}

static void * initFunc(xsltTransformContextPtr ctxt, const xmlChar *uri)
{
    VALUE modules = rb_iv_get(xslt, "@modules");
    VALUE obj = rb_hash_aref(modules, rb_str_new2((const char *)uri));
    VALUE args = { Qfalse };
    VALUE methods = rb_funcall(obj, rb_intern("instance_methods"), 1, args);
    VALUE inst;
    nokogiriXsltStylesheetTuple *wrapper;
    int i;

    for(i = 0; i < RARRAY_LEN(methods); i++) {
	VALUE method_name = rb_obj_as_string(rb_ary_entry(methods, i));
	xsltRegisterExtFunction(ctxt,
          (unsigned char *)StringValueCStr(method_name), uri, method_caller);
    }

    Data_Get_Struct(ctxt->style->_private, nokogiriXsltStylesheetTuple,
                    wrapper);
    inst = rb_class_new_instance(0, NULL, obj);
    rb_ary_push(wrapper->func_instances, inst);

    return (void *)inst;
}

static void shutdownFunc(xsltTransformContextPtr ctxt,
	const xmlChar *uri, void *data)
{
    nokogiriXsltStylesheetTuple *wrapper;

    Data_Get_Struct(ctxt->style->_private, nokogiriXsltStylesheetTuple,
                    wrapper);

    rb_ary_clear(wrapper->func_instances);
}

/*
 *  call-seq:
 *    register(uri, custom_handler_class)
 *
 *  Register a class that implements custom XSLT transformation functions.
 */
static VALUE registr(VALUE self, VALUE uri, VALUE obj)
{
    VALUE modules = rb_iv_get(self, "@modules");
    if(NIL_P(modules)) rb_raise(rb_eRuntimeError, "wtf! @modules isn't set");

    rb_hash_aset(modules, uri, obj);
    xsltRegisterExtModule((unsigned char *)StringValueCStr(uri), initFunc, shutdownFunc);
    return self;
}

VALUE cNokogiriXsltStylesheet ;
void init_xslt_stylesheet()
{
  VALUE nokogiri;
  VALUE klass;

  nokogiri = rb_define_module("Nokogiri");
  xslt = rb_define_module_under(nokogiri, "XSLT");
  klass = rb_define_class_under(xslt, "Stylesheet", rb_cObject);

  rb_iv_set(xslt, "@modules", rb_hash_new());

  cNokogiriXsltStylesheet = klass;

  rb_define_singleton_method(klass, "parse_stylesheet_doc", parse_stylesheet_doc, 1);
  rb_define_singleton_method(xslt, "register", registr, 2);
  rb_define_method(klass, "serialize", serialize, 1);
  rb_define_method(klass, "transform", transform, -1);
}

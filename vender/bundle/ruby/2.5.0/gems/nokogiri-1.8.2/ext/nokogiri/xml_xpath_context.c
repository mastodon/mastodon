#include <xml_xpath_context.h>

int vasprintf (char **strp, const char *fmt, va_list ap);

static void deallocate(xmlXPathContextPtr ctx)
{
  NOKOGIRI_DEBUG_START(ctx);
  xmlXPathFreeContext(ctx);
  NOKOGIRI_DEBUG_END(ctx);
}

/*
 * call-seq:
 *  register_ns(prefix, uri)
 *
 * Register the namespace with +prefix+ and +uri+.
 */
static VALUE register_ns(VALUE self, VALUE prefix, VALUE uri)
{
  xmlXPathContextPtr ctx;
  Data_Get_Struct(self, xmlXPathContext, ctx);

  xmlXPathRegisterNs( ctx,
                      (const xmlChar *)StringValueCStr(prefix),
                      (const xmlChar *)StringValueCStr(uri)
  );
  return self;
}

/*
 * call-seq:
 *  register_variable(name, value)
 *
 * Register the variable +name+ with +value+.
 */
static VALUE register_variable(VALUE self, VALUE name, VALUE value)
{
   xmlXPathContextPtr ctx;
   xmlXPathObjectPtr xmlValue;
   Data_Get_Struct(self, xmlXPathContext, ctx);

   xmlValue = xmlXPathNewCString(StringValueCStr(value));

   xmlXPathRegisterVariable( ctx,
      (const xmlChar *)StringValueCStr(name),
      xmlValue
   );

   return self;
}

void Nokogiri_marshal_xpath_funcall_and_return_values(xmlXPathParserContextPtr ctx, int nargs, VALUE handler, const char* function_name)
{
  int i;
  VALUE result, doc;
  VALUE *argv;
  VALUE node_set = Qnil;
  xmlNodeSetPtr xml_node_set = NULL;
  xmlXPathObjectPtr obj;

  assert(ctx->context->doc);
  assert(DOC_RUBY_OBJECT_TEST(ctx->context->doc));

  argv = (VALUE *)calloc((size_t)nargs, sizeof(VALUE));
  for (i = 0 ; i < nargs ; ++i) {
    rb_gc_register_address(&argv[i]);
  }

  doc = DOC_RUBY_OBJECT(ctx->context->doc);

  if (nargs > 0) {
    i = nargs - 1;
    do {
      obj = valuePop(ctx);
      switch(obj->type) {
        case XPATH_STRING:
          argv[i] = NOKOGIRI_STR_NEW2(obj->stringval);
          break;
        case XPATH_BOOLEAN:
          argv[i] = obj->boolval == 1 ? Qtrue : Qfalse;
          break;
        case XPATH_NUMBER:
          argv[i] = rb_float_new(obj->floatval);
          break;
        case XPATH_NODESET:
          argv[i] = Nokogiri_wrap_xml_node_set(obj->nodesetval, doc);
          break;
        default:
          argv[i] = NOKOGIRI_STR_NEW2(xmlXPathCastToString(obj));
      }
      xmlXPathFreeNodeSetList(obj);
    } while(i-- > 0);
  }

  result = rb_funcall2(handler, rb_intern((const char*)function_name), nargs, argv);

  for (i = 0 ; i < nargs ; ++i) {
    rb_gc_unregister_address(&argv[i]);
  }
  free(argv);

  switch(TYPE(result)) {
    case T_FLOAT:
    case T_BIGNUM:
    case T_FIXNUM:
      xmlXPathReturnNumber(ctx, NUM2DBL(result));
      break;
    case T_STRING:
      xmlXPathReturnString(
          ctx,
          xmlCharStrdup(StringValueCStr(result))
      );
      break;
    case T_TRUE:
      xmlXPathReturnTrue(ctx);
      break;
    case T_FALSE:
      xmlXPathReturnFalse(ctx);
      break;
    case T_NIL:
      break;
    case T_ARRAY:
      {
        VALUE args[2];
        args[0] = doc;
        args[1] = result;
        node_set = rb_class_new_instance(2, args, cNokogiriXmlNodeSet);
        Data_Get_Struct(node_set, xmlNodeSet, xml_node_set);
        xmlXPathReturnNodeSet(ctx, xmlXPathNodeSetMerge(NULL, xml_node_set));
      }
    break;
    case T_DATA:
      if(rb_obj_is_kind_of(result, cNokogiriXmlNodeSet)) {
        Data_Get_Struct(result, xmlNodeSet, xml_node_set);
        /* Copy the node set, otherwise it will get GC'd. */
        xmlXPathReturnNodeSet(ctx, xmlXPathNodeSetMerge(NULL, xml_node_set));
        break;
      }
    default:
      rb_raise(rb_eRuntimeError, "Invalid return type");
    }
}

static void ruby_funcall(xmlXPathParserContextPtr ctx, int nargs)
{
  VALUE handler = Qnil;
  const char *function = NULL ;

  assert(ctx);
  assert(ctx->context);
  assert(ctx->context->userData);
  assert(ctx->context->function);

  handler = (VALUE)(ctx->context->userData);
  function = (const char*)(ctx->context->function);

  Nokogiri_marshal_xpath_funcall_and_return_values(ctx, nargs, handler, function);
}

static xmlXPathFunction lookup( void *ctx,
                                const xmlChar * name,
                                const xmlChar* ns_uri )
{
  VALUE xpath_handler = (VALUE)ctx;
  if(rb_respond_to(xpath_handler, rb_intern((const char *)name)))
    return ruby_funcall;

  return NULL;
}

NORETURN(static void xpath_generic_exception_handler(void * ctx, const char *msg, ...));
static void xpath_generic_exception_handler(void * ctx, const char *msg, ...)
{
  char * message;

  va_list args;
  va_start(args, msg);
  vasprintf(&message, msg, args);
  va_end(args);

  rb_raise(rb_eRuntimeError, "%s", message);
}

/*
 * call-seq:
 *  evaluate(search_path, handler = nil)
 *
 * Evaluate the +search_path+ returning an XML::XPath object.
 */
static VALUE evaluate(int argc, VALUE *argv, VALUE self)
{
  VALUE search_path, xpath_handler;
  VALUE thing = Qnil;
  xmlXPathContextPtr ctx;
  xmlXPathObjectPtr xpath;
  xmlChar *query;

  Data_Get_Struct(self, xmlXPathContext, ctx);

  if(rb_scan_args(argc, argv, "11", &search_path, &xpath_handler) == 1)
    xpath_handler = Qnil;

  query = (xmlChar *)StringValueCStr(search_path);

  if(Qnil != xpath_handler) {
    /* FIXME: not sure if this is the correct place to shove private data. */
    ctx->userData = (void *)xpath_handler;
    xmlXPathRegisterFuncLookup(ctx, lookup, (void *)xpath_handler);
  }

  xmlResetLastError();
  xmlSetStructuredErrorFunc(NULL, Nokogiri_error_raise);

  /* For some reason, xmlXPathEvalExpression will blow up with a generic error */
  /* when there is a non existent function. */
  xmlSetGenericErrorFunc(NULL, xpath_generic_exception_handler);

  xpath = xmlXPathEvalExpression(query, ctx);
  xmlSetStructuredErrorFunc(NULL, NULL);
  xmlSetGenericErrorFunc(NULL, NULL);

  if(xpath == NULL) {
    xmlErrorPtr error = xmlGetLastError();
    rb_exc_raise(Nokogiri_wrap_xml_syntax_error(error));
  }

  assert(ctx->doc);
  assert(DOC_RUBY_OBJECT_TEST(ctx->doc));

  switch(xpath->type) {
    case XPATH_STRING:
      thing = NOKOGIRI_STR_NEW2(xpath->stringval);
      xmlFree(xpath->stringval);
      break;
    case XPATH_NODESET:
      thing = Nokogiri_wrap_xml_node_set(xpath->nodesetval,
                                         DOC_RUBY_OBJECT(ctx->doc));
      break;
    case XPATH_NUMBER:
      thing = rb_float_new(xpath->floatval);
      break;
    case XPATH_BOOLEAN:
      thing = xpath->boolval == 1 ? Qtrue : Qfalse;
      break;
    default:
      thing = Nokogiri_wrap_xml_node_set(NULL, DOC_RUBY_OBJECT(ctx->doc));
  }

  xmlXPathFreeNodeSetList(xpath);

  return thing;
}

/*
 * call-seq:
 *  new(node)
 *
 * Create a new XPathContext with +node+ as the reference point.
 */
static VALUE new(VALUE klass, VALUE nodeobj)
{
  xmlNodePtr node;
  xmlXPathContextPtr ctx;
  VALUE self;

  xmlXPathInit();

  Data_Get_Struct(nodeobj, xmlNode, node);

  ctx = xmlXPathNewContext(node->doc);
  ctx->node = node;
  self = Data_Wrap_Struct(klass, 0, deallocate, ctx);
  /*rb_iv_set(self, "@xpath_handler", Qnil); */
  return self;
}

VALUE cNokogiriXmlXpathContext;
void init_xml_xpath_context(void)
{
  VALUE module = rb_define_module("Nokogiri");

  /*
   * Nokogiri::XML
   */
  VALUE xml = rb_define_module_under(module, "XML");

  /*
   * XPathContext is the entry point for searching a Document by using XPath.
   */
  VALUE klass = rb_define_class_under(xml, "XPathContext", rb_cObject);

  cNokogiriXmlXpathContext = klass;

  rb_define_singleton_method(klass, "new", new, 1);
  rb_define_method(klass, "evaluate", evaluate, -1);
  rb_define_method(klass, "register_variable", register_variable, 2);
  rb_define_method(klass, "register_ns", register_ns, 2);
}

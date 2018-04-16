#include <xml_reader.h>

static void dealloc(xmlTextReaderPtr reader)
{
  NOKOGIRI_DEBUG_START(reader);
  xmlFreeTextReader(reader);
  NOKOGIRI_DEBUG_END(reader);
}

static int has_attributes(xmlTextReaderPtr reader)
{
  /*
   *  this implementation of xmlTextReaderHasAttributes explicitly includes
   *  namespaces and properties, because some earlier versions ignore
   *  namespaces.
   */
  xmlNodePtr node ;
  node = xmlTextReaderCurrentNode(reader);
  if (node == NULL)
    return(0);

  if ((node->type == XML_ELEMENT_NODE) &&
      ((node->properties != NULL) || (node->nsDef != NULL)))
    return(1);
  return(0);
}

static void Nokogiri_xml_node_namespaces(xmlNodePtr node, VALUE attr_hash)
{
  xmlNsPtr ns;
  static char buffer[XMLNS_BUFFER_LEN] ;
  char *key ;
  size_t keylen ;

  if (node->type != XML_ELEMENT_NODE) return ;

  ns = node->nsDef;
  while (ns != NULL) {

    keylen = XMLNS_PREFIX_LEN + (ns->prefix ? (strlen((const char*)ns->prefix) + 1) : 0) ;
    if (keylen > XMLNS_BUFFER_LEN) {
      key = (char*)malloc(keylen) ;
    } else {
      key = buffer ;
    }

    if (ns->prefix) {
      sprintf(key, "%s:%s", XMLNS_PREFIX, ns->prefix);
    } else {
      sprintf(key, "%s", XMLNS_PREFIX);
    }

    rb_hash_aset(attr_hash,
        NOKOGIRI_STR_NEW2(key),
        (ns->href ? NOKOGIRI_STR_NEW2(ns->href) : Qnil)
    );
    if (key != buffer) {
      free(key);
    }
    ns = ns->next ;
  }
}


/*
 * call-seq:
 *   default?
 *
 * Was an attribute generated from the default value in the DTD or schema?
 */
static VALUE default_eh(VALUE self)
{
  xmlTextReaderPtr reader;
  int eh;

  Data_Get_Struct(self, xmlTextReader, reader);
  eh = xmlTextReaderIsDefault(reader);
  if(eh == 0) return Qfalse;
  if(eh == 1) return Qtrue;

  return Qnil;
}

/*
 * call-seq:
 *   value?
 *
 * Does this node have a text value?
 */
static VALUE value_eh(VALUE self)
{
  xmlTextReaderPtr reader;
  int eh;

  Data_Get_Struct(self, xmlTextReader, reader);
  eh = xmlTextReaderHasValue(reader);
  if(eh == 0) return Qfalse;
  if(eh == 1) return Qtrue;

  return Qnil;
}

/*
 * call-seq:
 *   attributes?
 *
 * Does this node have attributes?
 */
static VALUE attributes_eh(VALUE self)
{
  xmlTextReaderPtr reader;
  int eh;

  Data_Get_Struct(self, xmlTextReader, reader);
  eh = has_attributes(reader);
  if(eh == 0) return Qfalse;
  if(eh == 1) return Qtrue;

  return Qnil;
}

/*
 * call-seq:
 *   namespaces
 *
 * Get a hash of namespaces for this Node
 */
static VALUE namespaces(VALUE self)
{
  xmlTextReaderPtr reader;
  xmlNodePtr ptr;
  VALUE attr ;

  Data_Get_Struct(self, xmlTextReader, reader);

  attr = rb_hash_new() ;

  if (! has_attributes(reader))
    return attr ;

  ptr = xmlTextReaderExpand(reader);
  if(ptr == NULL) return Qnil;

  Nokogiri_xml_node_namespaces(ptr, attr);

  return attr ;
}

/*
 * call-seq:
 *   attribute_nodes
 *
 * Get a list of attributes for this Node
 */
static VALUE attribute_nodes(VALUE self)
{
  xmlTextReaderPtr reader;
  xmlNodePtr ptr;
  VALUE attr ;

  Data_Get_Struct(self, xmlTextReader, reader);

  attr = rb_ary_new() ;

  if (! has_attributes(reader))
    return attr ;

  ptr = xmlTextReaderExpand(reader);
  if(ptr == NULL) return Qnil;

  Nokogiri_xml_node_properties(ptr, attr);

  return attr ;
}

/*
 * call-seq:
 *   attribute_at(index)
 *
 * Get the value of attribute at +index+
 */
static VALUE attribute_at(VALUE self, VALUE index)
{
  xmlTextReaderPtr reader;
  xmlChar *value;
  VALUE rb_value;

  Data_Get_Struct(self, xmlTextReader, reader);

  if(NIL_P(index)) return Qnil;
  index = rb_Integer(index);

  value = xmlTextReaderGetAttributeNo(
      reader,
      (int)NUM2INT(index)
  );
  if(value == NULL) return Qnil;

  rb_value = NOKOGIRI_STR_NEW2(value);
  xmlFree(value);
  return rb_value;
}

/*
 * call-seq:
 *   attribute(name)
 *
 * Get the value of attribute named +name+
 */
static VALUE reader_attribute(VALUE self, VALUE name)
{
  xmlTextReaderPtr reader;
  xmlChar *value ;
  VALUE rb_value;

  Data_Get_Struct(self, xmlTextReader, reader);

  if(NIL_P(name)) return Qnil;
  name = StringValue(name) ;

  value = xmlTextReaderGetAttribute(reader, (xmlChar*)StringValueCStr(name));
  if(value == NULL) return Qnil;

  rb_value = NOKOGIRI_STR_NEW2(value);
  xmlFree(value);
  return rb_value;
}

/*
 * call-seq:
 *   attribute_count
 *
 * Get the number of attributes for the current node
 */
static VALUE attribute_count(VALUE self)
{
  xmlTextReaderPtr reader;
  int count;

  Data_Get_Struct(self, xmlTextReader, reader);
  count = xmlTextReaderAttributeCount(reader);
  if(count == -1) return Qnil;

  return INT2NUM((long)count);
}

/*
 * call-seq:
 *   depth
 *
 * Get the depth of the node
 */
static VALUE depth(VALUE self)
{
  xmlTextReaderPtr reader;
  int depth;

  Data_Get_Struct(self, xmlTextReader, reader);
  depth = xmlTextReaderDepth(reader);
  if(depth == -1) return Qnil;

  return INT2NUM((long)depth);
}

/*
 * call-seq:
 *   xml_version
 *
 * Get the XML version of the document being read
 */
static VALUE xml_version(VALUE self)
{
  xmlTextReaderPtr reader;
  const char *version;

  Data_Get_Struct(self, xmlTextReader, reader);
  version = (const char *)xmlTextReaderConstXmlVersion(reader);
  if(version == NULL) return Qnil;

  return NOKOGIRI_STR_NEW2(version);
}

/*
 * call-seq:
 *   lang
 *
 * Get the xml:lang scope within which the node resides.
 */
static VALUE lang(VALUE self)
{
  xmlTextReaderPtr reader;
  const char *lang;

  Data_Get_Struct(self, xmlTextReader, reader);
  lang = (const char *)xmlTextReaderConstXmlLang(reader);
  if(lang == NULL) return Qnil;

  return NOKOGIRI_STR_NEW2(lang);
}

/*
 * call-seq:
 *   value
 *
 * Get the text value of the node if present. Returns a utf-8 encoded string.
 */
static VALUE value(VALUE self)
{
  xmlTextReaderPtr reader;
  const char *value;

  Data_Get_Struct(self, xmlTextReader, reader);
  value = (const char *)xmlTextReaderConstValue(reader);
  if(value == NULL) return Qnil;

  return NOKOGIRI_STR_NEW2(value);
}

/*
 * call-seq:
 *   prefix
 *
 * Get the shorthand reference to the namespace associated with the node.
 */
static VALUE prefix(VALUE self)
{
  xmlTextReaderPtr reader;
  const char *prefix;

  Data_Get_Struct(self, xmlTextReader, reader);
  prefix = (const char *)xmlTextReaderConstPrefix(reader);
  if(prefix == NULL) return Qnil;

  return NOKOGIRI_STR_NEW2(prefix);
}

/*
 * call-seq:
 *   namespace_uri
 *
 * Get the URI defining the namespace associated with the node
 */
static VALUE namespace_uri(VALUE self)
{
  xmlTextReaderPtr reader;
  const char *uri;

  Data_Get_Struct(self, xmlTextReader, reader);
  uri = (const char *)xmlTextReaderConstNamespaceUri(reader);
  if(uri == NULL) return Qnil;

  return NOKOGIRI_STR_NEW2(uri);
}

/*
 * call-seq:
 *   local_name
 *
 * Get the local name of the node
 */
static VALUE local_name(VALUE self)
{
  xmlTextReaderPtr reader;
  const char *name;

  Data_Get_Struct(self, xmlTextReader, reader);
  name = (const char *)xmlTextReaderConstLocalName(reader);
  if(name == NULL) return Qnil;

  return NOKOGIRI_STR_NEW2(name);
}

/*
 * call-seq:
 *   name
 *
 * Get the name of the node. Returns a utf-8 encoded string.
 */
static VALUE name(VALUE self)
{
  xmlTextReaderPtr reader;
  const char *name;

  Data_Get_Struct(self, xmlTextReader, reader);
  name = (const char *)xmlTextReaderConstName(reader);
  if(name == NULL) return Qnil;

  return NOKOGIRI_STR_NEW2(name);
}

/*
 * call-seq:
 * base_uri
 *
 * Get the xml:base of the node
 */
static VALUE base_uri(VALUE self)
{
  xmlTextReaderPtr reader;
  const char * base_uri;

  Data_Get_Struct(self, xmlTextReader, reader);
  base_uri = (const char *)xmlTextReaderBaseUri(reader);
  if (base_uri == NULL) return Qnil;

  return NOKOGIRI_STR_NEW2(base_uri);
}

/*
 * call-seq:
 *   state
 *
 * Get the state of the reader
 */
static VALUE state(VALUE self)
{
  xmlTextReaderPtr reader;
  Data_Get_Struct(self, xmlTextReader, reader);
  return INT2NUM((long)xmlTextReaderReadState(reader));
}

/*
 * call-seq:
 *   node_type
 *
 * Get the type of readers current node
 */
static VALUE node_type(VALUE self)
{
  xmlTextReaderPtr reader;
  Data_Get_Struct(self, xmlTextReader, reader);
  return INT2NUM((long)xmlTextReaderNodeType(reader));
}

/*
 * call-seq:
 *   read
 *
 * Move the Reader forward through the XML document.
 */
static VALUE read_more(VALUE self)
{
  xmlTextReaderPtr reader;
  xmlErrorPtr error;
  VALUE error_list;
  int ret;

  Data_Get_Struct(self, xmlTextReader, reader);

  error_list = rb_funcall(self, rb_intern("errors"), 0);

  xmlSetStructuredErrorFunc((void *)error_list, Nokogiri_error_array_pusher);
  ret = xmlTextReaderRead(reader);
  xmlSetStructuredErrorFunc(NULL, NULL);

  if(ret == 1) return self;
  if(ret == 0) return Qnil;

  error = xmlGetLastError();
  if(error)
    rb_exc_raise(Nokogiri_wrap_xml_syntax_error(error));
  else
    rb_raise(rb_eRuntimeError, "Error pulling: %d", ret);

  return Qnil;
}

/*
 * call-seq:
 *   inner_xml
 *
 * Read the contents of the current node, including child nodes and markup.
 * Returns a utf-8 encoded string.
 */
static VALUE inner_xml(VALUE self)
{
  xmlTextReaderPtr reader;
  xmlChar* value;
  VALUE str;

  Data_Get_Struct(self, xmlTextReader, reader);

  value = xmlTextReaderReadInnerXml(reader);

  str = Qnil;
  if(value) {
    str = NOKOGIRI_STR_NEW2((char*)value);
    xmlFree(value);
  }

  return str;
}

/*
 * call-seq:
 *   outer_xml
 *
 * Read the current node and its contents, including child nodes and markup.
 * Returns a utf-8 encoded string.
 */
static VALUE outer_xml(VALUE self)
{
  xmlTextReaderPtr reader;
  xmlChar *value;
  VALUE str = Qnil;

  Data_Get_Struct(self, xmlTextReader, reader);

  value = xmlTextReaderReadOuterXml(reader);

  if(value) {
    str = NOKOGIRI_STR_NEW2((char*)value);
    xmlFree(value);
  }
  return str;
}

/*
 * call-seq:
 *   from_memory(string, url = nil, encoding = nil, options = 0)
 *
 * Create a new reader that parses +string+
 */
static VALUE from_memory(int argc, VALUE *argv, VALUE klass)
{
  VALUE rb_buffer, rb_url, encoding, rb_options;
  xmlTextReaderPtr reader;
  const char * c_url      = NULL;
  const char * c_encoding = NULL;
  int c_options           = 0;
  VALUE rb_reader, args[3];

  rb_scan_args(argc, argv, "13", &rb_buffer, &rb_url, &encoding, &rb_options);

  if (!RTEST(rb_buffer)) rb_raise(rb_eArgError, "string cannot be nil");
  if (RTEST(rb_url)) c_url = StringValueCStr(rb_url);
  if (RTEST(encoding)) c_encoding = StringValueCStr(encoding);
  if (RTEST(rb_options)) c_options = (int)NUM2INT(rb_options);

  reader = xmlReaderForMemory(
      StringValuePtr(rb_buffer),
      (int)RSTRING_LEN(rb_buffer),
      c_url,
      c_encoding,
      c_options
  );

  if(reader == NULL) {
    xmlFreeTextReader(reader);
    rb_raise(rb_eRuntimeError, "couldn't create a parser");
  }

  rb_reader = Data_Wrap_Struct(klass, NULL, dealloc, reader);
  args[0] = rb_buffer;
  args[1] = rb_url;
  args[2] = encoding;
  rb_obj_call_init(rb_reader, 3, args);

  return rb_reader;
}

/*
 * call-seq:
 *   from_io(io, url = nil, encoding = nil, options = 0)
 *
 * Create a new reader that parses +io+
 */
static VALUE from_io(int argc, VALUE *argv, VALUE klass)
{
  VALUE rb_io, rb_url, encoding, rb_options;
  xmlTextReaderPtr reader;
  const char * c_url      = NULL;
  const char * c_encoding = NULL;
  int c_options           = 0;
  VALUE rb_reader, args[3];

  rb_scan_args(argc, argv, "13", &rb_io, &rb_url, &encoding, &rb_options);

  if (!RTEST(rb_io)) rb_raise(rb_eArgError, "io cannot be nil");
  if (RTEST(rb_url)) c_url = StringValueCStr(rb_url);
  if (RTEST(encoding)) c_encoding = StringValueCStr(encoding);
  if (RTEST(rb_options)) c_options = (int)NUM2INT(rb_options);

  reader = xmlReaderForIO(
      (xmlInputReadCallback)io_read_callback,
      (xmlInputCloseCallback)io_close_callback,
      (void *)rb_io,
      c_url,
      c_encoding,
      c_options
  );

  if(reader == NULL) {
    xmlFreeTextReader(reader);
    rb_raise(rb_eRuntimeError, "couldn't create a parser");
  }

  rb_reader = Data_Wrap_Struct(klass, NULL, dealloc, reader);
  args[0] = rb_io;
  args[1] = rb_url;
  args[2] = encoding;
  rb_obj_call_init(rb_reader, 3, args);

  return rb_reader;
}

/*
 * call-seq:
 *   reader.empty_element? # => true or false
 *
 * Returns true if the current node is empty, otherwise false.
 */
static VALUE empty_element_p(VALUE self)
{
  xmlTextReaderPtr reader;

  Data_Get_Struct(self, xmlTextReader, reader);

  if(xmlTextReaderIsEmptyElement(reader))
    return Qtrue;

  return Qfalse;
}

VALUE cNokogiriXmlReader;

void init_xml_reader()
{
  VALUE module = rb_define_module("Nokogiri");
  VALUE xml = rb_define_module_under(module, "XML");

  /*
   * The Reader parser allows you to effectively pull parse an XML document.
   * Once instantiated, call Nokogiri::XML::Reader#each to iterate over each
   * node.  Note that you may only iterate over the document once!
   */
  VALUE klass = rb_define_class_under(xml, "Reader", rb_cObject);

  cNokogiriXmlReader = klass;

  rb_define_singleton_method(klass, "from_memory", from_memory, -1);
  rb_define_singleton_method(klass, "from_io", from_io, -1);

  rb_define_method(klass, "read", read_more, 0);
  rb_define_method(klass, "inner_xml", inner_xml, 0);
  rb_define_method(klass, "outer_xml", outer_xml, 0);
  rb_define_method(klass, "state", state, 0);
  rb_define_method(klass, "node_type", node_type, 0);
  rb_define_method(klass, "name", name, 0);
  rb_define_method(klass, "local_name", local_name, 0);
  rb_define_method(klass, "namespace_uri", namespace_uri, 0);
  rb_define_method(klass, "prefix", prefix, 0);
  rb_define_method(klass, "value", value, 0);
  rb_define_method(klass, "lang", lang, 0);
  rb_define_method(klass, "xml_version", xml_version, 0);
  rb_define_method(klass, "depth", depth, 0);
  rb_define_method(klass, "attribute_count", attribute_count, 0);
  rb_define_method(klass, "attribute", reader_attribute, 1);
  rb_define_method(klass, "namespaces", namespaces, 0);
  rb_define_method(klass, "attribute_at", attribute_at, 1);
  rb_define_method(klass, "empty_element?", empty_element_p, 0);
  rb_define_method(klass, "attributes?", attributes_eh, 0);
  rb_define_method(klass, "value?", value_eh, 0);
  rb_define_method(klass, "default?", default_eh, 0);
  rb_define_method(klass, "base_uri", base_uri, 0);

  rb_define_private_method(klass, "attr_nodes", attribute_nodes, 0);
}

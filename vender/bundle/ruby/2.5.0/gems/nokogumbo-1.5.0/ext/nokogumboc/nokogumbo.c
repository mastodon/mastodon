//
// nokogumbo.c defines the following:
//
//   class Nokogumbo
//     def parse(utf8_string) # returns Nokogiri::HTML::Document
//   end
//
// Processing starts by calling gumbo_parse_with_options.  The resulting
// document tree is then walked:
//
//  * if Nokogiri and libxml2 headers are available at compile time,
//    (ifdef NGLIB) then a parallel libxml2 tree is constructed, and the
//    final document is then wrapped using Nokogiri_wrap_xml_document.
//    This approach reduces memory and CPU requirements as Ruby objects
//    are only built when necessary.
//
//  * if the necessary headers are not available at compile time, Nokogiri
//    methods are called instead, producing the equivalent functionality.
//

#include <ruby.h>
#include "gumbo.h"
#include "error.h"
#include "parser.h"

// class constants
static VALUE Document;
static VALUE XMLSyntaxError;

#ifdef NGLIB
#include <nokogiri.h>
#include <libxml/tree.h>

#define NIL NULL
#define CONST_CAST (xmlChar const*)
#else
#define NIL 0
#define CONST_CAST

// more class constants
static VALUE Element;
static VALUE Text;
static VALUE CDATA;
static VALUE Comment;

// interned symbols
static VALUE new;
static VALUE set_attribute;
static VALUE add_child;
static VALUE internal_subset;
static VALUE remove_;
static VALUE create_internal_subset;

// map libxml2 types to Ruby VALUE
#define xmlNodePtr VALUE
#define xmlDocPtr VALUE

// redefine libxml2 API as Ruby function calls
#define xmlNewDocNode(doc, ns, name, content) \
  rb_funcall(Element, new, 2, rb_str_new2(name), doc)
#define xmlNewProp(element, name, value) \
  rb_funcall(element, set_attribute, 2, rb_str_new2(name), rb_str_new2(value))
#define xmlNewDocText(doc, text) \
  rb_funcall(Text, new, 2, rb_str_new2(text), doc)
#define xmlNewCDataBlock(doc, content, length) \
  rb_funcall(CDATA, new, 2, rb_str_new(content, length), doc)
#define xmlNewDocComment(doc, text) \
  rb_funcall(Comment, new, 2, doc, rb_str_new2(text))
#define xmlAddChild(element, node) \
  rb_funcall(element, add_child, 1, node)
#define xmlDocSetRootElement(doc, root) \
  rb_funcall(doc, add_child, 1, root)
#define xmlCreateIntSubset(doc, name, external, system) \
  rb_funcall(doc, create_internal_subset, 3, rb_str_new2(name), \
    (external ? rb_str_new2(external) : Qnil), \
    (system ? rb_str_new2(system) : Qnil));
#define Nokogiri_wrap_xml_document(klass, doc) \
  doc

// remove internal subset from newly created documents
static VALUE xmlNewDoc(char* version) {
  VALUE doc = rb_funcall(Document, new, 0);
  rb_funcall(rb_funcall(doc, internal_subset, 0), remove_, 0);
  return doc;
}
#endif

// Build a xmlNodePtr for a given GumboNode (recursively)
static xmlNodePtr walk_tree(xmlDocPtr document, GumboNode *node);

// Build a xmlNodePtr for a given GumboElement (recursively)
static xmlNodePtr walk_element(xmlDocPtr document, GumboElement *node) {
  // determine tag name for a given node
  xmlNodePtr element;
  if (node->tag != GUMBO_TAG_UNKNOWN) {
    element = xmlNewDocNode(document, NIL,
      CONST_CAST gumbo_normalized_tagname(node->tag), NIL);
  } else {
    GumboStringPiece tag = node->original_tag;
    gumbo_tag_from_original_text(&tag);
#ifdef _MSC_VER
    char* name = alloca(tag.length+1);
#else
    char name[tag.length+1];
#endif
    strncpy(name, tag.data, tag.length);
    name[tag.length] = '\0';
    element = xmlNewDocNode(document, NIL, CONST_CAST name, NIL);
  }

  // add in the attributes
  GumboVector* attrs = &node->attributes;
  char *name = NULL;
  int namelen = 0;
  char *ns;
  for (int i=0; i < attrs->length; i++) {
    GumboAttribute *attr = attrs->data[i];

    switch (attr->attr_namespace) {
      case GUMBO_ATTR_NAMESPACE_XLINK:
        ns = "xlink:";
        break;

      case GUMBO_ATTR_NAMESPACE_XML:
        ns = "xml:";
        break;

      case GUMBO_ATTR_NAMESPACE_XMLNS:
        ns = "xmlns:";
        if (!strcmp(attr->name, "xmlns")) ns = NULL;
        break;

      default:
        ns = NULL;
    }

    if (ns) {
      if (strlen(ns) + strlen(attr->name) + 1 > namelen) {
        free(name);
        name = NULL;
      }

      if (!name) {
        namelen = strlen(ns) + strlen(attr->name) + 1;
        name = malloc(namelen);
      }

      strcpy(name, ns);
      strcat(name, attr->name);
      xmlNewProp(element, CONST_CAST name, CONST_CAST attr->value);
    } else {
      xmlNewProp(element, CONST_CAST attr->name, CONST_CAST attr->value);
    }
  }
  if (name) free(name);

  // add in the children
  GumboVector* children = &node->children;
  for (int i=0; i < children->length; i++) {
    xmlNodePtr node = walk_tree(document, children->data[i]);
    if (node) xmlAddChild(element, node);
  }

  return element;
}

static xmlNodePtr walk_tree(xmlDocPtr document, GumboNode *node) {
  switch (node->type) {
    case GUMBO_NODE_DOCUMENT:
      return NIL;
    case GUMBO_NODE_ELEMENT:
    case GUMBO_NODE_TEMPLATE:
      return walk_element(document, &node->v.element);
    case GUMBO_NODE_TEXT:
    case GUMBO_NODE_WHITESPACE:
      return xmlNewDocText(document, CONST_CAST node->v.text.text);
    case GUMBO_NODE_CDATA:
      return xmlNewCDataBlock(document,
        CONST_CAST node->v.text.original_text.data,
        (int) node->v.text.original_text.length);
    case GUMBO_NODE_COMMENT:
      return xmlNewDocComment(document, CONST_CAST node->v.text.text);
  }
}

// Parse a string using gumbo_parse into a Nokogiri document
static VALUE parse(VALUE self, VALUE string, VALUE max_parse_errors) {
  GumboOptions options;
  memcpy(&options, &kGumboDefaultOptions, sizeof options);
  options.max_errors = NUM2INT(max_parse_errors);

  const char *input = RSTRING_PTR(string);
  size_t input_len = RSTRING_LEN(string);
  GumboOutput *output = gumbo_parse_with_options(&options, input, input_len);
  xmlDocPtr doc = xmlNewDoc(CONST_CAST "1.0");
#ifdef NGLIB
  doc->type = XML_HTML_DOCUMENT_NODE;
#endif
  if (output->document->v.document.has_doctype) {
    const char *name   = output->document->v.document.name;
    const char *public = output->document->v.document.public_identifier;
    const char *system = output->document->v.document.system_identifier;
    xmlCreateIntSubset(doc, CONST_CAST name,
      (public[0] ? CONST_CAST public : NIL),
      (system[0] ? CONST_CAST system : NIL));
  }

  GumboVector *children = &output->document->v.document.children;
  for (int i=0; i < children->length; i++) {
    GumboNode *child = children->data[i];
    xmlNodePtr node = walk_tree(doc, child);
    if (node) {
      if (child == output->root)
        xmlDocSetRootElement(doc, node);
      else
        xmlAddChild((xmlNodePtr)doc, node);
    }
  }

  VALUE rdoc = Nokogiri_wrap_xml_document(Document, doc);

  // Add parse errors to rdoc.
  if (output->errors.length) {
    GumboVector *errors = &output->errors;
    GumboParser parser = { ._options = &options };
    GumboStringBuffer msg;
    VALUE rerrors = rb_ary_new2(errors->length);

    gumbo_string_buffer_init(&parser, &msg);
    for (int i=0; i < errors->length; i++) {
      GumboError *err = errors->data[i];
      gumbo_string_buffer_clear(&parser, &msg);
      // Work around bug in gumbo_caret_diagnostic_to_string.
      // See https://github.com/google/gumbo-parser/pull/371
      // The bug occurs when the error starts with a newline (unless it's the
      // first character in the input--but that shouldn't cause an error in
      // the first place.
      if (*err->original_text == '\n' && err->original_text != input)
        --err->original_text;
      gumbo_caret_diagnostic_to_string(&parser, err, input, &msg);
      VALUE err_str = rb_str_new(msg.data, msg.length);
      VALUE syntax_error = rb_class_new_instance(1, &err_str, XMLSyntaxError);
      rb_iv_set(syntax_error, "@domain", INT2NUM(1)); // XML_FROM_PARSER
      rb_iv_set(syntax_error, "@code", INT2NUM(1));   // XML_ERR_INTERNAL_ERROR
      rb_iv_set(syntax_error, "@level", INT2NUM(2));  // XML_ERR_ERROR
      rb_iv_set(syntax_error, "@file", Qnil);
      rb_iv_set(syntax_error, "@line", INT2NUM(err->position.line));
      rb_iv_set(syntax_error, "@str1", Qnil);
      rb_iv_set(syntax_error, "@str2", Qnil);
      rb_iv_set(syntax_error, "@str3", Qnil);
      rb_iv_set(syntax_error, "@int1", INT2NUM(err->type));
      rb_iv_set(syntax_error, "@column", INT2NUM(err->position.column));
      rb_ary_push(rerrors, syntax_error);
    }
    rb_iv_set(rdoc, "@errors", rerrors);
    gumbo_string_buffer_destroy(&parser, &msg);
  }

  gumbo_destroy_output(&options, output);

  return rdoc;
}

// Initialize the Nokogumbo class and fetch constants we will use later
void Init_nokogumboc() {
  rb_funcall(rb_mKernel, rb_intern("gem"), 1, rb_str_new2("nokogiri"));
  rb_require("nokogiri");

  // class constants
  VALUE Nokogiri = rb_const_get(rb_cObject, rb_intern("Nokogiri"));
  VALUE HTML = rb_const_get(Nokogiri, rb_intern("HTML"));
  Document = rb_const_get(HTML, rb_intern("Document"));
  VALUE XML = rb_const_get(Nokogiri, rb_intern("XML"));
  XMLSyntaxError = rb_const_get(XML, rb_intern("SyntaxError"));

#ifndef NGLIB
  // more class constants
  Element = rb_const_get(XML, rb_intern("Element"));
  Text = rb_const_get(XML, rb_intern("Text"));
  CDATA = rb_const_get(XML, rb_intern("CDATA"));
  Comment = rb_const_get(XML, rb_intern("Comment"));

  // interned symbols
  new = rb_intern("new");
  set_attribute = rb_intern("set_attribute");
  add_child = rb_intern("add_child_node_and_reparent_attrs");
  internal_subset = rb_intern("internal_subset");
  remove_ = rb_intern("remove");
  create_internal_subset = rb_intern("create_internal_subset");
#endif

  // define Nokogumbo class with a singleton parse method
  VALUE Gumbo = rb_define_class("Nokogumbo", rb_cObject);
  rb_define_singleton_method(Gumbo, "parse", parse, 2);
}

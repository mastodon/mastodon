#include <xml_comment.h>

static ID document_id ;

/*
 * call-seq:
 *  new(document_or_node, content)
 *
 * Create a new Comment element on the +document+ with +content+.
 * Alternatively, if a +node+ is passed, the +node+'s document is used.
 */
static VALUE new(int argc, VALUE *argv, VALUE klass)
{
  xmlDocPtr xml_doc;
  xmlNodePtr node;
  VALUE document;
  VALUE content;
  VALUE rest;
  VALUE rb_node;

  rb_scan_args(argc, argv, "2*", &document, &content, &rest);

  if (rb_obj_is_kind_of(document, cNokogiriXmlNode))
  {
    document = rb_funcall(document, document_id, 0);
  }
  else if (   !rb_obj_is_kind_of(document, cNokogiriXmlDocument)
           && !rb_obj_is_kind_of(document, cNokogiriXmlDocumentFragment))
  {
    rb_raise(rb_eArgError, "first argument must be a XML::Document or XML::Node");
  }

  Data_Get_Struct(document, xmlDoc, xml_doc);

  node = xmlNewDocComment(
      xml_doc,
      (const xmlChar *)StringValueCStr(content)
  );

  rb_node = Nokogiri_wrap_xml_node(klass, node);
  rb_obj_call_init(rb_node, argc, argv);

  nokogiri_root_node(node);

  if(rb_block_given_p()) rb_yield(rb_node);

  return rb_node;
}

VALUE cNokogiriXmlComment;
void init_xml_comment()
{
  VALUE nokogiri = rb_define_module("Nokogiri");
  VALUE xml = rb_define_module_under(nokogiri, "XML");
  VALUE node = rb_define_class_under(xml, "Node", rb_cObject);
  VALUE char_data = rb_define_class_under(xml, "CharacterData", node);

  /*
   * Comment represents a comment node in an xml document.
   */
  VALUE klass = rb_define_class_under(xml, "Comment", char_data);


  cNokogiriXmlComment = klass;

  rb_define_singleton_method(klass, "new", new, -1);

  document_id = rb_intern("document");
}

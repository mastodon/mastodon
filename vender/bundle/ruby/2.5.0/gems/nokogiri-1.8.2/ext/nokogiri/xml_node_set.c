#include <xml_node_set.h>
#include <xml_namespace.h>
#include <libxml/xpathInternals.h>

static ID decorate ;
static void xpath_node_set_del(xmlNodeSetPtr cur, xmlNodePtr val);


static void Check_Node_Set_Node_Type(VALUE node)
{
  if (!(rb_obj_is_kind_of(node, cNokogiriXmlNode) ||
        rb_obj_is_kind_of(node, cNokogiriXmlNamespace))) {
    rb_raise(rb_eArgError, "node must be a Nokogiri::XML::Node or Nokogiri::XML::Namespace");
  }
}


static void deallocate(xmlNodeSetPtr node_set)
{
  /*
   *
   *  since xpath queries return copies of the xmlNs structs,
   *  xmlXPathFreeNodeSet() frees those xmlNs structs that are in the
   *  NodeSet.
   *
   *  this is bad if someone is still trying to use the Namespace object wrapped
   *  around the xmlNs, so we need to avoid that.
   *
   *  here we reproduce xmlXPathFreeNodeSet() without the xmlNs logic.
   *
   *  this doesn't cause a leak because Namespace objects that are in an XPath
   *  query NodeSet are given their own lifecycle in
   *  Nokogiri_wrap_xml_namespace().
   */
  NOKOGIRI_DEBUG_START(node_set) ;
  if (node_set->nodeTab != NULL)
    xmlFree(node_set->nodeTab);

  xmlFree(node_set);
  NOKOGIRI_DEBUG_END(node_set) ;
}

static VALUE allocate(VALUE klass)
{
  return Nokogiri_wrap_xml_node_set(xmlXPathNodeSetCreate(NULL), Qnil);
}


/*
 * call-seq:
 *  dup
 *
 * Duplicate this node set
 */
static VALUE duplicate(VALUE self)
{
  xmlNodeSetPtr node_set;
  xmlNodeSetPtr dupl;

  Data_Get_Struct(self, xmlNodeSet, node_set);

  dupl = xmlXPathNodeSetMerge(NULL, node_set);

  return Nokogiri_wrap_xml_node_set(dupl, rb_iv_get(self, "@document"));
}

/*
 * call-seq:
 *  length
 *
 * Get the length of the node set
 */
static VALUE length(VALUE self)
{
  xmlNodeSetPtr node_set;

  Data_Get_Struct(self, xmlNodeSet, node_set);

  return node_set ? INT2NUM(node_set->nodeNr) : INT2NUM(0);
}

/*
 * call-seq:
 *  push(node)
 *
 * Append +node+ to the NodeSet.
 */
static VALUE push(VALUE self, VALUE rb_node)
{
  xmlNodeSetPtr node_set;
  xmlNodePtr node;

  Check_Node_Set_Node_Type(rb_node);

  Data_Get_Struct(self, xmlNodeSet, node_set);
  Data_Get_Struct(rb_node, xmlNode, node);

  xmlXPathNodeSetAdd(node_set, node);

  return self;
}

/*
 *  call-seq:
 *    delete(node)
 *
 *  Delete +node+ from the Nodeset, if it is a member. Returns the deleted node
 *  if found, otherwise returns nil.
 */
static VALUE
delete(VALUE self, VALUE rb_node)
{
  xmlNodeSetPtr node_set;
  xmlNodePtr node;

  Check_Node_Set_Node_Type(rb_node);

  Data_Get_Struct(self, xmlNodeSet, node_set);
  Data_Get_Struct(rb_node, xmlNode, node);

  if (xmlXPathNodeSetContains(node_set, node)) {
    xpath_node_set_del(node_set, node);
    return rb_node;
  }
  return Qnil ;
}


/*
 * call-seq:
 *  &(node_set)
 *
 * Set Intersection — Returns a new NodeSet containing nodes common to the two NodeSets.
 */
static VALUE intersection(VALUE self, VALUE rb_other)
{
  xmlNodeSetPtr node_set, other ;
  xmlNodeSetPtr intersection;

  if(!rb_obj_is_kind_of(rb_other, cNokogiriXmlNodeSet))
    rb_raise(rb_eArgError, "node_set must be a Nokogiri::XML::NodeSet");

  Data_Get_Struct(self, xmlNodeSet, node_set);
  Data_Get_Struct(rb_other, xmlNodeSet, other);

  intersection = xmlXPathIntersection(node_set, other);
  return Nokogiri_wrap_xml_node_set(intersection, rb_iv_get(self, "@document"));
}


/*
 * call-seq:
 *  include?(node)
 *
 *  Returns true if any member of node set equals +node+.
 */
static VALUE include_eh(VALUE self, VALUE rb_node)
{
  xmlNodeSetPtr node_set;
  xmlNodePtr node;

  Check_Node_Set_Node_Type(rb_node);

  Data_Get_Struct(self, xmlNodeSet, node_set);
  Data_Get_Struct(rb_node, xmlNode, node);

  return (xmlXPathNodeSetContains(node_set, node) ? Qtrue : Qfalse);
}


/*
 * call-seq:
 *  |(node_set)
 *
 * Returns a new set built by merging the set and the elements of the given
 * set.
 */
static VALUE set_union(VALUE self, VALUE rb_other)
{
  xmlNodeSetPtr node_set, other;
  xmlNodeSetPtr new;

  if(!rb_obj_is_kind_of(rb_other, cNokogiriXmlNodeSet))
    rb_raise(rb_eArgError, "node_set must be a Nokogiri::XML::NodeSet");

  Data_Get_Struct(self, xmlNodeSet, node_set);
  Data_Get_Struct(rb_other, xmlNodeSet, other);

  new = xmlXPathNodeSetMerge(NULL, node_set);
  new = xmlXPathNodeSetMerge(new, other);

  return Nokogiri_wrap_xml_node_set(new, rb_iv_get(self, "@document"));
}

/*
 * call-seq:
 *  -(node_set)
 *
 *  Difference - returns a new NodeSet that is a copy of this NodeSet, removing
 *  each item that also appears in +node_set+
 */
static VALUE minus(VALUE self, VALUE rb_other)
{
  xmlNodeSetPtr node_set, other;
  xmlNodeSetPtr new;
  int j ;

  if(!rb_obj_is_kind_of(rb_other, cNokogiriXmlNodeSet))
    rb_raise(rb_eArgError, "node_set must be a Nokogiri::XML::NodeSet");

  Data_Get_Struct(self, xmlNodeSet, node_set);
  Data_Get_Struct(rb_other, xmlNodeSet, other);

  new = xmlXPathNodeSetMerge(NULL, node_set);
  for (j = 0 ; j < other->nodeNr ; ++j) {
    xpath_node_set_del(new, other->nodeTab[j]);
  }

  return Nokogiri_wrap_xml_node_set(new, rb_iv_get(self, "@document"));
}


static VALUE index_at(VALUE self, long offset)
{
  xmlNodeSetPtr node_set;

  Data_Get_Struct(self, xmlNodeSet, node_set);

  if (offset >= node_set->nodeNr || abs((int)offset) > node_set->nodeNr) {
    return Qnil;
  }

  if (offset < 0) { offset += node_set->nodeNr ; }

  return Nokogiri_wrap_xml_node_set_node(node_set->nodeTab[offset], self);
}

static VALUE subseq(VALUE self, long beg, long len)
{
  long j;
  xmlNodeSetPtr node_set;
  xmlNodeSetPtr new_set ;

  Data_Get_Struct(self, xmlNodeSet, node_set);

  if (beg > node_set->nodeNr) return Qnil ;
  if (beg < 0 || len < 0) return Qnil ;

  if ((beg + len) > node_set->nodeNr) {
    len = node_set->nodeNr - beg ;
  }

  new_set = xmlXPathNodeSetCreate(NULL);
  for (j = beg ; j < beg+len ; ++j) {
    xmlXPathNodeSetAddUnique(new_set, node_set->nodeTab[j]);
  }
  return Nokogiri_wrap_xml_node_set(new_set, rb_iv_get(self, "@document"));
}

/*
 * call-seq:
 *  [index] -> Node or nil
 *  [start, length] -> NodeSet or nil
 *  [range] -> NodeSet or nil
 *  slice(index) -> Node or nil
 *  slice(start, length) -> NodeSet or nil
 *  slice(range) -> NodeSet or nil
 *
 * Element reference - returns the node at +index+, or returns a NodeSet
 * containing nodes starting at +start+ and continuing for +length+ elements, or
 * returns a NodeSet containing nodes specified by +range+. Negative +indices+
 * count backward from the end of the +node_set+ (-1 is the last node). Returns
 * nil if the +index+ (or +start+) are out of range.
 */
static VALUE slice(int argc, VALUE *argv, VALUE self)
{
  VALUE arg ;
  long beg, len ;
  xmlNodeSetPtr node_set;

  Data_Get_Struct(self, xmlNodeSet, node_set);

  if (argc == 2) {
    beg = NUM2LONG(argv[0]);
    len = NUM2LONG(argv[1]);
    if (beg < 0) {
      beg += node_set->nodeNr ;
    }
    return subseq(self, beg, len);
  }

  if (argc != 1) {
    rb_scan_args(argc, argv, "11", NULL, NULL);
  }
  arg = argv[0];

  if (FIXNUM_P(arg)) {
    return index_at(self, FIX2LONG(arg));
  }

  /* if arg is Range */
  switch (rb_range_beg_len(arg, &beg, &len, (long)node_set->nodeNr, 0)) {
  case Qfalse:
    break;
  case Qnil:
    return Qnil;
  default:
    return subseq(self, beg, len);
  }

  return index_at(self, NUM2LONG(arg));
}


/*
 * call-seq:
 *  to_a
 *
 * Return this list as an Array
 */
static VALUE to_array(VALUE self, VALUE rb_node)
{
  xmlNodeSetPtr node_set ;
  VALUE list;
  int i;

  Data_Get_Struct(self, xmlNodeSet, node_set);

  list = rb_ary_new2(node_set->nodeNr);
  for(i = 0; i < node_set->nodeNr; i++) {
    VALUE elt = Nokogiri_wrap_xml_node_set_node(node_set->nodeTab[i], self);
    rb_ary_push( list, elt );
  }

  return list;
}

/*
 *  call-seq:
 *    unlink
 *
 * Unlink this NodeSet and all Node objects it contains from their current context.
 */
static VALUE unlink_nodeset(VALUE self)
{
  xmlNodeSetPtr node_set;
  int j, nodeNr ;

  Data_Get_Struct(self, xmlNodeSet, node_set);

  nodeNr = node_set->nodeNr ;
  for (j = 0 ; j < nodeNr ; j++) {
    if (! Nokogiri_namespace_eh(node_set->nodeTab[j])) {
      VALUE node ;
      xmlNodePtr node_ptr;
      node = Nokogiri_wrap_xml_node(Qnil, node_set->nodeTab[j]);
      rb_funcall(node, rb_intern("unlink"), 0); /* modifies the C struct out from under the object */
      Data_Get_Struct(node, xmlNode, node_ptr);
      node_set->nodeTab[j] = node_ptr ;
    }
  }
  return self ;
}


static void reify_node_set_namespaces(VALUE self)
{
  /*
   *  as mentioned in deallocate() above, xmlNs structs returned in an XPath
   *  NodeSet are duplicates, and we don't clean them up at deallocate() time.
   *
   *  as a result, we need to make sure the Ruby manages this memory. we do this
   *  by forcing the creation of a Ruby object wrapped around the xmlNs.
   *
   *  we also have to make sure that the NodeSet has a reference to the
   *  Namespace object, otherwise GC will kick in and the Namespace won't be
   *  marked.
   *
   *  we *could* do this safely with *all* the nodes in the NodeSet, but we only
   *  *need* to do it for xmlNs structs, and so you get the code we have here.
   */
  int j ;
  xmlNodeSetPtr node_set ;
  VALUE namespace_cache ;

  Data_Get_Struct(self, xmlNodeSet, node_set);

  namespace_cache = rb_iv_get(self, "@namespace_cache");

  for (j = 0 ; j < node_set->nodeNr ; j++) {
    if (Nokogiri_namespace_eh(node_set->nodeTab[j])) {
      rb_ary_push(namespace_cache, Nokogiri_wrap_xml_node_set_node(node_set->nodeTab[j], self));
    }
  }
}


VALUE Nokogiri_wrap_xml_node_set(xmlNodeSetPtr node_set, VALUE document)
{
  VALUE new_set ;

  if (node_set == NULL) {
    node_set = xmlXPathNodeSetCreate(NULL);
  }

  new_set = Data_Wrap_Struct(cNokogiriXmlNodeSet, 0, deallocate, node_set);

  if (!NIL_P(document)) {
    rb_iv_set(new_set, "@document", document);
    rb_funcall(document, decorate, 1, new_set);
  }

  rb_iv_set(new_set, "@namespace_cache", rb_ary_new());
  reify_node_set_namespaces(new_set);

  return new_set ;
}

VALUE Nokogiri_wrap_xml_node_set_node(xmlNodePtr node, VALUE node_set)
{
  xmlDocPtr document ;

  if (Nokogiri_namespace_eh(node)) {
    Data_Get_Struct(rb_iv_get(node_set, "@document"), xmlDoc, document);
    return Nokogiri_wrap_xml_namespace(document, (xmlNsPtr)node);
  } else {
    return Nokogiri_wrap_xml_node(Qnil, node);
  }
}


static void xpath_node_set_del(xmlNodeSetPtr cur, xmlNodePtr val)
{
  /*
   * as mentioned a few times above, we do not want to free xmlNs structs
   * outside of the Namespace lifecycle.
   *
   * xmlXPathNodeSetDel() frees xmlNs structs, and so here we reproduce that
   * function with the xmlNs logic.
   */
  int i;

  if (cur == NULL) return;
  if (val == NULL) return;

  /*
   * find node in nodeTab
   */
  for (i = 0;i < cur->nodeNr;i++)
    if (cur->nodeTab[i] == val) break;

  if (i >= cur->nodeNr) {	/* not found */
    return;
  }
  cur->nodeNr--;
  for (;i < cur->nodeNr;i++)
    cur->nodeTab[i] = cur->nodeTab[i + 1];
  cur->nodeTab[cur->nodeNr] = NULL;
}


VALUE cNokogiriXmlNodeSet ;
void init_xml_node_set(void)
{
  VALUE nokogiri = rb_define_module("Nokogiri");
  VALUE xml      = rb_define_module_under(nokogiri, "XML");
  VALUE klass    = rb_define_class_under(xml, "NodeSet", rb_cObject);
  cNokogiriXmlNodeSet = klass;

  rb_define_alloc_func(klass, allocate);
  rb_define_method(klass, "length", length, 0);
  rb_define_method(klass, "[]", slice, -1);
  rb_define_method(klass, "slice", slice, -1);
  rb_define_method(klass, "push", push, 1);
  rb_define_method(klass, "|", set_union, 1);
  rb_define_method(klass, "-", minus, 1);
  rb_define_method(klass, "unlink", unlink_nodeset, 0);
  rb_define_method(klass, "to_a", to_array, 0);
  rb_define_method(klass, "dup", duplicate, 0);
  rb_define_method(klass, "delete", delete, 1);
  rb_define_method(klass, "&", intersection, 1);
  rb_define_method(klass, "include?", include_eh, 1);

  decorate = rb_intern("decorate");
}

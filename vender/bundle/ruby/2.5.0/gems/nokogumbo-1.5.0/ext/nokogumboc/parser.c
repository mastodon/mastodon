// Copyright 2010 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Author: jdtang@google.com (Jonathan Tang)

#include <assert.h>
#include <ctype.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

#include "attribute.h"
#include "error.h"
#include "gumbo.h"
#include "insertion_mode.h"
#include "parser.h"
#include "tokenizer.h"
#include "tokenizer_states.h"
#include "utf8.h"
#include "util.h"
#include "vector.h"

#define AVOID_UNUSED_VARIABLE_WARNING(i) (void)(i)

#define GUMBO_STRING(literal) \
  { literal, sizeof(literal) - 1 }
#define TERMINATOR \
  { "", 0 }

typedef char gumbo_tagset[GUMBO_TAG_LAST];
#define TAG(tag) [GUMBO_TAG_##tag] = (1 << GUMBO_NAMESPACE_HTML)
#define TAG_SVG(tag) [GUMBO_TAG_##tag] = (1 << GUMBO_NAMESPACE_SVG)
#define TAG_MATHML(tag) [GUMBO_TAG_##tag] = (1 << GUMBO_NAMESPACE_MATHML)

#define TAGSET_INCLUDES(tagset, namespace, tag) \
  (tag < GUMBO_TAG_LAST && tagset[(int) tag] == (1 << (int) namespace))

// selected forward declarations as it is getting hard to find
// an appropriate order
static bool node_html_tag_is(const GumboNode*, GumboTag);
static GumboInsertionMode get_current_template_insertion_mode(
    const GumboParser*);
static bool handle_in_template(GumboParser*, GumboToken*);
static void destroy_node(GumboParser*, GumboNode*);

static void* malloc_wrapper(void* unused, size_t size) { return malloc(size); }

static void free_wrapper(void* unused, void* ptr) { free(ptr); }

const GumboOptions kGumboDefaultOptions = {&malloc_wrapper, &free_wrapper, NULL,
    8, false, -1, GUMBO_TAG_LAST, GUMBO_NAMESPACE_HTML};

static const GumboStringPiece kDoctypeHtml = GUMBO_STRING("html");
static const GumboStringPiece kPublicIdHtml4_0 =
    GUMBO_STRING("-//W3C//DTD HTML 4.0//EN");
static const GumboStringPiece kPublicIdHtml4_01 =
    GUMBO_STRING("-//W3C//DTD HTML 4.01//EN");
static const GumboStringPiece kPublicIdXhtml1_0 =
    GUMBO_STRING("-//W3C//DTD XHTML 1.0 Strict//EN");
static const GumboStringPiece kPublicIdXhtml1_1 =
    GUMBO_STRING("-//W3C//DTD XHTML 1.1//EN");
static const GumboStringPiece kSystemIdRecHtml4_0 =
    GUMBO_STRING("http://www.w3.org/TR/REC-html40/strict.dtd");
static const GumboStringPiece kSystemIdHtml4 =
    GUMBO_STRING("http://www.w3.org/TR/html4/strict.dtd");
static const GumboStringPiece kSystemIdXhtmlStrict1_1 =
    GUMBO_STRING("http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd");
static const GumboStringPiece kSystemIdXhtml1_1 =
    GUMBO_STRING("http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd");
static const GumboStringPiece kSystemIdLegacyCompat =
    GUMBO_STRING("about:legacy-compat");

// The doctype arrays have an explicit terminator because we want to pass them
// to a helper function, and passing them as a pointer discards sizeof
// information.  The SVG arrays are used only by one-off functions, and so loops
// over them use sizeof directly instead of a terminator.

static const GumboStringPiece kQuirksModePublicIdPrefixes[] = {
    GUMBO_STRING("+//Silmaril//dtd html Pro v0r11 19970101//"),
    GUMBO_STRING("-//AdvaSoft Ltd//DTD HTML 3.0 asWedit + extensions//"),
    GUMBO_STRING("-//AS//DTD HTML 3.0 asWedit + extensions//"),
    GUMBO_STRING("-//IETF//DTD HTML 2.0 Level 1//"),
    GUMBO_STRING("-//IETF//DTD HTML 2.0 Level 2//"),
    GUMBO_STRING("-//IETF//DTD HTML 2.0 Strict Level 1//"),
    GUMBO_STRING("-//IETF//DTD HTML 2.0 Strict Level 2//"),
    GUMBO_STRING("-//IETF//DTD HTML 2.0 Strict//"),
    GUMBO_STRING("-//IETF//DTD HTML 2.0//"),
    GUMBO_STRING("-//IETF//DTD HTML 2.1E//"),
    GUMBO_STRING("-//IETF//DTD HTML 3.0//"),
    GUMBO_STRING("-//IETF//DTD HTML 3.2 Final//"),
    GUMBO_STRING("-//IETF//DTD HTML 3.2//"),
    GUMBO_STRING("-//IETF//DTD HTML 3//"),
    GUMBO_STRING("-//IETF//DTD HTML Level 0//"),
    GUMBO_STRING("-//IETF//DTD HTML Level 1//"),
    GUMBO_STRING("-//IETF//DTD HTML Level 2//"),
    GUMBO_STRING("-//IETF//DTD HTML Level 3//"),
    GUMBO_STRING("-//IETF//DTD HTML Strict Level 0//"),
    GUMBO_STRING("-//IETF//DTD HTML Strict Level 1//"),
    GUMBO_STRING("-//IETF//DTD HTML Strict Level 2//"),
    GUMBO_STRING("-//IETF//DTD HTML Strict Level 3//"),
    GUMBO_STRING("-//IETF//DTD HTML Strict//"),
    GUMBO_STRING("-//IETF//DTD HTML//"),
    GUMBO_STRING("-//Metrius//DTD Metrius Presentational//"),
    GUMBO_STRING("-//Microsoft//DTD Internet Explorer 2.0 HTML Strict//"),
    GUMBO_STRING("-//Microsoft//DTD Internet Explorer 2.0 HTML//"),
    GUMBO_STRING("-//Microsoft//DTD Internet Explorer 2.0 Tables//"),
    GUMBO_STRING("-//Microsoft//DTD Internet Explorer 3.0 HTML Strict//"),
    GUMBO_STRING("-//Microsoft//DTD Internet Explorer 3.0 HTML//"),
    GUMBO_STRING("-//Microsoft//DTD Internet Explorer 3.0 Tables//"),
    GUMBO_STRING("-//Netscape Comm. Corp.//DTD HTML//"),
    GUMBO_STRING("-//Netscape Comm. Corp.//DTD Strict HTML//"),
    GUMBO_STRING("-//O'Reilly and Associates//DTD HTML 2.0//"),
    GUMBO_STRING("-//O'Reilly and Associates//DTD HTML Extended 1.0//"),
    GUMBO_STRING("-//O'Reilly and Associates//DTD HTML Extended Relaxed 1.0//"),
    GUMBO_STRING(
        "-//SoftQuad Software//DTD HoTMetaL PRO 6.0::19990601::)"
        "extensions to HTML 4.0//"),
    GUMBO_STRING(
        "-//SoftQuad//DTD HoTMetaL PRO 4.0::19971010::"
        "extensions to HTML 4.0//"),
    GUMBO_STRING("-//Spyglass//DTD HTML 2.0 Extended//"),
    GUMBO_STRING("-//SQ//DTD HTML 2.0 HoTMetaL + extensions//"),
    GUMBO_STRING("-//Sun Microsystems Corp.//DTD HotJava HTML//"),
    GUMBO_STRING("-//Sun Microsystems Corp.//DTD HotJava Strict HTML//"),
    GUMBO_STRING("-//W3C//DTD HTML 3 1995-03-24//"),
    GUMBO_STRING("-//W3C//DTD HTML 3.2 Draft//"),
    GUMBO_STRING("-//W3C//DTD HTML 3.2 Final//"),
    GUMBO_STRING("-//W3C//DTD HTML 3.2//"),
    GUMBO_STRING("-//W3C//DTD HTML 3.2S Draft//"),
    GUMBO_STRING("-//W3C//DTD HTML 4.0 Frameset//"),
    GUMBO_STRING("-//W3C//DTD HTML 4.0 Transitional//"),
    GUMBO_STRING("-//W3C//DTD HTML Experimental 19960712//"),
    GUMBO_STRING("-//W3C//DTD HTML Experimental 970421//"),
    GUMBO_STRING("-//W3C//DTD W3 HTML//"),
    GUMBO_STRING("-//W3O//DTD W3 HTML 3.0//"),
    GUMBO_STRING("-//WebTechs//DTD Mozilla HTML 2.0//"),
    GUMBO_STRING("-//WebTechs//DTD Mozilla HTML//"), TERMINATOR};

static const GumboStringPiece kQuirksModePublicIdExactMatches[] = {
    GUMBO_STRING("-//W3O//DTD W3 HTML Strict 3.0//EN//"),
    GUMBO_STRING("-/W3C/DTD HTML 4.0 Transitional/EN"), GUMBO_STRING("HTML"),
    TERMINATOR};

static const GumboStringPiece kQuirksModeSystemIdExactMatches[] = {
    GUMBO_STRING("http://www.ibm.com/data/dtd/v11/ibmxhtml1-transitional.dtd"),
    TERMINATOR};

static const GumboStringPiece kLimitedQuirksPublicIdPrefixes[] = {
    GUMBO_STRING("-//W3C//DTD XHTML 1.0 Frameset//"),
    GUMBO_STRING("-//W3C//DTD XHTML 1.0 Transitional//"), TERMINATOR};

static const GumboStringPiece kLimitedQuirksRequiresSystemIdPublicIdPrefixes[] =
    {GUMBO_STRING("-//W3C//DTD HTML 4.01 Frameset//"),
        GUMBO_STRING("-//W3C//DTD HTML 4.01 Transitional//"), TERMINATOR};

// Indexed by GumboNamespaceEnum; keep in sync with that.
static const char* kLegalXmlns[] = {"http://www.w3.org/1999/xhtml",
    "http://www.w3.org/2000/svg", "http://www.w3.org/1998/Math/MathML"};

typedef struct _ReplacementEntry {
  const GumboStringPiece from;
  const GumboStringPiece to;
} ReplacementEntry;

#define REPLACEMENT_ENTRY(from, to) \
  { GUMBO_STRING(from), GUMBO_STRING(to) }

// Static data for SVG attribute replacements.
// https://html.spec.whatwg.org/multipage/syntax.html#creating-and-inserting-nodes
static const ReplacementEntry kSvgAttributeReplacements[] = {
    REPLACEMENT_ENTRY("attributename", "attributeName"),
    REPLACEMENT_ENTRY("attributetype", "attributeType"),
    REPLACEMENT_ENTRY("basefrequency", "baseFrequency"),
    REPLACEMENT_ENTRY("baseprofile", "baseProfile"),
    REPLACEMENT_ENTRY("calcmode", "calcMode"),
    REPLACEMENT_ENTRY("clippathunits", "clipPathUnits"),
    // REPLACEMENT_ENTRY("contentscripttype", "contentScriptType"),
    // REPLACEMENT_ENTRY("contentstyletype", "contentStyleType"),
    REPLACEMENT_ENTRY("diffuseconstant", "diffuseConstant"),
    REPLACEMENT_ENTRY("edgemode", "edgeMode"),
    // REPLACEMENT_ENTRY("externalresourcesrequired",
    // "externalResourcesRequired"),
    // REPLACEMENT_ENTRY("filterres", "filterRes"),
    REPLACEMENT_ENTRY("filterunits", "filterUnits"),
    REPLACEMENT_ENTRY("glyphref", "glyphRef"),
    REPLACEMENT_ENTRY("gradienttransform", "gradientTransform"),
    REPLACEMENT_ENTRY("gradientunits", "gradientUnits"),
    REPLACEMENT_ENTRY("kernelmatrix", "kernelMatrix"),
    REPLACEMENT_ENTRY("kernelunitlength", "kernelUnitLength"),
    REPLACEMENT_ENTRY("keypoints", "keyPoints"),
    REPLACEMENT_ENTRY("keysplines", "keySplines"),
    REPLACEMENT_ENTRY("keytimes", "keyTimes"),
    REPLACEMENT_ENTRY("lengthadjust", "lengthAdjust"),
    REPLACEMENT_ENTRY("limitingconeangle", "limitingConeAngle"),
    REPLACEMENT_ENTRY("markerheight", "markerHeight"),
    REPLACEMENT_ENTRY("markerunits", "markerUnits"),
    REPLACEMENT_ENTRY("markerwidth", "markerWidth"),
    REPLACEMENT_ENTRY("maskcontentunits", "maskContentUnits"),
    REPLACEMENT_ENTRY("maskunits", "maskUnits"),
    REPLACEMENT_ENTRY("numoctaves", "numOctaves"),
    REPLACEMENT_ENTRY("pathlength", "pathLength"),
    REPLACEMENT_ENTRY("patterncontentunits", "patternContentUnits"),
    REPLACEMENT_ENTRY("patterntransform", "patternTransform"),
    REPLACEMENT_ENTRY("patternunits", "patternUnits"),
    REPLACEMENT_ENTRY("pointsatx", "pointsAtX"),
    REPLACEMENT_ENTRY("pointsaty", "pointsAtY"),
    REPLACEMENT_ENTRY("pointsatz", "pointsAtZ"),
    REPLACEMENT_ENTRY("preservealpha", "preserveAlpha"),
    REPLACEMENT_ENTRY("preserveaspectratio", "preserveAspectRatio"),
    REPLACEMENT_ENTRY("primitiveunits", "primitiveUnits"),
    REPLACEMENT_ENTRY("refx", "refX"), REPLACEMENT_ENTRY("refy", "refY"),
    REPLACEMENT_ENTRY("repeatcount", "repeatCount"),
    REPLACEMENT_ENTRY("repeatdur", "repeatDur"),
    REPLACEMENT_ENTRY("requiredextensions", "requiredExtensions"),
    REPLACEMENT_ENTRY("requiredfeatures", "requiredFeatures"),
    REPLACEMENT_ENTRY("specularconstant", "specularConstant"),
    REPLACEMENT_ENTRY("specularexponent", "specularExponent"),
    REPLACEMENT_ENTRY("spreadmethod", "spreadMethod"),
    REPLACEMENT_ENTRY("startoffset", "startOffset"),
    REPLACEMENT_ENTRY("stddeviation", "stdDeviation"),
    REPLACEMENT_ENTRY("stitchtiles", "stitchTiles"),
    REPLACEMENT_ENTRY("surfacescale", "surfaceScale"),
    REPLACEMENT_ENTRY("systemlanguage", "systemLanguage"),
    REPLACEMENT_ENTRY("tablevalues", "tableValues"),
    REPLACEMENT_ENTRY("targetx", "targetX"),
    REPLACEMENT_ENTRY("targety", "targetY"),
    REPLACEMENT_ENTRY("textlength", "textLength"),
    REPLACEMENT_ENTRY("viewbox", "viewBox"),
    REPLACEMENT_ENTRY("viewtarget", "viewTarget"),
    REPLACEMENT_ENTRY("xchannelselector", "xChannelSelector"),
    REPLACEMENT_ENTRY("ychannelselector", "yChannelSelector"),
    REPLACEMENT_ENTRY("zoomandpan", "zoomAndPan"),
};

static const ReplacementEntry kSvgTagReplacements[] = {
    REPLACEMENT_ENTRY("altglyph", "altGlyph"),
    REPLACEMENT_ENTRY("altglyphdef", "altGlyphDef"),
    REPLACEMENT_ENTRY("altglyphitem", "altGlyphItem"),
    REPLACEMENT_ENTRY("animatecolor", "animateColor"),
    REPLACEMENT_ENTRY("animatemotion", "animateMotion"),
    REPLACEMENT_ENTRY("animatetransform", "animateTransform"),
    REPLACEMENT_ENTRY("clippath", "clipPath"),
    REPLACEMENT_ENTRY("feblend", "feBlend"),
    REPLACEMENT_ENTRY("fecolormatrix", "feColorMatrix"),
    REPLACEMENT_ENTRY("fecomponenttransfer", "feComponentTransfer"),
    REPLACEMENT_ENTRY("fecomposite", "feComposite"),
    REPLACEMENT_ENTRY("feconvolvematrix", "feConvolveMatrix"),
    REPLACEMENT_ENTRY("fediffuselighting", "feDiffuseLighting"),
    REPLACEMENT_ENTRY("fedisplacementmap", "feDisplacementMap"),
    REPLACEMENT_ENTRY("fedistantlight", "feDistantLight"),
    REPLACEMENT_ENTRY("feflood", "feFlood"),
    REPLACEMENT_ENTRY("fefunca", "feFuncA"),
    REPLACEMENT_ENTRY("fefuncb", "feFuncB"),
    REPLACEMENT_ENTRY("fefuncg", "feFuncG"),
    REPLACEMENT_ENTRY("fefuncr", "feFuncR"),
    REPLACEMENT_ENTRY("fegaussianblur", "feGaussianBlur"),
    REPLACEMENT_ENTRY("feimage", "feImage"),
    REPLACEMENT_ENTRY("femerge", "feMerge"),
    REPLACEMENT_ENTRY("femergenode", "feMergeNode"),
    REPLACEMENT_ENTRY("femorphology", "feMorphology"),
    REPLACEMENT_ENTRY("feoffset", "feOffset"),
    REPLACEMENT_ENTRY("fepointlight", "fePointLight"),
    REPLACEMENT_ENTRY("fespecularlighting", "feSpecularLighting"),
    REPLACEMENT_ENTRY("fespotlight", "feSpotLight"),
    REPLACEMENT_ENTRY("fetile", "feTile"),
    REPLACEMENT_ENTRY("feturbulence", "feTurbulence"),
    REPLACEMENT_ENTRY("foreignobject", "foreignObject"),
    REPLACEMENT_ENTRY("glyphref", "glyphRef"),
    REPLACEMENT_ENTRY("lineargradient", "linearGradient"),
    REPLACEMENT_ENTRY("radialgradient", "radialGradient"),
    REPLACEMENT_ENTRY("textpath", "textPath"),
};

typedef struct _NamespacedAttributeReplacement {
  const char* from;
  const char* local_name;
  const GumboAttributeNamespaceEnum attr_namespace;
} NamespacedAttributeReplacement;

static const NamespacedAttributeReplacement kForeignAttributeReplacements[] = {
    {"xlink:actuate", "actuate", GUMBO_ATTR_NAMESPACE_XLINK},
    {"xlink:actuate", "actuate", GUMBO_ATTR_NAMESPACE_XLINK},
    {"xlink:href", "href", GUMBO_ATTR_NAMESPACE_XLINK},
    {"xlink:role", "role", GUMBO_ATTR_NAMESPACE_XLINK},
    {"xlink:show", "show", GUMBO_ATTR_NAMESPACE_XLINK},
    {"xlink:title", "title", GUMBO_ATTR_NAMESPACE_XLINK},
    {"xlink:type", "type", GUMBO_ATTR_NAMESPACE_XLINK},
    {"xml:base", "base", GUMBO_ATTR_NAMESPACE_XML},
    {"xml:lang", "lang", GUMBO_ATTR_NAMESPACE_XML},
    {"xml:space", "space", GUMBO_ATTR_NAMESPACE_XML},
    {"xmlns", "xmlns", GUMBO_ATTR_NAMESPACE_XMLNS},
    {"xmlns:xlink", "xlink", GUMBO_ATTR_NAMESPACE_XMLNS},
};

// The "scope marker" for the list of active formatting elements.  We use a
// pointer to this as a generic marker element, since the particular element
// scope doesn't matter.
static const GumboNode kActiveFormattingScopeMarker;

// The tag_is and tag_in function use true & false to denote start & end tags,
// but for readability, we define constants for them here.
static const bool kStartTag = true;
static const bool kEndTag = false;

// Because GumboStringPieces are immutable, we can't insert a character directly
// into a text node.  Instead, we accumulate all pending characters here and
// flush them out to a text node whenever a new element is inserted.
//
// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#insert-a-character
typedef struct _TextNodeBufferState {
  // The accumulated text to be inserted into the current text node.
  GumboStringBuffer _buffer;

  // A pointer to the original text represented by this text node.  Note that
  // because of foster parenting and other strange DOM manipulations, this may
  // include other non-text HTML tags in it; it is defined as the span of
  // original text from the first character in this text node to the last
  // character in this text node.
  const char* _start_original_text;

  // The source position of the start of this text node.
  GumboSourcePosition _start_position;

  // The type of node that will be inserted (TEXT, CDATA, or WHITESPACE).
  GumboNodeType _type;
} TextNodeBufferState;

typedef struct GumboInternalParserState {
  // http://www.whatwg.org/specs/web-apps/current-work/complete/parsing.html#insertion-mode
  GumboInsertionMode _insertion_mode;

  // Used for run_generic_parsing_algorithm, which needs to switch back to the
  // original insertion mode at its conclusion.
  GumboInsertionMode _original_insertion_mode;

  // http://www.whatwg.org/specs/web-apps/current-work/complete/parsing.html#the-stack-of-open-elements
  GumboVector /*GumboNode*/ _open_elements;

  // http://www.whatwg.org/specs/web-apps/current-work/complete/parsing.html#the-list-of-active-formatting-elements
  GumboVector /*GumboNode*/ _active_formatting_elements;

  // The stack of template insertion modes.
  // http://www.whatwg.org/specs/web-apps/current-work/multipage/parsing.html#the-insertion-mode
  GumboVector /*InsertionMode*/ _template_insertion_modes;

  // http://www.whatwg.org/specs/web-apps/current-work/complete/parsing.html#the-element-pointers
  GumboNode* _head_element;
  GumboNode* _form_element;

  // The element used as fragment context when parsing in fragment mode
  GumboNode* _fragment_ctx;

  // The flag for when the spec says "Reprocess the current token in..."
  bool _reprocess_current_token;

  // The flag for "acknowledge the token's self-closing flag".
  bool _self_closing_flag_acknowledged;

  // The "frameset-ok" flag from the spec.
  bool _frameset_ok;

  // The flag for "If the next token is a LINE FEED, ignore that token...".
  bool _ignore_next_linefeed;

  // The flag for "whenever a node would be inserted into the current node, it
  // must instead be foster parented".  This is used for misnested table
  // content, which needs to be handled according to "in body" rules yet foster
  // parented outside of the table.
  // It would perhaps be more explicit to have this as a parameter to
  // handle_in_body and insert_element, but given how special-purpose this is
  // and the number of call-sites that would need to take the extra parameter,
  // it's easier just to have a state flag.
  bool _foster_parent_insertions;

  // The accumulated text node buffer state.
  TextNodeBufferState _text_node;

  // The current token.
  GumboToken* _current_token;

  // The way that the spec is written, the </body> and </html> tags are *always*
  // implicit, because encountering one of those tokens merely switches the
  // insertion mode out of "in body".  So we have individual state flags for
  // those end tags that are then inspected by pop_current_node when the <body>
  // and <html> nodes are popped to set the GUMBO_INSERTION_IMPLICIT_END_TAG
  // flag appropriately.
  bool _closed_body_tag;
  bool _closed_html_tag;
} GumboParserState;

static bool token_has_attribute(const GumboToken* token, const char* name) {
  assert(token->type == GUMBO_TOKEN_START_TAG);
  return gumbo_get_attribute(&token->v.start_tag.attributes, name) != NULL;
}

// Checks if the value of the specified attribute is a case-insensitive match
// for the specified string.
static bool attribute_matches(
    const GumboVector* attributes, const char* name, const char* value) {
  const GumboAttribute* attr = gumbo_get_attribute(attributes, name);
  return attr ? strcasecmp(value, attr->value) == 0 : false;
}

// Checks if the value of the specified attribute is a case-sensitive match
// for the specified string.
static bool attribute_matches_case_sensitive(
    const GumboVector* attributes, const char* name, const char* value) {
  const GumboAttribute* attr = gumbo_get_attribute(attributes, name);
  return attr ? strcmp(value, attr->value) == 0 : false;
}

// Checks if the specified attribute vectors are identical.
static bool all_attributes_match(
    const GumboVector* attr1, const GumboVector* attr2) {
  unsigned int num_unmatched_attr2_elements = attr2->length;
  for (unsigned int i = 0; i < attr1->length; ++i) {
    const GumboAttribute* attr = attr1->data[i];
    if (attribute_matches_case_sensitive(attr2, attr->name, attr->value)) {
      --num_unmatched_attr2_elements;
    } else {
      return false;
    }
  }
  return num_unmatched_attr2_elements == 0;
}

static void set_frameset_not_ok(GumboParser* parser) {
  gumbo_debug("Setting frameset_ok to false.\n");
  parser->_parser_state->_frameset_ok = false;
}

static GumboNode* create_node(GumboParser* parser, GumboNodeType type) {
  GumboNode* node = gumbo_parser_allocate(parser, sizeof(GumboNode));
  node->parent = NULL;
  node->index_within_parent = -1;
  node->type = type;
  node->parse_flags = GUMBO_INSERTION_NORMAL;
  return node;
}

static GumboNode* new_document_node(GumboParser* parser) {
  GumboNode* document_node = create_node(parser, GUMBO_NODE_DOCUMENT);
  document_node->parse_flags = GUMBO_INSERTION_BY_PARSER;
  gumbo_vector_init(parser, 1, &document_node->v.document.children);

  // Must be initialized explicitly, as there's no guarantee that we'll see a
  // doc type token.
  GumboDocument* document = &document_node->v.document;
  document->has_doctype = false;
  document->name = NULL;
  document->public_identifier = NULL;
  document->system_identifier = NULL;
  return document_node;
}

static void output_init(GumboParser* parser) {
  GumboOutput* output = gumbo_parser_allocate(parser, sizeof(GumboOutput));
  output->root = NULL;
  output->document = new_document_node(parser);
  parser->_output = output;
  gumbo_init_errors(parser);
}

static void parser_state_init(GumboParser* parser) {
  GumboParserState* parser_state =
      gumbo_parser_allocate(parser, sizeof(GumboParserState));
  parser_state->_insertion_mode = GUMBO_INSERTION_MODE_INITIAL;
  parser_state->_reprocess_current_token = false;
  parser_state->_frameset_ok = true;
  parser_state->_ignore_next_linefeed = false;
  parser_state->_foster_parent_insertions = false;
  parser_state->_text_node._type = GUMBO_NODE_WHITESPACE;
  gumbo_string_buffer_init(parser, &parser_state->_text_node._buffer);
  gumbo_vector_init(parser, 10, &parser_state->_open_elements);
  gumbo_vector_init(parser, 5, &parser_state->_active_formatting_elements);
  gumbo_vector_init(parser, 5, &parser_state->_template_insertion_modes);
  parser_state->_head_element = NULL;
  parser_state->_form_element = NULL;
  parser_state->_fragment_ctx = NULL;
  parser_state->_current_token = NULL;
  parser_state->_closed_body_tag = false;
  parser_state->_closed_html_tag = false;
  parser->_parser_state = parser_state;
}

static void parser_state_destroy(GumboParser* parser) {
  GumboParserState* state = parser->_parser_state;
  if (state->_fragment_ctx) {
    destroy_node(parser, state->_fragment_ctx);
  }
  gumbo_vector_destroy(parser, &state->_active_formatting_elements);
  gumbo_vector_destroy(parser, &state->_open_elements);
  gumbo_vector_destroy(parser, &state->_template_insertion_modes);
  gumbo_string_buffer_destroy(parser, &state->_text_node._buffer);
  gumbo_parser_deallocate(parser, state);
}

static GumboNode* get_document_node(GumboParser* parser) {
  return parser->_output->document;
}

static bool is_fragment_parser(const GumboParser* parser) {
  return !!parser->_parser_state->_fragment_ctx;
}

// Returns the node at the bottom of the stack of open elements, or NULL if no
// elements have been added yet.
static GumboNode* get_current_node(GumboParser* parser) {
  GumboVector* open_elements = &parser->_parser_state->_open_elements;
  if (open_elements->length == 0) {
    assert(!parser->_output->root);
    return NULL;
  }
  assert(open_elements->length > 0);
  assert(open_elements->data != NULL);
  return open_elements->data[open_elements->length - 1];
}

static GumboNode* get_adjusted_current_node(GumboParser* parser) {
  GumboParserState* state = parser->_parser_state;
  if (state->_open_elements.length == 1 && state->_fragment_ctx) {
    return state->_fragment_ctx;
  }
  return get_current_node(parser);
}

// Returns true if the given needle is in the given array of literal
// GumboStringPieces.  If exact_match is true, this requires that they match
// exactly; otherwise, this performs a prefix match to check if any of the
// elements in haystack start with needle.  This always performs a
// case-insensitive match.
static bool is_in_static_list(
    const char* needle, const GumboStringPiece* haystack, bool exact_match) {
  for (unsigned int i = 0; haystack[i].length > 0; ++i) {
    if ((exact_match && !strcmp(needle, haystack[i].data)) ||
        (!exact_match && !strcasecmp(needle, haystack[i].data))) {
      return true;
    }
  }
  return false;
}

static void set_insertion_mode(GumboParser* parser, GumboInsertionMode mode) {
  parser->_parser_state->_insertion_mode = mode;
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/parsing.html#reset-the-insertion-mode-appropriately
// This is a helper function that returns the appropriate insertion mode instead
// of setting it.  Returns GUMBO_INSERTION_MODE_INITIAL as a sentinel value to
// indicate that there is no appropriate insertion mode, and the loop should
// continue.
static GumboInsertionMode get_appropriate_insertion_mode(
    const GumboParser* parser, int index) {
  const GumboVector* open_elements = &parser->_parser_state->_open_elements;
  const GumboNode* node = open_elements->data[index];
  const bool is_last = index == 0;

  if (is_last && is_fragment_parser(parser)) {
    node = parser->_parser_state->_fragment_ctx;
  }

  assert(node->type == GUMBO_NODE_ELEMENT || node->type == GUMBO_NODE_TEMPLATE);
  switch (node->v.element.tag) {
    case GUMBO_TAG_SELECT: {
      if (is_last) {
        return GUMBO_INSERTION_MODE_IN_SELECT;
      }
      for (int i = index; i > 0; --i) {
        const GumboNode* ancestor = open_elements->data[i];
        if (node_html_tag_is(ancestor, GUMBO_TAG_TEMPLATE)) {
          return GUMBO_INSERTION_MODE_IN_SELECT;
        }
        if (node_html_tag_is(ancestor, GUMBO_TAG_TABLE)) {
          return GUMBO_INSERTION_MODE_IN_SELECT_IN_TABLE;
        }
      }
      return GUMBO_INSERTION_MODE_IN_SELECT;
    }
    case GUMBO_TAG_TD:
    case GUMBO_TAG_TH:
      if (!is_last) return GUMBO_INSERTION_MODE_IN_CELL;
      break;
    case GUMBO_TAG_TR:
      return GUMBO_INSERTION_MODE_IN_ROW;
    case GUMBO_TAG_TBODY:
    case GUMBO_TAG_THEAD:
    case GUMBO_TAG_TFOOT:
      return GUMBO_INSERTION_MODE_IN_TABLE_BODY;
    case GUMBO_TAG_CAPTION:
      return GUMBO_INSERTION_MODE_IN_CAPTION;
    case GUMBO_TAG_COLGROUP:
      return GUMBO_INSERTION_MODE_IN_COLUMN_GROUP;
    case GUMBO_TAG_TABLE:
      return GUMBO_INSERTION_MODE_IN_TABLE;
    case GUMBO_TAG_TEMPLATE:
      return get_current_template_insertion_mode(parser);
    case GUMBO_TAG_HEAD:
      if (!is_last) return GUMBO_INSERTION_MODE_IN_HEAD;
      break;
    case GUMBO_TAG_BODY:
      return GUMBO_INSERTION_MODE_IN_BODY;
    case GUMBO_TAG_FRAMESET:
      return GUMBO_INSERTION_MODE_IN_FRAMESET;
    case GUMBO_TAG_HTML:
      return parser->_parser_state->_head_element
                 ? GUMBO_INSERTION_MODE_AFTER_HEAD
                 : GUMBO_INSERTION_MODE_BEFORE_HEAD;
    default:
      break;
  }
  return is_last ? GUMBO_INSERTION_MODE_IN_BODY : GUMBO_INSERTION_MODE_INITIAL;
}

// This performs the actual "reset the insertion mode" loop.
static void reset_insertion_mode_appropriately(GumboParser* parser) {
  const GumboVector* open_elements = &parser->_parser_state->_open_elements;
  for (int i = open_elements->length; --i >= 0;) {
    GumboInsertionMode mode = get_appropriate_insertion_mode(parser, i);
    if (mode != GUMBO_INSERTION_MODE_INITIAL) {
      set_insertion_mode(parser, mode);
      return;
    }
  }
  // Should never get here, because is_last will be set on the last iteration
  // and will force GUMBO_INSERTION_MODE_IN_BODY.
  assert(0);
}

static GumboError* parser_add_parse_error(
    GumboParser* parser, const GumboToken* token) {
  gumbo_debug("Adding parse error.\n");
  GumboError* error = gumbo_add_error(parser);
  if (!error) {
    return NULL;
  }
  error->type = GUMBO_ERR_PARSER;
  error->position = token->position;
  error->original_text = token->original_text.data;
  GumboParserError* extra_data = &error->v.parser;
  extra_data->input_type = token->type;
  extra_data->input_tag = GUMBO_TAG_UNKNOWN;
  if (token->type == GUMBO_TOKEN_START_TAG) {
    extra_data->input_tag = token->v.start_tag.tag;
  } else if (token->type == GUMBO_TOKEN_END_TAG) {
    extra_data->input_tag = token->v.end_tag;
  }
  GumboParserState* state = parser->_parser_state;
  extra_data->parser_state = state->_insertion_mode;
  gumbo_vector_init(
      parser, state->_open_elements.length, &extra_data->tag_stack);
  for (unsigned int i = 0; i < state->_open_elements.length; ++i) {
    const GumboNode* node = state->_open_elements.data[i];
    assert(
        node->type == GUMBO_NODE_ELEMENT || node->type == GUMBO_NODE_TEMPLATE);
    gumbo_vector_add(
        parser, (void*) node->v.element.tag, &extra_data->tag_stack);
  }
  return error;
}

// Returns true if the specified token is either a start or end tag (specified
// by is_start) with one of the tag types in the varargs list.  Terminate the
// list with GUMBO_TAG_LAST; this functions as a sentinel since no portion of
// the spec references tags that are not in the spec.
static bool tag_in(
    const GumboToken* token, bool is_start, const gumbo_tagset tags) {
  GumboTag token_tag;
  if (is_start && token->type == GUMBO_TOKEN_START_TAG) {
    token_tag = token->v.start_tag.tag;
  } else if (!is_start && token->type == GUMBO_TOKEN_END_TAG) {
    token_tag = token->v.end_tag;
  } else {
    return false;
  }
  return (token_tag < GUMBO_TAG_LAST && tags[(int) token_tag] != 0);
}

// Like tag_in, but for the single-tag case.
static bool tag_is(const GumboToken* token, bool is_start, GumboTag tag) {
  if (is_start && token->type == GUMBO_TOKEN_START_TAG) {
    return token->v.start_tag.tag == tag;
  } else if (!is_start && token->type == GUMBO_TOKEN_END_TAG) {
    return token->v.end_tag == tag;
  } else {
    return false;
  }
}

// Like tag_in, but checks for the tag of a node, rather than a token.
static bool node_tag_in_set(const GumboNode* node, const gumbo_tagset tags) {
  assert(node != NULL);
  if (node->type != GUMBO_NODE_ELEMENT && node->type != GUMBO_NODE_TEMPLATE) {
    return false;
  }
  return TAGSET_INCLUDES(
      tags, node->v.element.tag_namespace, node->v.element.tag);
}

// Like node_tag_in, but for the single-tag case.
static bool node_qualified_tag_is(
    const GumboNode* node, GumboNamespaceEnum ns, GumboTag tag) {
  assert(node);
  return (node->type == GUMBO_NODE_ELEMENT ||
             node->type == GUMBO_NODE_TEMPLATE) &&
         node->v.element.tag == tag && node->v.element.tag_namespace == ns;
}

// Like node_tag_in, but for the single-tag case in the HTML namespace
static bool node_html_tag_is(const GumboNode* node, GumboTag tag) {
  return node_qualified_tag_is(node, GUMBO_NAMESPACE_HTML, tag);
}

static void push_template_insertion_mode(
    GumboParser* parser, GumboInsertionMode mode) {
  gumbo_vector_add(
      parser, (void*) mode, &parser->_parser_state->_template_insertion_modes);
}

static void pop_template_insertion_mode(GumboParser* parser) {
  gumbo_vector_pop(parser, &parser->_parser_state->_template_insertion_modes);
}

// Returns the current template insertion mode.  If the stack of template
// insertion modes is empty, this returns GUMBO_INSERTION_MODE_INITIAL.
static GumboInsertionMode get_current_template_insertion_mode(
    const GumboParser* parser) {
  GumboVector* template_insertion_modes =
      &parser->_parser_state->_template_insertion_modes;
  if (template_insertion_modes->length == 0) {
    return GUMBO_INSERTION_MODE_INITIAL;
  }
  return (GumboInsertionMode)
      template_insertion_modes->data[(template_insertion_modes->length - 1)];
}

// http://www.whatwg.org/specs/web-apps/current-work/multipage/tree-construction.html#mathml-text-integration-point
static bool is_mathml_integration_point(const GumboNode* node) {
  return node_tag_in_set(
      node, (gumbo_tagset){TAG_MATHML(MI), TAG_MATHML(MO), TAG_MATHML(MN),
                TAG_MATHML(MS), TAG_MATHML(MTEXT)});
}

// http://www.whatwg.org/specs/web-apps/current-work/multipage/tree-construction.html#html-integration-point
static bool is_html_integration_point(const GumboNode* node) {
  return node_tag_in_set(node, (gumbo_tagset){TAG_SVG(FOREIGNOBJECT),
                                   TAG_SVG(DESC), TAG_SVG(TITLE)}) ||
         (node_qualified_tag_is(
              node, GUMBO_NAMESPACE_MATHML, GUMBO_TAG_ANNOTATION_XML) &&
             (attribute_matches(
                  &node->v.element.attributes, "encoding", "text/html") ||
                 attribute_matches(&node->v.element.attributes, "encoding",
                     "application/xhtml+xml")));
}

// This represents a place to insert a node, consisting of a target parent and a
// child index within that parent.  If the node should be inserted at the end of
// the parent's child, index will be -1.
typedef struct {
  GumboNode* target;
  int index;
} InsertionLocation;

InsertionLocation get_appropriate_insertion_location(
    GumboParser* parser, GumboNode* override_target) {
  InsertionLocation retval = {override_target, -1};
  if (retval.target == NULL) {
    // No override target; default to the current node, but special-case the
    // root node since get_current_node() assumes the stack of open elements is
    // non-empty.
    retval.target = parser->_output->root != NULL ? get_current_node(parser)
                                                  : get_document_node(parser);
  }
  if (!parser->_parser_state->_foster_parent_insertions ||
      !node_tag_in_set(retval.target, (gumbo_tagset){TAG(TABLE), TAG(TBODY),
                                          TAG(TFOOT), TAG(THEAD), TAG(TR)})) {
    return retval;
  }

  // Foster-parenting case.
  int last_template_index = -1;
  int last_table_index = -1;
  GumboVector* open_elements = &parser->_parser_state->_open_elements;
  for (unsigned int i = 0; i < open_elements->length; ++i) {
    if (node_html_tag_is(open_elements->data[i], GUMBO_TAG_TEMPLATE)) {
      last_template_index = i;
    }
    if (node_html_tag_is(open_elements->data[i], GUMBO_TAG_TABLE)) {
      last_table_index = i;
    }
  }
  if (last_template_index != -1 &&
      (last_table_index == -1 || last_template_index > last_table_index)) {
    retval.target = open_elements->data[last_template_index];
    return retval;
  }
  if (last_table_index == -1) {
    retval.target = open_elements->data[0];
    return retval;
  }
  GumboNode* last_table = open_elements->data[last_table_index];
  if (last_table->parent != NULL) {
    retval.target = last_table->parent;
    retval.index = last_table->index_within_parent;
    return retval;
  }

  retval.target = open_elements->data[last_table_index - 1];
  return retval;
}

// Appends a node to the end of its parent, setting the "parent" and
// "index_within_parent" fields appropriately.
static void append_node(
    GumboParser* parser, GumboNode* parent, GumboNode* node) {
  assert(node->parent == NULL);
  assert(node->index_within_parent == -1);
  GumboVector* children;
  if (parent->type == GUMBO_NODE_ELEMENT ||
      parent->type == GUMBO_NODE_TEMPLATE) {
    children = &parent->v.element.children;
  } else {
    assert(parent->type == GUMBO_NODE_DOCUMENT);
    children = &parent->v.document.children;
  }
  node->parent = parent;
  node->index_within_parent = children->length;
  gumbo_vector_add(parser, (void*) node, children);
  assert(node->index_within_parent < children->length);
}

// Inserts a node at the specified InsertionLocation, updating the
// "parent" and "index_within_parent" fields of it and all its siblings.
// If the index of the location is -1, this calls append_node.
static void insert_node(
    GumboParser* parser, GumboNode* node, InsertionLocation location) {
  assert(node->parent == NULL);
  assert(node->index_within_parent == -1);
  GumboNode* parent = location.target;
  int index = location.index;
  if (index != -1) {
    GumboVector* children = NULL;
    if (parent->type == GUMBO_NODE_ELEMENT ||
        parent->type == GUMBO_NODE_TEMPLATE) {
      children = &parent->v.element.children;
    } else if (parent->type == GUMBO_NODE_DOCUMENT) {
      children = &parent->v.document.children;
      assert(children->length == 0);
    } else {
      assert(0);
    }

    assert(index >= 0);
    assert((unsigned int) index < children->length);
    node->parent = parent;
    node->index_within_parent = index;
    gumbo_vector_insert_at(parser, (void*) node, index, children);
    assert(node->index_within_parent < children->length);
    for (unsigned int i = index + 1; i < children->length; ++i) {
      GumboNode* sibling = children->data[i];
      sibling->index_within_parent = i;
      assert(sibling->index_within_parent < children->length);
    }
  } else {
    append_node(parser, parent, node);
  }
}

static void maybe_flush_text_node_buffer(GumboParser* parser) {
  GumboParserState* state = parser->_parser_state;
  TextNodeBufferState* buffer_state = &state->_text_node;
  if (buffer_state->_buffer.length == 0) {
    return;
  }

  assert(buffer_state->_type == GUMBO_NODE_WHITESPACE ||
         buffer_state->_type == GUMBO_NODE_TEXT ||
         buffer_state->_type == GUMBO_NODE_CDATA);
  GumboNode* text_node = create_node(parser, buffer_state->_type);
  GumboText* text_node_data = &text_node->v.text;
  text_node_data->text =
      gumbo_string_buffer_to_string(parser, &buffer_state->_buffer);
  text_node_data->original_text.data = buffer_state->_start_original_text;
  text_node_data->original_text.length =
      state->_current_token->original_text.data -
      buffer_state->_start_original_text;
  text_node_data->start_pos = buffer_state->_start_position;

  gumbo_debug("Flushing text node buffer of %.*s.\n",
      (int) buffer_state->_buffer.length, buffer_state->_buffer.data);

  InsertionLocation location = get_appropriate_insertion_location(parser, NULL);
  if (location.target->type == GUMBO_NODE_DOCUMENT) {
    // The DOM does not allow Document nodes to have Text children, so per the
    // spec, they are dropped on the floor.
    destroy_node(parser, text_node);
  } else {
    insert_node(parser, text_node, location);
  }

  gumbo_string_buffer_clear(parser, &buffer_state->_buffer);
  buffer_state->_type = GUMBO_NODE_WHITESPACE;
  assert(buffer_state->_buffer.length == 0);
}

static void record_end_of_element(
    GumboToken* current_token, GumboElement* element) {
  element->end_pos = current_token->position;
  element->original_end_tag = current_token->type == GUMBO_TOKEN_END_TAG
                                  ? current_token->original_text
                                  : kGumboEmptyString;
}

static GumboNode* pop_current_node(GumboParser* parser) {
  GumboParserState* state = parser->_parser_state;
  maybe_flush_text_node_buffer(parser);
  if (state->_open_elements.length > 0) {
    assert(node_html_tag_is(state->_open_elements.data[0], GUMBO_TAG_HTML));
    gumbo_debug("Popping %s node.\n",
        gumbo_normalized_tagname(get_current_node(parser)->v.element.tag));
  }
  GumboNode* current_node = gumbo_vector_pop(parser, &state->_open_elements);
  if (!current_node) {
    assert(state->_open_elements.length == 0);
    return NULL;
  }
  assert(current_node->type == GUMBO_NODE_ELEMENT ||
         current_node->type == GUMBO_NODE_TEMPLATE);
  bool is_closed_body_or_html_tag =
      (node_html_tag_is(current_node, GUMBO_TAG_BODY) &&
          state->_closed_body_tag) ||
      (node_html_tag_is(current_node, GUMBO_TAG_HTML) &&
          state->_closed_html_tag);
  if ((state->_current_token->type != GUMBO_TOKEN_END_TAG ||
          !node_html_tag_is(current_node, state->_current_token->v.end_tag)) &&
      !is_closed_body_or_html_tag) {
    current_node->parse_flags |= GUMBO_INSERTION_IMPLICIT_END_TAG;
  }
  if (!is_closed_body_or_html_tag) {
    record_end_of_element(state->_current_token, &current_node->v.element);
  }
  return current_node;
}

static void append_comment_node(
    GumboParser* parser, GumboNode* node, const GumboToken* token) {
  maybe_flush_text_node_buffer(parser);
  GumboNode* comment = create_node(parser, GUMBO_NODE_COMMENT);
  comment->type = GUMBO_NODE_COMMENT;
  comment->parse_flags = GUMBO_INSERTION_NORMAL;
  comment->v.text.text = token->v.text;
  comment->v.text.original_text = token->original_text;
  comment->v.text.start_pos = token->position;
  append_node(parser, node, comment);
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#clear-the-stack-back-to-a-table-row-context
static void clear_stack_to_table_row_context(GumboParser* parser) {
  while (!node_tag_in_set(get_current_node(parser),
             (gumbo_tagset){TAG(HTML), TAG(TR), TAG(TEMPLATE)})) {
    pop_current_node(parser);
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#clear-the-stack-back-to-a-table-context
static void clear_stack_to_table_context(GumboParser* parser) {
  while (!node_tag_in_set(get_current_node(parser),
             (gumbo_tagset){TAG(HTML), TAG(TABLE), TAG(TEMPLATE)})) {
    pop_current_node(parser);
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#clear-the-stack-back-to-a-table-body-context
void clear_stack_to_table_body_context(GumboParser* parser) {
  while (!node_tag_in_set(get_current_node(parser),
             (gumbo_tagset){TAG(HTML), TAG(TBODY), TAG(TFOOT), TAG(THEAD),
                 TAG(TEMPLATE)})) {
    pop_current_node(parser);
  }
}

// Creates a parser-inserted element in the HTML namespace and returns it.
static GumboNode* create_element(GumboParser* parser, GumboTag tag) {
  GumboNode* node = create_node(parser, GUMBO_NODE_ELEMENT);
  GumboElement* element = &node->v.element;
  gumbo_vector_init(parser, 1, &element->children);
  gumbo_vector_init(parser, 0, &element->attributes);
  element->tag = tag;
  element->tag_namespace = GUMBO_NAMESPACE_HTML;
  element->original_tag = kGumboEmptyString;
  element->original_end_tag = kGumboEmptyString;
  element->start_pos = (parser->_parser_state->_current_token)
                           ? parser->_parser_state->_current_token->position
                           : kGumboEmptySourcePosition;
  element->end_pos = kGumboEmptySourcePosition;
  return node;
}

// Constructs an element from the given start tag token.
static GumboNode* create_element_from_token(
    GumboParser* parser, GumboToken* token, GumboNamespaceEnum tag_namespace) {
  assert(token->type == GUMBO_TOKEN_START_TAG);
  GumboTokenStartTag* start_tag = &token->v.start_tag;

  GumboNodeType type = (tag_namespace == GUMBO_NAMESPACE_HTML &&
                           start_tag->tag == GUMBO_TAG_TEMPLATE)
                           ? GUMBO_NODE_TEMPLATE
                           : GUMBO_NODE_ELEMENT;

  GumboNode* node = create_node(parser, type);
  GumboElement* element = &node->v.element;
  gumbo_vector_init(parser, 1, &element->children);
  element->attributes = start_tag->attributes;
  element->tag = start_tag->tag;
  element->tag_namespace = tag_namespace;

  assert(token->original_text.length >= 2);
  assert(token->original_text.data[0] == '<');
  assert(token->original_text.data[token->original_text.length - 1] == '>');
  element->original_tag = token->original_text;
  element->start_pos = token->position;
  element->original_end_tag = kGumboEmptyString;
  element->end_pos = kGumboEmptySourcePosition;

  // The element takes ownership of the attributes from the token, so any
  // allocated-memory fields should be nulled out.
  start_tag->attributes = kGumboEmptyVector;
  return node;
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#insert-an-html-element
static void insert_element(GumboParser* parser, GumboNode* node,
    bool is_reconstructing_formatting_elements) {
  GumboParserState* state = parser->_parser_state;
  // NOTE(jdtang): The text node buffer must always be flushed before inserting
  // a node, otherwise we're handling nodes in a different order than the spec
  // mandated.  However, one clause of the spec (character tokens in the body)
  // requires that we reconstruct the active formatting elements *before* adding
  // the character, and reconstructing the active formatting elements may itself
  // result in the insertion of new elements (which should be pushed onto the
  // stack of open elements before the buffer is flushed).  We solve this (for
  // the time being, the spec has been rewritten for <template> and the new
  // version may be simpler here) with a boolean flag to this method.
  if (!is_reconstructing_formatting_elements) {
    maybe_flush_text_node_buffer(parser);
  }
  InsertionLocation location = get_appropriate_insertion_location(parser, NULL);
  insert_node(parser, node, location);
  gumbo_vector_add(parser, (void*) node, &state->_open_elements);
}

// Convenience method that combines create_element_from_token and
// insert_element, inserting the generated element directly into the current
// node.  Returns the node inserted.
static GumboNode* insert_element_from_token(
    GumboParser* parser, GumboToken* token) {
  GumboNode* element =
      create_element_from_token(parser, token, GUMBO_NAMESPACE_HTML);
  insert_element(parser, element, false);
  gumbo_debug("Inserting <%s> element (@%x) from token.\n",
      gumbo_normalized_tagname(element->v.element.tag), element);
  return element;
}

// Convenience method that combines create_element and insert_element, inserting
// a parser-generated element of a specific tag type.  Returns the node
// inserted.
static GumboNode* insert_element_of_tag_type(
    GumboParser* parser, GumboTag tag, GumboParseFlags reason) {
  GumboNode* element = create_element(parser, tag);
  element->parse_flags |= GUMBO_INSERTION_BY_PARSER | reason;
  insert_element(parser, element, false);
  gumbo_debug("Inserting %s element (@%x) from tag type.\n",
      gumbo_normalized_tagname(tag), element);
  return element;
}

// Convenience method for creating foreign namespaced element.  Returns the node
// inserted.
static GumboNode* insert_foreign_element(
    GumboParser* parser, GumboToken* token, GumboNamespaceEnum tag_namespace) {
  assert(token->type == GUMBO_TOKEN_START_TAG);
  GumboNode* element = create_element_from_token(parser, token, tag_namespace);
  insert_element(parser, element, false);
  if (token_has_attribute(token, "xmlns") &&
      !attribute_matches_case_sensitive(&token->v.start_tag.attributes, "xmlns",
          kLegalXmlns[tag_namespace])) {
    // TODO(jdtang): Since there're multiple possible error codes here, we
    // eventually need reason codes to differentiate them.
    parser_add_parse_error(parser, token);
  }
  if (token_has_attribute(token, "xmlns:xlink") &&
      !attribute_matches_case_sensitive(&token->v.start_tag.attributes,
          "xmlns:xlink", "http://www.w3.org/1999/xlink")) {
    parser_add_parse_error(parser, token);
  }
  return element;
}

static void insert_text_token(GumboParser* parser, GumboToken* token) {
  assert(token->type == GUMBO_TOKEN_WHITESPACE ||
         token->type == GUMBO_TOKEN_CHARACTER ||
         token->type == GUMBO_TOKEN_NULL || token->type == GUMBO_TOKEN_CDATA);
  TextNodeBufferState* buffer_state = &parser->_parser_state->_text_node;
  if (buffer_state->_buffer.length == 0) {
    // Initialize position fields.
    buffer_state->_start_original_text = token->original_text.data;
    buffer_state->_start_position = token->position;
  }
  gumbo_string_buffer_append_codepoint(
      parser, token->v.character, &buffer_state->_buffer);
  if (token->type == GUMBO_TOKEN_CHARACTER) {
    buffer_state->_type = GUMBO_NODE_TEXT;
  } else if (token->type == GUMBO_TOKEN_CDATA) {
    buffer_state->_type = GUMBO_NODE_CDATA;
  }
  gumbo_debug("Inserting text token '%c'.\n", token->v.character);
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#generic-rcdata-element-parsing-algorithm
static void run_generic_parsing_algorithm(
    GumboParser* parser, GumboToken* token, GumboTokenizerEnum lexer_state) {
  insert_element_from_token(parser, token);
  gumbo_tokenizer_set_state(parser, lexer_state);
  parser->_parser_state->_original_insertion_mode =
      parser->_parser_state->_insertion_mode;
  parser->_parser_state->_insertion_mode = GUMBO_INSERTION_MODE_TEXT;
}

static void acknowledge_self_closing_tag(GumboParser* parser) {
  parser->_parser_state->_self_closing_flag_acknowledged = true;
}

// Returns true if there's an anchor tag in the list of active formatting
// elements, and fills in its index if so.
static bool find_last_anchor_index(GumboParser* parser, int* anchor_index) {
  GumboVector* elements = &parser->_parser_state->_active_formatting_elements;
  for (int i = elements->length; --i >= 0;) {
    GumboNode* node = elements->data[i];
    if (node == &kActiveFormattingScopeMarker) {
      return false;
    }
    if (node_html_tag_is(node, GUMBO_TAG_A)) {
      *anchor_index = i;
      return true;
    }
  }
  return false;
}

// Counts the number of open formatting elements in the list of active
// formatting elements (after the last active scope marker) that have a specific
// tag.  If this is > 0, then earliest_matching_index will be filled in with the
// index of the first such element.
static int count_formatting_elements_of_tag(GumboParser* parser,
    const GumboNode* desired_node, int* earliest_matching_index) {
  const GumboElement* desired_element = &desired_node->v.element;
  GumboVector* elements = &parser->_parser_state->_active_formatting_elements;
  int num_identical_elements = 0;
  for (int i = elements->length; --i >= 0;) {
    GumboNode* node = elements->data[i];
    if (node == &kActiveFormattingScopeMarker) {
      break;
    }
    assert(node->type == GUMBO_NODE_ELEMENT);
    if (node_qualified_tag_is(
            node, desired_element->tag_namespace, desired_element->tag) &&
        all_attributes_match(
            &node->v.element.attributes, &desired_element->attributes)) {
      num_identical_elements++;
      *earliest_matching_index = i;
    }
  }
  return num_identical_elements;
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/parsing.html#reconstruct-the-active-formatting-elements
static void add_formatting_element(GumboParser* parser, const GumboNode* node) {
  assert(node == &kActiveFormattingScopeMarker ||
         node->type == GUMBO_NODE_ELEMENT);
  GumboVector* elements = &parser->_parser_state->_active_formatting_elements;
  if (node == &kActiveFormattingScopeMarker) {
    gumbo_debug("Adding a scope marker.\n");
  } else {
    gumbo_debug("Adding a formatting element.\n");
  }

  // Hunt for identical elements.
  int earliest_identical_element = elements->length;
  int num_identical_elements = count_formatting_elements_of_tag(
      parser, node, &earliest_identical_element);

  // Noah's Ark clause: if there're at least 3, remove the earliest.
  if (num_identical_elements >= 3) {
    gumbo_debug("Noah's ark clause: removing element at %d.\n",
        earliest_identical_element);
    gumbo_vector_remove_at(parser, earliest_identical_element, elements);
  }

  gumbo_vector_add(parser, (void*) node, elements);
}

static bool is_open_element(GumboParser* parser, const GumboNode* node) {
  GumboVector* open_elements = &parser->_parser_state->_open_elements;
  for (unsigned int i = 0; i < open_elements->length; ++i) {
    if (open_elements->data[i] == node) {
      return true;
    }
  }
  return false;
}

// Clones attributes, tags, etc. of a node, but does not copy the content.  The
// clone shares no structure with the original node: all owned strings and
// values are fresh copies.
GumboNode* clone_node(
    GumboParser* parser, GumboNode* node, GumboParseFlags reason) {
  assert(node->type == GUMBO_NODE_ELEMENT || node->type == GUMBO_NODE_TEMPLATE);
  GumboNode* new_node = gumbo_parser_allocate(parser, sizeof(GumboNode));
  *new_node = *node;
  new_node->parent = NULL;
  new_node->index_within_parent = -1;
  // Clear the GUMBO_INSERTION_IMPLICIT_END_TAG flag, as the cloned node may
  // have a separate end tag.
  new_node->parse_flags &= ~GUMBO_INSERTION_IMPLICIT_END_TAG;
  new_node->parse_flags |= reason | GUMBO_INSERTION_BY_PARSER;
  GumboElement* element = &new_node->v.element;
  gumbo_vector_init(parser, 1, &element->children);

  const GumboVector* old_attributes = &node->v.element.attributes;
  gumbo_vector_init(parser, old_attributes->length, &element->attributes);
  for (unsigned int i = 0; i < old_attributes->length; ++i) {
    const GumboAttribute* old_attr = old_attributes->data[i];
    GumboAttribute* attr =
        gumbo_parser_allocate(parser, sizeof(GumboAttribute));
    *attr = *old_attr;
    attr->name = gumbo_copy_stringz(parser, old_attr->name);
    attr->value = gumbo_copy_stringz(parser, old_attr->value);
    gumbo_vector_add(parser, attr, &element->attributes);
  }
  return new_node;
}

// "Reconstruct active formatting elements" part of the spec.
// This implementation is based on the html5lib translation from the mess of
// GOTOs in the spec to reasonably structured programming.
// http://code.google.com/p/html5lib/source/browse/python/html5lib/treebuilders/_base.py
static void reconstruct_active_formatting_elements(GumboParser* parser) {
  GumboVector* elements = &parser->_parser_state->_active_formatting_elements;
  // Step 1
  if (elements->length == 0) {
    return;
  }

  // Step 2 & 3
  unsigned int i = elements->length - 1;
  GumboNode* element = elements->data[i];
  if (element == &kActiveFormattingScopeMarker ||
      is_open_element(parser, element)) {
    return;
  }

  // Step 6
  do {
    if (i == 0) {
      // Step 4
      i = -1;  // Incremented to 0 below.
      break;
    }
    // Step 5
    element = elements->data[--i];
  } while (element != &kActiveFormattingScopeMarker &&
           !is_open_element(parser, element));

  ++i;
  gumbo_debug("Reconstructing elements from %d on %s parent.\n", i,
      gumbo_normalized_tagname(get_current_node(parser)->v.element.tag));
  for (; i < elements->length; ++i) {
    // Step 7 & 8.
    assert(elements->length > 0);
    assert(i < elements->length);
    element = elements->data[i];
    assert(element != &kActiveFormattingScopeMarker);
    GumboNode* clone = clone_node(
        parser, element, GUMBO_INSERTION_RECONSTRUCTED_FORMATTING_ELEMENT);
    // Step 9.
    InsertionLocation location =
        get_appropriate_insertion_location(parser, NULL);
    insert_node(parser, clone, location);
    gumbo_vector_add(
        parser, (void*) clone, &parser->_parser_state->_open_elements);

    // Step 10.
    elements->data[i] = clone;
    gumbo_debug("Reconstructed %s element at %d.\n",
        gumbo_normalized_tagname(clone->v.element.tag), i);
  }
}

static void clear_active_formatting_elements(GumboParser* parser) {
  GumboVector* elements = &parser->_parser_state->_active_formatting_elements;
  int num_elements_cleared = 0;
  const GumboNode* node;
  do {
    node = gumbo_vector_pop(parser, elements);
    ++num_elements_cleared;
  } while (node && node != &kActiveFormattingScopeMarker);
  gumbo_debug("Cleared %d elements from active formatting list.\n",
      num_elements_cleared);
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#the-initial-insertion-mode
static GumboQuirksModeEnum compute_quirks_mode(
    const GumboTokenDocType* doctype) {
  if (doctype->force_quirks || strcmp(doctype->name, kDoctypeHtml.data) ||
      is_in_static_list(
          doctype->public_identifier, kQuirksModePublicIdPrefixes, false) ||
      is_in_static_list(
          doctype->public_identifier, kQuirksModePublicIdExactMatches, true) ||
      is_in_static_list(
          doctype->system_identifier, kQuirksModeSystemIdExactMatches, true) ||
      (is_in_static_list(doctype->public_identifier,
           kLimitedQuirksRequiresSystemIdPublicIdPrefixes, false) &&
          !doctype->has_system_identifier)) {
    return GUMBO_DOCTYPE_QUIRKS;
  } else if (is_in_static_list(doctype->public_identifier,
                 kLimitedQuirksPublicIdPrefixes, false) ||
             (is_in_static_list(doctype->public_identifier,
                  kLimitedQuirksRequiresSystemIdPublicIdPrefixes, false) &&
                 doctype->has_system_identifier)) {
    return GUMBO_DOCTYPE_LIMITED_QUIRKS;
  }
  return GUMBO_DOCTYPE_NO_QUIRKS;
}

// The following functions are all defined by the "has an element in __ scope"
// sections of the HTML5 spec:
// http://www.whatwg.org/specs/web-apps/current-work/multipage/parsing.html#has-an-element-in-the-specific-scope
// The basic idea behind them is that they check for an element of the given
// qualified name, contained within a scope formed by a set of other qualified
// names.  For example, "has an element in list scope" looks for an element of
// the given qualified name within the nearest enclosing <ol> or <ul>, along
// with a bunch of generic element types that serve to "firewall" their content
// from the rest of the document. Note that because of the way the spec is
// written,
// all elements are expected to be in the HTML namespace
static bool has_an_element_in_specific_scope(GumboParser* parser,
    int expected_size, const GumboTag* expected, bool negate,
    const gumbo_tagset tags) {
  GumboVector* open_elements = &parser->_parser_state->_open_elements;
  for (int i = open_elements->length; --i >= 0;) {
    const GumboNode* node = open_elements->data[i];
    if (node->type != GUMBO_NODE_ELEMENT && node->type != GUMBO_NODE_TEMPLATE)
      continue;

    GumboTag node_tag = node->v.element.tag;
    GumboNamespaceEnum node_ns = node->v.element.tag_namespace;
    for (int j = 0; j < expected_size; ++j) {
      if (node_tag == expected[j] && node_ns == GUMBO_NAMESPACE_HTML)
        return true;
    }

    bool found = TAGSET_INCLUDES(tags, node_ns, node_tag);
    if (negate != found) return false;
  }
  return false;
}

// Checks for the presence of an open element of the specified tag type.
static bool has_open_element(GumboParser* parser, GumboTag tag) {
  return has_an_element_in_specific_scope(
      parser, 1, &tag, false, (gumbo_tagset){TAG(HTML)});
}

// http://www.whatwg.org/specs/web-apps/current-work/multipage/parsing.html#has-an-element-in-scope
static bool has_an_element_in_scope(GumboParser* parser, GumboTag tag) {
  return has_an_element_in_specific_scope(parser, 1, &tag, false,
      (gumbo_tagset){TAG(APPLET), TAG(CAPTION), TAG(HTML), TAG(TABLE), TAG(TD),
          TAG(TH), TAG(MARQUEE), TAG(OBJECT), TAG(TEMPLATE), TAG_MATHML(MI),
          TAG_MATHML(MO), TAG_MATHML(MN), TAG_MATHML(MS), TAG_MATHML(MTEXT),
          TAG_MATHML(ANNOTATION_XML), TAG_SVG(FOREIGNOBJECT), TAG_SVG(DESC),
          TAG_SVG(TITLE)});
}

// Like "has an element in scope", but for the specific case of looking for a
// unique target node, not for any node with a given tag name.  This duplicates
// much of the algorithm from has_an_element_in_specific_scope because the
// predicate is different when checking for an exact node, and it's easier &
// faster just to duplicate the code for this one case than to try and
// parameterize it.
static bool has_node_in_scope(GumboParser* parser, const GumboNode* node) {
  GumboVector* open_elements = &parser->_parser_state->_open_elements;
  for (int i = open_elements->length; --i >= 0;) {
    const GumboNode* current = open_elements->data[i];
    if (current == node) {
      return true;
    }
    if (current->type != GUMBO_NODE_ELEMENT &&
        current->type != GUMBO_NODE_TEMPLATE) {
      continue;
    }
    if (node_tag_in_set(current,
            (gumbo_tagset){TAG(APPLET), TAG(CAPTION), TAG(HTML), TAG(TABLE),
                TAG(TD), TAG(TH), TAG(MARQUEE), TAG(OBJECT), TAG(TEMPLATE),
                TAG_MATHML(MI), TAG_MATHML(MO), TAG_MATHML(MN), TAG_MATHML(MS),
                TAG_MATHML(MTEXT), TAG_MATHML(ANNOTATION_XML),
                TAG_SVG(FOREIGNOBJECT), TAG_SVG(DESC), TAG_SVG(TITLE)})) {
      return false;
    }
  }
  assert(false);
  return false;
}

// Like has_an_element_in_scope, but restricts the expected qualified name to a
// range of possible qualified names instead of just a single one.
static bool has_an_element_in_scope_with_tagname(
    GumboParser* parser, int expected_len, const GumboTag expected[]) {
  return has_an_element_in_specific_scope(parser, expected_len, expected, false,
      (gumbo_tagset){TAG(APPLET), TAG(CAPTION), TAG(HTML), TAG(TABLE), TAG(TD),
          TAG(TH), TAG(MARQUEE), TAG(OBJECT), TAG(TEMPLATE), TAG_MATHML(MI),
          TAG_MATHML(MO), TAG_MATHML(MN), TAG_MATHML(MS), TAG_MATHML(MTEXT),
          TAG_MATHML(ANNOTATION_XML), TAG_SVG(FOREIGNOBJECT), TAG_SVG(DESC),
          TAG_SVG(TITLE)});
}

// http://www.whatwg.org/specs/web-apps/current-work/multipage/parsing.html#has-an-element-in-list-item-scope
static bool has_an_element_in_list_scope(GumboParser* parser, GumboTag tag) {
  return has_an_element_in_specific_scope(parser, 1, &tag, false,
      (gumbo_tagset){TAG(APPLET), TAG(CAPTION), TAG(HTML), TAG(TABLE), TAG(TD),
          TAG(TH), TAG(MARQUEE), TAG(OBJECT), TAG(TEMPLATE), TAG_MATHML(MI),
          TAG_MATHML(MO), TAG_MATHML(MN), TAG_MATHML(MS), TAG_MATHML(MTEXT),
          TAG_MATHML(ANNOTATION_XML), TAG_SVG(FOREIGNOBJECT), TAG_SVG(DESC),
          TAG_SVG(TITLE), TAG(OL), TAG(UL)});
}

// http://www.whatwg.org/specs/web-apps/current-work/multipage/parsing.html#has-an-element-in-button-scope
static bool has_an_element_in_button_scope(GumboParser* parser, GumboTag tag) {
  return has_an_element_in_specific_scope(parser, 1, &tag, false,
      (gumbo_tagset){TAG(APPLET), TAG(CAPTION), TAG(HTML), TAG(TABLE), TAG(TD),
          TAG(TH), TAG(MARQUEE), TAG(OBJECT), TAG(TEMPLATE), TAG_MATHML(MI),
          TAG_MATHML(MO), TAG_MATHML(MN), TAG_MATHML(MS), TAG_MATHML(MTEXT),
          TAG_MATHML(ANNOTATION_XML), TAG_SVG(FOREIGNOBJECT), TAG_SVG(DESC),
          TAG_SVG(TITLE), TAG(BUTTON)});
}

// http://www.whatwg.org/specs/web-apps/current-work/multipage/parsing.html#has-an-element-in-table-scope
static bool has_an_element_in_table_scope(GumboParser* parser, GumboTag tag) {
  return has_an_element_in_specific_scope(parser, 1, &tag, false,
      (gumbo_tagset){TAG(HTML), TAG(TABLE), TAG(TEMPLATE)});
}

// http://www.whatwg.org/specs/web-apps/current-work/multipage/parsing.html#has-an-element-in-select-scope
static bool has_an_element_in_select_scope(GumboParser* parser, GumboTag tag) {
  return has_an_element_in_specific_scope(
      parser, 1, &tag, true, (gumbo_tagset){TAG(OPTGROUP), TAG(OPTION)});
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#generate-implied-end-tags
// "exception" is the "element to exclude from the process" listed in the spec.
// Pass GUMBO_TAG_LAST to not exclude any of them.
static void generate_implied_end_tags(GumboParser* parser, GumboTag exception) {
  for (; node_tag_in_set(get_current_node(parser),
             (gumbo_tagset){TAG(DD), TAG(DT), TAG(LI), TAG(OPTION),
                 TAG(OPTGROUP), TAG(P), TAG(RP), TAG(RB), TAG(RT), TAG(RTC)}) &&
         !node_html_tag_is(get_current_node(parser), exception);
       pop_current_node(parser))
    ;
}

// This is the "generate all implied end tags thoroughly" clause of the spec.
// https://html.spec.whatwg.org/multipage/syntax.html#closing-elements-that-have-implied-end-tags
static void generate_all_implied_end_tags_thoroughly(GumboParser* parser) {
  for (
      ; node_tag_in_set(get_current_node(parser),
          (gumbo_tagset){TAG(CAPTION), TAG(COLGROUP), TAG(DD), TAG(DT), TAG(LI),
              TAG(OPTION), TAG(OPTGROUP), TAG(P), TAG(RP), TAG(RT), TAG(RTC),
              TAG(TBODY), TAG(TD), TAG(TFOOT), TAG(TH), TAG(HEAD), TAG(TR)});
      pop_current_node(parser))
    ;
}

// This factors out the clauses relating to "act as if an end tag token with tag
// name "table" had been seen.  Returns true if there's a table element in table
// scope which was successfully closed, false if not and the token should be
// ignored.  Does not add parse errors; callers should handle that.
static bool close_table(GumboParser* parser) {
  if (!has_an_element_in_table_scope(parser, GUMBO_TAG_TABLE)) {
    return false;
  }

  GumboNode* node = pop_current_node(parser);
  while (!node_html_tag_is(node, GUMBO_TAG_TABLE)) {
    node = pop_current_node(parser);
  }
  reset_insertion_mode_appropriately(parser);
  return true;
}

// This factors out the clauses relating to "act as if an end tag token with tag
// name `cell_tag` had been seen".
static bool close_table_cell(
    GumboParser* parser, const GumboToken* token, GumboTag cell_tag) {
  bool result = true;
  generate_implied_end_tags(parser, GUMBO_TAG_LAST);
  const GumboNode* node = get_current_node(parser);
  if (!node_html_tag_is(node, cell_tag)) {
    parser_add_parse_error(parser, token);
    result = false;
  }
  do {
    node = pop_current_node(parser);
  } while (!node_html_tag_is(node, cell_tag));

  clear_active_formatting_elements(parser);
  set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_ROW);
  return result;
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#close-the-cell
// This holds the logic to determine whether we should close a <td> or a <th>.
static bool close_current_cell(GumboParser* parser, const GumboToken* token) {
  if (has_an_element_in_table_scope(parser, GUMBO_TAG_TD)) {
    assert(!has_an_element_in_table_scope(parser, GUMBO_TAG_TH));
    return close_table_cell(parser, token, GUMBO_TAG_TD);
  } else {
    assert(has_an_element_in_table_scope(parser, GUMBO_TAG_TH));
    return close_table_cell(parser, token, GUMBO_TAG_TH);
  }
}

// This factors out the "act as if an end tag of tag name 'select' had been
// seen" clause of the spec, since it's referenced in several places.  It pops
// all nodes from the stack until the current <select> has been closed, then
// resets the insertion mode appropriately.
static void close_current_select(GumboParser* parser) {
  GumboNode* node = pop_current_node(parser);
  while (!node_html_tag_is(node, GUMBO_TAG_SELECT)) {
    node = pop_current_node(parser);
  }
  reset_insertion_mode_appropriately(parser);
}

// The list of nodes in the "special" category:
// http://www.whatwg.org/specs/web-apps/current-work/complete/parsing.html#special
static bool is_special_node(const GumboNode* node) {
  assert(node->type == GUMBO_NODE_ELEMENT || node->type == GUMBO_NODE_TEMPLATE);
  return node_tag_in_set(node,
      (gumbo_tagset){TAG(ADDRESS), TAG(APPLET), TAG(AREA), TAG(ARTICLE),
          TAG(ASIDE), TAG(BASE), TAG(BASEFONT), TAG(BGSOUND), TAG(BLOCKQUOTE),
          TAG(BODY), TAG(BR), TAG(BUTTON), TAG(CAPTION), TAG(CENTER), TAG(COL),
          TAG(COLGROUP), TAG(MENUITEM), TAG(DD), TAG(DETAILS), TAG(DIR),
          TAG(DIV), TAG(DL), TAG(DT), TAG(EMBED), TAG(FIELDSET),
          TAG(FIGCAPTION), TAG(FIGURE), TAG(FOOTER), TAG(FORM), TAG(FRAME),
          TAG(FRAMESET), TAG(H1), TAG(H2), TAG(H3), TAG(H4), TAG(H5), TAG(H6),
          TAG(HEAD), TAG(HEADER), TAG(HGROUP), TAG(HR), TAG(HTML), TAG(IFRAME),
          TAG(IMG), TAG(INPUT), TAG(ISINDEX), TAG(LI), TAG(LINK), TAG(LISTING),
          TAG(MARQUEE), TAG(MENU), TAG(META), TAG(NAV), TAG(NOEMBED),
          TAG(NOFRAMES), TAG(NOSCRIPT), TAG(OBJECT), TAG(OL), TAG(P),
          TAG(PARAM), TAG(PLAINTEXT), TAG(PRE), TAG(SCRIPT), TAG(SECTION),
          TAG(SELECT), TAG(STYLE), TAG(SUMMARY), TAG(TABLE), TAG(TBODY),
          TAG(TD), TAG(TEMPLATE), TAG(TEXTAREA), TAG(TFOOT), TAG(TH),
          TAG(THEAD), TAG(TITLE), TAG(TR), TAG(UL), TAG(WBR), TAG(XMP),

          TAG_MATHML(MI), TAG_MATHML(MO), TAG_MATHML(MN), TAG_MATHML(MS),
          TAG_MATHML(MTEXT), TAG_MATHML(ANNOTATION_XML),

          TAG_SVG(FOREIGNOBJECT), TAG_SVG(DESC)});
}

// Implicitly closes currently open elements until it reaches an element with
// the
// specified qualified name.  If the elements closed are in the set handled by
// generate_implied_end_tags, this is normal operation and this function returns
// true.  Otherwise, a parse error is recorded and this function returns false.
static bool implicitly_close_tags(GumboParser* parser, GumboToken* token,
    GumboNamespaceEnum target_ns, GumboTag target) {
  bool result = true;
  generate_implied_end_tags(parser, target);
  if (!node_qualified_tag_is(get_current_node(parser), target_ns, target)) {
    parser_add_parse_error(parser, token);
    while (
        !node_qualified_tag_is(get_current_node(parser), target_ns, target)) {
      pop_current_node(parser);
    }
    result = false;
  }
  assert(node_qualified_tag_is(get_current_node(parser), target_ns, target));
  pop_current_node(parser);
  return result;
}

// If the stack of open elements has a <p> tag in button scope, this acts as if
// a </p> tag was encountered, implicitly closing tags.  Returns false if a
// parse error occurs.  This is a convenience function because this particular
// clause appears several times in the spec.
static bool maybe_implicitly_close_p_tag(
    GumboParser* parser, GumboToken* token) {
  if (has_an_element_in_button_scope(parser, GUMBO_TAG_P)) {
    return implicitly_close_tags(
        parser, token, GUMBO_NAMESPACE_HTML, GUMBO_TAG_P);
  }
  return true;
}

// Convenience function to encapsulate the logic for closing <li> or <dd>/<dt>
// tags.  Pass true to is_li for handling <li> tags, false for <dd> and <dt>.
static void maybe_implicitly_close_list_tag(
    GumboParser* parser, GumboToken* token, bool is_li) {
  GumboParserState* state = parser->_parser_state;
  state->_frameset_ok = false;
  for (int i = state->_open_elements.length; --i >= 0;) {
    const GumboNode* node = state->_open_elements.data[i];
    bool is_list_tag =
        is_li ? node_html_tag_is(node, GUMBO_TAG_LI)
              : node_tag_in_set(node, (gumbo_tagset){TAG(DD), TAG(DT)});
    if (is_list_tag) {
      implicitly_close_tags(
          parser, token, node->v.element.tag_namespace, node->v.element.tag);
      return;
    }
    if (is_special_node(node) &&
        !node_tag_in_set(
            node, (gumbo_tagset){TAG(ADDRESS), TAG(DIV), TAG(P)})) {
      return;
    }
  }
}

static void merge_attributes(
    GumboParser* parser, GumboToken* token, GumboNode* node) {
  assert(token->type == GUMBO_TOKEN_START_TAG);
  assert(node->type == GUMBO_NODE_ELEMENT);
  const GumboVector* token_attr = &token->v.start_tag.attributes;
  GumboVector* node_attr = &node->v.element.attributes;

  for (unsigned int i = 0; i < token_attr->length; ++i) {
    GumboAttribute* attr = token_attr->data[i];
    if (!gumbo_get_attribute(node_attr, attr->name)) {
      // Ownership of the attribute is transferred by this gumbo_vector_add,
      // so it has to be nulled out of the original token so it doesn't get
      // double-deleted.
      gumbo_vector_add(parser, attr, node_attr);
      token_attr->data[i] = NULL;
    }
  }
  // When attributes are merged, it means the token has been ignored and merged
  // with another token, so we need to free its memory.  The attributes that are
  // transferred need to be nulled-out in the vector above so that they aren't
  // double-deleted.
  gumbo_token_destroy(parser, token);

#ifndef NDEBUG
  // Mark this sentinel so the assertion in the main loop knows it's been
  // destroyed.
  token->v.start_tag.attributes = kGumboEmptyVector;
#endif
}

const char* gumbo_normalize_svg_tagname(const GumboStringPiece* tag) {
  for (size_t i = 0; i < sizeof(kSvgTagReplacements) / sizeof(ReplacementEntry);
       ++i) {
    const ReplacementEntry* entry = &kSvgTagReplacements[i];
    if (gumbo_string_equals_ignore_case(tag, &entry->from)) {
      return entry->to.data;
    }
  }
  return NULL;
}

// http://www.whatwg.org/specs/web-apps/current-work/multipage/tree-construction.html#adjust-foreign-attributes
// This destructively modifies any matching attributes on the token and sets the
// namespace appropriately.
static void adjust_foreign_attributes(GumboParser* parser, GumboToken* token) {
  assert(token->type == GUMBO_TOKEN_START_TAG);
  const GumboVector* attributes = &token->v.start_tag.attributes;
  for (size_t i = 0; i < sizeof(kForeignAttributeReplacements) /
                             sizeof(NamespacedAttributeReplacement);
       ++i) {
    const NamespacedAttributeReplacement* entry =
        &kForeignAttributeReplacements[i];
    GumboAttribute* attr = gumbo_get_attribute(attributes, entry->from);
    if (!attr) {
      continue;
    }
    gumbo_parser_deallocate(parser, (void*) attr->name);
    attr->attr_namespace = entry->attr_namespace;
    attr->name = gumbo_copy_stringz(parser, entry->local_name);
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#adjust-svg-attributes
// This destructively modifies any matching attributes on the token.
static void adjust_svg_attributes(GumboParser* parser, GumboToken* token) {
  assert(token->type == GUMBO_TOKEN_START_TAG);
  const GumboVector* attributes = &token->v.start_tag.attributes;
  for (size_t i = 0;
       i < sizeof(kSvgAttributeReplacements) / sizeof(ReplacementEntry); ++i) {
    const ReplacementEntry* entry = &kSvgAttributeReplacements[i];
    GumboAttribute* attr = gumbo_get_attribute(attributes, entry->from.data);
    if (!attr) {
      continue;
    }
    gumbo_parser_deallocate(parser, (void*) attr->name);
    attr->name = gumbo_copy_stringz(parser, entry->to.data);
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#adjust-mathml-attributes
// Note that this may destructively modify the token with the new attribute
// value.
static void adjust_mathml_attributes(GumboParser* parser, GumboToken* token) {
  assert(token->type == GUMBO_TOKEN_START_TAG);
  GumboAttribute* attr =
      gumbo_get_attribute(&token->v.start_tag.attributes, "definitionurl");
  if (!attr) {
    return;
  }
  gumbo_parser_deallocate(parser, (void*) attr->name);
  attr->name = gumbo_copy_stringz(parser, "definitionURL");
}

static bool doctype_matches(const GumboTokenDocType* doctype,
    const GumboStringPiece* public_id, const GumboStringPiece* system_id,
    bool allow_missing_system_id) {
  return !strcmp(doctype->public_identifier, public_id->data) &&
         (allow_missing_system_id || doctype->has_system_identifier) &&
         !strcmp(doctype->system_identifier, system_id->data);
}

static bool maybe_add_doctype_error(
    GumboParser* parser, const GumboToken* token) {
  const GumboTokenDocType* doctype = &token->v.doc_type;
  bool html_doctype = !strcmp(doctype->name, kDoctypeHtml.data);
  if ((!html_doctype || doctype->has_public_identifier ||
          (doctype->has_system_identifier &&
              !strcmp(
                  doctype->system_identifier, kSystemIdLegacyCompat.data))) &&
      !(html_doctype && (doctype_matches(doctype, &kPublicIdHtml4_0,
                             &kSystemIdRecHtml4_0, true) ||
                            doctype_matches(doctype, &kPublicIdHtml4_01,
                                &kSystemIdHtml4, true) ||
                            doctype_matches(doctype, &kPublicIdXhtml1_0,
                                &kSystemIdXhtmlStrict1_1, false) ||
                            doctype_matches(doctype, &kPublicIdXhtml1_1,
                                &kSystemIdXhtml1_1, false)))) {
    parser_add_parse_error(parser, token);
    return false;
  }
  return true;
}

static void remove_from_parent(GumboParser* parser, GumboNode* node) {
  if (!node->parent) {
    // The node may not have a parent if, for example, it is a newly-cloned copy
    // of an active formatting element.  DOM manipulations continue with the
    // orphaned fragment of the DOM tree until it's appended/foster-parented to
    // the common ancestor at the end of the adoption agency algorithm.
    return;
  }
  assert(node->parent->type == GUMBO_NODE_ELEMENT);
  GumboVector* children = &node->parent->v.element.children;
  int index = gumbo_vector_index_of(children, node);
  assert(index != -1);

  gumbo_vector_remove_at(parser, index, children);
  node->parent = NULL;
  node->index_within_parent = -1;
  for (unsigned int i = index; i < children->length; ++i) {
    GumboNode* child = children->data[i];
    child->index_within_parent = i;
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/multipage/the-end.html#an-introduction-to-error-handling-and-strange-cases-in-the-parser
// Also described in the "in body" handling for end formatting tags.
static bool adoption_agency_algorithm(
    GumboParser* parser, GumboToken* token, GumboTag subject) {
  GumboParserState* state = parser->_parser_state;
  gumbo_debug("Entering adoption agency algorithm.\n");
  // Step 1.
  GumboNode* current_node = get_current_node(parser);
  if (current_node->v.element.tag_namespace == GUMBO_NAMESPACE_HTML &&
      current_node->v.element.tag == subject &&
      gumbo_vector_index_of(
          &state->_active_formatting_elements, current_node) == -1) {
    pop_current_node(parser);
    return false;
  }
  // Steps 2-4 & 20:
  for (unsigned int i = 0; i < 8; ++i) {
    // Step 5.
    GumboNode* formatting_node = NULL;
    int formatting_node_in_open_elements = -1;
    for (int j = state->_active_formatting_elements.length; --j >= 0;) {
      GumboNode* current_node = state->_active_formatting_elements.data[j];
      if (current_node == &kActiveFormattingScopeMarker) {
        gumbo_debug("Broke on scope marker; aborting.\n");
        // Last scope marker; abort the algorithm.
        return false;
      }
      if (node_html_tag_is(current_node, subject)) {
        // Found it.
        formatting_node = current_node;
        formatting_node_in_open_elements =
            gumbo_vector_index_of(&state->_open_elements, formatting_node);
        gumbo_debug("Formatting element of tag %s at %d.\n",
            gumbo_normalized_tagname(subject),
            formatting_node_in_open_elements);
        break;
      }
    }
    if (!formatting_node) {
      // No matching tag; not a parse error outright, but fall through to the
      // "any other end tag" clause (which may potentially add a parse error,
      // but not always).
      gumbo_debug("No active formatting elements; aborting.\n");
      return false;
    }

    // Step 6
    if (formatting_node_in_open_elements == -1) {
      gumbo_debug("Formatting node not on stack of open elements.\n");
      parser_add_parse_error(parser, token);
      gumbo_vector_remove(
          parser, formatting_node, &state->_active_formatting_elements);
      return false;
    }

    // Step 7
    if (!has_an_element_in_scope(parser, formatting_node->v.element.tag)) {
      parser_add_parse_error(parser, token);
      gumbo_debug("Element not in scope.\n");
      return false;
    }

    // Step 8
    if (formatting_node != get_current_node(parser)) {
      parser_add_parse_error(parser, token);  // But continue onwards.
    }
    assert(formatting_node);
    assert(!node_html_tag_is(formatting_node, GUMBO_TAG_HTML));
    assert(!node_html_tag_is(formatting_node, GUMBO_TAG_BODY));

    // Step 9 & 10
    GumboNode* furthest_block = NULL;
    for (unsigned int j = formatting_node_in_open_elements;
         j < state->_open_elements.length; ++j) {
      assert(j > 0);
      GumboNode* current = state->_open_elements.data[j];
      if (is_special_node(current)) {
        // Step 9.
        furthest_block = current;
        break;
      }
    }
    if (!furthest_block) {
      // Step 10.
      while (get_current_node(parser) != formatting_node) {
        pop_current_node(parser);
      }
      // And the formatting element itself.
      pop_current_node(parser);
      gumbo_vector_remove(
          parser, formatting_node, &state->_active_formatting_elements);
      return false;
    }
    assert(!node_html_tag_is(furthest_block, GUMBO_TAG_HTML));
    assert(furthest_block);

    // Step 11.
    // Elements may be moved and reparented by this algorithm, so
    // common_ancestor is not necessarily the same as formatting_node->parent.
    GumboNode* common_ancestor =
        state->_open_elements.data[gumbo_vector_index_of(&state->_open_elements,
                                       formatting_node) -
                                   1];
    gumbo_debug("Common ancestor tag = %s, furthest block tag = %s.\n",
        gumbo_normalized_tagname(common_ancestor->v.element.tag),
        gumbo_normalized_tagname(furthest_block->v.element.tag));

    // Step 12.
    int bookmark = gumbo_vector_index_of(
                       &state->_active_formatting_elements, formatting_node) +
                   1;
    gumbo_debug("Bookmark at %d.\n", bookmark);
    // Step 13.
    GumboNode* node = furthest_block;
    GumboNode* last_node = furthest_block;
    // Must be stored explicitly, in case node is removed from the stack of open
    // elements, to handle step 9.4.
    int saved_node_index = gumbo_vector_index_of(&state->_open_elements, node);
    assert(saved_node_index > 0);
    // Step 13.1.
    for (int j = 0;;) {
      // Step 13.2.
      ++j;
      // Step 13.3.
      int node_index = gumbo_vector_index_of(&state->_open_elements, node);
      gumbo_debug(
          "Current index: %d, last index: %d.\n", node_index, saved_node_index);
      if (node_index == -1) {
        node_index = saved_node_index;
      }
      saved_node_index = --node_index;
      assert(node_index > 0);
      assert((unsigned int) node_index < state->_open_elements.capacity);
      node = state->_open_elements.data[node_index];
      assert(node->parent);
      if (node == formatting_node) {
        // Step 13.4.
        break;
      }
      int formatting_index =
          gumbo_vector_index_of(&state->_active_formatting_elements, node);
      if (j > 3 && formatting_index != -1) {
        // Step 13.5.
        gumbo_debug("Removing formatting element at %d.\n", formatting_index);
        gumbo_vector_remove_at(
            parser, formatting_index, &state->_active_formatting_elements);
        // Removing the element shifts all indices over by one, so we may need
        // to move the bookmark.
        if (formatting_index < bookmark) {
          --bookmark;
          gumbo_debug("Moving bookmark to %d.\n", bookmark);
        }
        continue;
      }
      if (formatting_index == -1) {
        // Step 13.6.
        gumbo_vector_remove_at(parser, node_index, &state->_open_elements);
        continue;
      }
      // Step 13.7.
      // "common ancestor as the intended parent" doesn't actually mean insert
      // it into the common ancestor; that happens below.
      node = clone_node(parser, node, GUMBO_INSERTION_ADOPTION_AGENCY_CLONED);
      assert(formatting_index >= 0);
      state->_active_formatting_elements.data[formatting_index] = node;
      assert(node_index >= 0);
      state->_open_elements.data[node_index] = node;
      // Step 13.8.
      if (last_node == furthest_block) {
        bookmark = formatting_index + 1;
        gumbo_debug("Bookmark moved to %d.\n", bookmark);
        assert((unsigned int) bookmark <= state->_active_formatting_elements.length);
      }
      // Step 13.9.
      last_node->parse_flags |= GUMBO_INSERTION_ADOPTION_AGENCY_MOVED;
      remove_from_parent(parser, last_node);
      append_node(parser, node, last_node);
      // Step 13.10.
      last_node = node;
    }  // Step 13.11.

    // Step 14.
    gumbo_debug("Removing %s node from parent ",
        gumbo_normalized_tagname(last_node->v.element.tag));
    remove_from_parent(parser, last_node);
    last_node->parse_flags |= GUMBO_INSERTION_ADOPTION_AGENCY_MOVED;
    InsertionLocation location =
        get_appropriate_insertion_location(parser, common_ancestor);
    gumbo_debug("and inserting it into %s.\n",
        gumbo_normalized_tagname(location.target->v.element.tag));
    insert_node(parser, last_node, location);

    // Step 15.
    GumboNode* new_formatting_node = clone_node(
        parser, formatting_node, GUMBO_INSERTION_ADOPTION_AGENCY_CLONED);
    formatting_node->parse_flags |= GUMBO_INSERTION_IMPLICIT_END_TAG;

    // Step 16.  Instead of appending nodes one-by-one, we swap the children
    // vector of furthest_block with the empty children of new_formatting_node,
    // reducing memory traffic and allocations.  We still have to reset their
    // parent pointers, though.
    GumboVector temp = new_formatting_node->v.element.children;
    new_formatting_node->v.element.children =
        furthest_block->v.element.children;
    furthest_block->v.element.children = temp;

    temp = new_formatting_node->v.element.children;
    for (unsigned int i = 0; i < temp.length; ++i) {
      GumboNode* child = temp.data[i];
      child->parent = new_formatting_node;
    }

    // Step 17.
    append_node(parser, furthest_block, new_formatting_node);

    // Step 18.
    // If the formatting node was before the bookmark, it may shift over all
    // indices after it, so we need to explicitly find the index and possibly
    // adjust the bookmark.
    int formatting_node_index = gumbo_vector_index_of(
        &state->_active_formatting_elements, formatting_node);
    assert(formatting_node_index != -1);
    if (formatting_node_index < bookmark) {
      gumbo_debug(
          "Formatting node at %d is before bookmark at %d; decrementing.\n",
          formatting_node_index, bookmark);
      --bookmark;
    }
    gumbo_vector_remove_at(
        parser, formatting_node_index, &state->_active_formatting_elements);
    assert(bookmark >= 0);
    assert((unsigned int) bookmark <= state->_active_formatting_elements.length);
    gumbo_vector_insert_at(parser, new_formatting_node, bookmark,
        &state->_active_formatting_elements);

    // Step 19.
    gumbo_vector_remove(parser, formatting_node, &state->_open_elements);
    int insert_at =
        gumbo_vector_index_of(&state->_open_elements, furthest_block) + 1;
    assert(insert_at >= 0);
    assert((unsigned int) insert_at <= state->_open_elements.length);
    gumbo_vector_insert_at(
        parser, new_formatting_node, insert_at, &state->_open_elements);
  }  // Step 20.
  return true;
}

// This is here to clean up memory when the spec says "Ignore current token."
static void ignore_token(GumboParser* parser) {
  GumboToken* token = parser->_parser_state->_current_token;
  // Ownership of the token's internal buffers are normally transferred to the
  // element, but if no element is emitted (as happens in non-verbatim-mode
  // when a token is ignored), we need to free it here to prevent a memory
  // leak.
  gumbo_token_destroy(parser, token);
#ifndef NDEBUG
  if (token->type == GUMBO_TOKEN_START_TAG) {
    // Mark this sentinel so the assertion in the main loop knows it's been
    // destroyed.
    token->v.start_tag.attributes = kGumboEmptyVector;
  }
#endif
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/the-end.html
static void finish_parsing(GumboParser* parser) {
  gumbo_debug("Finishing parsing");
  maybe_flush_text_node_buffer(parser);
  GumboParserState* state = parser->_parser_state;
  for (GumboNode* node = pop_current_node(parser); node;
       node = pop_current_node(parser)) {
    if ((node_html_tag_is(node, GUMBO_TAG_BODY) && state->_closed_body_tag) ||
        (node_html_tag_is(node, GUMBO_TAG_HTML) && state->_closed_html_tag)) {
      continue;
    }
    node->parse_flags |= GUMBO_INSERTION_IMPLICIT_END_TAG;
  }
  while (pop_current_node(parser))
    ;  // Pop them all.
}

static bool handle_initial(GumboParser* parser, GumboToken* token) {
  GumboDocument* document = &get_document_node(parser)->v.document;
  if (token->type == GUMBO_TOKEN_WHITESPACE) {
    ignore_token(parser);
    return true;
  } else if (token->type == GUMBO_TOKEN_COMMENT) {
    append_comment_node(parser, get_document_node(parser), token);
    return true;
  } else if (token->type == GUMBO_TOKEN_DOCTYPE) {
    document->has_doctype = true;
    document->name = token->v.doc_type.name;
    document->public_identifier = token->v.doc_type.public_identifier;
    document->system_identifier = token->v.doc_type.system_identifier;
    document->doc_type_quirks_mode = compute_quirks_mode(&token->v.doc_type);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_BEFORE_HTML);
    return maybe_add_doctype_error(parser, token);
  }
  parser_add_parse_error(parser, token);
  document->doc_type_quirks_mode = GUMBO_DOCTYPE_QUIRKS;
  set_insertion_mode(parser, GUMBO_INSERTION_MODE_BEFORE_HTML);
  parser->_parser_state->_reprocess_current_token = true;
  return true;
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#the-before-html-insertion-mode
static bool handle_before_html(GumboParser* parser, GumboToken* token) {
  if (token->type == GUMBO_TOKEN_DOCTYPE) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else if (token->type == GUMBO_TOKEN_COMMENT) {
    append_comment_node(parser, get_document_node(parser), token);
    return true;
  } else if (token->type == GUMBO_TOKEN_WHITESPACE) {
    ignore_token(parser);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_HTML)) {
    GumboNode* html_node = insert_element_from_token(parser, token);
    parser->_output->root = html_node;
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_BEFORE_HEAD);
    return true;
  } else if (token->type == GUMBO_TOKEN_END_TAG &&
             !tag_in(token, false,
                 (gumbo_tagset){TAG(HEAD), TAG(BODY), TAG(HTML), TAG(BR)})) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else {
    GumboNode* html_node = insert_element_of_tag_type(
        parser, GUMBO_TAG_HTML, GUMBO_INSERTION_IMPLIED);
    assert(html_node);
    parser->_output->root = html_node;
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_BEFORE_HEAD);
    parser->_parser_state->_reprocess_current_token = true;
    return true;
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#the-before-head-insertion-mode
static bool handle_before_head(GumboParser* parser, GumboToken* token) {
  if (token->type == GUMBO_TOKEN_DOCTYPE) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else if (token->type == GUMBO_TOKEN_COMMENT) {
    append_comment_node(parser, get_current_node(parser), token);
    return true;
  } else if (token->type == GUMBO_TOKEN_WHITESPACE) {
    ignore_token(parser);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_HEAD)) {
    GumboNode* node = insert_element_from_token(parser, token);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_HEAD);
    parser->_parser_state->_head_element = node;
    return true;
  } else if (token->type == GUMBO_TOKEN_END_TAG &&
             !tag_in(token, false,
                 (gumbo_tagset){TAG(HEAD), TAG(BODY), TAG(HTML), TAG(BR)})) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else {
    GumboNode* node = insert_element_of_tag_type(
        parser, GUMBO_TAG_HEAD, GUMBO_INSERTION_IMPLIED);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_HEAD);
    parser->_parser_state->_head_element = node;
    parser->_parser_state->_reprocess_current_token = true;
    return true;
  }
}

// Forward declarations because of mutual dependencies.
static bool handle_token(GumboParser* parser, GumboToken* token);
static bool handle_in_body(GumboParser* parser, GumboToken* token);

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#parsing-main-inhead
static bool handle_in_head(GumboParser* parser, GumboToken* token) {
  if (token->type == GUMBO_TOKEN_WHITESPACE) {
    insert_text_token(parser, token);
    return true;
  } else if (token->type == GUMBO_TOKEN_DOCTYPE) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else if (token->type == GUMBO_TOKEN_COMMENT) {
    append_comment_node(parser, get_current_node(parser), token);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_HTML)) {
    return handle_in_body(parser, token);
  } else if (tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(BASE), TAG(BASEFONT), TAG(BGSOUND),
                     TAG(MENUITEM), TAG(LINK)})) {
    insert_element_from_token(parser, token);
    pop_current_node(parser);
    acknowledge_self_closing_tag(parser);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_META)) {
    insert_element_from_token(parser, token);
    pop_current_node(parser);
    acknowledge_self_closing_tag(parser);
    // NOTE(jdtang): Gumbo handles only UTF-8, so the encoding clause of the
    // spec doesn't apply.  If clients want to handle meta-tag re-encoding, they
    // should specifically look for that string in the document and re-encode it
    // before passing to Gumbo.
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_TITLE)) {
    run_generic_parsing_algorithm(parser, token, GUMBO_LEX_RCDATA);
    return true;
  } else if (tag_in(
                 token, kStartTag, (gumbo_tagset){TAG(NOFRAMES), TAG(STYLE)})) {
    run_generic_parsing_algorithm(parser, token, GUMBO_LEX_RAWTEXT);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_NOSCRIPT)) {
    insert_element_from_token(parser, token);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_HEAD_NOSCRIPT);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_SCRIPT)) {
    run_generic_parsing_algorithm(parser, token, GUMBO_LEX_SCRIPT);
    return true;
  } else if (tag_is(token, kEndTag, GUMBO_TAG_HEAD)) {
    GumboNode* head = pop_current_node(parser);
    AVOID_UNUSED_VARIABLE_WARNING(head);
    assert(node_html_tag_is(head, GUMBO_TAG_HEAD));
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_AFTER_HEAD);
    return true;
  } else if (tag_in(token, kEndTag,
                 (gumbo_tagset){TAG(BODY), TAG(HTML), TAG(BR)})) {
    pop_current_node(parser);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_AFTER_HEAD);
    parser->_parser_state->_reprocess_current_token = true;
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_TEMPLATE)) {
    insert_element_from_token(parser, token);
    add_formatting_element(parser, &kActiveFormattingScopeMarker);
    parser->_parser_state->_frameset_ok = false;
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_TEMPLATE);
    push_template_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_TEMPLATE);
    return true;
  } else if (tag_is(token, kEndTag, GUMBO_TAG_TEMPLATE)) {
    if (!has_open_element(parser, GUMBO_TAG_TEMPLATE)) {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    }
    generate_all_implied_end_tags_thoroughly(parser);
    bool success = true;
    if (!node_html_tag_is(get_current_node(parser), GUMBO_TAG_TEMPLATE)) {
      parser_add_parse_error(parser, token);
      success = false;
    }
    while (!node_html_tag_is(pop_current_node(parser), GUMBO_TAG_TEMPLATE))
      ;
    clear_active_formatting_elements(parser);
    pop_template_insertion_mode(parser);
    reset_insertion_mode_appropriately(parser);
    return success;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_HEAD) ||
             (token->type == GUMBO_TOKEN_END_TAG)) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else {
    pop_current_node(parser);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_AFTER_HEAD);
    parser->_parser_state->_reprocess_current_token = true;
    return true;
  }
  return true;
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#parsing-main-inheadnoscript
static bool handle_in_head_noscript(GumboParser* parser, GumboToken* token) {
  if (token->type == GUMBO_TOKEN_DOCTYPE) {
    parser_add_parse_error(parser, token);
    return false;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_HTML)) {
    return handle_in_body(parser, token);
  } else if (tag_is(token, kEndTag, GUMBO_TAG_NOSCRIPT)) {
    const GumboNode* node = pop_current_node(parser);
    assert(node_html_tag_is(node, GUMBO_TAG_NOSCRIPT));
    AVOID_UNUSED_VARIABLE_WARNING(node);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_HEAD);
    return true;
  } else if (token->type == GUMBO_TOKEN_WHITESPACE ||
             token->type == GUMBO_TOKEN_COMMENT ||
             tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(BASEFONT), TAG(BGSOUND), TAG(LINK),
                     TAG(META), TAG(NOFRAMES), TAG(STYLE)})) {
    return handle_in_head(parser, token);
  } else if (tag_in(
                 token, kStartTag, (gumbo_tagset){TAG(HEAD), TAG(NOSCRIPT)}) ||
             (token->type == GUMBO_TOKEN_END_TAG &&
                 !tag_is(token, kEndTag, GUMBO_TAG_BR))) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else {
    parser_add_parse_error(parser, token);
    const GumboNode* node = pop_current_node(parser);
    assert(node_html_tag_is(node, GUMBO_TAG_NOSCRIPT));
    AVOID_UNUSED_VARIABLE_WARNING(node);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_HEAD);
    parser->_parser_state->_reprocess_current_token = true;
    return false;
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#the-after-head-insertion-mode
static bool handle_after_head(GumboParser* parser, GumboToken* token) {
  GumboParserState* state = parser->_parser_state;
  if (token->type == GUMBO_TOKEN_WHITESPACE) {
    insert_text_token(parser, token);
    return true;
  } else if (token->type == GUMBO_TOKEN_DOCTYPE) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else if (token->type == GUMBO_TOKEN_COMMENT) {
    append_comment_node(parser, get_current_node(parser), token);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_HTML)) {
    return handle_in_body(parser, token);
  } else if (tag_is(token, kStartTag, GUMBO_TAG_BODY)) {
    insert_element_from_token(parser, token);
    state->_frameset_ok = false;
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_BODY);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_FRAMESET)) {
    insert_element_from_token(parser, token);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_FRAMESET);
    return true;
  } else if (tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(BASE), TAG(BASEFONT), TAG(BGSOUND),
                     TAG(LINK), TAG(META), TAG(NOFRAMES), TAG(SCRIPT),
                     TAG(STYLE), TAG(TEMPLATE), TAG(TITLE)})) {
    parser_add_parse_error(parser, token);
    assert(state->_head_element != NULL);
    // This must be flushed before we push the head element on, as there may be
    // pending character tokens that should be attached to the root.
    maybe_flush_text_node_buffer(parser);
    gumbo_vector_add(parser, state->_head_element, &state->_open_elements);
    bool result = handle_in_head(parser, token);
    gumbo_vector_remove(parser, state->_head_element, &state->_open_elements);
    return result;
  } else if (tag_is(token, kEndTag, GUMBO_TAG_TEMPLATE)) {
    return handle_in_head(parser, token);
  } else if (tag_is(token, kStartTag, GUMBO_TAG_HEAD) ||
             (token->type == GUMBO_TOKEN_END_TAG &&
                 !tag_in(token, kEndTag,
                     (gumbo_tagset){TAG(BODY), TAG(HTML), TAG(BR)}))) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else {
    insert_element_of_tag_type(parser, GUMBO_TAG_BODY, GUMBO_INSERTION_IMPLIED);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_BODY);
    state->_reprocess_current_token = true;
    return true;
  }
}

static void destroy_node(GumboParser* parser, GumboNode* node) {
  switch (node->type) {
    case GUMBO_NODE_DOCUMENT: {
      GumboDocument* doc = &node->v.document;
      for (unsigned int i = 0; i < doc->children.length; ++i) {
        destroy_node(parser, doc->children.data[i]);
      }
      gumbo_parser_deallocate(parser, (void*) doc->children.data);
      gumbo_parser_deallocate(parser, (void*) doc->name);
      gumbo_parser_deallocate(parser, (void*) doc->public_identifier);
      gumbo_parser_deallocate(parser, (void*) doc->system_identifier);
    } break;
    case GUMBO_NODE_TEMPLATE:
    case GUMBO_NODE_ELEMENT:
      for (unsigned int i = 0; i < node->v.element.attributes.length; ++i) {
        gumbo_destroy_attribute(parser, node->v.element.attributes.data[i]);
      }
      gumbo_parser_deallocate(parser, node->v.element.attributes.data);
      for (unsigned int i = 0; i < node->v.element.children.length; ++i) {
        destroy_node(parser, node->v.element.children.data[i]);
      }
      gumbo_parser_deallocate(parser, node->v.element.children.data);
      break;
    case GUMBO_NODE_TEXT:
    case GUMBO_NODE_CDATA:
    case GUMBO_NODE_COMMENT:
    case GUMBO_NODE_WHITESPACE:
      gumbo_parser_deallocate(parser, (void*) node->v.text.text);
      break;
  }
  gumbo_parser_deallocate(parser, node);
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#parsing-main-inbody
static bool handle_in_body(GumboParser* parser, GumboToken* token) {
  GumboParserState* state = parser->_parser_state;
  assert(state->_open_elements.length > 0);
  if (token->type == GUMBO_TOKEN_NULL) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else if (token->type == GUMBO_TOKEN_WHITESPACE) {
    reconstruct_active_formatting_elements(parser);
    insert_text_token(parser, token);
    return true;
  } else if (token->type == GUMBO_TOKEN_CHARACTER ||
             token->type == GUMBO_TOKEN_CDATA) {
    reconstruct_active_formatting_elements(parser);
    insert_text_token(parser, token);
    set_frameset_not_ok(parser);
    return true;
  } else if (token->type == GUMBO_TOKEN_COMMENT) {
    append_comment_node(parser, get_current_node(parser), token);
    return true;
  } else if (token->type == GUMBO_TOKEN_DOCTYPE) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_HTML)) {
    parser_add_parse_error(parser, token);
    if (has_open_element(parser, GUMBO_TAG_TEMPLATE)) {
      ignore_token(parser);
      return false;
    }
    assert(parser->_output->root != NULL);
    assert(parser->_output->root->type == GUMBO_NODE_ELEMENT);
    merge_attributes(parser, token, parser->_output->root);
    return false;
  } else if (tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(BASE), TAG(BASEFONT), TAG(BGSOUND),
                     TAG(MENUITEM), TAG(LINK), TAG(META), TAG(NOFRAMES),
                     TAG(SCRIPT), TAG(STYLE), TAG(TEMPLATE), TAG(TITLE)}) ||
             tag_is(token, kEndTag, GUMBO_TAG_TEMPLATE)) {
    return handle_in_head(parser, token);
  } else if (tag_is(token, kStartTag, GUMBO_TAG_BODY)) {
    parser_add_parse_error(parser, token);
    if (state->_open_elements.length < 2 ||
        !node_html_tag_is(state->_open_elements.data[1], GUMBO_TAG_BODY) ||
        has_open_element(parser, GUMBO_TAG_TEMPLATE)) {
      ignore_token(parser);
      return false;
    }
    state->_frameset_ok = false;
    merge_attributes(parser, token, state->_open_elements.data[1]);
    return false;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_FRAMESET)) {
    parser_add_parse_error(parser, token);
    if (state->_open_elements.length < 2 ||
        !node_html_tag_is(state->_open_elements.data[1], GUMBO_TAG_BODY) ||
        !state->_frameset_ok) {
      ignore_token(parser);
      return false;
    }
    // Save the body node for later removal.
    GumboNode* body_node = state->_open_elements.data[1];

    // Pop all nodes except root HTML element.
    GumboNode* node;
    do {
      node = pop_current_node(parser);
    } while (node != state->_open_elements.data[1]);

    // Removing & destroying the body node is going to kill any nodes that have
    // been added to the list of active formatting elements, and so we should
    // clear it to prevent a use-after-free if the list of active formatting
    // elements is reconstructed afterwards.  This may happen if whitespace
    // follows the </frameset>.
    clear_active_formatting_elements(parser);

    // Remove the body node.  We may want to factor this out into a generic
    // helper, but right now this is the only code that needs to do this.
    GumboVector* children = &parser->_output->root->v.element.children;
    for (unsigned int i = 0; i < children->length; ++i) {
      if (children->data[i] == body_node) {
        gumbo_vector_remove_at(parser, i, children);
        break;
      }
    }
    destroy_node(parser, body_node);

    // Insert the <frameset>, and switch the insertion mode.
    insert_element_from_token(parser, token);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_FRAMESET);
    return true;
  } else if (token->type == GUMBO_TOKEN_EOF) {
    for (unsigned int i = 0; i < state->_open_elements.length; ++i) {
      if (!node_tag_in_set(state->_open_elements.data[i],
              (gumbo_tagset){TAG(DD), TAG(DT), TAG(LI), TAG(P), TAG(TBODY),
                  TAG(TD), TAG(TFOOT), TAG(TH), TAG(THEAD), TAG(TR), TAG(BODY),
                  TAG(HTML)})) {
        parser_add_parse_error(parser, token);
      }
    }
    if (get_current_template_insertion_mode(parser) !=
        GUMBO_INSERTION_MODE_INITIAL) {
      return handle_in_template(parser, token);
    }
    return true;
  } else if (tag_in(token, kEndTag, (gumbo_tagset){TAG(BODY), TAG(HTML)})) {
    if (!has_an_element_in_scope(parser, GUMBO_TAG_BODY)) {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    }
    bool success = true;
    for (unsigned int i = 0; i < state->_open_elements.length; ++i) {
      if (!node_tag_in_set(state->_open_elements.data[i],
              (gumbo_tagset){TAG(DD), TAG(DT), TAG(LI), TAG(OPTGROUP),
                  TAG(OPTION), TAG(P), TAG(RB), TAG(RP), TAG(RT), TAG(RTC),
                  TAG(TBODY), TAG(TD), TAG(TFOOT), TAG(TH), TAG(THEAD), TAG(TR),
                  TAG(BODY), TAG(HTML)})) {
        parser_add_parse_error(parser, token);
        success = false;
        break;
      }
    }
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_AFTER_BODY);
    if (tag_is(token, kEndTag, GUMBO_TAG_HTML)) {
      parser->_parser_state->_reprocess_current_token = true;
    } else {
      GumboNode* body = state->_open_elements.data[1];
      assert(node_html_tag_is(body, GUMBO_TAG_BODY));
      record_end_of_element(state->_current_token, &body->v.element);
    }
    return success;
  } else if (tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(ADDRESS), TAG(ARTICLE), TAG(ASIDE),
                     TAG(BLOCKQUOTE), TAG(CENTER), TAG(DETAILS), TAG(DIR),
                     TAG(DIV), TAG(DL), TAG(FIELDSET), TAG(FIGCAPTION),
                     TAG(FIGURE), TAG(FOOTER), TAG(HEADER), TAG(HGROUP),
                     TAG(MENU), TAG(MAIN), TAG(NAV), TAG(OL), TAG(P),
                     TAG(SECTION), TAG(SUMMARY), TAG(UL)})) {
    bool result = maybe_implicitly_close_p_tag(parser, token);
    insert_element_from_token(parser, token);
    return result;
  } else if (tag_in(token, kStartTag, (gumbo_tagset){TAG(H1), TAG(H2), TAG(H3),
                                          TAG(H4), TAG(H5), TAG(H6)})) {
    bool result = maybe_implicitly_close_p_tag(parser, token);
    if (node_tag_in_set(
            get_current_node(parser), (gumbo_tagset){TAG(H1), TAG(H2), TAG(H3),
                                          TAG(H4), TAG(H5), TAG(H6)})) {
      parser_add_parse_error(parser, token);
      pop_current_node(parser);
      result = false;
    }
    insert_element_from_token(parser, token);
    return result;
  } else if (tag_in(token, kStartTag, (gumbo_tagset){TAG(PRE), TAG(LISTING)})) {
    bool result = maybe_implicitly_close_p_tag(parser, token);
    insert_element_from_token(parser, token);
    state->_ignore_next_linefeed = true;
    state->_frameset_ok = false;
    return result;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_FORM)) {
    if (state->_form_element != NULL &&
        !has_open_element(parser, GUMBO_TAG_TEMPLATE)) {
      gumbo_debug("Ignoring nested form.\n");
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    }
    bool result = maybe_implicitly_close_p_tag(parser, token);
    GumboNode* form_element = insert_element_from_token(parser, token);
    if (!has_open_element(parser, GUMBO_TAG_TEMPLATE)) {
      state->_form_element = form_element;
    }
    return result;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_LI)) {
    maybe_implicitly_close_list_tag(parser, token, true);
    bool result = maybe_implicitly_close_p_tag(parser, token);
    insert_element_from_token(parser, token);
    return result;
  } else if (tag_in(token, kStartTag, (gumbo_tagset){TAG(DD), TAG(DT)})) {
    maybe_implicitly_close_list_tag(parser, token, false);
    bool result = maybe_implicitly_close_p_tag(parser, token);
    insert_element_from_token(parser, token);
    return result;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_PLAINTEXT)) {
    bool result = maybe_implicitly_close_p_tag(parser, token);
    insert_element_from_token(parser, token);
    gumbo_tokenizer_set_state(parser, GUMBO_LEX_PLAINTEXT);
    return result;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_BUTTON)) {
    if (has_an_element_in_scope(parser, GUMBO_TAG_BUTTON)) {
      parser_add_parse_error(parser, token);
      implicitly_close_tags(
          parser, token, GUMBO_NAMESPACE_HTML, GUMBO_TAG_BUTTON);
      state->_reprocess_current_token = true;
      return false;
    }
    reconstruct_active_formatting_elements(parser);
    insert_element_from_token(parser, token);
    state->_frameset_ok = false;
    return true;
  } else if (tag_in(token, kEndTag,
                 (gumbo_tagset){TAG(ADDRESS), TAG(ARTICLE), TAG(ASIDE),
                     TAG(BLOCKQUOTE), TAG(BUTTON), TAG(CENTER), TAG(DETAILS),
                     TAG(DIR), TAG(DIV), TAG(DL), TAG(FIELDSET),
                     TAG(FIGCAPTION), TAG(FIGURE), TAG(FOOTER), TAG(HEADER),
                     TAG(HGROUP), TAG(LISTING), TAG(MAIN), TAG(MENU), TAG(NAV),
                     TAG(OL), TAG(PRE), TAG(SECTION), TAG(SUMMARY), TAG(UL)})) {
    GumboTag tag = token->v.end_tag;
    if (!has_an_element_in_scope(parser, tag)) {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    }
    implicitly_close_tags(
        parser, token, GUMBO_NAMESPACE_HTML, token->v.end_tag);
    return true;
  } else if (tag_is(token, kEndTag, GUMBO_TAG_FORM)) {
    if (has_open_element(parser, GUMBO_TAG_TEMPLATE)) {
      if (!has_an_element_in_scope(parser, GUMBO_TAG_FORM)) {
        parser_add_parse_error(parser, token);
        ignore_token(parser);
        return false;
      }
      bool success = true;
      generate_implied_end_tags(parser, GUMBO_TAG_LAST);
      if (!node_html_tag_is(get_current_node(parser), GUMBO_TAG_FORM)) {
        parser_add_parse_error(parser, token);
        return false;
      }
      while (!node_html_tag_is(pop_current_node(parser), GUMBO_TAG_FORM))
        ;
      return success;
    } else {
      bool result = true;
      const GumboNode* node = state->_form_element;
      assert(!node || node->type == GUMBO_NODE_ELEMENT);
      state->_form_element = NULL;
      if (!node || !has_node_in_scope(parser, node)) {
        gumbo_debug("Closing an unopened form.\n");
        parser_add_parse_error(parser, token);
        ignore_token(parser);
        return false;
      }
      // This differs from implicitly_close_tags because we remove *only* the
      // <form> element; other nodes are left in scope.
      generate_implied_end_tags(parser, GUMBO_TAG_LAST);
      if (get_current_node(parser) != node) {
        parser_add_parse_error(parser, token);
        result = false;
      }

      GumboVector* open_elements = &state->_open_elements;
      int index = gumbo_vector_index_of(open_elements, node);
      assert(index >= 0);
      gumbo_vector_remove_at(parser, index, open_elements);
      return result;
    }
  } else if (tag_is(token, kEndTag, GUMBO_TAG_P)) {
    if (!has_an_element_in_button_scope(parser, GUMBO_TAG_P)) {
      parser_add_parse_error(parser, token);
      // reconstruct_active_formatting_elements(parser);
      insert_element_of_tag_type(
          parser, GUMBO_TAG_P, GUMBO_INSERTION_CONVERTED_FROM_END_TAG);
      state->_reprocess_current_token = true;
      return false;
    }
    return implicitly_close_tags(
        parser, token, GUMBO_NAMESPACE_HTML, GUMBO_TAG_P);
  } else if (tag_is(token, kEndTag, GUMBO_TAG_LI)) {
    if (!has_an_element_in_list_scope(parser, GUMBO_TAG_LI)) {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    }
    return implicitly_close_tags(
        parser, token, GUMBO_NAMESPACE_HTML, GUMBO_TAG_LI);
  } else if (tag_in(token, kEndTag, (gumbo_tagset){TAG(DD), TAG(DT)})) {
    assert(token->type == GUMBO_TOKEN_END_TAG);
    GumboTag token_tag = token->v.end_tag;
    if (!has_an_element_in_scope(parser, token_tag)) {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    }
    return implicitly_close_tags(
        parser, token, GUMBO_NAMESPACE_HTML, token_tag);
  } else if (tag_in(token, kEndTag, (gumbo_tagset){TAG(H1), TAG(H2), TAG(H3),
                                        TAG(H4), TAG(H5), TAG(H6)})) {
    if (!has_an_element_in_scope_with_tagname(
            parser, 6, (GumboTag[]){GUMBO_TAG_H1, GUMBO_TAG_H2, GUMBO_TAG_H3,
                           GUMBO_TAG_H4, GUMBO_TAG_H5, GUMBO_TAG_H6})) {
      // No heading open; ignore the token entirely.
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    } else {
      generate_implied_end_tags(parser, GUMBO_TAG_LAST);
      const GumboNode* current_node = get_current_node(parser);
      bool success = node_html_tag_is(current_node, token->v.end_tag);
      if (!success) {
        // There're children of the heading currently open; close them below and
        // record a parse error.
        // TODO(jdtang): Add a way to distinguish this error case from the one
        // above.
        parser_add_parse_error(parser, token);
      }
      do {
        current_node = pop_current_node(parser);
      } while (!node_tag_in_set(
                   current_node, (gumbo_tagset){TAG(H1), TAG(H2), TAG(H3),
                                     TAG(H4), TAG(H5), TAG(H6)}));
      return success;
    }
  } else if (tag_is(token, kStartTag, GUMBO_TAG_A)) {
    bool success = true;
    int last_a;
    int has_matching_a = find_last_anchor_index(parser, &last_a);
    if (has_matching_a) {
      assert(has_matching_a == 1);
      parser_add_parse_error(parser, token);
      adoption_agency_algorithm(parser, token, GUMBO_TAG_A);
      // The adoption agency algorithm usually removes all instances of <a>
      // from the list of active formatting elements, but in case it doesn't,
      // we're supposed to do this.  (The conditions where it might not are
      // listed in the spec.)
      if (find_last_anchor_index(parser, &last_a)) {
        void* last_element = gumbo_vector_remove_at(
            parser, last_a, &state->_active_formatting_elements);
        gumbo_vector_remove(parser, last_element, &state->_open_elements);
      }
      success = false;
    }
    reconstruct_active_formatting_elements(parser);
    add_formatting_element(parser, insert_element_from_token(parser, token));
    return success;
  } else if (tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(B), TAG(BIG), TAG(CODE), TAG(EM), TAG(FONT),
                     TAG(I), TAG(S), TAG(SMALL), TAG(STRIKE), TAG(STRONG),
                     TAG(TT), TAG(U)})) {
    reconstruct_active_formatting_elements(parser);
    add_formatting_element(parser, insert_element_from_token(parser, token));
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_NOBR)) {
    bool result = true;
    reconstruct_active_formatting_elements(parser);
    if (has_an_element_in_scope(parser, GUMBO_TAG_NOBR)) {
      result = false;
      parser_add_parse_error(parser, token);
      adoption_agency_algorithm(parser, token, GUMBO_TAG_NOBR);
      reconstruct_active_formatting_elements(parser);
    }
    insert_element_from_token(parser, token);
    add_formatting_element(parser, get_current_node(parser));
    return result;
  } else if (tag_in(token, kEndTag,
                 (gumbo_tagset){TAG(A), TAG(B), TAG(BIG), TAG(CODE), TAG(EM),
                     TAG(FONT), TAG(I), TAG(NOBR), TAG(S), TAG(SMALL),
                     TAG(STRIKE), TAG(STRONG), TAG(TT), TAG(U)})) {
    return adoption_agency_algorithm(parser, token, token->v.end_tag);
  } else if (tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(APPLET), TAG(MARQUEE), TAG(OBJECT)})) {
    reconstruct_active_formatting_elements(parser);
    insert_element_from_token(parser, token);
    add_formatting_element(parser, &kActiveFormattingScopeMarker);
    set_frameset_not_ok(parser);
    return true;
  } else if (tag_in(token, kEndTag,
                 (gumbo_tagset){TAG(APPLET), TAG(MARQUEE), TAG(OBJECT)})) {
    GumboTag token_tag = token->v.end_tag;
    if (!has_an_element_in_table_scope(parser, token_tag)) {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    }
    implicitly_close_tags(parser, token, GUMBO_NAMESPACE_HTML, token_tag);
    clear_active_formatting_elements(parser);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_TABLE)) {
    if (get_document_node(parser)->v.document.doc_type_quirks_mode !=
        GUMBO_DOCTYPE_QUIRKS) {
      maybe_implicitly_close_p_tag(parser, token);
    }
    insert_element_from_token(parser, token);
    set_frameset_not_ok(parser);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_TABLE);
    return true;
  } else if (tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(AREA), TAG(BR), TAG(EMBED), TAG(IMG),
                     TAG(IMAGE), TAG(KEYGEN), TAG(WBR)})) {
    bool success = true;
    if (tag_is(token, kStartTag, GUMBO_TAG_IMAGE)) {
      success = false;
      parser_add_parse_error(parser, token);
      token->v.start_tag.tag = GUMBO_TAG_IMG;
    }
    reconstruct_active_formatting_elements(parser);
    GumboNode* node = insert_element_from_token(parser, token);
    if (tag_is(token, kStartTag, GUMBO_TAG_IMAGE)) {
      success = false;
      parser_add_parse_error(parser, token);
      node->v.element.tag = GUMBO_TAG_IMG;
      node->parse_flags |= GUMBO_INSERTION_FROM_IMAGE;
    }
    pop_current_node(parser);
    acknowledge_self_closing_tag(parser);
    set_frameset_not_ok(parser);
    return success;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_INPUT)) {
    if (!attribute_matches(&token->v.start_tag.attributes, "type", "hidden")) {
      // Must be before the element is inserted, as that takes ownership of the
      // token's attribute vector.
      set_frameset_not_ok(parser);
    }
    reconstruct_active_formatting_elements(parser);
    insert_element_from_token(parser, token);
    pop_current_node(parser);
    acknowledge_self_closing_tag(parser);
    return true;
  } else if (tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(PARAM), TAG(SOURCE), TAG(TRACK)})) {
    insert_element_from_token(parser, token);
    pop_current_node(parser);
    acknowledge_self_closing_tag(parser);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_HR)) {
    bool result = maybe_implicitly_close_p_tag(parser, token);
    insert_element_from_token(parser, token);
    pop_current_node(parser);
    acknowledge_self_closing_tag(parser);
    set_frameset_not_ok(parser);
    return result;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_ISINDEX)) {
    parser_add_parse_error(parser, token);
    if (parser->_parser_state->_form_element != NULL &&
        !has_open_element(parser, GUMBO_TAG_TEMPLATE)) {
      ignore_token(parser);
      return false;
    }
    acknowledge_self_closing_tag(parser);
    maybe_implicitly_close_p_tag(parser, token);
    set_frameset_not_ok(parser);

    GumboVector* token_attrs = &token->v.start_tag.attributes;
    GumboAttribute* prompt_attr = gumbo_get_attribute(token_attrs, "prompt");
    GumboAttribute* action_attr = gumbo_get_attribute(token_attrs, "action");
    GumboAttribute* name_attr = gumbo_get_attribute(token_attrs, "name");

    GumboNode* form = insert_element_of_tag_type(
        parser, GUMBO_TAG_FORM, GUMBO_INSERTION_FROM_ISINDEX);
    if (!has_open_element(parser, GUMBO_TAG_TEMPLATE)) {
      parser->_parser_state->_form_element = form;
    }
    if (action_attr) {
      gumbo_vector_add(parser, action_attr, &form->v.element.attributes);
    }
    insert_element_of_tag_type(
        parser, GUMBO_TAG_HR, GUMBO_INSERTION_FROM_ISINDEX);
    pop_current_node(parser);  // <hr>

    insert_element_of_tag_type(
        parser, GUMBO_TAG_LABEL, GUMBO_INSERTION_FROM_ISINDEX);
    TextNodeBufferState* text_state = &parser->_parser_state->_text_node;
    text_state->_start_original_text = token->original_text.data;
    text_state->_start_position = token->position;
    text_state->_type = GUMBO_NODE_TEXT;
    if (prompt_attr) {
      int prompt_attr_length = strlen(prompt_attr->value);
      gumbo_string_buffer_destroy(parser, &text_state->_buffer);
      text_state->_buffer.data = gumbo_copy_stringz(parser, prompt_attr->value);
      text_state->_buffer.length = prompt_attr_length;
      text_state->_buffer.capacity = prompt_attr_length + 1;
      gumbo_destroy_attribute(parser, prompt_attr);
    } else {
      GumboStringPiece prompt_text =
          GUMBO_STRING("This is a searchable index. Enter search keywords: ");
      gumbo_string_buffer_append_string(
          parser, &prompt_text, &text_state->_buffer);
    }

    GumboNode* input = insert_element_of_tag_type(
        parser, GUMBO_TAG_INPUT, GUMBO_INSERTION_FROM_ISINDEX);
    for (unsigned int i = 0; i < token_attrs->length; ++i) {
      GumboAttribute* attr = token_attrs->data[i];
      if (attr != prompt_attr && attr != action_attr && attr != name_attr) {
        gumbo_vector_add(parser, attr, &input->v.element.attributes);
      }
      token_attrs->data[i] = NULL;
    }

    // All attributes have been successfully transferred and nulled out at this
    // point, so the call to ignore_token will free the memory for it without
    // touching the attributes.
    ignore_token(parser);

    // The name attribute, if present, should be destroyed since it's ignored
    // when copying over.  The action attribute should be kept since it's moved
    // to the form.
    if (name_attr) {
      gumbo_destroy_attribute(parser, name_attr);
    }

    GumboAttribute* name =
        gumbo_parser_allocate(parser, sizeof(GumboAttribute));
    GumboStringPiece name_str = GUMBO_STRING("name");
    GumboStringPiece isindex_str = GUMBO_STRING("isindex");
    name->attr_namespace = GUMBO_ATTR_NAMESPACE_NONE;
    name->name = gumbo_copy_stringz(parser, "name");
    name->value = gumbo_copy_stringz(parser, "isindex");
    name->original_name = name_str;
    name->original_value = isindex_str;
    name->name_start = kGumboEmptySourcePosition;
    name->name_end = kGumboEmptySourcePosition;
    name->value_start = kGumboEmptySourcePosition;
    name->value_end = kGumboEmptySourcePosition;
    gumbo_vector_add(parser, name, &input->v.element.attributes);

    pop_current_node(parser);  // <input>
    pop_current_node(parser);  // <label>
    insert_element_of_tag_type(
        parser, GUMBO_TAG_HR, GUMBO_INSERTION_FROM_ISINDEX);
    pop_current_node(parser);  // <hr>
    pop_current_node(parser);  // <form>
    if (!has_open_element(parser, GUMBO_TAG_TEMPLATE)) {
      parser->_parser_state->_form_element = NULL;
    }
    return false;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_TEXTAREA)) {
    run_generic_parsing_algorithm(parser, token, GUMBO_LEX_RCDATA);
    parser->_parser_state->_ignore_next_linefeed = true;
    set_frameset_not_ok(parser);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_XMP)) {
    bool result = maybe_implicitly_close_p_tag(parser, token);
    reconstruct_active_formatting_elements(parser);
    set_frameset_not_ok(parser);
    run_generic_parsing_algorithm(parser, token, GUMBO_LEX_RAWTEXT);
    return result;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_IFRAME)) {
    set_frameset_not_ok(parser);
    run_generic_parsing_algorithm(parser, token, GUMBO_LEX_RAWTEXT);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_NOEMBED)) {
    run_generic_parsing_algorithm(parser, token, GUMBO_LEX_RAWTEXT);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_SELECT)) {
    reconstruct_active_formatting_elements(parser);
    insert_element_from_token(parser, token);
    set_frameset_not_ok(parser);
    GumboInsertionMode state = parser->_parser_state->_insertion_mode;
    if (state == GUMBO_INSERTION_MODE_IN_TABLE ||
        state == GUMBO_INSERTION_MODE_IN_CAPTION ||
        state == GUMBO_INSERTION_MODE_IN_TABLE_BODY ||
        state == GUMBO_INSERTION_MODE_IN_ROW ||
        state == GUMBO_INSERTION_MODE_IN_CELL) {
      set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_SELECT_IN_TABLE);
    } else {
      set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_SELECT);
    }
    return true;
  } else if (tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(OPTION), TAG(OPTGROUP)})) {
    if (node_html_tag_is(get_current_node(parser), GUMBO_TAG_OPTION)) {
      pop_current_node(parser);
    }
    reconstruct_active_formatting_elements(parser);
    insert_element_from_token(parser, token);
    return true;
  } else if (tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(RB), TAG(RP), TAG(RT), TAG(RTC)})) {
    bool success = true;
    GumboTag exception =
        tag_in(token, kStartTag, (gumbo_tagset){TAG(RT), TAG(RP)})
            ? GUMBO_TAG_RTC
            : GUMBO_TAG_LAST;
    if (has_an_element_in_scope(parser, GUMBO_TAG_RUBY)) {
      generate_implied_end_tags(parser, exception);
    }
    if (!node_html_tag_is(get_current_node(parser), GUMBO_TAG_RUBY) &&
        !(exception == GUMBO_TAG_LAST ||
            node_html_tag_is(get_current_node(parser), GUMBO_TAG_RTC))) {
      parser_add_parse_error(parser, token);
      success = false;
    }
    insert_element_from_token(parser, token);
    return success;
  } else if (tag_is(token, kEndTag, GUMBO_TAG_BR)) {
    parser_add_parse_error(parser, token);
    reconstruct_active_formatting_elements(parser);
    insert_element_of_tag_type(
        parser, GUMBO_TAG_BR, GUMBO_INSERTION_CONVERTED_FROM_END_TAG);
    pop_current_node(parser);
    return false;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_MATH)) {
    reconstruct_active_formatting_elements(parser);
    adjust_mathml_attributes(parser, token);
    adjust_foreign_attributes(parser, token);
    insert_foreign_element(parser, token, GUMBO_NAMESPACE_MATHML);
    if (token->v.start_tag.is_self_closing) {
      pop_current_node(parser);
      acknowledge_self_closing_tag(parser);
    }
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_SVG)) {
    reconstruct_active_formatting_elements(parser);
    adjust_svg_attributes(parser, token);
    adjust_foreign_attributes(parser, token);
    insert_foreign_element(parser, token, GUMBO_NAMESPACE_SVG);
    if (token->v.start_tag.is_self_closing) {
      pop_current_node(parser);
      acknowledge_self_closing_tag(parser);
    }
    return true;
  } else if (tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(CAPTION), TAG(COL), TAG(COLGROUP),
                     TAG(FRAME), TAG(HEAD), TAG(TBODY), TAG(TD), TAG(TFOOT),
                     TAG(TH), TAG(THEAD), TAG(TR)})) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else if (token->type == GUMBO_TOKEN_START_TAG) {
    reconstruct_active_formatting_elements(parser);
    insert_element_from_token(parser, token);
    return true;
  } else {
    assert(token->type == GUMBO_TOKEN_END_TAG);
    GumboTag end_tag = token->v.end_tag;
    assert(state->_open_elements.length > 0);
    assert(node_html_tag_is(state->_open_elements.data[0], GUMBO_TAG_HTML));
    // Walk up the stack of open elements until we find one that either:
    // a) Matches the tag name we saw
    // b) Is in the "special" category.
    // If we see a), implicitly close everything up to and including it.  If we
    // see b), then record a parse error, don't close anything (except the
    // implied end tags) and ignore the end tag token.
    for (int i = state->_open_elements.length; --i >= 0;) {
      const GumboNode* node = state->_open_elements.data[i];
      if (node_html_tag_is(node, end_tag)) {
        generate_implied_end_tags(parser, end_tag);
        // TODO(jdtang): Do I need to add a parse error here?  The condition in
        // the spec seems like it's the inverse of the loop condition above, and
        // so would never fire.
        while (node != pop_current_node(parser))
          ;  // Pop everything.
        return true;
      } else if (is_special_node(node)) {
        parser_add_parse_error(parser, token);
        ignore_token(parser);
        return false;
      }
    }
    // <html> is in the special category, so we should never get here.
    assert(0);
    return false;
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#parsing-main-incdata
static bool handle_text(GumboParser* parser, GumboToken* token) {
  if (token->type == GUMBO_TOKEN_CHARACTER ||
      token->type == GUMBO_TOKEN_WHITESPACE) {
    insert_text_token(parser, token);
  } else {
    // We provide only bare-bones script handling that doesn't involve any of
    // the parser-pause/already-started/script-nesting flags or re-entrant
    // invocations of the tokenizer.  Because the intended usage of this library
    // is mostly for templating, refactoring, and static-analysis libraries, we
    // provide the script body as a text-node child of the <script> element.
    // This behavior doesn't support document.write of partial HTML elements,
    // but should be adequate for almost all other scripting support.
    if (token->type == GUMBO_TOKEN_EOF) {
      parser_add_parse_error(parser, token);
      parser->_parser_state->_reprocess_current_token = true;
    }
    pop_current_node(parser);
    set_insertion_mode(parser, parser->_parser_state->_original_insertion_mode);
  }
  return true;
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#parsing-main-intable
static bool handle_in_table(GumboParser* parser, GumboToken* token) {
  GumboParserState* state = parser->_parser_state;
  if (token->type == GUMBO_TOKEN_CHARACTER ||
      token->type == GUMBO_TOKEN_WHITESPACE) {
    // The "pending table character tokens" list described in the spec is
    // nothing more than the TextNodeBufferState.  We accumulate text tokens as
    // normal, except that when we go to flush them in the handle_in_table_text,
    // we set _foster_parent_insertions if there're non-whitespace characters in
    // the buffer.
    assert(state->_text_node._buffer.length == 0);
    state->_original_insertion_mode = state->_insertion_mode;
    state->_reprocess_current_token = true;
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_TABLE_TEXT);
    return true;
  } else if (token->type == GUMBO_TOKEN_DOCTYPE) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else if (token->type == GUMBO_TOKEN_COMMENT) {
    append_comment_node(parser, get_current_node(parser), token);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_CAPTION)) {
    clear_stack_to_table_context(parser);
    add_formatting_element(parser, &kActiveFormattingScopeMarker);
    insert_element_from_token(parser, token);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_CAPTION);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_COLGROUP)) {
    clear_stack_to_table_context(parser);
    insert_element_from_token(parser, token);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_COLUMN_GROUP);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_COL)) {
    clear_stack_to_table_context(parser);
    insert_element_of_tag_type(
        parser, GUMBO_TAG_COLGROUP, GUMBO_INSERTION_IMPLIED);
    parser->_parser_state->_reprocess_current_token = true;
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_COLUMN_GROUP);
    return true;
  } else if (tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(TBODY), TAG(TFOOT), TAG(THEAD), TAG(TD),
                     TAG(TH), TAG(TR)})) {
    clear_stack_to_table_context(parser);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_TABLE_BODY);
    if (tag_in(token, kStartTag, (gumbo_tagset){TAG(TD), TAG(TH), TAG(TR)})) {
      insert_element_of_tag_type(
          parser, GUMBO_TAG_TBODY, GUMBO_INSERTION_IMPLIED);
      state->_reprocess_current_token = true;
    } else {
      insert_element_from_token(parser, token);
    }
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_TABLE)) {
    parser_add_parse_error(parser, token);
    if (close_table(parser)) {
      parser->_parser_state->_reprocess_current_token = true;
    } else {
      ignore_token(parser);
    }
    return false;
  } else if (tag_is(token, kEndTag, GUMBO_TAG_TABLE)) {
    if (!close_table(parser)) {
      parser_add_parse_error(parser, token);
      return false;
    }
    return true;
  } else if (tag_in(token, kEndTag,
                 (gumbo_tagset){TAG(BODY), TAG(CAPTION), TAG(COL),
                     TAG(COLGROUP), TAG(HTML), TAG(TBODY), TAG(TD), TAG(TFOOT),
                     TAG(TH), TAG(THEAD), TAG(TR)})) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else if (tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(STYLE), TAG(SCRIPT), TAG(TEMPLATE)}) ||
             (tag_is(token, kEndTag, GUMBO_TAG_TEMPLATE))) {
    return handle_in_head(parser, token);
  } else if (tag_is(token, kStartTag, GUMBO_TAG_INPUT) &&
             attribute_matches(
                 &token->v.start_tag.attributes, "type", "hidden")) {
    parser_add_parse_error(parser, token);
    insert_element_from_token(parser, token);
    pop_current_node(parser);
    return false;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_FORM)) {
    parser_add_parse_error(parser, token);
    if (state->_form_element || has_open_element(parser, GUMBO_TAG_TEMPLATE)) {
      ignore_token(parser);
      return false;
    }
    state->_form_element = insert_element_from_token(parser, token);
    pop_current_node(parser);
    return false;
  } else if (token->type == GUMBO_TOKEN_EOF) {
    return handle_in_body(parser, token);
  } else {
    parser_add_parse_error(parser, token);
    state->_foster_parent_insertions = true;
    bool result = handle_in_body(parser, token);
    state->_foster_parent_insertions = false;
    return result;
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#parsing-main-intabletext
static bool handle_in_table_text(GumboParser* parser, GumboToken* token) {
  if (token->type == GUMBO_TOKEN_NULL) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else if (token->type == GUMBO_TOKEN_CHARACTER ||
             token->type == GUMBO_TOKEN_WHITESPACE) {
    insert_text_token(parser, token);
    return true;
  } else {
    GumboParserState* state = parser->_parser_state;
    GumboStringBuffer* buffer = &state->_text_node._buffer;
    // Can't use strspn for this because GumboStringBuffers are not
    // null-terminated.
    // Note that TextNodeBuffer may contain UTF-8 characters, but the presence
    // of any one byte that is not whitespace means we flip the flag, so this
    // loop is still valid.
    for (unsigned int i = 0; i < buffer->length; ++i) {
      if (!isspace((unsigned char) buffer->data[i]) ||
          buffer->data[i] == '\v') {
        state->_foster_parent_insertions = true;
        reconstruct_active_formatting_elements(parser);
        break;
      }
    }
    maybe_flush_text_node_buffer(parser);
    state->_foster_parent_insertions = false;
    state->_reprocess_current_token = true;
    state->_insertion_mode = state->_original_insertion_mode;
    return true;
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#parsing-main-incaption
static bool handle_in_caption(GumboParser* parser, GumboToken* token) {
  if (tag_is(token, kEndTag, GUMBO_TAG_CAPTION)) {
    if (!has_an_element_in_table_scope(parser, GUMBO_TAG_CAPTION)) {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    } else {
      generate_implied_end_tags(parser, GUMBO_TAG_LAST);
      bool result = true;
      if (!node_html_tag_is(get_current_node(parser), GUMBO_TAG_CAPTION)) {
        parser_add_parse_error(parser, token);
      }
      while (!node_html_tag_is(pop_current_node(parser), GUMBO_TAG_CAPTION))
        ;
      clear_active_formatting_elements(parser);
      set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_TABLE);
      return result;
    }
  } else if (tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(CAPTION), TAG(COL), TAG(COLGROUP),
                     TAG(TBODY), TAG(TD), TAG(TFOOT), TAG(TH), TAG(THEAD),
                     TAG(TR)}) ||
             (tag_is(token, kEndTag, GUMBO_TAG_TABLE))) {
    if (!has_an_element_in_table_scope(parser, GUMBO_TAG_CAPTION)) {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    }
    while (!node_html_tag_is(pop_current_node(parser), GUMBO_TAG_CAPTION))
      ;
    clear_active_formatting_elements(parser);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_TABLE);
    parser->_parser_state->_reprocess_current_token = true;
    return true;
  } else if (tag_in(token, kEndTag,
                 (gumbo_tagset){TAG(BODY), TAG(COL), TAG(COLGROUP), TAG(HTML),
                     TAG(TBODY), TAG(TD), TAG(TFOOT), TAG(TH), TAG(THEAD),
                     TAG(TR)})) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else {
    return handle_in_body(parser, token);
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#parsing-main-incolgroup
static bool handle_in_column_group(GumboParser* parser, GumboToken* token) {
  if (token->type == GUMBO_TOKEN_WHITESPACE) {
    insert_text_token(parser, token);
    return true;
  } else if (token->type == GUMBO_TOKEN_DOCTYPE) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else if (token->type == GUMBO_TOKEN_COMMENT) {
    append_comment_node(parser, get_current_node(parser), token);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_HTML)) {
    return handle_in_body(parser, token);
  } else if (tag_is(token, kStartTag, GUMBO_TAG_COL)) {
    insert_element_from_token(parser, token);
    pop_current_node(parser);
    acknowledge_self_closing_tag(parser);
    return true;
  } else if (tag_is(token, kEndTag, GUMBO_TAG_COLGROUP)) {
    if (!node_html_tag_is(get_current_node(parser), GUMBO_TAG_COLGROUP)) {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    }
    pop_current_node(parser);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_TABLE);
    return false;
  } else if (tag_is(token, kEndTag, GUMBO_TAG_COL)) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_TEMPLATE) ||
             tag_is(token, kEndTag, GUMBO_TAG_TEMPLATE)) {
    return handle_in_head(parser, token);
  } else if (token->type == GUMBO_TOKEN_EOF) {
    return handle_in_body(parser, token);
  } else {
    if (!node_html_tag_is(get_current_node(parser), GUMBO_TAG_COLGROUP)) {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    }
    pop_current_node(parser);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_TABLE);
    parser->_parser_state->_reprocess_current_token = true;
    return true;
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#parsing-main-intbody
static bool handle_in_table_body(GumboParser* parser, GumboToken* token) {
  if (tag_is(token, kStartTag, GUMBO_TAG_TR)) {
    clear_stack_to_table_body_context(parser);
    insert_element_from_token(parser, token);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_ROW);
    return true;
  } else if (tag_in(token, kStartTag, (gumbo_tagset){TAG(TD), TAG(TH)})) {
    parser_add_parse_error(parser, token);
    clear_stack_to_table_body_context(parser);
    insert_element_of_tag_type(parser, GUMBO_TAG_TR, GUMBO_INSERTION_IMPLIED);
    parser->_parser_state->_reprocess_current_token = true;
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_ROW);
    return false;
  } else if (tag_in(token, kEndTag,
                 (gumbo_tagset){TAG(TBODY), TAG(TFOOT), TAG(THEAD)})) {
    if (!has_an_element_in_table_scope(parser, token->v.end_tag)) {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    }
    clear_stack_to_table_body_context(parser);
    pop_current_node(parser);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_TABLE);
    return true;
  } else if (tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(CAPTION), TAG(COL), TAG(COLGROUP),
                     TAG(TBODY), TAG(TFOOT), TAG(THEAD)}) ||
             tag_is(token, kEndTag, GUMBO_TAG_TABLE)) {
    if (!(has_an_element_in_table_scope(parser, GUMBO_TAG_TBODY) ||
            has_an_element_in_table_scope(parser, GUMBO_TAG_THEAD) ||
            has_an_element_in_table_scope(parser, GUMBO_TAG_TFOOT))) {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    }
    clear_stack_to_table_body_context(parser);
    pop_current_node(parser);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_TABLE);
    parser->_parser_state->_reprocess_current_token = true;
    return true;
  } else if (tag_in(token, kEndTag,
                 (gumbo_tagset){TAG(BODY), TAG(CAPTION), TAG(COL), TAG(TR),
                     TAG(COLGROUP), TAG(HTML), TAG(TD), TAG(TH)})) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else {
    return handle_in_table(parser, token);
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#parsing-main-intr
static bool handle_in_row(GumboParser* parser, GumboToken* token) {
  if (tag_in(token, kStartTag, (gumbo_tagset){TAG(TH), TAG(TD)})) {
    clear_stack_to_table_row_context(parser);
    insert_element_from_token(parser, token);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_CELL);
    add_formatting_element(parser, &kActiveFormattingScopeMarker);
    return true;
  } else if (tag_is(token, kEndTag, GUMBO_TAG_TR)) {
    if (!has_an_element_in_table_scope(parser, GUMBO_TAG_TR)) {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    } else {
      clear_stack_to_table_row_context(parser);
      pop_current_node(parser);
      set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_TABLE_BODY);
      return true;
    }
  } else if (tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(CAPTION), TAG(COL), TAG(COLGROUP),
                     TAG(TBODY), TAG(TFOOT), TAG(THEAD), TAG(TR)}) ||
             tag_is(token, kEndTag, GUMBO_TAG_TABLE)) {
    if (!has_an_element_in_table_scope(parser, GUMBO_TAG_TR)) {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    } else {
      clear_stack_to_table_row_context(parser);
      pop_current_node(parser);
      set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_TABLE_BODY);
      parser->_parser_state->_reprocess_current_token = true;
      return true;
    }
  } else if (tag_in(token, kEndTag,
                 (gumbo_tagset){TAG(TBODY), TAG(TFOOT), TAG(THEAD)})) {
    if (!has_an_element_in_table_scope(parser, token->v.end_tag) ||
        (!has_an_element_in_table_scope(parser, GUMBO_TAG_TR))) {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    } else {
      clear_stack_to_table_row_context(parser);
      pop_current_node(parser);
      set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_TABLE_BODY);
      parser->_parser_state->_reprocess_current_token = true;
      return true;
    }
  } else if (tag_in(token, kEndTag,
                 (gumbo_tagset){TAG(BODY), TAG(CAPTION), TAG(COL),
                     TAG(COLGROUP), TAG(HTML), TAG(TD), TAG(TH)})) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else {
    return handle_in_table(parser, token);
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#parsing-main-intd
static bool handle_in_cell(GumboParser* parser, GumboToken* token) {
  if (tag_in(token, kEndTag, (gumbo_tagset){TAG(TD), TAG(TH)})) {
    GumboTag token_tag = token->v.end_tag;
    if (!has_an_element_in_table_scope(parser, token_tag)) {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    }
    return close_table_cell(parser, token, token_tag);
  } else if (tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(CAPTION), TAG(COL), TAG(COLGROUP),
                     TAG(TBODY), TAG(TD), TAG(TFOOT), TAG(TH), TAG(THEAD),
                     TAG(TR)})) {
    gumbo_debug("Handling <td> in cell.\n");
    if (!has_an_element_in_table_scope(parser, GUMBO_TAG_TH) &&
        !has_an_element_in_table_scope(parser, GUMBO_TAG_TD)) {
      gumbo_debug("Bailing out because there's no <td> or <th> in scope.\n");
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    }
    parser->_parser_state->_reprocess_current_token = true;
    return close_current_cell(parser, token);
  } else if (tag_in(token, kEndTag, (gumbo_tagset){TAG(BODY), TAG(CAPTION),
                                        TAG(COL), TAG(COLGROUP), TAG(HTML)})) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else if (tag_in(token, kEndTag, (gumbo_tagset){TAG(TABLE), TAG(TBODY),
                                        TAG(TFOOT), TAG(THEAD), TAG(TR)})) {
    if (!has_an_element_in_table_scope(parser, token->v.end_tag)) {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    }
    parser->_parser_state->_reprocess_current_token = true;
    return close_current_cell(parser, token);
  } else {
    return handle_in_body(parser, token);
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#parsing-main-inselect
static bool handle_in_select(GumboParser* parser, GumboToken* token) {
  if (token->type == GUMBO_TOKEN_NULL) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else if (token->type == GUMBO_TOKEN_CHARACTER ||
             token->type == GUMBO_TOKEN_WHITESPACE) {
    insert_text_token(parser, token);
    return true;
  } else if (token->type == GUMBO_TOKEN_DOCTYPE) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else if (token->type == GUMBO_TOKEN_COMMENT) {
    append_comment_node(parser, get_current_node(parser), token);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_HTML)) {
    return handle_in_body(parser, token);
  } else if (tag_is(token, kStartTag, GUMBO_TAG_OPTION)) {
    if (node_html_tag_is(get_current_node(parser), GUMBO_TAG_OPTION)) {
      pop_current_node(parser);
    }
    insert_element_from_token(parser, token);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_OPTGROUP)) {
    if (node_html_tag_is(get_current_node(parser), GUMBO_TAG_OPTION)) {
      pop_current_node(parser);
    }
    if (node_html_tag_is(get_current_node(parser), GUMBO_TAG_OPTGROUP)) {
      pop_current_node(parser);
    }
    insert_element_from_token(parser, token);
    return true;
  } else if (tag_is(token, kEndTag, GUMBO_TAG_OPTGROUP)) {
    GumboVector* open_elements = &parser->_parser_state->_open_elements;
    if (node_html_tag_is(get_current_node(parser), GUMBO_TAG_OPTION) &&
        node_html_tag_is(open_elements->data[open_elements->length - 2],
            GUMBO_TAG_OPTGROUP)) {
      pop_current_node(parser);
    }
    if (node_html_tag_is(get_current_node(parser), GUMBO_TAG_OPTGROUP)) {
      pop_current_node(parser);
      return true;
    } else {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    }
  } else if (tag_is(token, kEndTag, GUMBO_TAG_OPTION)) {
    if (node_html_tag_is(get_current_node(parser), GUMBO_TAG_OPTION)) {
      pop_current_node(parser);
      return true;
    } else {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    }
  } else if (tag_is(token, kEndTag, GUMBO_TAG_SELECT)) {
    if (!has_an_element_in_select_scope(parser, GUMBO_TAG_SELECT)) {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    }
    close_current_select(parser);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_SELECT)) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    if (has_an_element_in_select_scope(parser, GUMBO_TAG_SELECT)) {
      close_current_select(parser);
    }
    return false;
  } else if (tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(INPUT), TAG(KEYGEN), TAG(TEXTAREA)})) {
    parser_add_parse_error(parser, token);
    if (!has_an_element_in_select_scope(parser, GUMBO_TAG_SELECT)) {
      ignore_token(parser);
    } else {
      close_current_select(parser);
      parser->_parser_state->_reprocess_current_token = true;
    }
    return false;
  } else if (tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(SCRIPT), TAG(TEMPLATE)}) ||
             tag_is(token, kEndTag, GUMBO_TAG_TEMPLATE)) {
    return handle_in_head(parser, token);
  } else if (token->type == GUMBO_TOKEN_EOF) {
    return handle_in_body(parser, token);
  } else {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#parsing-main-inselectintable
static bool handle_in_select_in_table(GumboParser* parser, GumboToken* token) {
  if (tag_in(token, kStartTag,
          (gumbo_tagset){TAG(CAPTION), TAG(TABLE), TAG(TBODY), TAG(TFOOT),
              TAG(THEAD), TAG(TR), TAG(TD), TAG(TH)})) {
    parser_add_parse_error(parser, token);
    close_current_select(parser);
    parser->_parser_state->_reprocess_current_token = true;
    return false;
  } else if (tag_in(token, kEndTag,
                 (gumbo_tagset){TAG(CAPTION), TAG(TABLE), TAG(TBODY),
                     TAG(TFOOT), TAG(THEAD), TAG(TR), TAG(TD), TAG(TH)})) {
    parser_add_parse_error(parser, token);
    if (!has_an_element_in_table_scope(parser, token->v.end_tag)) {
      ignore_token(parser);
      return false;
    } else {
      close_current_select(parser);
      // close_current_select already does the
      // reset_insertion_mode_appropriately
      // reset_insertion_mode_appropriately(parser);
      parser->_parser_state->_reprocess_current_token = true;
      return false;
    }
  } else {
    return handle_in_select(parser, token);
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/multipage/tree-construction.html#parsing-main-intemplate
static bool handle_in_template(GumboParser* parser, GumboToken* token) {
  GumboParserState* state = parser->_parser_state;
  if (token->type == GUMBO_TOKEN_WHITESPACE ||
      token->type == GUMBO_TOKEN_CHARACTER ||
      token->type == GUMBO_TOKEN_COMMENT || token->type == GUMBO_TOKEN_NULL ||
      token->type == GUMBO_TOKEN_DOCTYPE) {
    return handle_in_body(parser, token);
  } else if (tag_in(token, kStartTag,
                 (gumbo_tagset){TAG(BASE), TAG(BASEFONT), TAG(BGSOUND),
                     TAG(LINK), TAG(META), TAG(NOFRAMES), TAG(SCRIPT),
                     TAG(STYLE), TAG(TEMPLATE), TAG(TITLE)}) ||
             tag_is(token, kEndTag, GUMBO_TAG_TEMPLATE)) {
    return handle_in_head(parser, token);
  } else if (tag_in(
                 token, kStartTag, (gumbo_tagset){TAG(CAPTION), TAG(COLGROUP),
                                       TAG(TBODY), TAG(TFOOT), TAG(THEAD)})) {
    pop_template_insertion_mode(parser);
    push_template_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_TABLE);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_TABLE);
    state->_reprocess_current_token = true;
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_COL)) {
    pop_template_insertion_mode(parser);
    push_template_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_COLUMN_GROUP);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_COLUMN_GROUP);
    state->_reprocess_current_token = true;
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_TR)) {
    pop_template_insertion_mode(parser);
    push_template_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_TABLE_BODY);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_TABLE_BODY);
    state->_reprocess_current_token = true;
    return true;
  } else if (tag_in(token, kStartTag, (gumbo_tagset){TAG(TD), TAG(TH)})) {
    pop_template_insertion_mode(parser);
    push_template_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_ROW);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_ROW);
    state->_reprocess_current_token = true;
    return true;
  } else if (token->type == GUMBO_TOKEN_START_TAG) {
    pop_template_insertion_mode(parser);
    push_template_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_BODY);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_BODY);
    state->_reprocess_current_token = true;
    return true;
  } else if (token->type == GUMBO_TOKEN_END_TAG) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else if (token->type == GUMBO_TOKEN_EOF) {
    if (!has_open_element(parser, GUMBO_TAG_TEMPLATE)) {
      // Stop parsing.
      return true;
    }
    parser_add_parse_error(parser, token);
    while (!node_html_tag_is(pop_current_node(parser), GUMBO_TAG_TEMPLATE))
      ;
    clear_active_formatting_elements(parser);
    pop_template_insertion_mode(parser);
    reset_insertion_mode_appropriately(parser);
    state->_reprocess_current_token = true;
    return false;
  } else {
    assert(0);
    return false;
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#parsing-main-afterbody
static bool handle_after_body(GumboParser* parser, GumboToken* token) {
  if (token->type == GUMBO_TOKEN_WHITESPACE ||
      tag_is(token, kStartTag, GUMBO_TAG_HTML)) {
    return handle_in_body(parser, token);
  } else if (token->type == GUMBO_TOKEN_COMMENT) {
    GumboNode* html_node = parser->_output->root;
    assert(html_node != NULL);
    append_comment_node(parser, html_node, token);
    return true;
  } else if (token->type == GUMBO_TOKEN_DOCTYPE) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else if (tag_is(token, kEndTag, GUMBO_TAG_HTML)) {
    /* fragment case: ignore the closing HTML token */
    if (is_fragment_parser(parser)) {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    }
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_AFTER_AFTER_BODY);
    GumboNode* html = parser->_parser_state->_open_elements.data[0];
    assert(node_html_tag_is(html, GUMBO_TAG_HTML));
    record_end_of_element(
        parser->_parser_state->_current_token, &html->v.element);
    return true;
  } else if (token->type == GUMBO_TOKEN_EOF) {
    return true;
  } else {
    parser_add_parse_error(parser, token);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_BODY);
    parser->_parser_state->_reprocess_current_token = true;
    return false;
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#parsing-main-inframeset
static bool handle_in_frameset(GumboParser* parser, GumboToken* token) {
  if (token->type == GUMBO_TOKEN_WHITESPACE) {
    insert_text_token(parser, token);
    return true;
  } else if (token->type == GUMBO_TOKEN_COMMENT) {
    append_comment_node(parser, get_current_node(parser), token);
    return true;
  } else if (token->type == GUMBO_TOKEN_DOCTYPE) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_HTML)) {
    return handle_in_body(parser, token);
  } else if (tag_is(token, kStartTag, GUMBO_TAG_FRAMESET)) {
    insert_element_from_token(parser, token);
    return true;
  } else if (tag_is(token, kEndTag, GUMBO_TAG_FRAMESET)) {
    if (node_html_tag_is(get_current_node(parser), GUMBO_TAG_HTML)) {
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    }
    pop_current_node(parser);
    if (!is_fragment_parser(parser) &&
        !node_html_tag_is(get_current_node(parser), GUMBO_TAG_FRAMESET)) {
      set_insertion_mode(parser, GUMBO_INSERTION_MODE_AFTER_FRAMESET);
    }
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_FRAME)) {
    insert_element_from_token(parser, token);
    pop_current_node(parser);
    acknowledge_self_closing_tag(parser);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_NOFRAMES)) {
    return handle_in_head(parser, token);
  } else if (token->type == GUMBO_TOKEN_EOF) {
    if (!node_html_tag_is(get_current_node(parser), GUMBO_TAG_HTML)) {
      parser_add_parse_error(parser, token);
      return false;
    }
    return true;
  } else {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#parsing-main-afterframeset
static bool handle_after_frameset(GumboParser* parser, GumboToken* token) {
  if (token->type == GUMBO_TOKEN_WHITESPACE) {
    insert_text_token(parser, token);
    return true;
  } else if (token->type == GUMBO_TOKEN_COMMENT) {
    append_comment_node(parser, get_current_node(parser), token);
    return true;
  } else if (token->type == GUMBO_TOKEN_DOCTYPE) {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_HTML)) {
    return handle_in_body(parser, token);
  } else if (tag_is(token, kEndTag, GUMBO_TAG_HTML)) {
    GumboNode* html = parser->_parser_state->_open_elements.data[0];
    assert(node_html_tag_is(html, GUMBO_TAG_HTML));
    record_end_of_element(
        parser->_parser_state->_current_token, &html->v.element);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_AFTER_AFTER_FRAMESET);
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_NOFRAMES)) {
    return handle_in_head(parser, token);
  } else if (token->type == GUMBO_TOKEN_EOF) {
    return true;
  } else {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#the-after-after-body-insertion-mode
static bool handle_after_after_body(GumboParser* parser, GumboToken* token) {
  if (token->type == GUMBO_TOKEN_COMMENT) {
    append_comment_node(parser, get_document_node(parser), token);
    return true;
  } else if (token->type == GUMBO_TOKEN_DOCTYPE ||
             token->type == GUMBO_TOKEN_WHITESPACE ||
             tag_is(token, kStartTag, GUMBO_TAG_HTML)) {
    return handle_in_body(parser, token);
  } else if (token->type == GUMBO_TOKEN_EOF) {
    return true;
  } else {
    parser_add_parse_error(parser, token);
    set_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_BODY);
    parser->_parser_state->_reprocess_current_token = true;
    return false;
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#the-after-after-frameset-insertion-mode
static bool handle_after_after_frameset(
    GumboParser* parser, GumboToken* token) {
  if (token->type == GUMBO_TOKEN_COMMENT) {
    append_comment_node(parser, get_document_node(parser), token);
    return true;
  } else if (token->type == GUMBO_TOKEN_DOCTYPE ||
             token->type == GUMBO_TOKEN_WHITESPACE ||
             tag_is(token, kStartTag, GUMBO_TAG_HTML)) {
    return handle_in_body(parser, token);
  } else if (token->type == GUMBO_TOKEN_EOF) {
    return true;
  } else if (tag_is(token, kStartTag, GUMBO_TAG_NOFRAMES)) {
    return handle_in_head(parser, token);
  } else {
    parser_add_parse_error(parser, token);
    ignore_token(parser);
    return false;
  }
}

// Function pointers for each insertion mode.  Keep in sync with
// insertion_mode.h.
typedef bool (*TokenHandler)(GumboParser* parser, GumboToken* token);
static const TokenHandler kTokenHandlers[] = {handle_initial,
    handle_before_html, handle_before_head, handle_in_head,
    handle_in_head_noscript, handle_after_head, handle_in_body, handle_text,
    handle_in_table, handle_in_table_text, handle_in_caption,
    handle_in_column_group, handle_in_table_body, handle_in_row, handle_in_cell,
    handle_in_select, handle_in_select_in_table, handle_in_template,
    handle_after_body, handle_in_frameset, handle_after_frameset,
    handle_after_after_body, handle_after_after_frameset};

static bool handle_html_content(GumboParser* parser, GumboToken* token) {
  return kTokenHandlers[(unsigned int) parser->_parser_state->_insertion_mode](
      parser, token);
}

// http://www.whatwg.org/specs/web-apps/current-work/complete/tokenization.html#parsing-main-inforeign
static bool handle_in_foreign_content(GumboParser* parser, GumboToken* token) {
  gumbo_debug("Handling foreign content");
  switch (token->type) {
    case GUMBO_TOKEN_NULL:
      parser_add_parse_error(parser, token);
      token->v.character = kUtf8ReplacementChar;
      insert_text_token(parser, token);
      return false;
    case GUMBO_TOKEN_WHITESPACE:
      insert_text_token(parser, token);
      return true;
    case GUMBO_TOKEN_CDATA:
    case GUMBO_TOKEN_CHARACTER:
      insert_text_token(parser, token);
      set_frameset_not_ok(parser);
      return true;
    case GUMBO_TOKEN_COMMENT:
      append_comment_node(parser, get_current_node(parser), token);
      return true;
    case GUMBO_TOKEN_DOCTYPE:
      parser_add_parse_error(parser, token);
      ignore_token(parser);
      return false;
    default:
      // Fall through to the if-statements below.
      break;
  }
  // Order matters for these clauses.
  if (tag_in(token, kStartTag,
          (gumbo_tagset){TAG(B), TAG(BIG), TAG(BLOCKQUOTE), TAG(BODY), TAG(BR),
              TAG(CENTER), TAG(CODE), TAG(DD), TAG(DIV), TAG(DL), TAG(DT),
              TAG(EM), TAG(EMBED), TAG(H1), TAG(H2), TAG(H3), TAG(H4), TAG(H5),
              TAG(H6), TAG(HEAD), TAG(HR), TAG(I), TAG(IMG), TAG(LI),
              TAG(LISTING), TAG(MENU), TAG(META), TAG(NOBR), TAG(OL), TAG(P),
              TAG(PRE), TAG(RUBY), TAG(S), TAG(SMALL), TAG(SPAN), TAG(STRONG),
              TAG(STRIKE), TAG(SUB), TAG(SUP), TAG(TABLE), TAG(TT), TAG(U),
              TAG(UL), TAG(VAR)}) ||
      (tag_is(token, kStartTag, GUMBO_TAG_FONT) &&
          (token_has_attribute(token, "color") ||
              token_has_attribute(token, "face") ||
              token_has_attribute(token, "size")))) {
    /* Parse error */
    parser_add_parse_error(parser, token);

    /*
     * Fragment case: If the parser was originally created for the HTML
     * fragment parsing algorithm, then act as described in the "any other
     * start tag" entry below.
     */
    if (!is_fragment_parser(parser)) {
      do {
        pop_current_node(parser);
      } while (!(is_mathml_integration_point(get_current_node(parser)) ||
                   is_html_integration_point(get_current_node(parser)) ||
                   get_current_node(parser)->v.element.tag_namespace ==
                       GUMBO_NAMESPACE_HTML));
      parser->_parser_state->_reprocess_current_token = true;
      return false;
    }

    assert(token->type == GUMBO_TOKEN_START_TAG);
  }

  if (token->type == GUMBO_TOKEN_START_TAG) {
    const GumboNamespaceEnum current_namespace =
        get_adjusted_current_node(parser)->v.element.tag_namespace;
    if (current_namespace == GUMBO_NAMESPACE_MATHML) {
      adjust_mathml_attributes(parser, token);
    }
    if (current_namespace == GUMBO_NAMESPACE_SVG) {
      // Tag adjustment is left to the gumbo_normalize_svg_tagname helper
      // function.
      adjust_svg_attributes(parser, token);
    }
    adjust_foreign_attributes(parser, token);
    insert_foreign_element(parser, token, current_namespace);
    if (token->v.start_tag.is_self_closing) {
      pop_current_node(parser);
      acknowledge_self_closing_tag(parser);
    }
    return true;
    // </script> tags are handled like any other end tag, putting the script's
    // text into a text node child and closing the current node.
  } else {
    assert(token->type == GUMBO_TOKEN_END_TAG);
    GumboNode* node = get_current_node(parser);
    assert(node != NULL);
    GumboStringPiece token_tagname = token->original_text;
    GumboStringPiece node_tagname = node->v.element.original_tag;
    gumbo_tag_from_original_text(&token_tagname);
    gumbo_tag_from_original_text(&node_tagname);

    bool is_success = true;
    if (!gumbo_string_equals_ignore_case(&node_tagname, &token_tagname)) {
      parser_add_parse_error(parser, token);
      is_success = false;
    }
    int i = parser->_parser_state->_open_elements.length;
    for (--i; i > 0;) {
      // Here we move up the stack until we find an HTML element (in which
      // case we do nothing) or we find the element that we're about to
      // close (in which case we pop everything we've seen until that
      // point.)
      gumbo_debug("Foreign %.*s node at %d.\n", node_tagname.length,
          node_tagname.data, i);
      if (gumbo_string_equals_ignore_case(&node_tagname, &token_tagname)) {
        gumbo_debug("Matches.\n");
        while (pop_current_node(parser) != node) {
          // Pop all the nodes below the current one.  Node is guaranteed to
          // be an element on the stack of open elements (set below), so
          // this loop is guaranteed to terminate.
        }
        return is_success;
      }
      --i;
      node = parser->_parser_state->_open_elements.data[i];
      if (node->v.element.tag_namespace == GUMBO_NAMESPACE_HTML) {
        // Must break before gumbo_tag_from_original_text to avoid passing
        // parser-inserted nodes through.
        break;
      }
      node_tagname = node->v.element.original_tag;
      gumbo_tag_from_original_text(&node_tagname);
    }
    assert(node->v.element.tag_namespace == GUMBO_NAMESPACE_HTML);
    // We can't call handle_token directly because the current node is still in
    // the SVG namespace, so it would re-enter this and result in infinite
    // recursion.
    return handle_html_content(parser, token) && is_success;
  }
}

// http://www.whatwg.org/specs/web-apps/current-work/multipage/tree-construction.html#tree-construction
static bool handle_token(GumboParser* parser, GumboToken* token) {
  if (parser->_parser_state->_ignore_next_linefeed &&
      token->type == GUMBO_TOKEN_WHITESPACE && token->v.character == '\n') {
    parser->_parser_state->_ignore_next_linefeed = false;
    ignore_token(parser);
    return true;
  }
  // This needs to be reset both here and in the conditional above to catch both
  // the case where the next token is not whitespace (so we don't ignore
  // whitespace in the middle of <pre> tags) and where there are multiple
  // whitespace tokens (so we don't ignore the second one).
  parser->_parser_state->_ignore_next_linefeed = false;

  if (tag_is(token, kEndTag, GUMBO_TAG_BODY)) {
    parser->_parser_state->_closed_body_tag = true;
  }
  if (tag_is(token, kEndTag, GUMBO_TAG_HTML)) {
    parser->_parser_state->_closed_html_tag = true;
  }

  const GumboNode* current_node = get_adjusted_current_node(parser);
  assert(!current_node || current_node->type == GUMBO_NODE_ELEMENT ||
         current_node->type == GUMBO_NODE_TEMPLATE);
  if (current_node) {
    gumbo_debug("Current node: <%s>.\n",
        gumbo_normalized_tagname(current_node->v.element.tag));
  }
  if (!current_node ||
      current_node->v.element.tag_namespace == GUMBO_NAMESPACE_HTML ||
      (is_mathml_integration_point(current_node) &&
          (token->type == GUMBO_TOKEN_CHARACTER ||
              token->type == GUMBO_TOKEN_WHITESPACE ||
              token->type == GUMBO_TOKEN_NULL ||
              (token->type == GUMBO_TOKEN_START_TAG &&
                  !tag_in(token, kStartTag,
                      (gumbo_tagset){TAG(MGLYPH), TAG(MALIGNMARK)})))) ||
      (current_node->v.element.tag_namespace == GUMBO_NAMESPACE_MATHML &&
          node_qualified_tag_is(
              current_node, GUMBO_NAMESPACE_MATHML, GUMBO_TAG_ANNOTATION_XML) &&
          tag_is(token, kStartTag, GUMBO_TAG_SVG)) ||
      (is_html_integration_point(current_node) &&
          (token->type == GUMBO_TOKEN_START_TAG ||
              token->type == GUMBO_TOKEN_CHARACTER ||
              token->type == GUMBO_TOKEN_NULL ||
              token->type == GUMBO_TOKEN_WHITESPACE)) ||
      token->type == GUMBO_TOKEN_EOF) {
    return handle_html_content(parser, token);
  } else {
    return handle_in_foreign_content(parser, token);
  }
}

static void fragment_parser_init(GumboParser* parser, GumboTag fragment_ctx,
    GumboNamespaceEnum fragment_namespace) {
  GumboNode* root;
  assert(fragment_ctx != GUMBO_TAG_LAST);

  // 3
  parser->_parser_state->_fragment_ctx = create_element(parser, fragment_ctx);
  parser->_parser_state->_fragment_ctx->v.element.tag_namespace =
      fragment_namespace;

  // 4
  if (fragment_namespace == GUMBO_NAMESPACE_HTML) {
    // Non-HTML namespaces always start in the DATA state.
    switch (fragment_ctx) {
      case GUMBO_TAG_TITLE:
      case GUMBO_TAG_TEXTAREA:
        gumbo_tokenizer_set_state(parser, GUMBO_LEX_RCDATA);
        break;

      case GUMBO_TAG_STYLE:
      case GUMBO_TAG_XMP:
      case GUMBO_TAG_IFRAME:
      case GUMBO_TAG_NOEMBED:
      case GUMBO_TAG_NOFRAMES:
        gumbo_tokenizer_set_state(parser, GUMBO_LEX_RAWTEXT);
        break;

      case GUMBO_TAG_SCRIPT:
        gumbo_tokenizer_set_state(parser, GUMBO_LEX_SCRIPT);
        break;

      case GUMBO_TAG_NOSCRIPT:
        /* scripting is disabled in Gumbo, so leave the tokenizer
         * in the default data state */
        break;

      case GUMBO_TAG_PLAINTEXT:
        gumbo_tokenizer_set_state(parser, GUMBO_LEX_PLAINTEXT);
        break;

      default:
        /* default data state */
        break;
    }
  }

  // 5. 6. 7.
  root = insert_element_of_tag_type(
      parser, GUMBO_TAG_HTML, GUMBO_INSERTION_IMPLIED);
  parser->_output->root = root;

  // 8.
  if (fragment_ctx == GUMBO_TAG_TEMPLATE) {
    push_template_insertion_mode(parser, GUMBO_INSERTION_MODE_IN_TEMPLATE);
  }

  // 10.
  reset_insertion_mode_appropriately(parser);
}

GumboOutput* gumbo_parse(const char* buffer) {
  return gumbo_parse_with_options(
      &kGumboDefaultOptions, buffer, strlen(buffer));
}

GumboOutput* gumbo_parse_with_options(
    const GumboOptions* options, const char* buffer, size_t length) {
  GumboParser parser;
  parser._options = options;
  output_init(&parser);
  gumbo_tokenizer_state_init(&parser, buffer, length);
  parser_state_init(&parser);

  if (options->fragment_context != GUMBO_TAG_LAST) {
    fragment_parser_init(
        &parser, options->fragment_context, options->fragment_namespace);
  }

  GumboParserState* state = parser._parser_state;
  gumbo_debug("Parsing %.*s.\n", length, buffer);

  // Sanity check so that infinite loops die with an assertion failure instead
  // of hanging the process before we ever get an error.
  int loop_count = 0;

  GumboToken token;
  bool has_error = false;

  do {
    if (state->_reprocess_current_token) {
      state->_reprocess_current_token = false;
    } else {
      GumboNode* current_node = get_current_node(&parser);
      gumbo_tokenizer_set_is_current_node_foreign(&parser,
          current_node &&
              current_node->v.element.tag_namespace != GUMBO_NAMESPACE_HTML);
      has_error = !gumbo_lex(&parser, &token) || has_error;
    }
    const char* token_type = "text";
    switch (token.type) {
      case GUMBO_TOKEN_DOCTYPE:
        token_type = "doctype";
        break;
      case GUMBO_TOKEN_START_TAG:
        token_type = gumbo_normalized_tagname(token.v.start_tag.tag);
        break;
      case GUMBO_TOKEN_END_TAG:
        token_type = gumbo_normalized_tagname(token.v.end_tag);
        break;
      case GUMBO_TOKEN_COMMENT:
        token_type = "comment";
        break;
      default:
        break;
    }
    gumbo_debug("Handling %s token @%d:%d in state %d.\n", (char*) token_type,
        token.position.line, token.position.column, state->_insertion_mode);

    state->_current_token = &token;
    state->_self_closing_flag_acknowledged =
        !(token.type == GUMBO_TOKEN_START_TAG &&
            token.v.start_tag.is_self_closing);

    has_error = !handle_token(&parser, &token) || has_error;

    // Check for memory leaks when ownership is transferred from start tag
    // tokens to nodes.
    assert(state->_reprocess_current_token ||
           token.type != GUMBO_TOKEN_START_TAG ||
           token.v.start_tag.attributes.data == NULL);

    if (!state->_self_closing_flag_acknowledged) {
      GumboError* error = parser_add_parse_error(&parser, &token);
      if (error) {
        error->type = GUMBO_ERR_UNACKNOWLEDGED_SELF_CLOSING_TAG;
      }
    }

    ++loop_count;
    assert(loop_count < 1000000000);

  } while ((token.type != GUMBO_TOKEN_EOF || state->_reprocess_current_token) &&
           !(options->stop_on_first_error && has_error));

  finish_parsing(&parser);
  // For API uniformity reasons, if the doctype still has nulls, convert them to
  // empty strings.
  GumboDocument* doc_type = &parser._output->document->v.document;
  if (doc_type->name == NULL) {
    doc_type->name = gumbo_copy_stringz(&parser, "");
  }
  if (doc_type->public_identifier == NULL) {
    doc_type->public_identifier = gumbo_copy_stringz(&parser, "");
  }
  if (doc_type->system_identifier == NULL) {
    doc_type->system_identifier = gumbo_copy_stringz(&parser, "");
  }

  parser_state_destroy(&parser);
  gumbo_tokenizer_state_destroy(&parser);
  return parser._output;
}

void gumbo_destroy_node(GumboOptions* options, GumboNode* node) {
  // Need a dummy GumboParser because the allocator comes along with the
  // options object.
  GumboParser parser;
  parser._options = options;
  destroy_node(&parser, node);
}

void gumbo_destroy_output(const GumboOptions* options, GumboOutput* output) {
  // Need a dummy GumboParser because the allocator comes along with the
  // options object.
  GumboParser parser;
  parser._options = options;
  destroy_node(&parser, output->document);
  for (unsigned int i = 0; i < output->errors.length; ++i) {
    gumbo_error_destroy(&parser, output->errors.data[i]);
  }
  gumbo_vector_destroy(&parser, &output->errors);
  gumbo_parser_deallocate(&parser, output);
}

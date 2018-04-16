#ifndef HAVE_XMLFIRSTELEMENTCHILD

#ifndef XML_LIBXML2_HACKS
#define XML_LIBXML2_HACKS

xmlNodePtr xmlFirstElementChild(xmlNodePtr parent);
xmlNodePtr xmlNextElementSibling(xmlNodePtr node);
xmlNodePtr xmlLastElementChild(xmlNodePtr parent);

#endif

#endif

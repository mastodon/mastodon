#ifndef HAVE_XMLFIRSTELEMENTCHILD
#include <libxml/tree.h>
/**
 * xmlFirstElementChild:
 * @parent: the parent node
 *
 * Finds the first child node of that element which is a Element node
 * Note the handling of entities references is different than in
 * the W3C DOM element traversal spec since we don't have back reference
 * from entities content to entities references.
 *
 * Returns the first element child or NULL if not available
 */
xmlNodePtr
xmlFirstElementChild(xmlNodePtr parent) {
    xmlNodePtr cur = NULL;

    if (parent == NULL)
        return(NULL);
    switch (parent->type) {
        case XML_ELEMENT_NODE:
        case XML_ENTITY_NODE:
        case XML_DOCUMENT_NODE:
        case XML_HTML_DOCUMENT_NODE:
            cur = parent->children;
            break;
        default:
            return(NULL);
    }
    while (cur != NULL) {
        if (cur->type == XML_ELEMENT_NODE)
            return(cur);
        cur = cur->next;
    }
    return(NULL);
}

/**
 * xmlNextElementSibling:
 * @node: the current node
 *
 * Finds the first closest next sibling of the node which is an
 * element node.
 * Note the handling of entities references is different than in
 * the W3C DOM element traversal spec since we don't have back reference
 * from entities content to entities references.
 *
 * Returns the next element sibling or NULL if not available
 */
xmlNodePtr
xmlNextElementSibling(xmlNodePtr node) {
    if (node == NULL)
        return(NULL);
    switch (node->type) {
        case XML_ELEMENT_NODE:
        case XML_TEXT_NODE:
        case XML_CDATA_SECTION_NODE:
        case XML_ENTITY_REF_NODE:
        case XML_ENTITY_NODE:
        case XML_PI_NODE:
        case XML_COMMENT_NODE:
        case XML_DTD_NODE:
        case XML_XINCLUDE_START:
        case XML_XINCLUDE_END:
            node = node->next;
            break;
        default:
            return(NULL);
    }
    while (node != NULL) {
        if (node->type == XML_ELEMENT_NODE)
            return(node);
        node = node->next;
    }
    return(NULL);
}

/**
 * xmlLastElementChild:
 * @parent: the parent node
 *
 * Finds the last child node of that element which is a Element node
 * Note the handling of entities references is different than in
 * the W3C DOM element traversal spec since we don't have back reference
 * from entities content to entities references.
 *
 * Returns the last element child or NULL if not available
 */
xmlNodePtr
xmlLastElementChild(xmlNodePtr parent) {
    xmlNodePtr cur = NULL;

    if (parent == NULL)
        return(NULL);
    switch (parent->type) {
        case XML_ELEMENT_NODE:
        case XML_ENTITY_NODE:
        case XML_DOCUMENT_NODE:
        case XML_HTML_DOCUMENT_NODE:
            cur = parent->last;
            break;
        default:
            return(NULL);
    }
    while (cur != NULL) {
        if (cur->type == XML_ELEMENT_NODE)
            return(cur);
        cur = cur->prev;
    }
    return(NULL);
}
#endif

import React from 'react';

// NB: This function can still return unsafe HTML
export const unescapeHTML = (html: string) => {
  const wrapper = document.createElement('div');
  wrapper.innerHTML = html
    .replace(/<br\s*\/?>/g, '\n')
    .replace(/<\/p><p>/g, '\n\n')
    .replace(/<[^>]*>/g, '');
  return wrapper.textContent;
};

interface QueueItem {
  node: Node;
  parent: React.ReactNode[];
  depth: number;
}

interface Options {
  maxDepth?: number;
  onText?: (text: string) => React.ReactNode;
  onElement?: (
    element: HTMLElement,
    children: React.ReactNode[],
  ) => React.ReactNode;
  onAttribute?: (
    name: string,
    value: string,
    tagName: string,
  ) => [string, unknown] | null;
  allowedTags?: Set<string>;
}
const DEFAULT_ALLOWED_TAGS: ReadonlySet<string> = new Set([
  'a',
  'abbr',
  'b',
  'blockquote',
  'br',
  'cite',
  'code',
  'del',
  'dfn',
  'dl',
  'dt',
  'em',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'hr',
  'i',
  'li',
  'ol',
  'p',
  'pre',
  'small',
  'span',
  'strong',
  'sub',
  'sup',
  'time',
  'u',
  'ul',
]);

export function htmlStringToComponents(
  htmlString: string,
  options: Options = {},
) {
  const wrapper = document.createElement('template');
  wrapper.innerHTML = htmlString;

  const rootChildren: React.ReactNode[] = [];
  const queue: QueueItem[] = [
    { node: wrapper.content, parent: rootChildren, depth: 0 },
  ];

  const {
    maxDepth = 10,
    allowedTags = DEFAULT_ALLOWED_TAGS,
    onAttribute,
    onElement,
    onText,
  } = options;

  while (queue.length > 0) {
    const item = queue.shift();
    if (!item) {
      break;
    }

    const { node, parent, depth } = item;
    // If maxDepth is exceeded, skip processing this node.
    if (depth > maxDepth) {
      continue;
    }

    switch (node.nodeType) {
      // Just process children for fragments.
      case Node.DOCUMENT_FRAGMENT_NODE: {
        for (const child of node.childNodes) {
          queue.push({ node: child, parent, depth: depth + 1 });
        }
        break;
      }

      // Text can be added directly if it has any non-whitespace content.
      case Node.TEXT_NODE: {
        const text = node.textContent;
        if (text && text.trim() !== '') {
          if (onText) {
            parent.push(onText(text));
          } else {
            parent.push(text);
          }
        }
        break;
      }

      // Process elements with attributes and then their children.
      case Node.ELEMENT_NODE: {
        if (!(node instanceof HTMLElement)) {
          console.warn('Expected HTMLElement, got', node);
          continue;
        }

        // If the tag is not allowed, skip it and its children.
        if (!allowedTags.has(node.tagName.toLowerCase())) {
          continue;
        }

        // Create the element and add it to the parent.
        const children: React.ReactNode[] = [];
        let element: React.ReactNode = undefined;

        // If onElement is provided, use it to create the element.
        if (onElement) {
          const component = onElement(node, children);
          // Check for undefined to allow returning null.
          if (component !== undefined) {
            element = component;
          }
        }

        // If the element wasn't created, use the default conversion.
        if (element === undefined) {
          const props: Record<string, unknown> = {};
          for (const attr of node.attributes) {
            if (onAttribute) {
              const result = onAttribute(
                attr.name,
                attr.value,
                node.tagName.toLowerCase(),
              );
              if (result) {
                const [name, value] = result;
                props[name] = value;
              }
            } else {
              props[attr.name] = attr.value;
            }
          }
          element = React.createElement(
            node.tagName.toLowerCase(),
            props,
            children,
          );
        }

        // Push the element to the parent.
        parent.push(element);

        // Iterate over the node children with the newly created component.
        for (const child of node.childNodes) {
          queue.push({ node: child, parent: children, depth: depth + 1 });
        }
        break;
      }
    }
  }

  return rootChildren;
}

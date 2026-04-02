import type { Key } from 'react';
import { useCallback } from 'react';

import htmlConfig from '@/config/html-tags.json';
import type { OnElementHandler } from '@/mastodon/utils/html';

export function useFieldHtml(
  hasCustomEmoji: boolean,
  onElement?: OnElementHandler,
): OnElementHandler {
  return useCallback(
    (element, props, children, extra) => {
      if (element instanceof HTMLAnchorElement) {
        // Don't allow custom emoji and links in the same field to prevent verification spoofing.
        if (hasCustomEmoji) {
          return (
            <span {...filterAttributesForSpan(props)} key={props.key as Key}>
              {children}
            </span>
          );
        }
        return onElement?.(element, props, children, extra);
      }
      return undefined;
    },
    [onElement, hasCustomEmoji],
  );
}

function filterAttributesForSpan(props: Record<string, unknown>) {
  const validAttributes: Record<string, unknown> = {};
  for (const key of Object.keys(props)) {
    if (key in htmlConfig.tags.span.attributes) {
      validAttributes[key] = props[key];
    }
  }
  return validAttributes;
}

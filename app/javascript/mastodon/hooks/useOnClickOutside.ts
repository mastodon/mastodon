/**
 * Handle clicks that occur outside of the element(s) provided in the first parameter
 */

import type { RefObject } from 'react';
import { useEffect, useEffectEvent } from 'react';

type PlainElement = Element | null;
type ElementOrRef = PlainElement | RefObject<PlainElement>;

export function useOnClickOutside(
  excludedElements: ElementOrRef | ElementOrRef[],
  onClick: (e: MouseEvent) => void,
  enabled = true,
) {
  const handleClickOutside = useEffectEvent((event: MouseEvent) => {
    const excludedRefs = Array.isArray(excludedElements)
      ? excludedElements
      : [excludedElements];

    for (const ref of excludedRefs) {
      const excludedElement = ref instanceof Element ? ref : ref?.current;

      // Bail out if the clicked element element is inside of excludedElement.
      if (
        excludedElement &&
        (excludedElement === event.target ||
          excludedElement.contains(event.target as Node))
      ) {
        return;
      }
    }

    onClick(event);
  });

  useEffect(() => {
    if (enabled) {
      document.addEventListener('click', handleClickOutside);

      return () => {
        document.removeEventListener('click', handleClickOutside);
      };
    }
    return () => null;
  }, [enabled]);
}

/**
 * Handle clicks that occur outside of the element(s) provided in the first parameter
 */

import type { RefObject } from 'react';
import { useEffect, useEffectEvent } from 'react';

type PlainElement = Element | null;
type ElementOrRef = PlainElement | RefObject<PlainElement>;

export function useOnClickOutside(
  excludedElement: ElementOrRef | ElementOrRef[],
  onClick: (e: MouseEvent) => void,
  enabled = true,
) {
  const handleClickOutside = useEffectEvent((event: MouseEvent) => {
    const excludedRefs = Array.isArray(excludedElement)
      ? excludedElement
      : [excludedElement];

    for (const ref of excludedRefs) {
      const excludedElement = ref instanceof Element ? ref : ref?.current;

      // Bail out if the clicked element or the currently focused element
      // is inside of excludedElement. We're also checking the focused element
      // to prevent an issue in Chrome where initiating a drag inside of an
      // input (to select the text inside of it) and ending that drag outside
      // of the input fires a click event, breaking our excludedElement rule.
      if (
        excludedElement &&
        (excludedElement === event.target ||
          excludedElement === document.activeElement ||
          excludedElement.contains(event.target as Node) ||
          excludedElement.contains(document.activeElement))
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
  }, [enabled, excludedElement, onClick]);
}

/**
 * Handle clicks that occur outside of the element(s) provided in the first parameter
 */

import type { MutableRefObject } from 'react';
import { useEffect } from 'react';

type ElementRef = MutableRefObject<HTMLElement | null>;

export function useOnClickOutside(
  excludedElementRef: ElementRef | ElementRef[] | null,
  onClick: (e: MouseEvent) => void,
  enabled = true,
) {
  useEffect(() => {
    // If the search popover is expanded, close it when tabbing or
    // clicking outside of it or the search form, while allowing
    // tabbing or clicking inside of the popover
    if (enabled) {
      function handleClickOutside(event: MouseEvent) {
        const excludedRefs = Array.isArray(excludedElementRef)
          ? excludedElementRef
          : [excludedElementRef];

        for (const ref of excludedRefs) {
          const excludedElement = ref?.current;

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
      }

      document.addEventListener('click', handleClickOutside);

      return () => {
        document.removeEventListener('click', handleClickOutside);
      };
    }
    return () => null;
  }, [enabled, excludedElementRef, onClick]);
}

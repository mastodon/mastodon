/**
 * Handle clicks that occur outside of the element(s) provided in the first parameter
 */

import type { RefObject } from 'react';
import { useEffect, useEffectEvent } from 'react';

type PlainElement = Element | null;
type ElementOrRef = PlainElement | RefObject<PlainElement>;

export function useOnClickOutside(
  excludedElements: ElementOrRef | ElementOrRef[],
  callback: (e: MouseEvent | FocusEvent) => void,
  {
    enabled = true,
    includeFocus = false,
  }: {
    enabled?: boolean;
    /**
     * Also runs the callback on focus events outside of excludedElements
     */
    includeFocus?: boolean;
  } = {},
) {
  const handleClickOutside = useEffectEvent(
    (event: MouseEvent | FocusEvent) => {
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

      callback(event);
    },
  );

  useEffect(() => {
    if (!enabled) {
      return () => null;
    }

    // Delay mounting the listeners by one tick to ignore the event
    // that caused this effect to run to prevent race conditions.
    let shouldListen = false;
    const listenTimeout = setTimeout(() => {
      shouldListen = true;
    }, 0);

    const listener = (event: MouseEvent | FocusEvent) => {
      if (shouldListen) {
        handleClickOutside(event);
      }
    };

    document.addEventListener('click', listener);
    if (includeFocus) {
      document.addEventListener('focus', listener, { capture: true });
    }

    return () => {
      clearTimeout(listenTimeout);
      document.removeEventListener('click', listener);
      if (includeFocus) {
        document.removeEventListener('focus', listener, { capture: true });
      }
    };
  }, [enabled, includeFocus]);
}

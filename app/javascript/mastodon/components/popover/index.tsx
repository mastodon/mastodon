import { useEffect } from 'react';

import type {
  ReferenceType,
  Placement,
  OffsetOptions,
  Strategy,
} from '@floating-ui/react-dom';
import {
  useFloating,
  autoUpdate,
  inline,
  offset as offsetMiddleware,
  shift,
  flip as flipMiddleware,
  size,
  hide,
} from '@floating-ui/react-dom';

import { useOnClickOutside } from '@/mastodon/hooks/useOnClickOutside';

import { Portal } from './portal';

export interface PopoverProps {
  /**
   * Set the visibility of the popover
   */
  isOpen?: boolean;
  /**
   * Callback triggered when the popover needs to be closed
   * (e.g. because the Esc key was pressed).
   */
  onClose: (e: Event) => void;
  /**
   * Pass an element that the popover should be attached to.
   * Must come from `useState`, not `useRef`.
   */
  reference: ReferenceType | null;
  /**
   * Pass the popover element (useful if you also need the element
   * in the parent and already have it in state).
   * Must come from `useState`, not `useRef`.
   */
  popoverElement?: HTMLElement | null;
  /**
   * Control which element the popover will be rendered into.
   * Passing `null` will render the popover in place.
   */
  container?: HTMLElement | null;
  /**
   * Control where the overlay element is positioned in relation
   * to the reference element
   */
  placement?: Placement;
  /**
   * Control the distance between popover and reference
   */
  offset?: OffsetOptions;
  /**
   * Allow the popover to flip to the other side of the reference
   * if there's no room in the specified direction. Enabled by default.
   */
  flip?: boolean;
  /**
   * Change the positioning strategy, defaults to 'fixed'
   * but can be changed to 'absolute'
   */
  strategy?: Strategy;
  /**
   * Adapt the popover's width to match that of the reference,
   * useful when attached to text input.
   */
  matchReferenceWidth?: boolean;
  /**
   * Control whether to close the popover when clicking outside
   * of it (enabled by default).
   */
  closeOnClickOutside?: boolean;
  /**
   * Render prop that must return the popover element.
   */
  children: (value: {
    /**
     * The popover's final computed placement. Can be used to
     * adjust the popover's style based on its position.
     */
    placement: Placement | undefined;
    /**
     * Re-computes the popover's position – call this when an
     * action inside of the popover has changed its size.
     */
    update: () => void;
    /**
     * These props must be passed to the popover element to
     * enable it to be sized and positioned. The `ref` prop
     * is not passed when the `popoverElement` prop is provided.
     */
    props: Record<string, unknown> & {
      ref?: React.RefCallback<HTMLElement>;
      style: React.CSSProperties;
    };
  }) => React.ReactNode;
}

export const Popover: React.FC<PopoverProps> = ({
  isOpen,
  onClose,
  reference,
  popoverElement,
  placement = 'bottom',
  offset,
  strategy = 'fixed',
  flip = true,
  container,
  matchReferenceWidth = false,
  closeOnClickOutside = true,
  children,
}) => {
  const {
    placement: computedPlacement,
    update,
    refs,
    floatingStyles,
    middlewareData,
    elements,
  } = useFloating({
    elements: {
      reference,
      floating: popoverElement,
    },
    placement,
    strategy,
    whileElementsMounted: autoUpdate,
    middleware: [
      offsetMiddleware(offset),
      inline(),
      shift(),
      flip ? flipMiddleware() : null,
      matchReferenceWidth
        ? size({
            apply({ rects, elements }) {
              Object.assign(elements.floating.style, {
                minWidth: `${rects.reference.width}px`,
              });
            },
          })
        : null,
      hide(),
    ],
  });

  // Close when clicking outside the popover
  useOnClickOutside(
    [
      elements.floating,
      // Only pass reference if it's not a "virtual element"
      elements.reference instanceof Element ? elements.reference : null,
    ],
    (e) => {
      onClose(e);
    },
    isOpen && closeOnClickOutside,
  );

  // Close when pressing Escape
  useEffect(() => {
    if (!isOpen) {
      return () => null;
    }

    function closeOnEscape(event: KeyboardEvent) {
      if (event.key === 'Escape') {
        onClose(event);
      }
    }

    document.addEventListener('keyup', closeOnEscape);

    return () => {
      document.removeEventListener('keyup', closeOnEscape);
    };
  }, [isOpen, onClose]);

  if (!isOpen) {
    return null;
  }

  return (
    <Portal container={container}>
      {children({
        placement: computedPlacement,
        update,
        props: {
          ref: popoverElement ? undefined : refs.setFloating,
          style: floatingStyles,
          'data-popover-placement': computedPlacement,
          'data-popover-reference-hidden': middlewareData.hide?.referenceHidden,
          'data-popover-escaped': middlewareData.hide?.escaped,
        },
      })}
    </Portal>
  );
};

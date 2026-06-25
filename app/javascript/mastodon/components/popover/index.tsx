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
  isOpen?: boolean;
  onClose: (e: Event) => void;
  reference: ReferenceType | null;
  popoverElement?: HTMLElement | null;
  placement?: Placement;
  offset?: OffsetOptions;
  strategy?: Strategy;
  flip?: boolean;
  /**
   * Passing `null` will render the popover in place
   */
  container?: HTMLElement | null;
  matchReferenceWidth?: boolean;
  closeOnClickOutside?: boolean;
  children: (value: {
    placement: Placement | undefined;
    update: () => void;
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
  placement,
  offset,
  strategy = 'fixed',
  flip,
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
          'data-floating-ui': true, // TODO: Remove me
          'data-popper-placement': computedPlacement,
          'data-popper-reference-hidden':
            middlewareData.hide?.referenceHidden ?? false,
          'data-popper-escaped': middlewareData.hide?.escaped ?? false,
        },
      })}
    </Portal>
  );
};

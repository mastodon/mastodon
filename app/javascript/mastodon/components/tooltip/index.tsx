import {
  useCallback,
  useEffect,
  useId,
  useLayoutEffect,
  useRef,
  useState,
} from 'react';

import classNames from 'classnames';

import { mergeProps } from '@react-aria/utils';

import type { PopoverProps } from '@/mastodon/components/popover';
import { Popover } from '@/mastodon/components/popover';
import { useMergedRefs } from '@/mastodon/hooks/useMergedRefs';

import classes from './styles.module.scss';

interface ForwardedReferenceProps {
  ref: (element: HTMLElement | null) => void;
  onClick: React.MouseEventHandler;
  onMouseEnter: React.MouseEventHandler;
  onMouseLeave: React.MouseEventHandler;
  onFocus: React.FocusEventHandler;
  onBlur: React.FocusEventHandler;
}

type GetTooltipProps = <T extends Record<string, unknown>>(
  props?: T,
) => T & ForwardedReferenceProps;

interface TooltipProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'children'
> {
  text: React.ReactNode;
  placement?: PopoverProps['placement'];
  offset?: PopoverProps['offset'];
  /**
   * Enable this to render the tooltip text in a hidden element
   * when the tooltip is closed, so that it can be referenced by
   * ID to provide an accessible label or description.
   */
  renderTextWhenClosed?: boolean;
  children: (options: {
    getTooltipProps: GetTooltipProps;
    tooltipId: string;
  }) => React.ReactNode;
}

/**
 * A component for adding tooltips to interactive elements.
 */
export const Tooltip: React.FC<TooltipProps> = ({
  text,
  placement = 'bottom',
  offset = 4,
  renderTextWhenClosed = false,
  id = '',
  className,
  children,
  ...otherProps
}) => {
  const uniqueId = useId();
  const tooltipId = id || uniqueId;

  const [referenceElement, setReferenceElement] = useState<HTMLElement | null>(
    null,
  );
  const [isOpen, setIsOpen] = useState(false);
  const openTimeout = useRef<ReturnType<typeof setTimeout>>(null);

  const clearOpenTimeout = useCallback(() => {
    if (openTimeout.current !== null) {
      clearTimeout(openTimeout.current);
      openTimeout.current = null;
    }
  }, []);

  const open = useCallback(() => {
    if (shouldSkipOpenDelay) {
      setIsOpen(true);
    }
    openTimeout.current = setTimeout(() => {
      setIsOpen(true);
      openTimeout.current = null;
    }, 250);
  }, []);

  const close = useCallback(() => {
    clearOpenTimeout();
    if (isOpen) {
      suppressEnterDelayTemporarily();
    }
    setIsOpen(false);
  }, [clearOpenTimeout, isOpen]);

  const handleFocus: React.FocusEventHandler = useCallback(
    (e) => {
      if (
        e.target instanceof HTMLElement &&
        e.target.matches(':focus-visible')
      ) {
        open();
      }
    },
    [open],
  );

  useEffect(() => {
    return () => {
      clearOpenTimeout();
    };
  }, [clearOpenTimeout]);

  /**
   * Merges props from an outer component with those needed
   * for the tooltip to avoid conflicts
   */
  const getTooltipProps = useCallback(
    <T extends Record<string, unknown>>(outerProps: T) => {
      const referenceProps = {
        ref: setReferenceElement,
        onClick: close,
        onMouseEnter: open,
        onMouseLeave: close,
        onFocus: handleFocus,
        onBlur: close,
      } satisfies ForwardedReferenceProps;

      return mergeProps(outerProps, referenceProps);
    },
    [close, handleFocus, open],
  );

  return (
    <>
      {
        // eslint-disable-next-line react-hooks/refs
        children({
          getTooltipProps: getTooltipProps as GetTooltipProps,
          tooltipId,
        })
      }
      {!isOpen && renderTextWhenClosed && (
        <span hidden id={tooltipId}>
          {text}
        </span>
      )}
      <Popover
        isOpen={isOpen}
        reference={referenceElement}
        offset={offset}
        placement={placement}
        onClose={close}
      >
        {({ props: popoverProps }) => (
          <TooltipElement
            {...otherProps}
            {...popoverProps}
            id={tooltipId}
            className={classNames(classes.tooltip, className)}
          >
            {text}
          </TooltipElement>
        )}
      </Popover>
    </>
  );
};

let shouldSkipOpenDelay = false;
let resetSkipEnterDelayTimeout: null | ReturnType<typeof setTimeout> = null;

/**
 * Globally disables the opening delay for any tooltips opened
 * right after another one was closed, to make it easy to read
 * the tooltips of grouped buttons, e.g. in a toolbar.
 */
function suppressEnterDelayTemporarily() {
  shouldSkipOpenDelay = true;

  if (resetSkipEnterDelayTimeout !== null) {
    clearTimeout(resetSkipEnterDelayTimeout);
    resetSkipEnterDelayTimeout = null;
  }
  resetSkipEnterDelayTimeout = setTimeout(() => {
    shouldSkipOpenDelay = false;
    resetSkipEnterDelayTimeout = null;
  }, 100);
}

// This is a separate component to allow rendering it in the top layer
// as a native popover element.
const TooltipElement: React.FC<React.ComponentPropsWithRef<'span'>> = ({
  children,
  ref,
  ...otherProps
}) => {
  const popoverRef = useRef<HTMLSpanElement>(null);

  useLayoutEffect(() => {
    const popover = popoverRef.current;
    if (!popover) return;

    popover.showPopover();

    return () => {
      popover.hidePopover();
    };
  }, []);

  return (
    <span {...otherProps} popover='manual' ref={useMergedRefs(ref, popoverRef)}>
      {children}
    </span>
  );
};

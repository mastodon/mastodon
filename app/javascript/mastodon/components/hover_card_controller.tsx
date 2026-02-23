import { useEffect, useRef, useState, useCallback } from 'react';

import { useLocation } from 'react-router-dom';

import type {
  OffsetValue,
  UsePopperOptions,
} from 'react-overlays/esm/usePopper';
import Overlay from 'react-overlays/Overlay';

import { HoverCardAccount } from 'mastodon/components/hover_card_account';
import { useTimeout } from 'mastodon/hooks/useTimeout';

const offset = [-12, 4] as OffsetValue;
const enterDelay = 750;
const leaveDelay = 150;
const popperConfig = { strategy: 'fixed' } as UsePopperOptions;

const isHoverCardAnchor = (element: HTMLElement) =>
  element.matches('[data-hover-card-account]');

export const HoverCardController: React.FC = () => {
  const [open, setOpen] = useState(false);
  const [accountId, setAccountId] = useState<string | undefined>();
  const [anchor, setAnchor] = useState<HTMLElement | null>(null);
  const cardRef = useRef<HTMLDivElement | null>(null);
  const [setLeaveTimeout, cancelLeaveTimeout] = useTimeout();
  const [setEnterTimeout, cancelEnterTimeout, delayEnterTimeout] = useTimeout();
  const [setScrollTimeout] = useTimeout();

  const handleClose = useCallback(() => {
    cancelEnterTimeout();
    cancelLeaveTimeout();
    setOpen(false);
    setAnchor(null);
  }, [cancelEnterTimeout, cancelLeaveTimeout, setOpen, setAnchor]);

  const location = useLocation();
  const [previousLocation, setPreviousLocation] = useState(location);
  if (location !== previousLocation) {
    setPreviousLocation(location);
    handleClose();
  }

  useEffect(() => {
    let isScrolling = false;
    let currentAnchor: HTMLElement | null = null;
    let currentTitle: string | null = null;

    const open = (target: HTMLElement) => {
      target.setAttribute('aria-describedby', 'hover-card');
      setOpen(true);
      setAnchor(target);
      setAccountId(target.getAttribute('data-hover-card-account') ?? undefined);
    };

    const close = () => {
      currentAnchor?.removeAttribute('aria-describedby');
      currentAnchor = null;
      setOpen(false);
      setAnchor(null);
      setAccountId(undefined);
    };

    const handleMouseEnter = (e: MouseEvent) => {
      const { target } = e;

      // We've exited the window
      if (!(target instanceof HTMLElement)) {
        close();
        return;
      }

      // We've entered an anchor
      if (!isScrolling && isHoverCardAnchor(target)) {
        cancelLeaveTimeout();

        currentAnchor?.removeAttribute('aria-describedby');
        currentAnchor = target;

        currentTitle = target.getAttribute('title');
        target.removeAttribute('title');

        setEnterTimeout(() => {
          open(target);
        }, enterDelay);
      }

      // We've entered the hover card
      if (
        !isScrolling &&
        (target === currentAnchor || target === cardRef.current)
      ) {
        cancelLeaveTimeout();
      }
    };

    const handleMouseLeave = (e: MouseEvent) => {
      const { target } = e;

      if (!currentAnchor) {
        return;
      }

      if (
        currentTitle &&
        target instanceof HTMLElement &&
        target === currentAnchor
      )
        target.setAttribute('title', currentTitle);

      if (target === currentAnchor || target === cardRef.current) {
        cancelEnterTimeout();

        setLeaveTimeout(() => {
          close();
        }, leaveDelay);
      }
    };

    const handleScrollEnd = () => {
      isScrolling = false;
    };

    const handleScroll = () => {
      isScrolling = true;
      cancelEnterTimeout();
      setScrollTimeout(handleScrollEnd, 100);
    };

    const handleMouseMove = () => {
      delayEnterTimeout(enterDelay);
    };

    document.body.addEventListener('mouseenter', handleMouseEnter, {
      passive: true,
      capture: true,
    });

    document.body.addEventListener('mousemove', handleMouseMove, {
      passive: true,
      capture: false,
    });

    document.body.addEventListener('mouseleave', handleMouseLeave, {
      passive: true,
      capture: true,
    });

    document.addEventListener('scroll', handleScroll, {
      passive: true,
      capture: true,
    });

    return () => {
      document.body.removeEventListener('mouseenter', handleMouseEnter);
      document.body.removeEventListener('mousemove', handleMouseMove);
      document.body.removeEventListener('mouseleave', handleMouseLeave);
      document.removeEventListener('scroll', handleScroll);
    };
  }, [
    setEnterTimeout,
    setLeaveTimeout,
    setScrollTimeout,
    cancelEnterTimeout,
    cancelLeaveTimeout,
    delayEnterTimeout,
    setOpen,
    setAccountId,
    setAnchor,
  ]);

  return (
    <Overlay
      rootClose
      onHide={handleClose}
      show={open}
      target={anchor}
      placement='bottom-start'
      flip
      offset={offset}
      popperConfig={popperConfig}
    >
      {({ props }) => (
        <div {...props} className='hover-card-controller'>
          <HoverCardAccount accountId={accountId} ref={cardRef} />
        </div>
      )}
    </Overlay>
  );
};

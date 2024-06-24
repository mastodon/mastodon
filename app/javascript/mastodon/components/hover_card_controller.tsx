import { useEffect, useRef, useState, useCallback } from 'react';

import { useLocation } from 'react-router-dom';

import Overlay from 'react-overlays/Overlay';
import type {
  OffsetValue,
  UsePopperOptions,
} from 'react-overlays/esm/usePopper';

import { HoverCardAccount } from 'mastodon/components/hover_card_account';

const offset = [-12, 4] as OffsetValue;
const enterDelay = 500;
const leaveDelay = 250;
const popperConfig = { strategy: 'fixed' } as UsePopperOptions;

const isHoverCardAnchor = (element: HTMLElement) =>
  element.matches('[data-hover-card-account]');

export const HoverCardController: React.FC = () => {
  const [open, setOpen] = useState(false);
  const [accountId, setAccountId] = useState<string | undefined>();
  const [anchor, setAnchor] = useState<HTMLElement | null>(null);
  const cardRef = useRef<HTMLDivElement>(null);
  const leaveTimerRef = useRef<ReturnType<typeof setTimeout>>();
  const enterTimerRef = useRef<ReturnType<typeof setTimeout>>();
  const location = useLocation();

  const handleAnchorMouseEnter = useCallback(
    (e: MouseEvent) => {
      const { target } = e;

      if (target instanceof HTMLElement && isHoverCardAnchor(target)) {
        clearTimeout(leaveTimerRef.current);
        clearTimeout(enterTimerRef.current);

        enterTimerRef.current = setTimeout(() => {
          target.setAttribute('aria-describedby', 'hover-card');
          setAnchor(target);
          setOpen(true);
          setAccountId(
            target.getAttribute('data-hover-card-account') ?? undefined,
          );
        }, enterDelay);
      }

      if (target === cardRef.current?.parentNode) {
        clearTimeout(leaveTimerRef.current);
      }
    },
    [setOpen, setAccountId, setAnchor],
  );

  const handleAnchorMouseLeave = useCallback(
    (e: MouseEvent) => {
      if (e.target === anchor || e.target === cardRef.current?.parentNode) {
        clearTimeout(leaveTimerRef.current);
        clearTimeout(enterTimerRef.current);

        leaveTimerRef.current = setTimeout(() => {
          anchor?.removeAttribute('aria-describedby');
          setOpen(false);
          setAnchor(null);
        }, leaveDelay);
      }
    },
    [setOpen, setAnchor, anchor],
  );

  const handleClose = useCallback(() => {
    clearTimeout(leaveTimerRef.current);
    clearTimeout(enterTimerRef.current);
    setOpen(false);
    setAnchor(null);
  }, [setOpen, setAnchor]);

  const handleScroll = useCallback(() => {
    clearTimeout(leaveTimerRef.current);
    clearTimeout(enterTimerRef.current);
  }, []);

  useEffect(() => {
    clearTimeout(leaveTimerRef.current);
    clearTimeout(enterTimerRef.current);
    setOpen(false);
    setAnchor(null);
  }, [setOpen, setAnchor, location]);

  useEffect(() => {
    document.body.addEventListener('mouseenter', handleAnchorMouseEnter, {
      passive: true,
      capture: true,
    });
    document.body.addEventListener('mouseleave', handleAnchorMouseLeave, {
      passive: true,
      capture: true,
    });
    document.body.addEventListener('scroll', handleScroll, {
      passive: true,
      capture: false,
    });

    return () => {
      document.body.removeEventListener('mouseenter', handleAnchorMouseEnter);
      document.body.removeEventListener('mouseleave', handleAnchorMouseLeave);
      document.body.removeEventListener('scroll', handleScroll);
    };
  }, [handleAnchorMouseEnter, handleAnchorMouseLeave, handleScroll]);

  if (!accountId) return null;

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

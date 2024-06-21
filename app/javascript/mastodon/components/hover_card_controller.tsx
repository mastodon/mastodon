import { useEffect, useRef, useState, useCallback } from 'react';

import Overlay from 'react-overlays/Overlay';
import type { OffsetValue } from 'react-overlays/esm/usePopper';

import { HoverCardAccount } from 'mastodon/components/hover_card_account';

const offset = [-12, 4] as OffsetValue;
const enterDelay = 500;
const leaveDelay = 500;

const isHoverCardAnchor = (element: HTMLElement) =>
  element.matches('[data-hover-card-account]');

export const HoverCardController: React.FC = () => {
  const [open, setOpen] = useState(false);
  const [accountId, setAccountId] = useState<string | undefined>();
  const [anchor, setAnchor] = useState<HTMLElement | null>(null);
  const cardRef = useRef<HTMLDivElement>(null);
  const leaveTimerRef = useRef<ReturnType<typeof setTimeout>>();
  const enterTimerRef = useRef<ReturnType<typeof setTimeout>>();

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

  const handleFocus = useCallback(
    (e: FocusEvent) => {
      const { target } = e;

      if (target instanceof HTMLElement && isHoverCardAnchor(target)) {
        target.setAttribute('aria-describedby', 'hover-card');
        setAnchor(target);
        setOpen(true);
        setAccountId(
          target.getAttribute('data-hover-card-account') ?? undefined,
        );
      }
    },
    [setAnchor, setOpen, setAccountId],
  );

  const handleBlur = useCallback(
    (e: FocusEvent) => {
      const { target } = e;

      if (target instanceof HTMLElement && isHoverCardAnchor(target)) {
        target.removeAttribute('aria-describedby');
        setOpen(false);
        setAnchor(null);
      }
    },
    [setOpen, setAnchor],
  );

  const handleClose = useCallback(() => {
    clearTimeout(leaveTimerRef.current);
    clearTimeout(enterTimerRef.current);
    setOpen(false);
    setAnchor(null);
  }, [setOpen, setAnchor]);

  useEffect(() => {
    document.body.addEventListener('mouseenter', handleAnchorMouseEnter, {
      passive: true,
      capture: true,
    });
    document.body.addEventListener('mouseleave', handleAnchorMouseLeave, {
      passive: true,
      capture: true,
    });
    document.body.addEventListener('focus', handleFocus, {
      passive: true,
      capture: true,
    });
    document.body.addEventListener('blur', handleBlur, {
      passive: true,
      capture: true,
    });

    return () => {
      document.body.removeEventListener('mouseenter', handleAnchorMouseEnter);
      document.body.removeEventListener('mouseleave', handleAnchorMouseLeave);
      document.body.removeEventListener('focus', handleFocus);
      document.body.removeEventListener('blur', handleBlur);
    };
  }, [handleAnchorMouseEnter, handleAnchorMouseLeave, handleFocus, handleBlur]);

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
    >
      {({ props }) => (
        <div {...props}>
          <HoverCardAccount accountId={accountId} ref={cardRef} />
        </div>
      )}
    </Overlay>
  );
};

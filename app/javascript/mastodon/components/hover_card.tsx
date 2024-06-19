import { useEffect, useRef, useState, useCallback } from 'react';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import Overlay from 'react-overlays/Overlay';
import type { OffsetValue } from 'react-overlays/esm/usePopper';

import { fetchAccount } from 'mastodon/actions/accounts';
import { AccountBio } from 'mastodon/components/account_bio';
import { AccountFields } from 'mastodon/components/account_fields';
import { Avatar } from 'mastodon/components/avatar';
import { FollowersCounter } from 'mastodon/components/counters';
import { DisplayName } from 'mastodon/components/display_name';
import { FollowButton } from 'mastodon/components/follow_button';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { ShortNumber } from 'mastodon/components/short_number';
import { domain } from 'mastodon/initial_state';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

const offset = [-12, 4] as OffsetValue;
const enterDelay = 250;
const leaveDelay = 300;

export const HoverCard: React.FC = () => {
  const [open, setOpen] = useState(false);
  const [accountId, setAccountId] = useState<string | undefined>();
  const [anchor, setAnchor] = useState<HTMLElement | null>(null);
  const cardRef = useRef<HTMLDivElement>(null);
  const dispatch = useAppDispatch();
  const account = useAppSelector((state) =>
    accountId ? state.accounts.get(accountId) : undefined,
  );
  const leaveTimerRef = useRef<ReturnType<typeof setTimeout>>();
  const enterTimerRef = useRef<ReturnType<typeof setTimeout>>();

  const handleAnchorMouseEnter = useCallback(
    (e: MouseEvent) => {
      const { target } = e;

      if (
        target instanceof HTMLElement &&
        target.matches('[data-hover-card]')
      ) {
        clearTimeout(leaveTimerRef.current);
        clearTimeout(enterTimerRef.current);

        enterTimerRef.current = setTimeout(() => {
          target.setAttribute('aria-describedby', 'hover-card');
          setAnchor(target);
          setOpen(true);
          setAccountId(target.getAttribute('data-hover-card') ?? undefined);
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

      if (
        target instanceof HTMLElement &&
        target.matches('[data-hover-card]')
      ) {
        target.setAttribute('aria-describedby', 'hover-card');
        setAnchor(target);
        setOpen(true);
        setAccountId(target.getAttribute('data-hover-card') ?? undefined);
      }
    },
    [setAnchor, setOpen, setAccountId],
  );

  const handleBlur = useCallback(
    (e: FocusEvent) => {
      const { target } = e;

      if (
        target instanceof HTMLElement &&
        target.matches('[data-hover-card]')
      ) {
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

  useEffect(() => {
    if (accountId) {
      dispatch(fetchAccount(accountId));
    }
  }, [dispatch, accountId]);

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
          <div
            id='hover-card'
            ref={cardRef}
            role='tooltip'
            className={classNames('hover-card dropdown-animation', {
              'hover-card--loading': !account,
            })}
          >
            {account && (
              <>
                <Link to={`/@${account.acct}`} className='hover-card__name'>
                  <Avatar account={account} size={46} />
                  <DisplayName account={account} localDomain={domain} />
                </Link>

                <div className='hover-card__text-row'>
                  <AccountBio
                    note={account.note_emojified}
                    className='hover-card__bio'
                  />
                  <AccountFields fields={account.fields} limit={2} />
                </div>

                <div className='hover-card__number'>
                  <ShortNumber
                    value={account.followers_count}
                    renderer={FollowersCounter}
                  />
                </div>

                <FollowButton accountId={accountId} />
              </>
            )}

            {!account && <LoadingIndicator />}
          </div>
        </div>
      )}
    </Overlay>
  );
};

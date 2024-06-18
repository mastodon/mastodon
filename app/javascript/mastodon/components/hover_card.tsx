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
const enterDelay = 100;
const leaveDelay = 500;

export const HoverCard: React.FC = () => {
  const [open, setOpen] = useState(false);
  const [accountId, setAccountId] = useState<string | undefined>();
  const cardRef = useRef<HTMLDivElement>(null);
  const anchorRef = useRef<HTMLElement | null>(null);
  const dispatch = useAppDispatch();
  const account = useAppSelector((state) =>
    accountId ? state.accounts.get(accountId) : undefined,
  );
  const leaveTimerRef = useRef<ReturnType<typeof setTimeout>>();
  const enterTimerRef = useRef<ReturnType<typeof setTimeout>>();

  const handleAnchorMouseEnter = useCallback(
    (e: MouseEvent) => {
      const { target } = e;

      if (!(target instanceof HTMLElement)) return;

      if (target.matches('[data-hover-card]')) {
        clearTimeout(leaveTimerRef.current);
        clearTimeout(enterTimerRef.current);

        enterTimerRef.current = setTimeout(() => {
          anchorRef.current = target;
          setOpen(true);
          setAccountId(target.getAttribute('data-hover-card') ?? undefined);
        }, enterDelay);
      }

      if (target === cardRef.current?.parentNode) {
        clearTimeout(leaveTimerRef.current);
      }
    },
    [setOpen, setAccountId],
  );

  const handleAnchorMouseLeave = useCallback(
    (e: MouseEvent) => {
      if (
        e.target === anchorRef.current ||
        e.target === cardRef.current?.parentNode
      ) {
        clearTimeout(leaveTimerRef.current);
        clearTimeout(enterTimerRef.current);

        leaveTimerRef.current = setTimeout(() => {
          setOpen(false);
          anchorRef.current = null;
        }, leaveDelay);
      }
    },
    [setOpen],
  );

  const handleClose = useCallback(() => {
    clearTimeout(leaveTimerRef.current);
    clearTimeout(enterTimerRef.current);
    setOpen(false);
    anchorRef.current = null;
  }, [setOpen]);

  useEffect(() => {
    window.addEventListener('mouseenter', handleAnchorMouseEnter, {
      passive: true,
      capture: true,
    });
    window.addEventListener('mouseleave', handleAnchorMouseLeave, {
      passive: true,
      capture: true,
    });

    return () => {
      window.removeEventListener('mouseenter', handleAnchorMouseEnter);
      window.removeEventListener('mouseleave', handleAnchorMouseLeave);
    };
  }, [handleAnchorMouseEnter, handleAnchorMouseLeave]);

  useEffect(() => {
    dispatch(fetchAccount(accountId));
  }, [dispatch, accountId]);

  if (!accountId) return null;

  return (
    <Overlay
      rootClose
      onHide={handleClose}
      show={open}
      target={anchorRef.current}
      placement='bottom-start'
      flip
      offset={offset}
    >
      {({ props }) => (
        <div {...props}>
          <div
            ref={cardRef}
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
                  <AccountFields fields={account.fields} />
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

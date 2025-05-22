import { useEffect, forwardRef } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import { fetchAccount } from 'mastodon/actions/accounts';
import { AccountBio } from 'mastodon/components/account_bio';
import { AccountFields } from 'mastodon/components/account_fields';
import { Avatar } from 'mastodon/components/avatar';
import { AvatarGroup } from 'mastodon/components/avatar_group';
import {
  FollowersCounter,
  FollowersYouKnowCounter,
} from 'mastodon/components/counters';
import { DisplayName } from 'mastodon/components/display_name';
import { FollowButton } from 'mastodon/components/follow_button';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { ShortNumber } from 'mastodon/components/short_number';
import { useFetchFamiliarFollowers } from 'mastodon/features/account_timeline/hooks/familiar_followers';
import { domain } from 'mastodon/initial_state';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

export const HoverCardAccount = forwardRef<
  HTMLDivElement,
  { accountId?: string }
>(({ accountId }, ref) => {
  const dispatch = useAppDispatch();

  const account = useAppSelector((state) =>
    accountId ? state.accounts.get(accountId) : undefined,
  );

  const note = useAppSelector(
    (state) =>
      state.relationships.getIn([accountId, 'note']) as string | undefined,
  );

  useEffect(() => {
    if (accountId && !account) {
      dispatch(fetchAccount(accountId));
    }
  }, [dispatch, accountId, account]);

  const { familiarFollowers } = useFetchFamiliarFollowers({ accountId });

  return (
    <div
      ref={ref}
      id='hover-card'
      role='tooltip'
      className={classNames('hover-card dropdown-animation', {
        'hover-card--loading': !account,
      })}
    >
      {account ? (
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
            {note && note.length > 0 && (
              <dl className='hover-card__note'>
                <dt className='hover-card__note-label'>
                  <FormattedMessage
                    id='account.account_note_header'
                    defaultMessage='Personal note'
                  />
                </dt>
                <dd>{note}</dd>
              </dl>
            )}
          </div>

          <div className='hover-card__numbers'>
            <ShortNumber
              value={account.followers_count}
              renderer={FollowersCounter}
            />
            {familiarFollowers.length > 0 && (
              <>
                &middot;
                <div className='hover-card__familiar-followers'>
                  <ShortNumber
                    value={familiarFollowers.length}
                    renderer={FollowersYouKnowCounter}
                  />
                  <AvatarGroup compact>
                    {familiarFollowers.slice(0, 3).map((account) => (
                      <Avatar key={account.id} account={account} size={22} />
                    ))}
                  </AvatarGroup>
                </div>
              </>
            )}
          </div>

          <FollowButton accountId={accountId} />
        </>
      ) : (
        <LoadingIndicator />
      )}
    </div>
  );
});

HoverCardAccount.displayName = 'HoverCardAccount';

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
import { getAccountHidden } from 'mastodon/selectors/accounts';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

export const HoverCardAccount = forwardRef<
  HTMLDivElement,
  { accountId?: string }
>(({ accountId }, ref) => {
  const dispatch = useAppDispatch();

  const account = useAppSelector((state) =>
    accountId ? state.accounts.get(accountId) : undefined,
  );
  const suspended = account?.suspended;
  const hidden = useAppSelector((state) =>
    accountId ? getAccountHidden(state, accountId) : undefined,
  );
  const isSuspendedOrHidden = Boolean(suspended || hidden);

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

  const relationship = useAppSelector((state) =>
    accountId ? state.relationships.get(accountId) : undefined,
  );
  const isMutual = relationship?.followed_by && relationship.following;
  const isFollower = relationship?.followed_by;
  const hasRelationshipLoaded = !!relationship;

  const shouldDisplayFamiliarFollowers =
    familiarFollowers.length > 0 &&
    hasRelationshipLoaded &&
    !isMutual &&
    !isFollower;

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
            <Avatar
              account={isSuspendedOrHidden ? undefined : account}
              size={46}
            />
            <DisplayName account={account} localDomain={domain} />
          </Link>

          {isSuspendedOrHidden ? (
            <div className='hover-card__limited-account-note'>
              {suspended ? (
                <FormattedMessage
                  id='empty_column.account_suspended'
                  defaultMessage='Account suspended'
                />
              ) : (
                <FormattedMessage
                  id='limited_account_hint.title'
                  defaultMessage='This profile has been hidden by the moderators of {domain}.'
                  values={{ domain }}
                />
              )}
            </div>
          ) : (
            <>
              <div className='hover-card__text-row'>
                <AccountBio
                  accountId={account.id}
                  className='hover-card__bio'
                />

                <div className='account-fields'>
                  <AccountFields
                    fields={account.fields.take(2)}
                    emojis={account.emojis}
                  />
                </div>

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
                {shouldDisplayFamiliarFollowers && (
                  <>
                    &middot;
                    <div className='hover-card__familiar-followers'>
                      <ShortNumber
                        value={familiarFollowers.length}
                        renderer={FollowersYouKnowCounter}
                      />
                      <AvatarGroup compact>
                        {familiarFollowers.slice(0, 3).map((account) => (
                          <Avatar
                            key={account.id}
                            account={account}
                            size={22}
                          />
                        ))}
                      </AvatarGroup>
                    </div>
                  </>
                )}
                {(isMutual || isFollower) && (
                  <>
                    &middot;
                    {isMutual ? (
                      <FormattedMessage
                        id='account.mutual'
                        defaultMessage='You follow each other'
                      />
                    ) : (
                      <FormattedMessage
                        id='account.follows_you'
                        defaultMessage='Follows you'
                      />
                    )}
                  </>
                )}
              </div>

              <FollowButton accountId={accountId} />
            </>
          )}
        </>
      ) : (
        <LoadingIndicator />
      )}
    </div>
  );
});

HoverCardAccount.displayName = 'HoverCardAccount';

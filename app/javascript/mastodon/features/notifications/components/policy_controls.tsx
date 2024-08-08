import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { updateNotificationsPolicy } from 'mastodon/actions/notification_policies';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { SelectWithLabel } from './select_with_label';

// eslint-disable-next-line @typescript-eslint/no-empty-function
const noop = () => {};

export const PolicyControls: React.FC = () => {
  const dispatch = useAppDispatch();

  const notificationPolicy = useAppSelector(
    (state) => state.notificationPolicy,
  );

  const handleFilterNotFollowing = useCallback(
    (value: string) => {
      void dispatch(
        updateNotificationsPolicy({
          filter_not_following: value !== 'accept',
        }),
      );
    },
    [dispatch],
  );

  const handleFilterNotFollowers = useCallback(
    (value: string) => {
      void dispatch(
        updateNotificationsPolicy({ filter_not_followers: value !== 'accept' }),
      );
    },
    [dispatch],
  );

  const handleFilterNewAccounts = useCallback(
    (value: string) => {
      void dispatch(
        updateNotificationsPolicy({ filter_new_accounts: value !== 'accept' }),
      );
    },
    [dispatch],
  );

  const handleFilterPrivateMentions = useCallback(
    (value: string) => {
      void dispatch(
        updateNotificationsPolicy({
          filter_private_mentions: value !== 'accept',
        }),
      );
    },
    [dispatch],
  );

  if (!notificationPolicy) return null;

  return (
    <section>
      <h3>
        <FormattedMessage
          id='notifications.policy.title'
          defaultMessage='Manage notifications from…'
        />
      </h3>

      <div className='column-settings__row'>
        <SelectWithLabel
          value={notificationPolicy.filter_not_following ? 'filter' : 'accept'}
          onChange={handleFilterNotFollowing}
        >
          <strong>
            <FormattedMessage
              id='notifications.policy.filter_not_following_title'
              defaultMessage="People you don't follow"
            />
          </strong>
          <span className='hint'>
            <FormattedMessage
              id='notifications.policy.filter_not_following_hint'
              defaultMessage='Until you manually approve them'
            />
          </span>
        </SelectWithLabel>

        <SelectWithLabel
          value={notificationPolicy.filter_not_followers ? 'filter' : 'accept'}
          onChange={handleFilterNotFollowers}
        >
          <strong>
            <FormattedMessage
              id='notifications.policy.filter_not_followers_title'
              defaultMessage='People not following you'
            />
          </strong>
          <span className='hint'>
            <FormattedMessage
              id='notifications.policy.filter_not_followers_hint'
              defaultMessage='Including people who have been following you fewer than {days, plural, one {one day} other {# days}}'
              values={{ days: 3 }}
            />
          </span>
        </SelectWithLabel>

        <SelectWithLabel
          value={notificationPolicy.filter_new_accounts ? 'filter' : 'accept'}
          onChange={handleFilterNewAccounts}
        >
          <strong>
            <FormattedMessage
              id='notifications.policy.filter_new_accounts_title'
              defaultMessage='New accounts'
            />
          </strong>
          <span className='hint'>
            <FormattedMessage
              id='notifications.policy.filter_new_accounts.hint'
              defaultMessage='Created within the past {days, plural, one {one day} other {# days}}'
              values={{ days: 30 }}
            />
          </span>
        </SelectWithLabel>

        <SelectWithLabel
          value={
            notificationPolicy.filter_private_mentions ? 'filter' : 'accept'
          }
          onChange={handleFilterPrivateMentions}
        >
          <strong>
            <FormattedMessage
              id='notifications.policy.filter_private_mentions_title'
              defaultMessage='Unsolicited private mentions'
            />
          </strong>
          <span className='hint'>
            <FormattedMessage
              id='notifications.policy.filter_private_mentions_hint'
              defaultMessage="Filtered unless it's in reply to your own mention or if you follow the sender"
            />
          </span>
        </SelectWithLabel>

        <SelectWithLabel value='filter' disabled onChange={noop}>
          <strong>
            <FormattedMessage
              id='notifications.policy.filter_limited_accounts_title'
              defaultMessage='Moderated accounts'
            />
          </strong>
          <span className='hint'>
            <FormattedMessage
              id='notifications.policy.filter_limited_accounts_hint'
              defaultMessage='Limited by server moderators'
            />
          </span>
        </SelectWithLabel>
      </div>
    </section>
  );
};

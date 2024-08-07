import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { updateNotificationsPolicy } from 'mastodon/actions/notification_policies';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { CheckboxWithLabel } from './checkbox_with_label';

// eslint-disable-next-line @typescript-eslint/no-empty-function
const noop = () => {};

export const PolicyControls: React.FC = () => {
  const dispatch = useAppDispatch();

  const notificationPolicy = useAppSelector(
    (state) => state.notificationPolicy,
  );

  const handleFilterNotFollowing = useCallback(
    (checked: boolean) => {
      void dispatch(
        updateNotificationsPolicy({ filter_not_following: checked }),
      );
    },
    [dispatch],
  );

  const handleFilterNotFollowers = useCallback(
    (checked: boolean) => {
      void dispatch(
        updateNotificationsPolicy({ filter_not_followers: checked }),
      );
    },
    [dispatch],
  );

  const handleFilterNewAccounts = useCallback(
    (checked: boolean) => {
      void dispatch(
        updateNotificationsPolicy({ filter_new_accounts: checked }),
      );
    },
    [dispatch],
  );

  const handleFilterPrivateMentions = useCallback(
    (checked: boolean) => {
      void dispatch(
        updateNotificationsPolicy({ filter_private_mentions: checked }),
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
          defaultMessage='Filter out notifications from…'
        />
      </h3>

      <div className='column-settings__row'>
        <CheckboxWithLabel
          checked={notificationPolicy.filter_not_following}
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
        </CheckboxWithLabel>

        <CheckboxWithLabel
          checked={notificationPolicy.filter_not_followers}
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
        </CheckboxWithLabel>

        <CheckboxWithLabel
          checked={notificationPolicy.filter_new_accounts}
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
        </CheckboxWithLabel>

        <CheckboxWithLabel
          checked={notificationPolicy.filter_private_mentions}
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
        </CheckboxWithLabel>

        <CheckboxWithLabel checked disabled onChange={noop}>
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
        </CheckboxWithLabel>
      </div>
    </section>
  );
};

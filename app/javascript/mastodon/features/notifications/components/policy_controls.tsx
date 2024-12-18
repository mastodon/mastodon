import { useCallback } from 'react';

import { useIntl, defineMessages, FormattedMessage } from 'react-intl';

import { openModal } from 'mastodon/actions/modal';
import { updateNotificationsPolicy } from 'mastodon/actions/notification_policies';
import type { AppDispatch } from 'mastodon/store';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { SelectWithLabel } from './select_with_label';

const messages = defineMessages({
  accept: { id: 'notifications.policy.accept', defaultMessage: 'Accept' },
  accept_hint: {
    id: 'notifications.policy.accept_hint',
    defaultMessage: 'Show in notifications',
  },
  filter: { id: 'notifications.policy.filter', defaultMessage: 'Filter' },
  filter_hint: {
    id: 'notifications.policy.filter_hint',
    defaultMessage: 'Send to filtered notifications inbox',
  },
  drop: { id: 'notifications.policy.drop', defaultMessage: 'Ignore' },
  drop_hint: {
    id: 'notifications.policy.drop_hint',
    defaultMessage: 'Send to the void, never to be seen again',
  },
});

// TODO: change the following when we change the API
const changeFilter = (
  dispatch: AppDispatch,
  filterType: string,
  value: string,
) => {
  if (value === 'drop') {
    dispatch(
      openModal({
        modalType: 'IGNORE_NOTIFICATIONS',
        modalProps: { filterType },
      }),
    );
  } else {
    void dispatch(updateNotificationsPolicy({ [filterType]: value }));
  }
};

export const PolicyControls: React.FC = () => {
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const notificationPolicy = useAppSelector(
    (state) => state.notificationPolicy,
  );

  const handleFilterNotFollowing = useCallback(
    (value: string) => {
      changeFilter(dispatch, 'for_not_following', value);
    },
    [dispatch],
  );

  const handleFilterNotFollowers = useCallback(
    (value: string) => {
      changeFilter(dispatch, 'for_not_followers', value);
    },
    [dispatch],
  );

  const handleFilterNewAccounts = useCallback(
    (value: string) => {
      changeFilter(dispatch, 'for_new_accounts', value);
    },
    [dispatch],
  );

  const handleFilterPrivateMentions = useCallback(
    (value: string) => {
      changeFilter(dispatch, 'for_private_mentions', value);
    },
    [dispatch],
  );

  const handleFilterLimitedAccounts = useCallback(
    (value: string) => {
      changeFilter(dispatch, 'for_limited_accounts', value);
    },
    [dispatch],
  );

  if (!notificationPolicy) return null;

  const options = [
    {
      value: 'accept',
      text: intl.formatMessage(messages.accept),
      meta: intl.formatMessage(messages.accept_hint),
    },
    {
      value: 'filter',
      text: intl.formatMessage(messages.filter),
      meta: intl.formatMessage(messages.filter_hint),
    },
    {
      value: 'drop',
      text: intl.formatMessage(messages.drop),
      meta: intl.formatMessage(messages.drop_hint),
    },
  ];

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
          value={notificationPolicy.for_not_following}
          onChange={handleFilterNotFollowing}
          options={options}
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
          value={notificationPolicy.for_not_followers}
          onChange={handleFilterNotFollowers}
          options={options}
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
          value={notificationPolicy.for_new_accounts}
          onChange={handleFilterNewAccounts}
          options={options}
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
          value={notificationPolicy.for_private_mentions}
          onChange={handleFilterPrivateMentions}
          options={options}
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

        <SelectWithLabel
          value={notificationPolicy.for_limited_accounts}
          onChange={handleFilterLimitedAccounts}
          options={options}
        >
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

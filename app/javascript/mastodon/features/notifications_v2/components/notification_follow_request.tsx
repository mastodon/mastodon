import { useCallback } from 'react';

import { FormattedMessage, useIntl, defineMessages } from 'react-intl';

import CheckIcon from '@/material-icons/400-24px/check.svg?react';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import PersonAddIcon from '@/material-icons/400-24px/person_add-fill.svg?react';
import {
  authorizeFollowRequest,
  rejectFollowRequest,
} from 'mastodon/actions/accounts';
import { IconButton } from 'mastodon/components/icon_button';
import type { NotificationGroupFollowRequest } from 'mastodon/models/notification_group';
import { useAppDispatch } from 'mastodon/store';

import type { LabelRenderer } from './notification_group_with_status';
import { NotificationGroupWithStatus } from './notification_group_with_status';

const messages = defineMessages({
  authorize: { id: 'follow_request.authorize', defaultMessage: 'Authorize' },
  reject: { id: 'follow_request.reject', defaultMessage: 'Reject' },
});

const labelRenderer: LabelRenderer = (displayedName, total) => {
  if (total === 1)
    return (
      <FormattedMessage
        id='notification.follow_request'
        defaultMessage='{name} has requested to follow you'
        values={{ name: displayedName }}
      />
    );

  return (
    <FormattedMessage
      id='notification.follow_request.name_and_others'
      defaultMessage='{name} and {count, plural, one {# other} other {# others}} has requested to follow you'
      values={{
        name: displayedName,
        count: total - 1,
      }}
    />
  );
};

export const NotificationFollowRequest: React.FC<{
  notification: NotificationGroupFollowRequest;
  unread: boolean;
}> = ({ notification, unread }) => {
  const intl = useIntl();

  const dispatch = useAppDispatch();

  const onAuthorize = useCallback(() => {
    dispatch(authorizeFollowRequest(notification.sampleAccountIds[0]));
  }, [dispatch, notification.sampleAccountIds]);

  const onReject = useCallback(() => {
    dispatch(rejectFollowRequest(notification.sampleAccountIds[0]));
  }, [dispatch, notification.sampleAccountIds]);

  const actions = (
    <>
      <IconButton
        title={intl.formatMessage(messages.reject)}
        icon='times'
        iconComponent={CloseIcon}
        onClick={onReject}
      />
      <IconButton
        title={intl.formatMessage(messages.authorize)}
        icon='check'
        iconComponent={CheckIcon}
        onClick={onAuthorize}
      />
    </>
  );

  return (
    <NotificationGroupWithStatus
      type='follow-request'
      icon={PersonAddIcon}
      iconId='person-add'
      accountIds={notification.sampleAccountIds}
      timestamp={notification.latest_page_notification_at}
      count={notification.notifications_count}
      labelRenderer={labelRenderer}
      actions={actions}
      unread={unread}
    />
  );
};

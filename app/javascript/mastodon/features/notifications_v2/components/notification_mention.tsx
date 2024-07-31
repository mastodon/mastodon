import { FormattedMessage } from 'react-intl';

import ReplyIcon from '@/material-icons/400-24px/reply-fill.svg?react';
import type { StatusVisibility } from 'mastodon/api_types/statuses';
import type { NotificationGroupMention } from 'mastodon/models/notification_group';
import { useAppSelector } from 'mastodon/store';

import type { LabelRenderer } from './notification_group_with_status';
import { NotificationWithStatus } from './notification_with_status';

const labelRenderer: LabelRenderer = (values) => (
  <FormattedMessage
    id='notification.mention'
    defaultMessage='{name} mentioned you'
    values={values}
  />
);

const privateMentionLabelRenderer: LabelRenderer = (values) => (
  <FormattedMessage
    id='notification.private_mention'
    defaultMessage='{name} privately mentioned you'
    values={values}
  />
);

export const NotificationMention: React.FC<{
  notification: NotificationGroupMention;
  unread: boolean;
}> = ({ notification, unread }) => {
  const statusVisibility = useAppSelector(
    (state) =>
      state.statuses.getIn([
        notification.statusId,
        'visibility',
      ]) as StatusVisibility,
  );

  return (
    <NotificationWithStatus
      type='mention'
      icon={ReplyIcon}
      iconId='reply'
      accountIds={notification.sampleAccountIds}
      count={notification.notifications_count}
      statusId={notification.statusId}
      labelRenderer={
        statusVisibility === 'direct'
          ? privateMentionLabelRenderer
          : labelRenderer
      }
      unread={unread}
    />
  );
};

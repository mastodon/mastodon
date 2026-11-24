import { FormattedMessage } from 'react-intl';

import { StatusQuoteIcon } from '@/mastodon/components/status/icons';
import type { NotificationGroupQuote } from 'mastodon/models/notification_group';

import type { LabelRenderer } from './notification_group_with_status';
import { NotificationWithStatus } from './notification_with_status';

const quoteLabelRenderer: LabelRenderer = (displayName) => (
  <FormattedMessage
    id='notification.label.quote'
    defaultMessage='{name} quoted your post'
    values={{ name: displayName }}
  />
);

export const NotificationQuote: React.FC<{
  notification: NotificationGroupQuote;
  unread: boolean;
}> = ({ notification, unread }) => {
  return (
    <NotificationWithStatus
      type='quote'
      icon={StatusQuoteIcon}
      iconId='quote'
      accountIds={notification.sampleAccountIds}
      count={notification.notifications_count}
      statusId={notification.statusId}
      labelRenderer={quoteLabelRenderer}
      unread={unread}
    />
  );
};

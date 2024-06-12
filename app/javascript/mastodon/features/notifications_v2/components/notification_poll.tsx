import { FormattedMessage } from 'react-intl';

import BarChart4BarsIcon from '@/material-icons/400-20px/bar_chart_4_bars.svg?react';
import { me } from 'mastodon/initial_state';
import type { NotificationGroupPoll } from 'mastodon/models/notification_group';

import { NotificationWithStatus } from './notification_with_status';

const labelRendererOther = () => (
  <FormattedMessage
    id='notification.poll'
    defaultMessage='A poll you have voted in has ended'
  />
);

const labelRendererOwn = () => (
  <FormattedMessage
    id='notification.own_poll'
    defaultMessage='Your poll has ended'
  />
);

export const NotificationPoll: React.FC<{
  notification: NotificationGroupPoll;
  unread: boolean;
}> = ({ notification, unread }) => (
  <NotificationWithStatus
    type='poll'
    icon={BarChart4BarsIcon}
    accountIds={notification.sampleAccountsIds}
    count={notification.notifications_count}
    statusId={notification.statusId}
    labelRenderer={
      notification.sampleAccountsIds[0] === me
        ? labelRendererOwn
        : labelRendererOther
    }
    unread={unread}
  />
);

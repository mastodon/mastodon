import { FormattedMessage } from 'react-intl';

import BarChart4BarsIcon from '@/material-icons/400-20px/bar_chart_4_bars.svg?react';
import { me } from 'mastodon/initial_state';
import type { NotificationGroupPoll } from 'mastodon/models/notification_group';

import { NotificationWithStatus } from './notification_with_status';

const labelRendererOther = () => (
  <FormattedMessage
    id='notification.poll'
    defaultMessage='A poll you voted in has ended'
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
    iconId='bar-chart-4-bars'
    accountIds={notification.sampleAccountIds}
    count={notification.notifications_count}
    statusId={notification.statusId}
    labelRenderer={
      notification.sampleAccountIds[0] === me
        ? labelRendererOwn
        : labelRendererOther
    }
    unread={unread}
  />
);

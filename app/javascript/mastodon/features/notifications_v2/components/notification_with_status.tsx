import { useMemo } from 'react';

import type { IconProp } from 'mastodon/components/icon';
import { Icon } from 'mastodon/components/icon';
import Status from 'mastodon/containers/status_container';

import { NamesList } from './names_list';
import type { LabelRenderer } from './notification_group_with_status';

export const NotificationWithStatus: React.FC<{
  type: string;
  icon: IconProp;
  accountIds: string[];
  statusId: string;
  count: number;
  labelRenderer: LabelRenderer;
}> = ({ icon, accountIds, statusId, count, labelRenderer, type }) => {
  const label = useMemo(
    () =>
      labelRenderer({
        name: <NamesList accountIds={accountIds} total={count} />,
      }),
    [labelRenderer, accountIds, count],
  );

  return (
    <div
      className={`notification-ungrouped focusable notification-ungrouped--${type}`}
      tabIndex='0'
    >
      <div className='notification-ungrouped__header'>
        <div className='notification-ungrouped__header__icon'>
          <Icon icon={icon} />
        </div>
        {label}
      </div>

      {/* @ts-expect-error -- <Status> is not yet typed */}
      <Status id={statusId} contextType='notifications' withDismiss />
    </div>
  );
};

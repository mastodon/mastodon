import { useMemo } from 'react';

import classNames from 'classnames';

import type { IconProp } from 'mastodon/components/icon';
import { Icon } from 'mastodon/components/icon';
import Status from 'mastodon/containers/status_container';

import { NamesList } from './names_list';
import type { LabelRenderer } from './notification_group_with_status';

export const NotificationWithStatus: React.FC<{
  type: string;
  icon: IconProp;
  iconId: string;
  accountIds: string[];
  statusId: string;
  count: number;
  labelRenderer: LabelRenderer;
  unread: boolean;
}> = ({
  icon,
  iconId,
  accountIds,
  statusId,
  count,
  labelRenderer,
  type,
  unread,
}) => {
  const label = useMemo(
    () =>
      labelRenderer({
        name: <NamesList accountIds={accountIds} total={count} />,
      }),
    [labelRenderer, accountIds, count],
  );

  return (
    <div
      role='button'
      className={classNames(
        `notification-ungrouped focusable notification-ungrouped--${type}`,
        { 'notification-ungrouped--unread': unread },
      )}
      tabIndex={0}
    >
      <div className='notification-ungrouped__header'>
        <div className='notification-ungrouped__header__icon'>
          <Icon icon={icon} id={iconId} />
        </div>
        {label}
      </div>

      {/* @ts-expect-error -- <Status> is not yet typed */}
      <Status id={statusId} contextType='notifications' withDismiss skipPrepend avatarSize={40} />
    </div>
  );
};

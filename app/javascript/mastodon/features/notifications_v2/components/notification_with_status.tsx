import { useMemo } from 'react';

import classNames from 'classnames';

import type { IconProp } from 'mastodon/components/icon';
import { Icon } from 'mastodon/components/icon';
import Status from 'mastodon/containers/status_container';
import { useAppSelector } from 'mastodon/store';

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

  const isPrivateMention = useAppSelector(
    (state) => state.statuses.getIn([statusId, 'visibility']) === 'direct',
  );

  return (
    <div
      role='button'
      className={classNames(
        `notification-ungrouped focusable notification-ungrouped--${type}`,
        {
          'notification-ungrouped--unread': unread,
          'notification-ungrouped--direct': isPrivateMention,
        },
      )}
      tabIndex={0}
    >
      <div className='notification-ungrouped__header'>
        <div className='notification-ungrouped__header__icon'>
          <Icon icon={icon} id={iconId} />
        </div>
        {label}
      </div>

      <Status
        // @ts-expect-error -- <Status> is not yet typed
        id={statusId}
        contextType='notifications'
        withDismiss
        skipPrepend
        avatarSize={40}
      />
    </div>
  );
};

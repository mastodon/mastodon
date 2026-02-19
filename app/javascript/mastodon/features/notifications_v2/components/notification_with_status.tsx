import { useMemo } from 'react';

import classNames from 'classnames';

import { LinkedDisplayName } from '@/mastodon/components/display_name';
import { replyComposeById } from 'mastodon/actions/compose';
import { toggleReblog, toggleFavourite } from 'mastodon/actions/interactions';
import {
  navigateToStatus,
  toggleStatusSpoilers,
} from 'mastodon/actions/statuses';
import { Hotkeys } from 'mastodon/components/hotkeys';
import type { IconProp } from 'mastodon/components/icon';
import { Icon } from 'mastodon/components/icon';
import { StatusQuoteManager } from 'mastodon/components/status_quoted';
import { getStatusHidden } from 'mastodon/selectors/filters';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import type { LabelRenderer } from './notification_group_with_status';

export const NotificationWithStatus: React.FC<{
  type: string;
  icon: IconProp;
  iconId: string;
  accountIds: string[];
  statusId: string | undefined;
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
  const dispatch = useAppDispatch();

  const account = useAppSelector((state) =>
    state.accounts.get(accountIds.at(0) ?? ''),
  );
  const label = useMemo(
    () =>
      labelRenderer(
        <LinkedDisplayName displayProps={{ account, variant: 'simple' }} />,
        count,
      ),
    [labelRenderer, account, count],
  );

  const isPrivateMention = useAppSelector(
    (state) => state.statuses.getIn([statusId, 'visibility']) === 'direct',
  );

  const isFiltered = useAppSelector(
    (state) =>
      statusId &&
      getStatusHidden(state, { id: statusId, contextType: 'notifications' }),
  );

  const handlers = useMemo(
    () => ({
      open: () => {
        dispatch(navigateToStatus(statusId));
      },

      reply: () => {
        dispatch(replyComposeById(statusId));
      },

      boost: () => {
        dispatch(toggleReblog(statusId));
      },

      favourite: () => {
        dispatch(toggleFavourite(statusId));
      },

      toggleHidden: () => {
        dispatch(toggleStatusSpoilers(statusId));
      },
    }),
    [dispatch, statusId],
  );

  if (!statusId || isFiltered) return null;

  return (
    <Hotkeys handlers={handlers}>
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

        <StatusQuoteManager
          id={statusId}
          contextType='notifications'
          withDismiss
          skipPrepend
          avatarSize={40}
          unfocusable
        />
      </div>
    </Hotkeys>
  );
};

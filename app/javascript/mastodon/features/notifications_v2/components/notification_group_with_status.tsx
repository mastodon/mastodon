import { useMemo } from 'react';

import classNames from 'classnames';

import { HotKeys } from 'react-hotkeys';

import { replyComposeById } from 'mastodon/actions/compose';
import { navigateToStatus } from 'mastodon/actions/statuses';
import type { IconProp } from 'mastodon/components/icon';
import { Icon } from 'mastodon/components/icon';
import { RelativeTimestamp } from 'mastodon/components/relative_timestamp';
import { useAppDispatch } from 'mastodon/store';

import { AvatarGroup } from './avatar_group';
import { EmbeddedStatus } from './embedded_status';
import { NamesList } from './names_list';

export type LabelRenderer = (
  values: Record<string, React.ReactNode>,
) => JSX.Element;

export const NotificationGroupWithStatus: React.FC<{
  icon: IconProp;
  iconId: string;
  statusId?: string;
  actions?: JSX.Element;
  count: number;
  accountIds: string[];
  timestamp: string;
  labelRenderer: LabelRenderer;
  labelSeeMoreHref?: string;
  type: string;
  unread: boolean;
}> = ({
  icon,
  iconId,
  timestamp,
  accountIds,
  actions,
  count,
  statusId,
  labelRenderer,
  labelSeeMoreHref,
  type,
  unread,
}) => {
  const dispatch = useAppDispatch();

  const label = useMemo(
    () =>
      labelRenderer({
        name: (
          <NamesList
            accountIds={accountIds}
            total={count}
            seeMoreHref={labelSeeMoreHref}
          />
        ),
      }),
    [labelRenderer, accountIds, count, labelSeeMoreHref],
  );

  const handlers = useMemo(
    () => ({
      open: () => {
        dispatch(navigateToStatus(statusId));
      },

      reply: () => {
        dispatch(replyComposeById(statusId));
      },
    }),
    [dispatch, statusId],
  );

  return (
    <HotKeys handlers={handlers}>
      <div
        role='button'
        className={classNames(
          `notification-group focusable notification-group--${type}`,
          { 'notification-group--unread': unread },
        )}
        tabIndex={0}
      >
        <div className='notification-group__icon'>
          <Icon icon={icon} id={iconId} />
        </div>

        <div className='notification-group__main'>
          <div className='notification-group__main__header'>
            <div className='notification-group__main__header__wrapper'>
              <AvatarGroup accountIds={accountIds} />

              {actions}
            </div>

            <div className='notification-group__main__header__label'>
              {label}
              {timestamp && <RelativeTimestamp timestamp={timestamp} />}
            </div>
          </div>

          {statusId && (
            <div className='notification-group__main__status'>
              <EmbeddedStatus statusId={statusId} />
            </div>
          )}
        </div>
      </div>
    </HotKeys>
  );
};

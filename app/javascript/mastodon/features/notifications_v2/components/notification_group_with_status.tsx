import { useMemo } from 'react';
import type { JSX } from 'react';

import classNames from 'classnames';

import { HotKeys } from 'react-hotkeys';

import { replyComposeById } from 'mastodon/actions/compose';
import { navigateToStatus } from 'mastodon/actions/statuses';
import { Avatar } from 'mastodon/components/avatar';
import { AvatarGroup } from 'mastodon/components/avatar_group';
import type { IconProp } from 'mastodon/components/icon';
import { Icon } from 'mastodon/components/icon';
import { RelativeTimestamp } from 'mastodon/components/relative_timestamp';
import { NOTIFICATIONS_GROUP_MAX_AVATARS } from 'mastodon/models/notification_group';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { DisplayedName } from './displayed_name';
import { EmbeddedStatus } from './embedded_status';

export const AvatarById: React.FC<{ accountId: string }> = ({ accountId }) => {
  const account = useAppSelector((state) => state.accounts.get(accountId));

  if (!account) return null;

  return <Avatar withLink account={account} size={28} />;
};

export type LabelRenderer = (
  displayedName: JSX.Element,
  total: number,
  seeMoreHref?: string,
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
  additionalContent?: JSX.Element;
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
  additionalContent,
}) => {
  const dispatch = useAppDispatch();

  const label = useMemo(
    () =>
      labelRenderer(
        <DisplayedName accountIds={accountIds} />,
        count,
        labelSeeMoreHref,
      ),
    [labelRenderer, accountIds, count, labelSeeMoreHref],
  );

  const isPrivateMention = useAppSelector(
    (state) => state.statuses.getIn([statusId, 'visibility']) === 'direct',
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
          {
            'notification-group--unread': unread,
            'notification-group--direct': isPrivateMention,
          },
        )}
        tabIndex={0}
      >
        <div className='notification-group__icon'>
          <Icon icon={icon} id={iconId} />
        </div>

        <div className='notification-group__main'>
          <div className='notification-group__main__header'>
            <div className='notification-group__main__header__wrapper'>
              <AvatarGroup>
                {accountIds
                  .slice(0, NOTIFICATIONS_GROUP_MAX_AVATARS)
                  .map((id) => (
                    <AvatarById key={id} accountId={id} />
                  ))}
              </AvatarGroup>

              {actions && (
                <div className='notification-group__actions'>{actions}</div>
              )}
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

          {additionalContent && (
            <div className='notification-group__main__additional-content'>
              {additionalContent}
            </div>
          )}
        </div>
      </div>
    </HotKeys>
  );
};

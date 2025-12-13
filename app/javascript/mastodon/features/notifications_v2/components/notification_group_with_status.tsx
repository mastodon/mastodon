import { useMemo } from 'react';
import type { JSX } from 'react';

import classNames from 'classnames';

import { LinkedDisplayName } from '@/mastodon/components/display_name';
import { replyComposeById } from 'mastodon/actions/compose';
import { navigateToStatus } from 'mastodon/actions/statuses';
import { Avatar } from 'mastodon/components/avatar';
import { AvatarGroup } from 'mastodon/components/avatar_group';
import { Hotkeys } from 'mastodon/components/hotkeys';
import type { IconProp } from 'mastodon/components/icon';
import { Icon } from 'mastodon/components/icon';
import { RelativeTimestamp } from 'mastodon/components/relative_timestamp';
import { NOTIFICATIONS_GROUP_MAX_AVATARS } from 'mastodon/models/notification_group';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { EmbeddedStatus } from './embedded_status';

const AVATAR_SIZE = 28;

export const AvatarById: React.FC<{ accountId: string }> = ({ accountId }) => {
  const account = useAppSelector((state) => state.accounts.get(accountId));

  if (!account) return null;

  return <Avatar withLink account={account} size={AVATAR_SIZE} />;
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
  const account = useAppSelector((state) =>
    state.accounts.get(accountIds.at(0) ?? ''),
  );

  const label = useMemo(
    () =>
      labelRenderer(
        <LinkedDisplayName displayProps={{ account, variant: 'simple' }} />,
        count,
        labelSeeMoreHref,
      ),
    [labelRenderer, account, count, labelSeeMoreHref],
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
    <Hotkeys handlers={handlers}>
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
              <AvatarGroup avatarHeight={AVATAR_SIZE}>
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
              {timestamp && (
                <>
                  <span className='notification-group__main__header__label-separator'>
                    &middot;
                  </span>
                  <RelativeTimestamp timestamp={timestamp} />
                </>
              )}
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
    </Hotkeys>
  );
};

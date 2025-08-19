import { useCallback, useMemo } from 'react';
import type { FC, MouseEventHandler } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { quoteComposeById } from '@/mastodon/actions/compose_typed';
import { toggleReblog } from '@/mastodon/actions/interactions';
import { openModal } from '@/mastodon/actions/modal';
import { me } from '@/mastodon/initial_state';
import type { ActionMenuItem } from '@/mastodon/models/dropdown_menu';
import type { Status, StatusVisibility } from '@/mastodon/models/status';
import { useAppDispatch } from '@/mastodon/store';
import { isFeatureEnabled } from '@/mastodon/utils/environment';
import RepeatIcon from '@/material-icons/400-24px/repeat.svg?react';
import RepeatActiveIcon from '@/svg-icons/repeat_active.svg?react';
import RepeatDisabledIcon from '@/svg-icons/repeat_disabled.svg?react';
import RepeatPrivateIcon from '@/svg-icons/repeat_private.svg?react';
import RepeatPrivateActiveIcon from '@/svg-icons/repeat_private_active.svg?react';

import type { RenderItemFn, RenderItemFnHandlers } from '../dropdown_menu';
import { Dropdown } from '../dropdown_menu';
import { Icon } from '../icon';
import { IconButton } from '../icon_button';

const messages = defineMessages({
  quote: { id: 'status.quote', defaultMessage: 'Quote' },
  quote_cannot: {
    id: 'status.cannot_quote',
    defaultMessage: 'Author has disabled quoting on this post',
  },
  quote_private: {
    id: 'status.quote_private',
    defaultMessage: 'Private posts cannot be quoted',
  },
  reblog: { id: 'status.reblog', defaultMessage: 'Boost' },
  reblog_private: {
    id: 'status.reblog_private',
    defaultMessage: 'Boost with original visibility',
  },
  reblog_private_cancel: {
    id: 'status.cancel_reblog_private',
    defaultMessage: 'Unboost',
  },
  reblog_cannot: {
    id: 'status.cannot_reblog',
    defaultMessage: 'This post cannot be boosted',
  },
});

export const StatusReblogButton: FC<{ status: Status }> = ({ status }) => {
  const intl = useIntl();

  const dispatch = useAppDispatch();
  const statusId = status.get('id') as string;
  const items: ActionMenuItem[] = useMemo(
    () => [
      {
        text: 'reblog',
        action: (event) => {
          if (me) {
            dispatch(toggleReblog(statusId, event.shiftKey));
          }
        },
      },
      {
        text: 'quote',
        action: () => {
          if (me) {
            dispatch(quoteComposeById(statusId));
          }
        },
      },
    ],
    [dispatch, statusId],
  );

  const handleDropdownOpen = useCallback(() => {
    if (!me) {
      dispatch(
        openModal({
          modalType: 'INTERACTION',
          modalProps: {
            type: 'reblog',
            accountId: status.getIn(['account', 'id']),
            url: status.get('uri'),
          },
        }),
      );
    }
  }, [dispatch, status]);

  const renderMenuItem: RenderItemFn<ActionMenuItem> = useCallback(
    (item, index, handlers) => (
      <ReblogMenuItem
        status={status}
        index={index}
        item={item}
        handlers={handlers}
        key={`${item.text}-${index}`}
      />
    ),
    [status],
  );

  return (
    <Dropdown
      icon='retweet'
      iconComponent={RepeatIcon}
      title={intl.formatMessage(messages.reblog)}
      items={items}
      renderItem={renderMenuItem}
      onOpen={handleDropdownOpen}
    />
  );
};

interface ReblogMenuItemProps {
  status: Status;
  item: ActionMenuItem;
  index: number;
  handlers: RenderItemFnHandlers;
}

const ReblogMenuItem: FC<ReblogMenuItemProps> = ({
  status,
  index,
  item: { text },
  handlers: { onRef, ...handlers },
}) => {
  const intl = useIntl();
  const { title, iconComponent, disabled } = useMemo(
    () => (text === 'quote' ? quoteIconText(status) : reblogIconText(status)),
    [status, text],
  );

  return (
    <li className='dropdown-menu__item' key={`${text}-${index}`}>
      <button
        {...handlers}
        title={intl.formatMessage(title)}
        ref={onRef}
        disabled={disabled}
        data-index={index}
      >
        <Icon id='retweet' icon={iconComponent} />
        <div>{intl.formatMessage(title)}</div>
      </button>
    </li>
  );
};

// Legacy helpers

// Switch between the legacy and new reblog button based on feature flag.
export const ReblogButton: FC<{ status: Status }> = ({ status }) => {
  if (isFeatureEnabled('outgoing_quotes')) {
    return <StatusReblogButton status={status} />;
  }
  return <LegacyReblogButton status={status} />;
};

export const LegacyReblogButton: FC<{ status: Status }> = ({ status }) => {
  const intl = useIntl();
  const { title, iconComponent, disabled } = useMemo(
    () => reblogIconText(status),
    [status],
  );

  const dispatch = useAppDispatch();
  const handleClick: MouseEventHandler = useCallback(
    (event) => {
      if (me) {
        dispatch(toggleReblog(status.get('id') as string, event.shiftKey));
      } else {
        dispatch(
          openModal({
            modalType: 'INTERACTION',
            modalProps: {
              type: 'reblog',
              accountId: status.getIn(['account', 'id']),
              url: status.get('uri'),
            },
          }),
        );
      }
    },
    [dispatch, status],
  );

  return (
    <IconButton
      disabled={disabled}
      active={!!status.get('reblogged')}
      title={intl.formatMessage(title)}
      icon='retweet'
      iconComponent={iconComponent}
      onClick={!disabled ? handleClick : undefined}
    />
  );
};

// Helpers for copy and state for status.
function reblogIconText(status: Status) {
  const publicStatus = ['public', 'unlisted'].includes(
    status.get('visibility') as StatusVisibility,
  );
  const reblogPrivate =
    status.getIn(['account', 'id']) === me &&
    status.get('visibility') === 'private';
  if (status.get('reblogged')) {
    return {
      title: messages.reblog_private_cancel,
      iconComponent: publicStatus ? RepeatActiveIcon : RepeatPrivateActiveIcon,
    };
  } else if (publicStatus) {
    return {
      title: messages.reblog,
      iconComponent: RepeatIcon,
    };
  } else if (reblogPrivate) {
    return {
      title: messages.reblog_private,
      iconComponent: RepeatPrivateIcon,
    };
  }
  return {
    title: messages.reblog_cannot,
    iconComponent: RepeatDisabledIcon,
    disabled: true,
  };
}

function quoteIconText(status: Status) {
  const publicStatus = ['public', 'unlisted'].includes(
    status.get('visibility') as StatusVisibility,
  );
  const quoteAllowed =
    status.getIn(['quote_approval', 'current_user']) === 'automatic';
  if (!quoteAllowed) {
    return {
      title: messages.quote_cannot,
      iconComponent: RepeatDisabledIcon,
      disabled: true,
    };
  } else if (!publicStatus) {
    return {
      title: messages.quote_private,
      iconComponent: RepeatPrivateIcon,
      disabled: true,
    };
  }
  return {
    title: messages.quote,
    iconComponent: RepeatIcon,
  };
}

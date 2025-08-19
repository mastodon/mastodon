import { useCallback, useMemo } from 'react';
import type { FC, MouseEventHandler, SVGProps } from 'react';

import type { MessageDescriptor } from 'react-intl';
import { defineMessages, useIntl } from 'react-intl';

import { quoteComposeById } from '@/mastodon/actions/compose_typed';
import { toggleReblog } from '@/mastodon/actions/interactions';
import { openModal } from '@/mastodon/actions/modal';
import type { ActionMenuItem } from '@/mastodon/models/dropdown_menu';
import type { Status, StatusVisibility } from '@/mastodon/models/status';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import { isFeatureEnabled } from '@/mastodon/utils/environment';
import FormatQuote from '@/material-icons/400-24px/format_quote.svg?react';
import FormatQuoteOff from '@/material-icons/400-24px/format_quote_off.svg?react';
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
  reblog_cancel: {
    id: 'status.cancel_reblog_private',
    defaultMessage: 'Unboost',
  },
  reblog_private: {
    id: 'status.reblog_private',
    defaultMessage: 'Boost with original visibility',
  },
  reblog_cannot: {
    id: 'status.cannot_reblog',
    defaultMessage: 'This post cannot be boosted',
  },
});

interface ReblogButtonProps {
  status: Status;
  counters?: boolean;
}

export const StatusReblogButton: FC<ReblogButtonProps> = ({
  status,
  counters,
}) => {
  const intl = useIntl();

  const isLoggedIn = useAppSelector((state) => !!state.meta.get('me'));

  const dispatch = useAppDispatch();
  const statusId = status.get('id') as string;
  const items: ActionMenuItem[] = useMemo(
    () => [
      {
        text: 'reblog',
        action: (event) => {
          if (isLoggedIn) {
            dispatch(toggleReblog(statusId, event.shiftKey));
          }
        },
      },
      {
        text: 'quote',
        action: () => {
          if (isLoggedIn) {
            dispatch(quoteComposeById(statusId));
          }
        },
      },
    ],
    [dispatch, isLoggedIn, statusId],
  );

  const handleDropdownOpen = useCallback(() => {
    if (!isLoggedIn) {
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
  }, [dispatch, isLoggedIn, status]);

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
      items={items}
      renderItem={renderMenuItem}
      onOpen={handleDropdownOpen}
    >
      <IconButton
        title={intl.formatMessage(messages.reblog)}
        icon='retweet'
        iconComponent={status.get('reblogged') ? RepeatActiveIcon : RepeatIcon}
        counter={counters ? (status.get('reblogs_count') as number) : undefined}
      />
    </Dropdown>
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
  const userId = useAppSelector(
    (state) => state.meta.get('me') as string | undefined,
  );
  const { title, meta, iconComponent, disabled } = useMemo(
    () =>
      text === 'quote' ? quoteIconText(status) : reblogIconText(status, userId),
    [status, text, userId],
  );

  return (
    <li
      className='dropdown-menu__item reblog-button__item'
      key={`${text}-${index}`}
    >
      <button
        {...handlers}
        title={intl.formatMessage(title)}
        ref={onRef}
        disabled={disabled}
        data-index={index}
      >
        <Icon
          id={text === 'quote' ? 'quote' : 'retweet'}
          icon={iconComponent}
        />
        <div>
          {intl.formatMessage(title)}
          {meta && (
            <span className='reblog-button__meta'>
              {intl.formatMessage(meta)}
            </span>
          )}
        </div>
      </button>
    </li>
  );
};

// Legacy helpers

// Switch between the legacy and new reblog button based on feature flag.
export const ReblogButton: FC<ReblogButtonProps> = (props) => {
  if (isFeatureEnabled('outgoing_quotes')) {
    return <StatusReblogButton {...props} />;
  }
  return <LegacyReblogButton {...props} />;
};

export const LegacyReblogButton: FC<ReblogButtonProps> = ({
  status,
  counters,
}) => {
  const intl = useIntl();
  const userId = useAppSelector(
    (state) => state.meta.get('me') as string | undefined,
  );
  const isLoggedIn = !!userId;

  const { title, meta, iconComponent, disabled } = useMemo(
    () => reblogIconText(status, userId),
    [status, userId],
  );

  const dispatch = useAppDispatch();
  const handleClick: MouseEventHandler = useCallback(
    (event) => {
      if (isLoggedIn) {
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
    [dispatch, isLoggedIn, status],
  );

  return (
    <IconButton
      disabled={disabled}
      active={!!status.get('reblogged')}
      title={intl.formatMessage(meta ?? title)}
      icon='retweet'
      iconComponent={iconComponent}
      onClick={!disabled ? handleClick : undefined}
      counter={counters ? (status.get('reblogs_count') as number) : undefined}
    />
  );
};

// Helpers for copy and state for status.
interface IconText {
  title: MessageDescriptor;
  meta?: MessageDescriptor;
  iconComponent: FC<SVGProps<SVGSVGElement>>;
  disabled?: boolean;
}

function reblogIconText(status: Status, userId?: string): IconText {
  const publicStatus = ['public', 'unlisted'].includes(
    status.get('visibility') as StatusVisibility,
  );
  const reblogPrivate =
    status.getIn(['account', 'id']) === userId &&
    status.get('visibility') === 'private';

  if (status.get('reblogged')) {
    return {
      title: messages.reblog_cancel,
      iconComponent: publicStatus ? RepeatActiveIcon : RepeatPrivateActiveIcon,
    };
  }
  const iconText: IconText = {
    title: messages.reblog,
    iconComponent: RepeatIcon,
  };

  if (reblogPrivate) {
    iconText.meta = messages.reblog_private;
    iconText.iconComponent = RepeatPrivateIcon;
  } else if (!publicStatus) {
    iconText.meta = messages.reblog_cannot;
    iconText.iconComponent = RepeatDisabledIcon;
    iconText.disabled = true;
  }
  return iconText;
}

function quoteIconText(status: Status): IconText {
  const publicStatus = ['public', 'unlisted'].includes(
    status.get('visibility') as StatusVisibility,
  );
  const quoteAllowed =
    status.getIn(['quote_approval', 'current_user']) === 'automatic';

  const iconText: IconText = {
    title: messages.quote,
    iconComponent: FormatQuote,
  };

  if (!quoteAllowed || !publicStatus) {
    iconText.meta = !quoteAllowed
      ? messages.quote_cannot
      : messages.quote_private;
    iconText.iconComponent = FormatQuoteOff;
    iconText.disabled = true;
  }
  return iconText;
}

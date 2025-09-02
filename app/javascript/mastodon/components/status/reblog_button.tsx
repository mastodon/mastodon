import { useCallback, useMemo } from 'react';
import type {
  FC,
  KeyboardEvent,
  MouseEvent,
  MouseEventHandler,
  SVGProps,
} from 'react';

import type { MessageDescriptor } from 'react-intl';
import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';

import { quoteComposeById } from '@/mastodon/actions/compose_typed';
import { toggleReblog } from '@/mastodon/actions/interactions';
import { openModal } from '@/mastodon/actions/modal';
import type { ActionMenuItem } from '@/mastodon/models/dropdown_menu';
import type { Status, StatusVisibility } from '@/mastodon/models/status';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';
import { isFeatureEnabled } from '@/mastodon/utils/environment';
import FormatQuote from '@/material-icons/400-24px/format_quote-fill.svg?react';
import FormatQuoteOff from '@/material-icons/400-24px/format_quote_off-fill.svg?react';
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
  all_disabled: {
    id: 'status.all_disabled',
    defaultMessage: 'Boosts and quotes are disabled',
  },
  quote: { id: 'status.quote', defaultMessage: 'Quote' },
  quote_cannot: {
    id: 'status.cannot_quote',
    defaultMessage: 'Quotes are disabled on this post',
  },
  quote_followers_only: {
    id: 'status.quote_followers_only',
    defaultMessage: 'Only followers can quote this post',
  },
  quote_manual_review: {
    id: 'status.quote_manual_review',
    defaultMessage: 'Author will manually review',
  },
  quote_private: {
    id: 'status.quote_private',
    defaultMessage: 'Private posts cannot be quoted',
  },
  reblog: { id: 'status.reblog', defaultMessage: 'Boost' },
  reblog_or_quote: {
    id: 'status.reblog_or_quote',
    defaultMessage: 'Boost or quote',
  },
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
  request_quote: {
    id: 'status.request_quote',
    defaultMessage: 'Request to quote',
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

  const statusState = useAppSelector((state) =>
    selectStatusState(state, status),
  );
  const {
    isLoggedIn,
    isReblogged,
    isReblogAllowed,
    isQuoteAutomaticallyAccepted,
    isQuoteManuallyAccepted,
  } = statusState;
  const { iconComponent } = useMemo(
    () => reblogIconText(statusState),
    [statusState],
  );
  const disabled =
    !isQuoteAutomaticallyAccepted &&
    !isQuoteManuallyAccepted &&
    !isReblogAllowed;

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

  const handleDropdownOpen = useCallback(
    (event: MouseEvent | KeyboardEvent) => {
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
      } else if (event.shiftKey) {
        dispatch(toggleReblog(status.get('id'), true));
        return false;
      }
      return true;
    },
    [dispatch, isLoggedIn, status],
  );

  const renderMenuItem: RenderItemFn<ActionMenuItem> = useCallback(
    (item, index, handlers, focusRefCallback) => (
      <ReblogMenuItem
        status={status}
        index={index}
        item={item}
        handlers={handlers}
        key={`${item.text}-${index}`}
        focusRefCallback={focusRefCallback}
      />
    ),
    [status],
  );

  return (
    <Dropdown
      items={items}
      renderItem={renderMenuItem}
      onOpen={handleDropdownOpen}
      disabled={disabled}
    >
      <IconButton
        title={intl.formatMessage(
          !disabled ? messages.reblog_or_quote : messages.all_disabled,
        )}
        icon='retweet'
        iconComponent={iconComponent}
        counter={
          counters
            ? (status.get('reblogs_count') as number) +
              (status.get('quotes_count') as number)
            : undefined
        }
        active={isReblogged}
      />
    </Dropdown>
  );
};

interface ReblogMenuItemProps {
  status: Status;
  item: ActionMenuItem;
  index: number;
  handlers: RenderItemFnHandlers;
  focusRefCallback?: (c: HTMLAnchorElement | HTMLButtonElement | null) => void;
}

const ReblogMenuItem: FC<ReblogMenuItemProps> = ({
  status,
  index,
  item: { text },
  handlers,
  focusRefCallback,
}) => {
  const intl = useIntl();
  const statusState = useAppSelector((state) =>
    selectStatusState(state, status),
  );
  const { title, meta, iconComponent, disabled } = useMemo(
    () =>
      text === 'quote'
        ? quoteIconText(statusState)
        : reblogIconText(statusState),
    [statusState, text],
  );
  const active = useMemo(
    () => text === 'reblog' && !!status.get('reblogged'),
    [status, text],
  );

  return (
    <li
      className={classNames('dropdown-menu__item reblog-button__item', {
        disabled,
        active,
      })}
      key={`${text}-${index}`}
    >
      <button
        {...handlers}
        title={intl.formatMessage(title)}
        ref={focusRefCallback}
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
  const statusState = useAppSelector((state) =>
    selectStatusState(state, status),
  );

  const { title, meta, iconComponent, disabled } = useMemo(
    () => reblogIconText(statusState),
    [statusState],
  );

  const dispatch = useAppDispatch();
  const handleClick: MouseEventHandler = useCallback(
    (event) => {
      if (statusState.isLoggedIn) {
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
    [dispatch, status, statusState.isLoggedIn],
  );

  return (
    <IconButton
      disabled={disabled}
      active={!!status.get('reblogged')}
      title={intl.formatMessage(meta ?? title)}
      icon='retweet'
      iconComponent={iconComponent}
      onClick={!disabled ? handleClick : undefined}
      counter={
        counters
          ? (status.get('reblogs_count') as number) +
            (status.get('quotes_count') as number)
          : undefined
      }
    />
  );
};

// Helpers for copy and state for status.
const selectStatusState = createAppSelector(
  [
    (state) => state.meta.get('me') as string | undefined,
    (_, status: Status) => status,
  ],
  (userId, status) => {
    const isPublic = ['public', 'unlisted'].includes(
      status.get('visibility') as StatusVisibility,
    );
    const isMineAndPrivate =
      userId === status.getIn(['account', 'id']) &&
      status.get('visibility') === 'private';
    return {
      isLoggedIn: !!userId,
      isPublic,
      isMine: userId === status.getIn(['account', 'id']),
      isPrivateReblog:
        userId === status.getIn(['account', 'id']) &&
        status.get('visibility') === 'private',
      isReblogged: !!status.get('reblogged'),
      isReblogAllowed: isPublic || isMineAndPrivate,
      isQuoteAutomaticallyAccepted:
        status.getIn(['quote_approval', 'current_user']) === 'automatic' &&
        (isPublic || isMineAndPrivate),
      isQuoteManuallyAccepted:
        status.getIn(['quote_approval', 'current_user']) === 'manual' &&
        (isPublic || isMineAndPrivate),
      isQuoteFollowersOnly:
        status.getIn(['quote_approval', 'automatic', 0]) === 'followers' ||
        status.getIn(['quote_approval', 'manual', 0]) === 'followers',
    };
  },
);
type StatusState = ReturnType<typeof selectStatusState>;

interface IconText {
  title: MessageDescriptor;
  meta?: MessageDescriptor;
  iconComponent: FC<SVGProps<SVGSVGElement>>;
  disabled?: boolean;
}

function reblogIconText({
  isPublic,
  isPrivateReblog,
  isReblogged,
}: StatusState): IconText {
  if (isReblogged) {
    return {
      title: messages.reblog_cancel,
      iconComponent: isPublic ? RepeatActiveIcon : RepeatPrivateActiveIcon,
    };
  }
  const iconText: IconText = {
    title: messages.reblog,
    iconComponent: RepeatIcon,
  };

  if (isPrivateReblog) {
    iconText.meta = messages.reblog_private;
    iconText.iconComponent = RepeatPrivateIcon;
  } else if (!isPublic) {
    iconText.meta = messages.reblog_cannot;
    iconText.iconComponent = RepeatDisabledIcon;
    iconText.disabled = true;
  }
  return iconText;
}

function quoteIconText({
  isMine,
  isQuoteAutomaticallyAccepted,
  isQuoteManuallyAccepted,
  isQuoteFollowersOnly,
  isPublic,
}: StatusState): IconText {
  const iconText: IconText = {
    title: messages.quote,
    iconComponent: FormatQuote,
  };

  if (!isPublic && !isMine) {
    iconText.disabled = true;
    iconText.iconComponent = FormatQuoteOff;
    iconText.meta = messages.quote_private;
  } else if (isQuoteAutomaticallyAccepted) {
    iconText.title = messages.quote;
  } else if (isQuoteManuallyAccepted) {
    iconText.title = messages.request_quote;
    iconText.meta = messages.quote_manual_review;
  } else {
    iconText.disabled = true;
    iconText.iconComponent = FormatQuoteOff;
    iconText.meta = isQuoteFollowersOnly
      ? messages.quote_followers_only
      : messages.quote_cannot;
  }

  return iconText;
}

import { defineMessages } from 'react-intl';
import type { MessageDescriptor } from 'react-intl';

import type { Status, StatusVisibility } from '@/mastodon/models/status';
import { createAppSelector } from '@/mastodon/store';
import FormatQuote from '@/material-icons/400-24px/format_quote-fill.svg?react';
import FormatQuoteOff from '@/material-icons/400-24px/format_quote_off-fill.svg?react';
import RepeatIcon from '@/material-icons/400-24px/repeat.svg?react';
import RepeatActiveIcon from '@/svg-icons/repeat_active.svg?react';
import RepeatDisabledIcon from '@/svg-icons/repeat_disabled.svg?react';
import RepeatPrivateIcon from '@/svg-icons/repeat_private.svg?react';
import RepeatPrivateActiveIcon from '@/svg-icons/repeat_private_active.svg?react';

import type { IconProp } from '../icon';

export const messages = defineMessages({
  all_disabled: {
    id: 'status.all_disabled',
    defaultMessage: 'Boosts and quotes are disabled',
  },
  quote: {
    id: 'status.quote',
    defaultMessage: 'Quote',
    description: 'Quote as a verb (e.g. Quote this post)',
  },
  quote_cannot: {
    id: 'status.cannot_quote',
    defaultMessage: 'You are not allowed to quote this post',
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
    defaultMessage: 'Share again with your followers',
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

export const selectStatusState = createAppSelector(
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

export type StatusState = ReturnType<typeof selectStatusState>;

export interface MenuItemState {
  title: MessageDescriptor;
  meta?: MessageDescriptor;
  iconComponent: IconProp;
  disabled?: boolean;
}

export function boostItemState({
  isPublic,
  isPrivateReblog,
  isReblogged,
}: StatusState): MenuItemState {
  if (isReblogged) {
    return {
      title: messages.reblog_cancel,
      iconComponent: isPublic ? RepeatActiveIcon : RepeatPrivateActiveIcon,
    };
  }
  const iconText: MenuItemState = {
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

export function quoteItemState({
  isLoggedIn,
  isMine,
  isQuoteAutomaticallyAccepted,
  isQuoteManuallyAccepted,
  isQuoteFollowersOnly,
  isPublic,
}: StatusState): MenuItemState {
  const iconText: MenuItemState = {
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
    // We don't show the disabled state when logged out
  } else if (isLoggedIn) {
    iconText.disabled = true;
    iconText.iconComponent = FormatQuoteOff;
    iconText.meta = isQuoteFollowersOnly
      ? messages.quote_followers_only
      : messages.quote_cannot;
  }

  return iconText;
}

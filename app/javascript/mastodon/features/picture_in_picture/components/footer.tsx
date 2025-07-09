import { useCallback, useMemo } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';
import { useHistory } from 'react-router-dom';

import OpenInNewIcon from '@/material-icons/400-24px/open_in_new.svg?react';
import RepeatIcon from '@/material-icons/400-24px/repeat.svg?react';
import ReplyIcon from '@/material-icons/400-24px/reply.svg?react';
import ReplyAllIcon from '@/material-icons/400-24px/reply_all.svg?react';
import StarIcon from '@/material-icons/400-24px/star-fill.svg?react';
import StarBorderIcon from '@/material-icons/400-24px/star.svg?react';
import RepeatActiveIcon from '@/svg-icons/repeat_active.svg?react';
import RepeatDisabledIcon from '@/svg-icons/repeat_disabled.svg?react';
import RepeatPrivateIcon from '@/svg-icons/repeat_private.svg?react';
import RepeatPrivateActiveIcon from '@/svg-icons/repeat_private_active.svg?react';
import { replyCompose } from 'mastodon/actions/compose';
import { toggleReblog, toggleFavourite } from 'mastodon/actions/interactions';
import { openModal } from 'mastodon/actions/modal';
import { IconButton } from 'mastodon/components/icon_button';
import { useIdentity } from 'mastodon/identity_context';
import { me } from 'mastodon/initial_state';
import type { Status } from 'mastodon/models/status';
import { makeGetStatus } from 'mastodon/selectors';
import type { RootState } from 'mastodon/store';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

const messages = defineMessages({
  reply: { id: 'status.reply', defaultMessage: 'Reply' },
  replyAll: { id: 'status.replyAll', defaultMessage: 'Reply to thread' },
  reblog: { id: 'status.reblog', defaultMessage: 'Boost' },
  reblog_private: {
    id: 'status.reblog_private',
    defaultMessage: 'Boost with original visibility',
  },
  cancel_reblog_private: {
    id: 'status.cancel_reblog_private',
    defaultMessage: 'Unboost',
  },
  cannot_reblog: {
    id: 'status.cannot_reblog',
    defaultMessage: 'This post cannot be boosted',
  },
  favourite: { id: 'status.favourite', defaultMessage: 'Favorite' },
  removeFavourite: {
    id: 'status.remove_favourite',
    defaultMessage: 'Remove from favorites',
  },
  open: { id: 'status.open', defaultMessage: 'Expand this status' },
});

type GetStatusSelector = (
  state: RootState,
  props: { id?: string | null; contextType?: string },
) => Status | null;

export const Footer: React.FC<{
  statusId: string;
  withOpenButton?: boolean;
  onClose: (arg0?: boolean) => void;
}> = ({ statusId, withOpenButton, onClose }) => {
  const { signedIn } = useIdentity();
  const intl = useIntl();
  const history = useHistory();
  const dispatch = useAppDispatch();
  const getStatus = useMemo(() => makeGetStatus(), []) as GetStatusSelector;
  const status = useAppSelector((state) => getStatus(state, { id: statusId }));
  const accountId = status?.get('account') as string | undefined;
  const account = useAppSelector((state) =>
    accountId ? state.accounts.get(accountId) : undefined,
  );
  const askReplyConfirmation = useAppSelector(
    (state) => (state.compose.get('text') as string).trim().length !== 0,
  );

  const handleReplyClick = useCallback(() => {
    if (!status) {
      return;
    }

    if (signedIn) {
      onClose(true);

      if (askReplyConfirmation) {
        dispatch(
          openModal({ modalType: 'CONFIRM_REPLY', modalProps: { status } }),
        );
      } else {
        dispatch(replyCompose(status));
      }
    } else {
      dispatch(
        openModal({
          modalType: 'INTERACTION',
          modalProps: {
            type: 'reply',
            accountId: status.getIn(['account', 'id']),
            url: status.get('uri'),
          },
        }),
      );
    }
  }, [dispatch, status, signedIn, askReplyConfirmation, onClose]);

  const handleFavouriteClick = useCallback(() => {
    if (!status) {
      return;
    }

    if (signedIn) {
      dispatch(toggleFavourite(status.get('id')));
    } else {
      dispatch(
        openModal({
          modalType: 'INTERACTION',
          modalProps: {
            type: 'favourite',
            accountId: status.getIn(['account', 'id']),
            url: status.get('uri'),
          },
        }),
      );
    }
  }, [dispatch, status, signedIn]);

  const handleReblogClick = useCallback(
    (e: React.MouseEvent) => {
      if (!status) {
        return;
      }

      if (signedIn) {
        dispatch(toggleReblog(status.get('id'), e.shiftKey));
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
    [dispatch, status, signedIn],
  );

  const handleOpenClick = useCallback(
    (e: React.MouseEvent) => {
      if (e.button !== 0 || !status) {
        return;
      }

      onClose();

      history.push(`/@${account?.acct}/${status.get('id') as string}`);
    },
    [history, status, account, onClose],
  );

  if (!status) {
    return null;
  }

  const publicStatus = ['public', 'unlisted'].includes(
    status.get('visibility') as string,
  );
  const reblogPrivate =
    status.getIn(['account', 'id']) === me &&
    status.get('visibility') === 'private';

  let replyIcon, replyIconComponent, replyTitle;

  if (status.get('in_reply_to_id', null) === null) {
    replyIcon = 'reply';
    replyIconComponent = ReplyIcon;
    replyTitle = intl.formatMessage(messages.reply);
  } else {
    replyIcon = 'reply-all';
    replyIconComponent = ReplyAllIcon;
    replyTitle = intl.formatMessage(messages.replyAll);
  }

  let reblogTitle, reblogIconComponent;

  if (status.get('reblogged')) {
    reblogTitle = intl.formatMessage(messages.cancel_reblog_private);
    reblogIconComponent = publicStatus
      ? RepeatActiveIcon
      : RepeatPrivateActiveIcon;
  } else if (publicStatus) {
    reblogTitle = intl.formatMessage(messages.reblog);
    reblogIconComponent = RepeatIcon;
  } else if (reblogPrivate) {
    reblogTitle = intl.formatMessage(messages.reblog_private);
    reblogIconComponent = RepeatPrivateIcon;
  } else {
    reblogTitle = intl.formatMessage(messages.cannot_reblog);
    reblogIconComponent = RepeatDisabledIcon;
  }

  const favouriteTitle = intl.formatMessage(
    status.get('favourited') ? messages.removeFavourite : messages.favourite,
  );

  return (
    <div className='picture-in-picture__footer'>
      <IconButton
        className='status__action-bar-button'
        title={replyTitle}
        icon={
          status.get('in_reply_to_account_id') ===
          status.getIn(['account', 'id'])
            ? 'reply'
            : replyIcon
        }
        iconComponent={
          status.get('in_reply_to_account_id') ===
          status.getIn(['account', 'id'])
            ? ReplyIcon
            : replyIconComponent
        }
        onClick={handleReplyClick}
        counter={status.get('replies_count') as number}
      />

      <IconButton
        className={classNames('status__action-bar-button', { reblogPrivate })}
        disabled={!publicStatus && !reblogPrivate}
        active={status.get('reblogged') as boolean}
        title={reblogTitle}
        icon='retweet'
        iconComponent={reblogIconComponent}
        onClick={handleReblogClick}
        counter={status.get('reblogs_count') as number}
      />

      <IconButton
        className='status__action-bar-button star-icon'
        animate
        active={status.get('favourited') as boolean}
        title={favouriteTitle}
        icon='star'
        iconComponent={status.get('favourited') ? StarIcon : StarBorderIcon}
        onClick={handleFavouriteClick}
        counter={status.get('favourites_count') as number}
      />

      {withOpenButton && (
        <IconButton
          className='status__action-bar-button'
          title={intl.formatMessage(messages.open)}
          icon='external-link'
          iconComponent={OpenInNewIcon}
          onClick={handleOpenClick}
          href={`/@${account?.acct}/${status.get('id') as string}`}
        />
      )}
    </div>
  );
};

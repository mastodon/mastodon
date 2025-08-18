import { useCallback, useMemo } from 'react';
import type { FC, MouseEventHandler } from 'react';

import { useIntl } from 'react-intl';

import classNames from 'classnames';

import {
  statusBookmark,
  statusFavourite,
  statusReblog,
  statusReply,
} from '@/mastodon/actions/statuses_typed';
import { useIdentity } from '@/mastodon/identity_context';
import { me } from '@/mastodon/initial_state';
import type { Status, StatusVisibility } from '@/mastodon/models/status';
import { useAppDispatch } from '@/mastodon/store';
import BookmarkIcon from '@/material-icons/400-24px/bookmark-fill.svg?react';
import BookmarkBorderIcon from '@/material-icons/400-24px/bookmark.svg?react';
import RepeatIcon from '@/material-icons/400-24px/repeat.svg?react';
import ReplyIcon from '@/material-icons/400-24px/reply.svg?react';
import ReplyAllIcon from '@/material-icons/400-24px/reply_all.svg?react';
import StarIcon from '@/material-icons/400-24px/star-fill.svg?react';
import StarBorderIcon from '@/material-icons/400-24px/star.svg?react';
import RepeatActiveIcon from '@/svg-icons/repeat_active.svg?react';
import RepeatDisabledIcon from '@/svg-icons/repeat_disabled.svg?react';
import RepeatPrivateIcon from '@/svg-icons/repeat_private.svg?react';
import RepeatPrivateActiveIcon from '@/svg-icons/repeat_private_active.svg?react';

import { IconButton } from '../icon_button';

import { messages } from './messages';
import { StatusMoreMenu } from './more-menu';

interface StatusBarProps {
  status: Status;
  withCounters?: boolean;
}

export const StatusBar: FC<StatusBarProps> = ({ withCounters, status }) => {
  const intl = useIntl();
  const reply = useMemo(() => {
    if (status.get('in_reply_to_id', null) === null) {
      return {
        icon: 'reply',
        iconComponent: ReplyIcon,
        title: intl.formatMessage(messages.reply),
      };
    }
    return {
      icon: 'reply-all',
      iconComponent: ReplyAllIcon,
      title: intl.formatMessage(messages.replyAll),
    };
  }, [intl, status]);
  const reblog = useMemo(() => {
    const publicStatus = ['public', 'unlisted'].includes(
      status.get('visibility') as StatusVisibility,
    );
    const reblogPrivate =
      status.getIn(['account', 'id']) === me &&
      status.get('visibility') === 'private';
    if (status.get('reblogged')) {
      return {
        title: intl.formatMessage(messages.cancel_reblog_private),
        iconComponent: publicStatus
          ? RepeatActiveIcon
          : RepeatPrivateActiveIcon,
      };
    } else if (publicStatus) {
      return {
        title: intl.formatMessage(messages.reblog),
        iconComponent: RepeatIcon,
      };
    } else if (reblogPrivate) {
      return {
        title: intl.formatMessage(messages.reblog_private),
        iconComponent: RepeatPrivateIcon,
      };
    }
    return {
      title: intl.formatMessage(messages.cannot_reblog),
      iconComponent: RepeatDisabledIcon,
    };
  }, [intl, status]);

  const reblogPrivate =
    status.getIn(['account', 'id']) === me &&
    status.get('visibility') === 'private';
  const bookmarkTitle = intl.formatMessage(
    status.get('bookmarked') ? messages.removeBookmark : messages.bookmark,
  );
  const favouriteTitle = intl.formatMessage(
    status.get('favourited') ? messages.removeFavourite : messages.favourite,
  );
  const isReply =
    status.get('in_reply_to_account_id') === status.getIn(['account', 'id']);
  const publicStatus = ['public', 'unlisted'].includes(
    status.get('visibility') as StatusVisibility,
  );

  const statusId = status.get('id') as string;
  const { signedIn } = useIdentity();

  const dispatch = useAppDispatch();
  const handleReplyClick = useCallback(() => {
    dispatch(statusReply({ statusId }));
  }, [dispatch, statusId]);
  const handleReblogClick: MouseEventHandler = useCallback(
    (event) => {
      dispatch(statusReblog({ event, statusId }));
    },
    [dispatch, statusId],
  );
  const handleFavouriteClick = useCallback(() => {
    dispatch(statusFavourite({ statusId }));
  }, [dispatch, statusId]);
  const handleBookmarkClick = useCallback(() => {
    dispatch(statusBookmark({ statusId }));
  }, [dispatch, statusId]);

  return (
    <div className='status__action-bar'>
      <div className='status__action-bar__button-wrapper'>
        <IconButton
          className='status__action-bar__button'
          title={reply.title}
          icon={isReply ? 'reply' : reply.icon}
          iconComponent={isReply ? ReplyIcon : reply.iconComponent}
          onClick={handleReplyClick}
          counter={status.get('replies_count') as number | undefined}
        />
      </div>
      <div className='status__action-bar__button-wrapper'>
        <IconButton
          className={classNames('status__action-bar__button', {
            reblogPrivate,
          })}
          disabled={!publicStatus && !reblogPrivate}
          active={!!status.get('reblogged')}
          title={reblog.title}
          icon='retweet'
          iconComponent={reblog.iconComponent}
          onClick={handleReblogClick}
          counter={
            withCounters ? (status.get('reblogs_count') as number) : undefined
          }
        />
      </div>
      <div className='status__action-bar__button-wrapper'>
        <IconButton
          className='status__action-bar__button star-icon'
          animate
          active={!!status.get('favourited')}
          title={favouriteTitle}
          icon='star'
          iconComponent={status.get('favourited') ? StarIcon : StarBorderIcon}
          onClick={handleFavouriteClick}
          counter={
            withCounters
              ? (status.get('favourites_count') as number)
              : undefined
          }
        />
      </div>
      <div className='status__action-bar__button-wrapper'>
        <IconButton
          className='status__action-bar__button bookmark-icon'
          disabled={!signedIn}
          active={!!status.get('bookmarked')}
          title={bookmarkTitle}
          icon='bookmark'
          iconComponent={
            status.get('bookmarked') ? BookmarkIcon : BookmarkBorderIcon
          }
          onClick={handleBookmarkClick}
        />
      </div>
      <div className='status__action-bar__button-wrapper'>
        <StatusMoreMenu status={status} />
      </div>
    </div>
  );
};

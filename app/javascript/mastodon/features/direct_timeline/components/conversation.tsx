import type React from 'react';
import { useCallback, useMemo } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { useHistory } from 'react-router-dom';

import { DotsThreeIcon } from '@phosphor-icons/react';

import { replyComposeById } from '@/mastodon/actions/compose_typed';
import {
  markConversationRead,
  deleteConversation,
} from '@/mastodon/actions/conversations';
import {
  muteStatus,
  unmuteStatus,
  toggleStatusSpoilers,
} from '@/mastodon/actions/statuses';
import { Avatars } from '@/mastodon/components/avatar';
import { IconButton } from '@/mastodon/components/button/redesign';
import { Hotkeys } from '@/mastodon/components/hotkeys';
import {
  LegacyDropdownMenuItems,
  Menu,
  MenuList,
  MenuTrigger,
} from '@/mastodon/components/menu';
import { StatusContent } from '@/mastodon/components/status/content';
import { StatusHeaderAuthors } from '@/mastodon/components/status/header';
import { StatusReplyIcon } from '@/mastodon/components/status/icons';
import { statusLink } from '@/mastodon/components/status/utils';
import { useAccountStatus } from '@/mastodon/hooks/useStatus';
import type { AccountShapeFull } from '@/mastodon/models/account';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';
import { filterNulls } from '@/mastodon/utils/types';

import classes from '../styles.module.scss';

import { ConversationAttachments } from './attachments';

const messages = defineMessages({
  open: { id: 'conversation.open', defaultMessage: 'View conversation' },
  markAsRead: {
    id: 'conversation.mark_as_read',
    defaultMessage: 'Mark as read',
  },
  delete: { id: 'conversation.delete', defaultMessage: 'Delete conversation' },
  muteConversation: {
    id: 'status.mute_conversation',
    defaultMessage: 'Mute conversation',
  },
  unmuteConversation: {
    id: 'status.unmute_conversation',
    defaultMessage: 'Unmute conversation',
  },
});

const selectAccounts = createAppSelector(
  [(state) => state.accounts, (_, accountIds: string[]) => accountIds],
  (accounts, accountIds) =>
    accountIds
      .map((id) => accounts.get(id)?.toJS())
      .filter(filterNulls) as unknown as AccountShapeFull[],
);

export interface TConversation {
  id: string;
  unread: boolean;
  accounts: string[];
  last_status: string | null;
}

export const Conversation: React.FC<{
  conversation: TConversation;
}> = ({ conversation }) => {
  const id = conversation.id;
  const unread = conversation.unread;
  const lastStatusId = conversation.last_status;
  const accountIds = conversation.accounts;
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const history = useHistory();
  const lastStatus = useAccountStatus(lastStatusId);
  const accounts = useAppSelector((state) => selectAccounts(state, accountIds));

  const handleClick = useCallback(() => {
    if (unread) {
      dispatch(markConversationRead(id));
    }

    if (lastStatus) {
      history.push(statusLink(lastStatus));
    }
  }, [dispatch, history, unread, id, lastStatus]);

  const handleReply = useCallback(() => {
    dispatch(replyComposeById({ statusId: lastStatus?.id }));
  }, [dispatch, lastStatus]);

  const handleShowMore = useCallback(() => {
    if (lastStatus) {
      dispatch(toggleStatusSpoilers(lastStatus.id));
    }
  }, [dispatch, lastStatus]);

  const handleConversationMute = useCallback(() => {
    if (lastStatus?.muted) {
      dispatch(unmuteStatus(lastStatus.id));
    } else {
      dispatch(muteStatus(lastStatus?.id));
    }
  }, [dispatch, lastStatus]);

  const handleDelete = useCallback(() => {
    dispatch(deleteConversation(id));
  }, [dispatch, id]);

  const handleMarkAsRead = useCallback(() => {
    dispatch(markConversationRead(id));
  }, [dispatch, id]);

  const menu = useMemo(() => {
    const menu = [
      { text: intl.formatMessage(messages.open), action: handleClick },
      null,
      {
        text: intl.formatMessage(
          lastStatus?.muted
            ? messages.unmuteConversation
            : messages.muteConversation,
        ),
        action: handleConversationMute,
      },
    ];

    if (unread) {
      menu.push({
        text: intl.formatMessage(messages.markAsRead),
        action: handleMarkAsRead,
      });
      menu.push(null);
    }

    menu.push({
      text: intl.formatMessage(messages.delete),
      action: handleDelete,
    });
    return menu;
  }, [
    handleClick,
    handleConversationMute,
    handleDelete,
    handleMarkAsRead,
    intl,
    lastStatus?.muted,
    unread,
  ]);

  if (!lastStatus) {
    return null;
  }

  const handlers = {
    reply: handleReply,
    open: handleClick,
    toggleHidden: handleShowMore,
  };

  return (
    <Hotkeys handlers={handlers}>
      <div
        className={classNames(
          'conversation focusable muted',
          { unread },
          classes.conversation,
        )}
        // eslint-disable-next-line jsx-a11y/no-noninteractive-tabindex
        tabIndex={0}
      >
        <div
          className='conversation__avatar'
          onClick={handleClick}
          role='presentation'
        >
          <Avatars
            accounts={accounts.slice(0, 3)}
            wrapperClassName={classNames(
              classes.avatars,
              accounts.length === 1 && classes.avatarsSingle,
            )}
            size={accounts.length === 1 ? 48 : 24}
          />
        </div>

        <div className='conversation__content'>
          <StatusHeaderAuthors status={lastStatus} className={classes.names} />

          <StatusContent
            status={lastStatus}
            onClick={handleClick}
            onReadMore={handleShowMore}
            collapsible
          />

          {lastStatus.media_attachments.length > 0 && (
            <ConversationAttachments media={lastStatus.media_attachments} />
          )}

          <div className='status__action-bar'>
            <IconButton icon={StatusReplyIcon} onClick={handleReply} size='sm'>
              <FormattedMessage id='status.reply' defaultMessage='Reply' />
            </IconButton>

            <div className='status__action-bar-dropdown'>
              <Menu>
                <MenuTrigger as={IconButton} icon={DotsThreeIcon} size='sm'>
                  <FormattedMessage id='status.more' defaultMessage='More' />
                </MenuTrigger>

                <MenuList placement='bottom-end'>
                  <LegacyDropdownMenuItems items={menu} />
                </MenuList>
              </Menu>
            </div>
          </div>
        </div>
      </div>
    </Hotkeys>
  );
};

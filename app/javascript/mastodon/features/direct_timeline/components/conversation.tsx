import type React from 'react';
import { useCallback, useMemo } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { useHistory } from 'react-router-dom';

import type { Map as ImmutableMap, Record as ImmutableRecord } from 'immutable';

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
import { LinkedDisplayName } from '@/mastodon/components/display_name';
import { AnimateEmojiProvider } from '@/mastodon/components/emoji/context';
import { Hotkeys } from '@/mastodon/components/hotkeys';
import {
  LegacyDropdownMenuItems,
  Menu,
  MenuList,
  MenuTrigger,
} from '@/mastodon/components/menu';
import { RelativeTimestamp } from '@/mastodon/components/relative_timestamp';
import { StatusContent } from '@/mastodon/components/status/content';
import { StatusReplyIcon } from '@/mastodon/components/status/icons';
import { statusLink } from '@/mastodon/components/status/utils';
import { useAccountStatus } from '@/mastodon/hooks/useStatus';
import type { Account, AccountShapeFull } from '@/mastodon/models/account';
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
  [
    (state) => state.accounts,
    (_, accountIds: Immutable.List<string>) => accountIds,
  ],
  (
    accounts: ImmutableMap<string, Account>,
    accountIds: Immutable.List<string>,
  ) =>
    accountIds
      .map((id) => accounts.get(id))
      .filter(filterNulls)
      .toJS() as unknown as AccountShapeFull[],
);

export interface TConversation {
  id: string;
  unread: boolean;
  accounts: Immutable.List<string>;
  last_status: string | null;
}

export const Conversation: React.FC<{
  conversation: ImmutableRecord<TConversation>;
}> = ({ conversation }) => {
  const id = conversation.get('id');
  const unread = conversation.get('unread');
  const lastStatusId = conversation.get('last_status');
  const accountIds = conversation.get('accounts');
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

  const names = useMemo(
    () =>
      intl.formatList(
        accounts.map((account) => (
          <LinkedDisplayName
            displayProps={{ account, variant: 'simple' }}
            key={account.id}
          />
        )),
      ),
    [accounts, intl],
  );

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
          <div className='conversation__content__info'>
            <div className='conversation__content__relative-time'>
              {unread && <span className='conversation__unread' />}{' '}
              <RelativeTimestamp timestamp={lastStatus.created_at} />
            </div>

            <AnimateEmojiProvider className='conversation__content__names'>
              <FormattedMessage
                id='conversation.with'
                defaultMessage='With {names}'
                values={{ names: <span>{names}</span> }}
              />
            </AnimateEmojiProvider>
          </div>

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

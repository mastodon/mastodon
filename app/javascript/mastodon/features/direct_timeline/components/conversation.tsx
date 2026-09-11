import { useCallback } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { useHistory } from 'react-router-dom';

import type {
  Map as ImmutableMap,
  List as ImmutableList,
  Record as ImmutableRecord,
} from 'immutable';

import { LinkedDisplayName } from '@/mastodon/components/display_name';
import { AnimateEmojiProvider } from '@/mastodon/components/emoji/context';
import type { Account } from '@/mastodon/models/account';
import type { StatusShape } from '@/mastodon/models/status';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';
import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import ReplyIcon from '@/material-icons/400-24px/reply.svg?react';
import { replyCompose } from 'mastodon/actions/compose';
import {
  markConversationRead,
  deleteConversation,
} from 'mastodon/actions/conversations';
import { openModal } from 'mastodon/actions/modal';
import {
  muteStatus,
  unmuteStatus,
  toggleStatusSpoilers,
} from 'mastodon/actions/statuses';
import AttachmentList from 'mastodon/components/attachment_list';
import AvatarComposite from 'mastodon/components/avatar_composite';
import { Dropdown } from 'mastodon/components/dropdown_menu';
import { Hotkeys } from 'mastodon/components/hotkeys';
import { IconButton } from 'mastodon/components/icon_button';
import { RelativeTimestamp } from 'mastodon/components/relative_timestamp';
import StatusContent from 'mastodon/components/status_content';
import { makeGetStatus } from 'mastodon/selectors';

const messages = defineMessages({
  more: { id: 'status.more', defaultMessage: 'More' },
  open: { id: 'conversation.open', defaultMessage: 'View conversation' },
  reply: { id: 'status.reply', defaultMessage: 'Reply' },
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

const getAccounts = createAppSelector(
  (state) => state.accounts,
  (_, accountIds: ImmutableList<string>) => accountIds,
  (
    accounts: ImmutableMap<string, Account>,
    accountIds: ImmutableList<string>,
  ) => accountIds.map((id) => accounts.get(id)),
);

const getStatus = makeGetStatus();

interface Conversation {
  id: string;
  unread: boolean;
  accounts: ImmutableList<string>;
  last_status: string | null;
}

export const Conversation: React.FC<{
  conversation: ImmutableRecord<Conversation>;
  scrollKey: string;
}> = ({ conversation, scrollKey }) => {
  const id = conversation.get('id');
  const unread = conversation.get('unread');
  const lastStatusId = conversation.get('last_status');
  const accountIds = conversation.get('accounts');
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const history = useHistory();
  const lastStatus = useAppSelector(
    (state) =>
      // @ts-expect-error getStatus isn't properly typed yet
      getStatus(state, { id: lastStatusId }) as
        | ImmutableRecord<StatusShape>
        | undefined,
  );
  const accounts = useAppSelector((state) => getAccounts(state, accountIds));

  const handleClick = useCallback(() => {
    if (unread) {
      dispatch(markConversationRead(id));
    }

    if (lastStatus) {
      history.push(
        `/@${lastStatus.getIn(['account', 'acct']) as string}/${lastStatus.get('id')}`,
      );
    }
  }, [dispatch, history, unread, id, lastStatus]);

  const handleMarkAsRead = useCallback(() => {
    dispatch(markConversationRead(id));
  }, [dispatch, id]);

  const handleReply = useCallback(() => {
    dispatch((_, getState) => {
      const state = getState();
      const composeText = state.compose.get('text');
      const text = typeof composeText === 'string' ? composeText.trim() : '';

      if (text.length !== 0) {
        dispatch(
          openModal({
            modalType: 'CONFIRM_REPLY',
            modalProps: { status: lastStatus },
          }),
        );
      } else {
        dispatch(replyCompose(lastStatus));
      }
    });
  }, [dispatch, lastStatus]);

  const handleDelete = useCallback(() => {
    dispatch(deleteConversation(id));
  }, [dispatch, id]);

  const handleConversationMute = useCallback(() => {
    if (!lastStatus) return;

    if (lastStatus.get('muted')) {
      dispatch(unmuteStatus(lastStatus.get('id')));
    } else {
      dispatch(muteStatus(lastStatus.get('id')));
    }
  }, [dispatch, lastStatus]);

  const handleShowMore = useCallback(() => {
    if (lastStatus) {
      dispatch(toggleStatusSpoilers(lastStatus.get('id')));
    }
  }, [dispatch, lastStatus]);

  if (!lastStatus) {
    return null;
  }

  const menu = [
    { text: intl.formatMessage(messages.open), action: handleClick },
    null,
    {
      text: intl.formatMessage(
        lastStatus.get('muted')
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

  const names: React.ReactNode = accounts
    .map((account) =>
      account ? (
        <LinkedDisplayName
          displayProps={{ account, variant: 'simple' }}
          key={account.get('id')}
        />
      ) : null,
    )
    .filter(Boolean)
    .reduce((prev, cur) => [prev, ', ', cur]);

  const handlers = {
    reply: handleReply,
    open: handleClick,
    toggleHidden: handleShowMore,
  };

  return (
    <Hotkeys handlers={handlers}>
      <div
        className={classNames('conversation focusable muted', { unread })}
        // eslint-disable-next-line jsx-a11y/no-noninteractive-tabindex
        tabIndex={0}
      >
        <div
          className='conversation__avatar'
          onClick={handleClick}
          role='presentation'
        >
          <AvatarComposite accounts={accounts} size={48} />
        </div>

        <div className='conversation__content'>
          <div className='conversation__content__info'>
            <div className='conversation__content__relative-time'>
              {unread && <span className='conversation__unread' />}{' '}
              <RelativeTimestamp timestamp={lastStatus.get('created_at')} />
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
            // @ts-expect-error StatusContent isn't typed yet
            status={lastStatus}
            onClick={handleClick}
            expanded={!lastStatus.get('hidden')}
            onExpandedToggle={handleShowMore}
            collapsible
          />

          {lastStatus
            // @ts-expect-error Status isn't properly typed yet
            .get('media_attachments').size > 0 && (
            <AttachmentList
              compact
              media={lastStatus.get('media_attachments')}
            />
          )}

          <div className='status__action-bar'>
            <IconButton
              className='status__action-bar-button'
              title={intl.formatMessage(messages.reply)}
              icon='reply'
              iconComponent={ReplyIcon}
              onClick={handleReply}
            />

            <div className='status__action-bar-dropdown'>
              <Dropdown
                scrollKey={scrollKey}
                // @ts-expect-error Dropdown status prop isn't properly typed
                status={lastStatus}
                items={menu}
                icon='ellipsis-h'
                iconComponent={MoreHorizIcon}
                size={18}
                direction='right'
                title={intl.formatMessage(messages.more)}
              />
            </div>
          </div>
        </div>
      </div>
    </Hotkeys>
  );
};

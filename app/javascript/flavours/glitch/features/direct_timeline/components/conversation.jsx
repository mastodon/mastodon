import PropTypes from 'prop-types';
import { useCallback, useState } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { useHistory } from 'react-router-dom';

import { createSelector } from '@reduxjs/toolkit';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { useDispatch, useSelector } from 'react-redux';


import { HotKeys } from 'react-hotkeys';

import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import ReplyIcon from '@/material-icons/400-24px/reply.svg?react';
import { replyCompose } from 'flavours/glitch/actions/compose';
import { markConversationRead, deleteConversation } from 'flavours/glitch/actions/conversations';
import { openModal } from 'flavours/glitch/actions/modal';
import { muteStatus, unmuteStatus, revealStatus, hideStatus } from 'flavours/glitch/actions/statuses';
import AttachmentList from 'flavours/glitch/components/attachment_list';
import AvatarComposite from 'flavours/glitch/components/avatar_composite';
import { IconButton } from 'flavours/glitch/components/icon_button';
import { Permalink } from 'flavours/glitch/components/permalink';
import { RelativeTimestamp } from 'flavours/glitch/components/relative_timestamp';
import StatusContent from 'flavours/glitch/components/status_content';
import DropdownMenuContainer from 'flavours/glitch/containers/dropdown_menu_container';
import { autoPlayGif } from 'flavours/glitch/initial_state';
import { makeGetStatus } from 'flavours/glitch/selectors';

const messages = defineMessages({
  more: { id: 'status.more', defaultMessage: 'More' },
  open: { id: 'conversation.open', defaultMessage: 'View conversation' },
  reply: { id: 'status.reply', defaultMessage: 'Reply' },
  markAsRead: { id: 'conversation.mark_as_read', defaultMessage: 'Mark as read' },
  delete: { id: 'conversation.delete', defaultMessage: 'Delete conversation' },
  muteConversation: { id: 'status.mute_conversation', defaultMessage: 'Mute conversation' },
  unmuteConversation: { id: 'status.unmute_conversation', defaultMessage: 'Unmute conversation' },
  replyConfirm: { id: 'confirmations.reply.confirm', defaultMessage: 'Reply' },
  replyMessage: { id: 'confirmations.reply.message', defaultMessage: 'Replying now will overwrite the message you are currently composing. Are you sure you want to proceed?' },
});

const getAccounts = createSelector(
  (state) => state.get('accounts'),
  (_, accountIds) => accountIds,
  (accounts, accountIds) =>
    accountIds.map(id => accounts.get(id))
);

const getStatus = makeGetStatus();

export const Conversation = ({ conversation, scrollKey, onMoveUp, onMoveDown }) => {
  const id = conversation.get('id');
  const unread = conversation.get('unread');
  const lastStatusId = conversation.get('last_status');
  const accountIds = conversation.get('accounts');
  const intl = useIntl();
  const dispatch = useDispatch();
  const history = useHistory();
  const lastStatus = useSelector(state => getStatus(state, { id: lastStatusId }));
  const accounts = useSelector(state => getAccounts(state, accountIds));

  // glitch-soc additions
  const sharedCWState = useSelector(state => state.getIn(['state', 'content_warnings', 'shared_state']));
  const [expanded, setExpanded] = useState(undefined);

  const parseClick = useCallback((e, destination) => {
    if (e.button === 0 && !(e.ctrlKey || e.altKey || e.metaKey)) {
      if (destination === undefined) {
        if (unread) {
          dispatch(markConversationRead(id));
        }
        destination = `/statuses/${lastStatus.get('id')}`;
      }
      history.push(destination);
      e.preventDefault();
    }
  }, [dispatch, history, unread, id, lastStatus]);

  const handleMouseEnter = useCallback(({ currentTarget }) => {
    if (autoPlayGif) {
      return;
    }

    const emojis = currentTarget.querySelectorAll('.custom-emoji');

    for (var i = 0; i < emojis.length; i++) {
      let emoji = emojis[i];
      emoji.src = emoji.getAttribute('data-original');
    }
  }, []);

  const handleMouseLeave = useCallback(({ currentTarget }) => {
    if (autoPlayGif) {
      return;
    }

    const emojis = currentTarget.querySelectorAll('.custom-emoji');

    for (var i = 0; i < emojis.length; i++) {
      let emoji = emojis[i];
      emoji.src = emoji.getAttribute('data-static');
    }
  }, []);

  const handleClick = useCallback(() => {
    if (unread) {
      dispatch(markConversationRead(id));
    }

    history.push(`/@${lastStatus.getIn(['account', 'acct'])}/${lastStatus.get('id')}`);
  }, [dispatch, history, unread, id, lastStatus]);

  const handleMarkAsRead = useCallback(() => {
    dispatch(markConversationRead(id));
  }, [dispatch, id]);

  const handleReply = useCallback(() => {
    dispatch((_, getState) => {
      let state = getState();

      if (state.getIn(['compose', 'text']).trim().length !== 0) {
        dispatch(openModal({
          modalType: 'CONFIRM',
          modalProps: {
            message: intl.formatMessage(messages.replyMessage),
            confirm: intl.formatMessage(messages.replyConfirm),
            onConfirm: () => dispatch(replyCompose(lastStatus, history)),
          },
        }));
      } else {
        dispatch(replyCompose(lastStatus, history));
      }
    });
  }, [dispatch, lastStatus, history, intl]);

  const handleDelete = useCallback(() => {
    dispatch(deleteConversation(id));
  }, [dispatch, id]);

  const handleHotkeyMoveUp = useCallback(() => {
    onMoveUp(id);
  }, [id, onMoveUp]);

  const handleHotkeyMoveDown = useCallback(() => {
    onMoveDown(id);
  }, [id, onMoveDown]);

  const handleConversationMute = useCallback(() => {
    if (lastStatus.get('muted')) {
      dispatch(unmuteStatus(lastStatus.get('id')));
    } else {
      dispatch(muteStatus(lastStatus.get('id')));
    }
  }, [dispatch, lastStatus]);

  const handleShowMore = useCallback(() => {
    if (lastStatus.get('hidden')) {
      dispatch(revealStatus(lastStatus.get('id')));
    } else {
      dispatch(hideStatus(lastStatus.get('id')));
    }

    if (lastStatus.get('spoiler_text')) {
      setExpanded(!expanded);
    }
  }, [dispatch, lastStatus, expanded]);

  if (!lastStatus) {
    return null;
  }

  const menu = [
    { text: intl.formatMessage(messages.open), action: handleClick },
    null,
    { text: intl.formatMessage(lastStatus.get('muted') ? messages.unmuteConversation : messages.muteConversation), action: handleConversationMute },
  ];

  if (unread) {
    menu.push({ text: intl.formatMessage(messages.markAsRead), action: handleMarkAsRead });
    menu.push(null);
  }

  menu.push({ text: intl.formatMessage(messages.delete), action: handleDelete });

  const names = accounts.map(a => (
    <Permalink to={`/@${a.get('acct')}`} href={a.get('url')} key={a.get('id')} title={a.get('acct')}>
      <bdi>
        <strong
          className='display-name__html'
          dangerouslySetInnerHTML={{ __html: a.get('display_name_html') }}
        />
      </bdi>
    </Permalink>
  )).reduce((prev, cur) => [prev, ', ', cur]);

  const handlers = {
    reply: handleReply,
    open: handleClick,
    moveUp: handleHotkeyMoveUp,
    moveDown: handleHotkeyMoveDown,
    toggleHidden: handleShowMore,
  };

  let media = null;
  if (lastStatus.get('media_attachments').size > 0) {
    media = <AttachmentList compact media={lastStatus.get('media_attachments')} />;
  }

  return (
    <HotKeys handlers={handlers}>
      <div className={classNames('conversation focusable muted', { 'conversation--unread': unread })} tabIndex={0}>
        <div className='conversation__avatar' onClick={handleClick} role='presentation'>
          <AvatarComposite accounts={accounts} size={48} />
        </div>

        <div className='conversation__content'>
          <div className='conversation__content__info'>
            <div className='conversation__content__relative-time'>
              {unread && <span className='conversation__unread' />} <RelativeTimestamp timestamp={lastStatus.get('created_at')} />
            </div>

            <div className='conversation__content__names' onMouseEnter={handleMouseEnter} onMouseLeave={handleMouseLeave}>
              <FormattedMessage id='conversation.with' defaultMessage='With {names}' values={{ names: <span>{names}</span> }} />
            </div>
          </div>

          <StatusContent
            status={lastStatus}
            parseClick={parseClick}
            expanded={sharedCWState ? lastStatus.get('hidden') : expanded}
            onExpandedToggle={handleShowMore}
            collapsible
            media={media}
          />

          <div className='status__action-bar'>
            <IconButton className='status__action-bar-button' title={intl.formatMessage(messages.reply)} icon='reply' iconComponent={ReplyIcon} onClick={handleReply} />

            <div className='status__action-bar-dropdown'>
              <DropdownMenuContainer
                scrollKey={scrollKey}
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
    </HotKeys>
  );
};

Conversation.propTypes = {
  conversation: ImmutablePropTypes.map.isRequired,
  scrollKey: PropTypes.string,
  onMoveUp: PropTypes.func,
  onMoveDown: PropTypes.func,
};

import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import StatusContent from 'flavours/glitch/components/status_content';
import AttachmentList from 'flavours/glitch/components/attachment_list';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import DropdownMenuContainer from 'flavours/glitch/containers/dropdown_menu_container';
import AvatarComposite from 'flavours/glitch/components/avatar_composite';
import Permalink from 'flavours/glitch/components/permalink';
import { IconButton } from 'flavours/glitch/components/icon_button';
import { RelativeTimestamp } from 'flavours/glitch/components/relative_timestamp';
import { HotKeys } from 'react-hotkeys';
import { autoPlayGif } from 'flavours/glitch/initial_state';
import classNames from 'classnames';

const messages = defineMessages({
  more: { id: 'status.more', defaultMessage: 'More' },
  open: { id: 'conversation.open', defaultMessage: 'View conversation' },
  reply: { id: 'status.reply', defaultMessage: 'Reply' },
  markAsRead: { id: 'conversation.mark_as_read', defaultMessage: 'Mark as read' },
  delete: { id: 'conversation.delete', defaultMessage: 'Delete conversation' },
  muteConversation: { id: 'status.mute_conversation', defaultMessage: 'Mute conversation' },
  unmuteConversation: { id: 'status.unmute_conversation', defaultMessage: 'Unmute conversation' },
});

class Conversation extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    conversationId: PropTypes.string.isRequired,
    accounts: ImmutablePropTypes.list.isRequired,
    lastStatus: ImmutablePropTypes.map,
    unread:PropTypes.bool.isRequired,
    scrollKey: PropTypes.string,
    onMoveUp: PropTypes.func,
    onMoveDown: PropTypes.func,
    markRead: PropTypes.func.isRequired,
    delete: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  state = {
    isExpanded: undefined,
  };

  parseClick = (e, destination) => {
    const { router } = this.context;
    const { lastStatus, unread, markRead } = this.props;
    if (!router) return;

    if (e.button === 0 && !(e.ctrlKey || e.altKey || e.metaKey)) {
      if (destination === undefined) {
        if (unread) {
          markRead();
        }
        destination = `/statuses/${lastStatus.get('id')}`;
      }
      let state = { ...router.history.location.state };
      state.mastodonBackSteps = (state.mastodonBackSteps || 0) + 1;
      router.history.push(destination, state);
      e.preventDefault();
    }
  };

  handleMouseEnter = ({ currentTarget }) => {
    if (autoPlayGif) {
      return;
    }

    const emojis = currentTarget.querySelectorAll('.custom-emoji');

    for (var i = 0; i < emojis.length; i++) {
      let emoji = emojis[i];
      emoji.src = emoji.getAttribute('data-original');
    }
  };

  handleMouseLeave = ({ currentTarget }) => {
    if (autoPlayGif) {
      return;
    }

    const emojis = currentTarget.querySelectorAll('.custom-emoji');

    for (var i = 0; i < emojis.length; i++) {
      let emoji = emojis[i];
      emoji.src = emoji.getAttribute('data-static');
    }
  };

  handleClick = () => {
    if (!this.context.router) {
      return;
    }

    const { lastStatus, unread, markRead } = this.props;

    if (unread) {
      markRead();
    }

    this.context.router.history.push(`/@${lastStatus.getIn(['account', 'acct'])}/${lastStatus.get('id')}`);
  };

  handleMarkAsRead = () => {
    this.props.markRead();
  };

  handleReply = () => {
    this.props.reply(this.props.lastStatus, this.context.router.history);
  };

  handleDelete = () => {
    this.props.delete();
  };

  handleHotkeyMoveUp = () => {
    this.props.onMoveUp(this.props.conversationId);
  };

  handleHotkeyMoveDown = () => {
    this.props.onMoveDown(this.props.conversationId);
  };

  handleConversationMute = () => {
    this.props.onMute(this.props.lastStatus);
  };

  handleShowMore = () => {
    this.props.onToggleHidden(this.props.lastStatus);

    if (this.props.lastStatus.get('spoiler_text')) {
      this.setExpansion(!this.state.isExpanded);
    }
  };

  setExpansion = value => {
    this.setState({ isExpanded: value });
  };

  render () {
    const { accounts, lastStatus, unread, scrollKey, intl } = this.props;

    if (lastStatus === null) {
      return null;
    }

    const isExpanded = this.props.settings.getIn(['content_warnings', 'shared_state']) ? !lastStatus.get('hidden') : this.state.isExpanded;

    const menu = [
      { text: intl.formatMessage(messages.open), action: this.handleClick },
      null,
    ];

    menu.push({ text: intl.formatMessage(lastStatus.get('muted') ? messages.unmuteConversation : messages.muteConversation), action: this.handleConversationMute });

    if (unread) {
      menu.push({ text: intl.formatMessage(messages.markAsRead), action: this.handleMarkAsRead });
      menu.push(null);
    }

    menu.push({ text: intl.formatMessage(messages.delete), action: this.handleDelete });

    const names = accounts.map(a => <Permalink to={`/@${a.get('acct')}`} href={a.get('url')} key={a.get('id')} title={a.get('acct')}><bdi><strong className='display-name__html' dangerouslySetInnerHTML={{ __html: a.get('display_name_html') }} /></bdi></Permalink>).reduce((prev, cur) => [prev, ', ', cur]);

    const handlers = {
      reply: this.handleReply,
      open: this.handleClick,
      moveUp: this.handleHotkeyMoveUp,
      moveDown: this.handleHotkeyMoveDown,
      toggleHidden: this.handleShowMore,
    };

    let media = null;
    if (lastStatus.get('media_attachments').size > 0) {
      media = <AttachmentList compact media={lastStatus.get('media_attachments')} />;
    }

    return (
      <HotKeys handlers={handlers}>
        <div className={classNames('conversation focusable muted', { 'conversation--unread': unread })} tabIndex={0}>
          <div className='conversation__avatar' onClick={this.handleClick} role='presentation'>
            <AvatarComposite accounts={accounts} size={48} />
          </div>

          <div className='conversation__content'>
            <div className='conversation__content__info'>
              <div className='conversation__content__relative-time'>
                {unread && <span className='conversation__unread' />} <RelativeTimestamp timestamp={lastStatus.get('created_at')} />
              </div>

              <div className='conversation__content__names' onMouseEnter={this.handleMouseEnter} onMouseLeave={this.handleMouseLeave}>
                <FormattedMessage id='conversation.with' defaultMessage='With {names}' values={{ names: <span>{names}</span> }} />
              </div>
            </div>

            <StatusContent
              status={lastStatus}
              parseClick={this.parseClick}
              expanded={isExpanded}
              onExpandedToggle={this.handleShowMore}
              collapsible
              media={media}
            />

            <div className='status__action-bar'>
              <IconButton className='status__action-bar-button' title={intl.formatMessage(messages.reply)} icon='reply' onClick={this.handleReply} />

              <div className='status__action-bar-dropdown'>
                <DropdownMenuContainer
                  scrollKey={scrollKey}
                  status={lastStatus}
                  items={menu}
                  icon='ellipsis-h'
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
  }

}

export default injectIntl(Conversation);

import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import StatusContent from '../../../components/status_content';
import RelativeTimestamp from '../../../components/relative_timestamp';
import DisplayName from '../../../components/display_name';
import Avatar from '../../../components/avatar';
import AttachmentList from '../../../components/attachment_list';
import { HotKeys } from 'react-hotkeys';
import classNames from 'classnames';

export default class Conversation extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    conversationId: PropTypes.string.isRequired,
    accounts: ImmutablePropTypes.list.isRequired,
    lastStatus: ImmutablePropTypes.map.isRequired,
    unread:PropTypes.bool.isRequired,
    onMoveUp: PropTypes.func,
    onMoveDown: PropTypes.func,
    markRead: PropTypes.func.isRequired,
  };

  handleClick = () => {
    if (!this.context.router) {
      return;
    }

    const { lastStatus, unread, markRead } = this.props;

    if (unread) {
      markRead();
    }

    this.context.router.history.push(`/statuses/${lastStatus.get('id')}`);
  }

  handleHotkeyMoveUp = () => {
    this.props.onMoveUp(this.props.conversationId);
  }

  handleHotkeyMoveDown = () => {
    this.props.onMoveDown(this.props.conversationId);
  }

  render () {
    const { accounts, lastStatus, lastAccount, unread } = this.props;

    if (lastStatus === null) {
      return null;
    }

    const handlers = {
      moveDown: this.handleHotkeyMoveDown,
      moveUp: this.handleHotkeyMoveUp,
      open: this.handleClick,
    };

    let media;

    if (lastStatus.get('media_attachments').size > 0) {
      media = <AttachmentList compact media={lastStatus.get('media_attachments')} />;
    }

    return (
      <HotKeys handlers={handlers}>
        <div className={classNames('conversation', 'focusable', { 'conversation--unread': unread })} tabIndex='0' onClick={this.handleClick} role='button'>
          <div className='conversation__header'>
            <div className='conversation__avatars'>
              <div>{accounts.map(account => <Avatar key={account.get('id')} size={36} account={account} />)}</div>
            </div>

            <div className='conversation__time'>
              <RelativeTimestamp timestamp={lastStatus.get('created_at')} />
              <br />
              <DisplayName account={lastAccount} withAcct={false} />
            </div>
          </div>

          <StatusContent status={lastStatus} onClick={this.handleClick} />

          {media}
        </div>
      </HotKeys>
    );
  }

}

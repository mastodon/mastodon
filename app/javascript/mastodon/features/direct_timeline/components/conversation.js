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

export default class Conversation extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    conversationId: PropTypes.string.isRequired,
    accounts: ImmutablePropTypes.list.isRequired,
    lastStatus: ImmutablePropTypes.map.isRequired,
    onMoveUp: PropTypes.func,
    onMoveDown: PropTypes.func,
  };

  handleClick = () => {
    if (!this.context.router) {
      return;
    }

    const { lastStatus } = this.props;
    this.context.router.history.push(`/statuses/${lastStatus.get('id')}`);
  }

  handleHotkeyMoveUp = () => {
    this.props.onMoveUp(this.props.conversationId);
  }

  handleHotkeyMoveDown = () => {
    this.props.onMoveDown(this.props.conversationId);
  }

  render () {
    const { accounts, lastStatus, lastAccount } = this.props;

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
        <div className='conversation focusable' tabIndex='0' onClick={this.handleClick} role='button'>
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

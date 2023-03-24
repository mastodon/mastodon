import React, { Fragment } from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Avatar from 'flavours/glitch/components/avatar';
import DisplayName from 'flavours/glitch/components/display_name';
import Permalink from 'flavours/glitch/components/permalink';
import IconButton from 'flavours/glitch/components/icon_button';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import NotificationOverlayContainer from '../containers/overlay_container';
import { HotKeys } from 'react-hotkeys';
import Icon from 'flavours/glitch/components/icon';
import classNames from 'classnames';

const messages = defineMessages({
  authorize: { id: 'follow_request.authorize', defaultMessage: 'Authorize' },
  reject: { id: 'follow_request.reject', defaultMessage: 'Reject' },
});

class FollowRequest extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    onAuthorize: PropTypes.func.isRequired,
    onReject: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    notification: ImmutablePropTypes.map.isRequired,
    unread: PropTypes.bool,
  };

  handleMoveUp = () => {
    const { notification, onMoveUp } = this.props;
    onMoveUp(notification.get('id'));
  };

  handleMoveDown = () => {
    const { notification, onMoveDown } = this.props;
    onMoveDown(notification.get('id'));
  };

  handleOpen = () => {
    this.handleOpenProfile();
  };

  handleOpenProfile = () => {
    const { notification } = this.props;
    this.context.router.history.push(`/@${notification.getIn(['account', 'acct'])}`);
  };

  handleMention = e => {
    e.preventDefault();

    const { notification, onMention } = this.props;
    onMention(notification.get('account'), this.context.router.history);
  };

  getHandlers () {
    return {
      moveUp: this.handleMoveUp,
      moveDown: this.handleMoveDown,
      open: this.handleOpen,
      openProfile: this.handleOpenProfile,
      mention: this.handleMention,
      reply: this.handleMention,
    };
  }

  render () {
    const { intl, hidden, account, onAuthorize, onReject, notification, unread } = this.props;

    if (!account) {
      return <div />;
    }

    if (hidden) {
      return (
        <Fragment>
          {account.get('display_name')}
          {account.get('username')}
        </Fragment>
      );
    }

    //  Links to the display name.
    const displayName = account.get('display_name_html') || account.get('username');
    const link = (
      <bdi><Permalink
        className='notification__display-name'
        href={account.get('url')}
        title={account.get('acct')}
        to={`/@${account.get('acct')}`}
        dangerouslySetInnerHTML={{ __html: displayName }}
      /></bdi>
    );

    return (
      <HotKeys handlers={this.getHandlers()}>
        <div className={classNames('notification notification-follow-request focusable', { unread })} tabIndex='0'>
          <div className='notification__message'>
            <div className='notification__favourite-icon-wrapper'>
              <Icon id='user' fixedWidth />
            </div>

            <FormattedMessage
              id='notification.follow_request'
              defaultMessage='{name} has requested to follow you'
              values={{ name: link }}
            />
          </div>

          <div className='account'>
            <div className='account__wrapper'>
              <Permalink key={account.get('id')} className='account__display-name' title={account.get('acct')} href={account.get('url')} to={`/@${account.get('acct')}`}>
                <div className='account__avatar-wrapper'><Avatar account={account} size={36} /></div>
                <DisplayName account={account} />
              </Permalink>

              <div className='account__relationship'>
                <IconButton title={intl.formatMessage(messages.authorize)} icon='check' onClick={onAuthorize} />
                <IconButton title={intl.formatMessage(messages.reject)} icon='times' onClick={onReject} />
              </div>
            </div>
          </div>

          <NotificationOverlayContainer notification={notification} />
        </div>
      </HotKeys>
    );
  }

}

export default injectIntl(FollowRequest);

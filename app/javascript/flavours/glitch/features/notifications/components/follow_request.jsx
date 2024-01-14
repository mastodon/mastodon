import PropTypes from 'prop-types';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { withRouter } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { ReactComponent as CheckIcon } from '@material-symbols/svg-600/outlined/check.svg';
import { ReactComponent as CloseIcon } from '@material-symbols/svg-600/outlined/close.svg';
import { ReactComponent as PersonIcon } from '@material-symbols/svg-600/outlined/person-fill.svg';
import { HotKeys } from 'react-hotkeys';

import { Avatar } from 'flavours/glitch/components/avatar';
import { DisplayName } from 'flavours/glitch/components/display_name';
import { Icon } from 'flavours/glitch/components/icon';
import { IconButton } from 'flavours/glitch/components/icon_button';
import Permalink from 'flavours/glitch/components/permalink';
import { WithRouterPropTypes } from 'flavours/glitch/utils/react_router';

import NotificationOverlayContainer from '../containers/overlay_container';

const messages = defineMessages({
  authorize: { id: 'follow_request.authorize', defaultMessage: 'Authorize' },
  reject: { id: 'follow_request.reject', defaultMessage: 'Reject' },
});

class FollowRequest extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.record.isRequired,
    onAuthorize: PropTypes.func.isRequired,
    onReject: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    notification: ImmutablePropTypes.map.isRequired,
    unread: PropTypes.bool,
    ...WithRouterPropTypes,
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
    const { history, notification } = this.props;
    history.push(`/@${notification.getIn(['account', 'acct'])}`);
  };

  handleMention = e => {
    e.preventDefault();

    const { history, notification, onMention } = this.props;
    onMention(notification.get('account'), history);
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
        <>
          {account.get('display_name')}
          {account.get('username')}
        </>
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
        <div className={classNames('notification notification-follow-request focusable', { unread })} tabIndex={0}>
          <div className='notification__message'>
            <div className='notification__favourite-icon-wrapper'>
              <Icon id='user' icon={PersonIcon} />
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
                <IconButton title={intl.formatMessage(messages.authorize)} icon='check' iconComponent={CheckIcon} onClick={onAuthorize} />
                <IconButton title={intl.formatMessage(messages.reject)} icon='times' iconComponent={CloseIcon} onClick={onReject} />
              </div>
            </div>
          </div>

          <NotificationOverlayContainer notification={notification} />
        </div>
      </HotKeys>
    );
  }

}

export default withRouter(injectIntl(FollowRequest));

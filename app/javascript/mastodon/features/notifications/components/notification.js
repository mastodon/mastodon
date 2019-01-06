import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import StatusContainer from '../../../containers/status_container';
import AccountContainer from '../../../containers/account_container';
import { injectIntl, FormattedMessage } from 'react-intl';
import Permalink from '../../../components/permalink';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { HotKeys } from 'react-hotkeys';

const notificationForScreenReader = (intl, message, timestamp) => {
  const output = [message];

  output.push(intl.formatDate(timestamp, { hour: '2-digit', minute: '2-digit', month: 'short', day: 'numeric' }));

  return output.join(', ');
};

export default @injectIntl
class Notification extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    notification: ImmutablePropTypes.map.isRequired,
    hidden: PropTypes.bool,
    onMoveUp: PropTypes.func.isRequired,
    onMoveDown: PropTypes.func.isRequired,
    onMention: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleMoveUp = () => {
    const { notification, onMoveUp } = this.props;
    onMoveUp(notification.get('id'));
  }

  handleMoveDown = () => {
    const { notification, onMoveDown } = this.props;
    onMoveDown(notification.get('id'));
  }

  handleOpen = () => {
    const { notification } = this.props;

    if (notification.get('status')) {
      this.context.router.history.push(`/statuses/${notification.get('status')}`);
    } else {
      this.handleOpenProfile();
    }
  }

  handleOpenProfile = () => {
    const { notification } = this.props;
    this.context.router.history.push(`/accounts/${notification.getIn(['account', 'id'])}`);
  }

  handleMention = e => {
    e.preventDefault();

    const { notification, onMention } = this.props;
    onMention(notification.get('account'), this.context.router.history);
  }

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

  renderFollow (notification, account, link) {
    const { intl } = this.props;

    return (
      <HotKeys handlers={this.getHandlers()}>
        <div className='notification notification-follow focusable' tabIndex='0' aria-label={notificationForScreenReader(intl, intl.formatMessage({ id: 'notification.follow', defaultMessage: '{name} followed you' }, { name: account.get('acct') }), notification.get('created_at'))}>
          <div className='notification__message'>
            <div className='notification__favourite-icon-wrapper'>
              <i className='fa fa-fw fa-user-plus' />
            </div>

            <span title={notification.get('created_at')}>
              <FormattedMessage id='notification.follow' defaultMessage='{name} followed you' values={{ name: link }} />
            </span>
          </div>

          <AccountContainer id={account.get('id')} withNote={false} hidden={this.props.hidden} />
        </div>
      </HotKeys>
    );
  }

  renderMention (notification) {
    return (
      <StatusContainer
        id={notification.get('status')}
        withDismiss
        hidden={this.props.hidden}
        onMoveDown={this.handleMoveDown}
        onMoveUp={this.handleMoveUp}
        contextType='notifications'
      />
    );
  }

  renderFavourite (notification, link) {
    const { intl } = this.props;

    return (
      <HotKeys handlers={this.getHandlers()}>
        <div className='notification notification-favourite focusable' tabIndex='0' aria-label={notificationForScreenReader(intl, intl.formatMessage({ id: 'notification.favourite', defaultMessage: '{name} favourited your status' }, { name: notification.getIn(['account', 'acct']) }), notification.get('created_at'))}>
          <div className='notification__message'>
            <div className='notification__favourite-icon-wrapper'>
              <i className='fa fa-fw fa-star star-icon' />
            </div>

            <span title={notification.get('created_at')}>
              <FormattedMessage id='notification.favourite' defaultMessage='{name} favourited your status' values={{ name: link }} />
            </span>
          </div>

          <StatusContainer id={notification.get('status')} account={notification.get('account')} muted withDismiss hidden={!!this.props.hidden} />
        </div>
      </HotKeys>
    );
  }

  renderReblog (notification, link) {
    const { intl } = this.props;

    return (
      <HotKeys handlers={this.getHandlers()}>
        <div className='notification notification-reblog focusable' tabIndex='0' aria-label={notificationForScreenReader(intl, intl.formatMessage({ id: 'notification.reblog', defaultMessage: '{name} boosted your status' }, { name: notification.getIn(['account', 'acct']) }), notification.get('created_at'))}>
          <div className='notification__message'>
            <div className='notification__favourite-icon-wrapper'>
              <i className='fa fa-fw fa-retweet' />
            </div>

            <span title={notification.get('created_at')}>
              <FormattedMessage id='notification.reblog' defaultMessage='{name} boosted your status' values={{ name: link }} />
            </span>
          </div>

          <StatusContainer id={notification.get('status')} account={notification.get('account')} muted withDismiss hidden={this.props.hidden} />
        </div>
      </HotKeys>
    );
  }

  render () {
    const { notification } = this.props;
    const account          = notification.get('account');
    const displayNameHtml  = { __html: account.get('display_name_html') };
    const link             = <bdi><Permalink className='notification__display-name' href={account.get('url')} title={account.get('acct')} to={`/accounts/${account.get('id')}`} dangerouslySetInnerHTML={displayNameHtml} /></bdi>;

    switch(notification.get('type')) {
    case 'follow':
      return this.renderFollow(notification, account, link);
    case 'mention':
      return this.renderMention(notification);
    case 'favourite':
      return this.renderFavourite(notification, link);
    case 'reblog':
      return this.renderReblog(notification, link);
    }

    return null;
  }

}

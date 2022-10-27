//  Package imports.
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { FormattedMessage, defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { HotKeys } from 'react-hotkeys';
import classNames from 'classnames';

// Our imports.
import Permalink from 'flavours/glitch/components/permalink';
import AccountContainer from 'flavours/glitch/containers/account_container';
import NotificationOverlayContainer from '../containers/overlay_container';
import Icon from 'flavours/glitch/components/icon';
import Report from './report';

const messages = defineMessages({
  adminReport: { id: 'notification.admin.report', defaultMessage: '{name} reported {target}' },
});

export default class AdminReport extends ImmutablePureComponent {

  static propTypes = {
    hidden: PropTypes.bool,
    id: PropTypes.string.isRequired,
    account: ImmutablePropTypes.map.isRequired,
    notification: ImmutablePropTypes.map.isRequired,
    unread: PropTypes.bool,
    report: ImmutablePropTypes.map.isRequired,
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
    this.handleOpenProfile();
  }

  handleOpenProfile = () => {
    const { notification } = this.props;
    this.context.router.history.push(`/@${notification.getIn(['account', 'acct'])}`);
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

  render () {
    const { intl, account, notification, unread, report } = this.props;

    if (!report) {
      return null;
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

    const targetAccount = report.get('target_account');
    const targetDisplayNameHtml = { __html: targetAccount.get('display_name_html') };
    const targetLink = <bdi><Permalink className='notification__display-name' href={targetAccount.get('url')} title={targetAccount.get('acct')} to={`/@${targetAccount.get('acct')}`} dangerouslySetInnerHTML={targetDisplayNameHtml} /></bdi>;

    return (
      <HotKeys handlers={this.getHandlers()}>
        <div className={classNames('notification notification-admin-report focusable', { unread })} tabIndex='0'>
          <div className='notification__message'>
            <div className='notification__favourite-icon-wrapper'>
              <Icon id='flag' fixedWidth />
            </div>

            <span title={notification.get('created_at')}>
              <FormattedMessage id='notification.admin.report' defaultMessage='{name} reported {target}' values={{ name: link, target: targetLink }} />
            </span>
          </div>

          <Report account={account} report={notification.get('report')} hidden={this.props.hidden} />
          <NotificationOverlayContainer notification={notification} />
        </div>
      </HotKeys>
    );
  }

}

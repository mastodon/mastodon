import PropTypes from 'prop-types';

import { injectIntl, FormattedMessage, defineMessages } from 'react-intl';

import classNames from 'classnames';
import { Link, withRouter } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { HotKeys } from 'react-hotkeys';

import EditIcon from '@/material-icons/400-24px/edit.svg?react';
import FlagIcon from '@/material-icons/400-24px/flag-fill.svg?react';
import HomeIcon from '@/material-icons/400-24px/home-fill.svg?react';
import InsertChartIcon from '@/material-icons/400-24px/insert_chart.svg?react';
import PersonIcon from '@/material-icons/400-24px/person-fill.svg?react';
import PersonAddIcon from '@/material-icons/400-24px/person_add-fill.svg?react';
import RepeatIcon from '@/material-icons/400-24px/repeat.svg?react';
import StarIcon from '@/material-icons/400-24px/star-fill.svg?react';
import { Icon }  from 'mastodon/components/icon';
import AccountContainer from 'mastodon/containers/account_container';
import StatusContainer from 'mastodon/containers/status_container';
import { me } from 'mastodon/initial_state';
import { WithRouterPropTypes } from 'mastodon/utils/react_router';

import FollowRequestContainer from '../containers/follow_request_container';

import { ModerationWarning } from './moderation_warning';
import { RelationshipsSeveranceEvent } from './relationships_severance_event';
import Report from './report';

const messages = defineMessages({
  favourite: { id: 'notification.favourite', defaultMessage: '{name} favorited your post' },
  follow: { id: 'notification.follow', defaultMessage: '{name} followed you' },
  ownPoll: { id: 'notification.own_poll', defaultMessage: 'Your poll has ended' },
  poll: { id: 'notification.poll', defaultMessage: 'A poll you voted in has ended' },
  reblog: { id: 'notification.reblog', defaultMessage: '{name} boosted your post' },
  status: { id: 'notification.status', defaultMessage: '{name} just posted' },
  update: { id: 'notification.update', defaultMessage: '{name} edited a post' },
  adminSignUp: { id: 'notification.admin.sign_up', defaultMessage: '{name} signed up' },
  adminReport: { id: 'notification.admin.report', defaultMessage: '{name} reported {target}' },
  relationshipsSevered: { id: 'notification.relationships_severance_event', defaultMessage: 'Lost connections with {name}' },
  moderationWarning: { id: 'notification.moderation_warning', defaultMessage: 'You have received a moderation warning' },
});

const notificationForScreenReader = (intl, message, timestamp) => {
  const output = [message];

  output.push(intl.formatDate(timestamp, { hour: '2-digit', minute: '2-digit', month: 'short', day: 'numeric' }));

  return output.join(', ');
};

class Notification extends ImmutablePureComponent {
  static propTypes = {
    notification: ImmutablePropTypes.map.isRequired,
    hidden: PropTypes.bool,
    onMoveUp: PropTypes.func.isRequired,
    onMoveDown: PropTypes.func.isRequired,
    onMention: PropTypes.func.isRequired,
    onFavourite: PropTypes.func.isRequired,
    onReblog: PropTypes.func.isRequired,
    onToggleHidden: PropTypes.func.isRequired,
    status: ImmutablePropTypes.map,
    intl: PropTypes.object.isRequired,
    getScrollPosition: PropTypes.func,
    updateScrollBottom: PropTypes.func,
    cacheMediaWidth: PropTypes.func,
    cachedMediaWidth: PropTypes.number,
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
    const { notification } = this.props;

    if (notification.get('status')) {
      this.props.history.push(`/@${notification.getIn(['status', 'account', 'acct'])}/${notification.get('status')}`);
    } else {
      this.handleOpenProfile();
    }
  };

  handleOpenProfile = () => {
    const { notification } = this.props;
    this.props.history.push(`/@${notification.getIn(['account', 'acct'])}`);
  };

  handleMention = e => {
    e.preventDefault();

    const { notification, onMention } = this.props;
    onMention(notification.get('account'));
  };

  handleHotkeyFavourite = () => {
    const { status } = this.props;
    if (status) this.props.onFavourite(status);
  };

  handleHotkeyBoost = e => {
    const { status } = this.props;
    if (status) this.props.onReblog(status, e);
  };

  handleHotkeyToggleHidden = () => {
    const { status } = this.props;
    if (status) this.props.onToggleHidden(status);
  };

  getHandlers () {
    return {
      reply: this.handleMention,
      favourite: this.handleHotkeyFavourite,
      boost: this.handleHotkeyBoost,
      mention: this.handleMention,
      open: this.handleOpen,
      openProfile: this.handleOpenProfile,
      moveUp: this.handleMoveUp,
      moveDown: this.handleMoveDown,
      toggleHidden: this.handleHotkeyToggleHidden,
    };
  }

  renderFollow (notification, account, link) {
    const { intl, unread } = this.props;

    return (
      <HotKeys handlers={this.getHandlers()}>
        <div className={classNames('notification notification-follow focusable', { unread })} tabIndex={0} aria-label={notificationForScreenReader(intl, intl.formatMessage(messages.follow, { name: account.get('acct') }), notification.get('created_at'))}>
          <div className='notification__message'>
            <Icon id='user-plus' icon={PersonAddIcon} />

            <span title={notification.get('created_at')}>
              <FormattedMessage id='notification.follow' defaultMessage='{name} followed you' values={{ name: link }} />
            </span>
          </div>

          <AccountContainer id={account.get('id')} hidden={this.props.hidden} />
        </div>
      </HotKeys>
    );
  }

  renderFollowRequest (notification, account, link) {
    const { intl, unread } = this.props;

    return (
      <HotKeys handlers={this.getHandlers()}>
        <div className={classNames('notification notification-follow-request focusable', { unread })} tabIndex={0} aria-label={notificationForScreenReader(intl, intl.formatMessage({ id: 'notification.follow_request', defaultMessage: '{name} has requested to follow you' }, { name: account.get('acct') }), notification.get('created_at'))}>
          <div className='notification__message'>
            <Icon id='user' icon={PersonIcon} />

            <span title={notification.get('created_at')}>
              <FormattedMessage id='notification.follow_request' defaultMessage='{name} has requested to follow you' values={{ name: link }} />
            </span>
          </div>

          <FollowRequestContainer id={account.get('id')} withNote={false} hidden={this.props.hidden} />
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
        getScrollPosition={this.props.getScrollPosition}
        updateScrollBottom={this.props.updateScrollBottom}
        cachedMediaWidth={this.props.cachedMediaWidth}
        cacheMediaWidth={this.props.cacheMediaWidth}
        unread={this.props.unread}
      />
    );
  }

  renderFavourite (notification, link) {
    const { intl, unread } = this.props;

    return (
      <HotKeys handlers={this.getHandlers()}>
        <div className={classNames('notification notification-favourite focusable', { unread })} tabIndex={0} aria-label={notificationForScreenReader(intl, intl.formatMessage(messages.favourite, { name: notification.getIn(['account', 'acct']) }), notification.get('created_at'))}>
          <div className='notification__message'>
            <Icon id='star' icon={StarIcon} className='star-icon' />

            <span title={notification.get('created_at')}>
              <FormattedMessage id='notification.favourite' defaultMessage='{name} favorited your post' values={{ name: link }} />
            </span>
          </div>

          <StatusContainer
            id={notification.get('status')}
            account={notification.get('account')}
            muted
            withDismiss
            hidden={!!this.props.hidden}
            getScrollPosition={this.props.getScrollPosition}
            updateScrollBottom={this.props.updateScrollBottom}
            cachedMediaWidth={this.props.cachedMediaWidth}
            cacheMediaWidth={this.props.cacheMediaWidth}
          />
        </div>
      </HotKeys>
    );
  }

  renderReblog (notification, link) {
    const { intl, unread } = this.props;

    return (
      <HotKeys handlers={this.getHandlers()}>
        <div className={classNames('notification notification-reblog focusable', { unread })} tabIndex={0} aria-label={notificationForScreenReader(intl, intl.formatMessage(messages.reblog, { name: notification.getIn(['account', 'acct']) }), notification.get('created_at'))}>
          <div className='notification__message'>
            <Icon id='retweet' icon={RepeatIcon} />

            <span title={notification.get('created_at')}>
              <FormattedMessage id='notification.reblog' defaultMessage='{name} boosted your post' values={{ name: link }} />
            </span>
          </div>

          <StatusContainer
            id={notification.get('status')}
            account={notification.get('account')}
            muted
            withDismiss
            hidden={this.props.hidden}
            getScrollPosition={this.props.getScrollPosition}
            updateScrollBottom={this.props.updateScrollBottom}
            cachedMediaWidth={this.props.cachedMediaWidth}
            cacheMediaWidth={this.props.cacheMediaWidth}
          />
        </div>
      </HotKeys>
    );
  }

  renderStatus (notification, link) {
    const { intl, unread, status } = this.props;

    if (!status) {
      return null;
    }

    return (
      <HotKeys handlers={this.getHandlers()}>
        <div className={classNames('notification notification-status focusable', { unread })} tabIndex={0} aria-label={notificationForScreenReader(intl, intl.formatMessage(messages.status, { name: notification.getIn(['account', 'acct']) }), notification.get('created_at'))}>
          <div className='notification__message'>
            <Icon id='home' icon={HomeIcon} />

            <span title={notification.get('created_at')}>
              <FormattedMessage id='notification.status' defaultMessage='{name} just posted' values={{ name: link }} />
            </span>
          </div>

          <StatusContainer
            id={notification.get('status')}
            account={notification.get('account')}
            contextType='notifications'
            muted
            withDismiss
            hidden={this.props.hidden}
            getScrollPosition={this.props.getScrollPosition}
            updateScrollBottom={this.props.updateScrollBottom}
            cachedMediaWidth={this.props.cachedMediaWidth}
            cacheMediaWidth={this.props.cacheMediaWidth}
          />
        </div>
      </HotKeys>
    );
  }

  renderUpdate (notification, link) {
    const { intl, unread, status } = this.props;

    if (!status) {
      return null;
    }

    return (
      <HotKeys handlers={this.getHandlers()}>
        <div className={classNames('notification notification-update focusable', { unread })} tabIndex={0} aria-label={notificationForScreenReader(intl, intl.formatMessage(messages.update, { name: notification.getIn(['account', 'acct']) }), notification.get('created_at'))}>
          <div className='notification__message'>
            <Icon id='pencil' icon={EditIcon} />

            <span title={notification.get('created_at')}>
              <FormattedMessage id='notification.update' defaultMessage='{name} edited a post' values={{ name: link }} />
            </span>
          </div>

          <StatusContainer
            id={notification.get('status')}
            account={notification.get('account')}
            contextType='notifications'
            muted
            withDismiss
            hidden={this.props.hidden}
            getScrollPosition={this.props.getScrollPosition}
            updateScrollBottom={this.props.updateScrollBottom}
            cachedMediaWidth={this.props.cachedMediaWidth}
            cacheMediaWidth={this.props.cacheMediaWidth}
          />
        </div>
      </HotKeys>
    );
  }

  renderPoll (notification, account) {
    const { intl, unread, status } = this.props;
    const ownPoll  = me === account.get('id');
    const message  = ownPoll ? intl.formatMessage(messages.ownPoll) : intl.formatMessage(messages.poll);

    if (!status) {
      return null;
    }

    return (
      <HotKeys handlers={this.getHandlers()}>
        <div className={classNames('notification notification-poll focusable', { unread })} tabIndex={0} aria-label={notificationForScreenReader(intl, message, notification.get('created_at'))}>
          <div className='notification__message'>
            <Icon id='tasks' icon={InsertChartIcon} />

            <span title={notification.get('created_at')}>
              {ownPoll ? (
                <FormattedMessage id='notification.own_poll' defaultMessage='Your poll has ended' />
              ) : (
                <FormattedMessage id='notification.poll' defaultMessage='A poll you voted in has ended' />
              )}
            </span>
          </div>

          <StatusContainer
            id={notification.get('status')}
            account={account}
            contextType='notifications'
            muted
            withDismiss
            hidden={this.props.hidden}
            getScrollPosition={this.props.getScrollPosition}
            updateScrollBottom={this.props.updateScrollBottom}
            cachedMediaWidth={this.props.cachedMediaWidth}
            cacheMediaWidth={this.props.cacheMediaWidth}
          />
        </div>
      </HotKeys>
    );
  }

  renderRelationshipsSevered (notification) {
    const { intl, unread, hidden } = this.props;
    const event = notification.get('event');

    if (!event) {
      return null;
    }

    return (
      <HotKeys handlers={this.getHandlers()}>
        <div className={classNames('notification notification-severed-relationships focusable', { unread })} tabIndex={0} aria-label={notificationForScreenReader(intl, intl.formatMessage(messages.relationshipsSevered, { name: notification.getIn(['event', 'target_name']) }), notification.get('created_at'))}>
          <RelationshipsSeveranceEvent
            type={event.get('type')}
            target={event.get('target_name')}
            followersCount={event.get('followers_count')}
            followingCount={event.get('following_count')}
            hidden={hidden}
          />
        </div>
      </HotKeys>
    );
  }

  renderModerationWarning (notification) {
    const { intl, unread, hidden } = this.props;
    const warning = notification.get('moderation_warning');

    if (!warning) {
      return null;
    }

    return (
      <HotKeys handlers={this.getHandlers()}>
        <div className={classNames('notification notification-moderation-warning focusable', { unread })} tabIndex={0} aria-label={notificationForScreenReader(intl, intl.formatMessage(messages.moderationWarning), notification.get('created_at'))}>
          <ModerationWarning
            action={warning.get('action')}
            id={warning.get('id')}
            hidden={hidden}
          />
        </div>
      </HotKeys>
    );
  }

  renderAdminSignUp (notification, account, link) {
    const { intl, unread } = this.props;

    return (
      <HotKeys handlers={this.getHandlers()}>
        <div className={classNames('notification notification-admin-sign-up focusable', { unread })} tabIndex={0} aria-label={notificationForScreenReader(intl, intl.formatMessage(messages.adminSignUp, { name: account.get('acct') }), notification.get('created_at'))}>
          <div className='notification__message'>
            <Icon id='user-plus' icon={PersonAddIcon} />

            <span title={notification.get('created_at')}>
              <FormattedMessage id='notification.admin.sign_up' defaultMessage='{name} signed up' values={{ name: link }} />
            </span>
          </div>

          <AccountContainer id={account.get('id')} hidden={this.props.hidden} />
        </div>
      </HotKeys>
    );
  }

  renderAdminReport (notification, account, link) {
    const { intl, unread, report } = this.props;

    if (!report) {
      return null;
    }

    const targetAccount = report.get('target_account');
    const targetDisplayNameHtml = { __html: targetAccount.get('display_name_html') };
    const targetLink = <bdi><Link className='notification__display-name' title={targetAccount.get('acct')} data-hover-card-account={targetAccount.get('id')} to={`/@${targetAccount.get('acct')}`} dangerouslySetInnerHTML={targetDisplayNameHtml} /></bdi>;

    return (
      <HotKeys handlers={this.getHandlers()}>
        <div className={classNames('notification notification-admin-report focusable', { unread })} tabIndex={0} aria-label={notificationForScreenReader(intl, intl.formatMessage(messages.adminReport, { name: account.get('acct'), target: notification.getIn(['report', 'target_account', 'acct']) }), notification.get('created_at'))}>
          <div className='notification__message'>
            <Icon id='flag' icon={FlagIcon} />

            <span title={notification.get('created_at')}>
              <FormattedMessage id='notification.admin.report' defaultMessage='{name} reported {target}' values={{ name: link, target: targetLink }} />
            </span>
          </div>

          <Report account={account} report={notification.get('report')} hidden={this.props.hidden} />
        </div>
      </HotKeys>
    );
  }

  render () {
    const { notification } = this.props;
    const account          = notification.get('account');
    const displayNameHtml  = { __html: account.get('display_name_html') };
    const link             = <bdi><Link className='notification__display-name' href={`/@${account.get('acct')}`} title={account.get('acct')} data-hover-card-account={account.get('id')} to={`/@${account.get('acct')}`} dangerouslySetInnerHTML={displayNameHtml} /></bdi>;

    switch(notification.get('type')) {
    case 'follow':
      return this.renderFollow(notification, account, link);
    case 'follow_request':
      return this.renderFollowRequest(notification, account, link);
    case 'mention':
      return this.renderMention(notification);
    case 'favourite':
      return this.renderFavourite(notification, link);
    case 'reblog':
      return this.renderReblog(notification, link);
    case 'status':
      return this.renderStatus(notification, link);
    case 'update':
      return this.renderUpdate(notification, link);
    case 'poll':
      return this.renderPoll(notification, account);
    case 'severed_relationships':
      return this.renderRelationshipsSevered(notification);
    case 'moderation_warning':
      return this.renderModerationWarning(notification);
    case 'admin.sign_up':
      return this.renderAdminSignUp(notification, account, link);
    case 'admin.report':
      return this.renderAdminReport(notification, account, link);
    }

    return null;
  }

}

export default withRouter(injectIntl(Notification));

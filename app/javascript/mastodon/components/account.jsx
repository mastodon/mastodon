import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Avatar from './avatar';
import DisplayName from './display_name';
import IconButton from './icon_button';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { me } from '../initial_state';
import RelativeTimestamp from './relative_timestamp';
import Skeleton from 'mastodon/components/skeleton';
import { Link } from 'react-router-dom';
import { counterRenderer } from 'mastodon/components/common_counter';
import ShortNumber from 'mastodon/components/short_number';
import classNames from 'classnames';
import VerifiedBadge from 'mastodon/components/verified_badge';

const messages = defineMessages({
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  requested: { id: 'account.requested', defaultMessage: 'Awaiting approval' },
  unblock: { id: 'account.unblock', defaultMessage: 'Unblock @{name}' },
  unmute: { id: 'account.unmute', defaultMessage: 'Unmute @{name}' },
  mute_notifications: { id: 'account.mute_notifications', defaultMessage: 'Mute notifications from @{name}' },
  unmute_notifications: { id: 'account.unmute_notifications', defaultMessage: 'Unmute notifications from @{name}' },
  mute: { id: 'account.mute', defaultMessage: 'Mute @{name}' },
  block: { id: 'account.block', defaultMessage: 'Block @{name}' },
});

class Account extends ImmutablePureComponent {

  static propTypes = {
    size: PropTypes.number,
    account: ImmutablePropTypes.map,
    onFollow: PropTypes.func.isRequired,
    onBlock: PropTypes.func.isRequired,
    onMute: PropTypes.func.isRequired,
    onMuteNotifications: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    hidden: PropTypes.bool,
    minimal: PropTypes.bool,
    actionIcon: PropTypes.string,
    actionTitle: PropTypes.string,
    defaultAction: PropTypes.string,
    onActionClick: PropTypes.func,
  };

  static defaultProps = {
    size: 46,
  };

  handleFollow = () => {
    this.props.onFollow(this.props.account);
  };

  handleBlock = () => {
    this.props.onBlock(this.props.account);
  };

  handleMute = () => {
    this.props.onMute(this.props.account);
  };

  handleMuteNotifications = () => {
    this.props.onMuteNotifications(this.props.account, true);
  };

  handleUnmuteNotifications = () => {
    this.props.onMuteNotifications(this.props.account, false);
  };

  handleAction = () => {
    this.props.onActionClick(this.props.account);
  };

  render () {
    const { account, intl, hidden, onActionClick, actionIcon, actionTitle, defaultAction, size, minimal } = this.props;

    if (!account) {
      return (
        <div className={classNames('account', { 'account--minimal': minimal })}>
          <div className='account__wrapper'>
            <div className='account__display-name'>
              <div className='account__avatar-wrapper'><Skeleton width={size} height={size} /></div>

              <div>
                <DisplayName />
                <Skeleton width='7ch' />
              </div>
            </div>
          </div>
        </div>
      );
    }

    if (hidden) {
      return (
        <>
          {account.get('display_name')}
          {account.get('username')}
        </>
      );
    }

    let buttons;

    if (actionIcon) {
      if (onActionClick) {
        buttons = <IconButton icon={actionIcon} title={actionTitle} onClick={this.handleAction} />;
      }
    } else if (account.get('id') !== me && account.get('relationship', null) !== null) {
      const following = account.getIn(['relationship', 'following']);
      const requested = account.getIn(['relationship', 'requested']);
      const blocking  = account.getIn(['relationship', 'blocking']);
      const muting  = account.getIn(['relationship', 'muting']);

      if (requested) {
        buttons = <IconButton disabled icon='hourglass' title={intl.formatMessage(messages.requested)} />;
      } else if (blocking) {
        buttons = <IconButton active icon='unlock' title={intl.formatMessage(messages.unblock, { name: account.get('username') })} onClick={this.handleBlock} />;
      } else if (muting) {
        let hidingNotificationsButton;
        if (account.getIn(['relationship', 'muting_notifications'])) {
          hidingNotificationsButton = <IconButton active icon='bell' title={intl.formatMessage(messages.unmute_notifications, { name: account.get('username') })} onClick={this.handleUnmuteNotifications} />;
        } else {
          hidingNotificationsButton = <IconButton active icon='bell-slash' title={intl.formatMessage(messages.mute_notifications, { name: account.get('username')  })} onClick={this.handleMuteNotifications} />;
        }
        buttons = (
          <>
            <IconButton active icon='volume-up' title={intl.formatMessage(messages.unmute, { name: account.get('username') })} onClick={this.handleMute} />
            {hidingNotificationsButton}
          </>
        );
      } else if (defaultAction === 'mute') {
        buttons = <IconButton icon='volume-off' title={intl.formatMessage(messages.mute, { name: account.get('username') })} onClick={this.handleMute} />;
      } else if (defaultAction === 'block') {
        buttons = <IconButton icon='lock' title={intl.formatMessage(messages.block, { name: account.get('username') })} onClick={this.handleBlock} />;
      } else if (!account.get('moved') || following) {
        buttons = <IconButton icon={following ? 'user-times' : 'user-plus'} title={intl.formatMessage(following ? messages.unfollow : messages.follow)} onClick={this.handleFollow} active={following} />;
      }
    }

    let muteTimeRemaining;

    if (account.get('mute_expires_at')) {
      muteTimeRemaining = <>· <RelativeTimestamp timestamp={account.get('mute_expires_at')} futureDate /></>;
    }

    let verification;

    const firstVerifiedField = account.get('fields').find(item => !!item.get('verified_at'));

    if (firstVerifiedField) {
      verification = <>· <VerifiedBadge link={firstVerifiedField.get('value')} verifiedAt={firstVerifiedField.get('verified_at')} /></>;
    }

    return (
      <div className={classNames('account', { 'account--minimal': minimal })}>
        <div className='account__wrapper'>
          <Link key={account.get('id')} className='account__display-name' title={account.get('acct')} to={`/@${account.get('acct')}`}>
            <div className='account__avatar-wrapper'>
              <Avatar account={account} size={size} />
            </div>

            <div>
              <DisplayName account={account} />
              {!minimal && <><ShortNumber value={account.get('followers_count')} renderer={counterRenderer('followers')} /> {verification} {muteTimeRemaining}</>}
            </div>
          </Link>

          {!minimal && (
            <div className='account__relationship'>
              {buttons}
            </div>
          )}
        </div>
      </div>
    );
  }

}

export default injectIntl(Account);

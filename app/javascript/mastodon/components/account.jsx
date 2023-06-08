import PropTypes from 'prop-types';

import { defineMessages, injectIntl } from 'react-intl';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { counterRenderer } from 'mastodon/components/common_counter';
import { EmptyAccount } from 'mastodon/components/empty_account';
import ShortNumber from 'mastodon/components/short_number';
import { VerifiedBadge } from 'mastodon/components/verified_badge';

import { me } from '../initial_state';

import { Avatar } from './avatar';
import Button from './button';
import { DisplayName } from './display_name';
import { IconButton } from './icon_button';
import { RelativeTimestamp } from './relative_timestamp';

const messages = defineMessages({
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  cancel_follow_request: { id: 'account.cancel_follow_request', defaultMessage: 'Withdraw follow request' },
  unblock: { id: 'account.unblock_short', defaultMessage: 'Unblock' },
  unmute: { id: 'account.unmute_short', defaultMessage: 'Unmute' },
  mute_notifications: { id: 'account.mute_notifications_short', defaultMessage: 'Mute notifications' },
  unmute_notifications: { id: 'account.unmute_notifications_short', defaultMessage: 'Unmute notifications' },
  mute: { id: 'account.mute_short', defaultMessage: 'Mute' },
  block: { id: 'account.block_short', defaultMessage: 'Block' },
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
      return <EmptyAccount size={size} minimal={minimal} />;
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

    if (actionIcon && onActionClick) {
      buttons = <IconButton icon={actionIcon} title={actionTitle} onClick={this.handleAction} />;
    } else if (!actionIcon && account.get('id') !== me && account.get('relationship', null) !== null) {
      const following = account.getIn(['relationship', 'following']);
      const requested = account.getIn(['relationship', 'requested']);
      const blocking  = account.getIn(['relationship', 'blocking']);
      const muting  = account.getIn(['relationship', 'muting']);

      if (requested) {
        buttons = <Button text={intl.formatMessage(messages.cancel_follow_request)} onClick={this.handleFollow} />;
      } else if (blocking) {
        buttons = <Button text={intl.formatMessage(messages.unblock)} onClick={this.handleBlock} />;
      } else if (muting) {
        let hidingNotificationsButton;

        if (account.getIn(['relationship', 'muting_notifications'])) {
          hidingNotificationsButton = <Button text={intl.formatMessage(messages.unmute_notifications)} onClick={this.handleUnmuteNotifications} />;
        } else {
          hidingNotificationsButton = <Button text={intl.formatMessage(messages.mute_notifications)} onClick={this.handleMuteNotifications} />;
        }

        buttons = (
          <>
            <Button text={intl.formatMessage(messages.unmute)} onClick={this.handleMute} />
            {hidingNotificationsButton}
          </>
        );
      } else if (defaultAction === 'mute') {
        buttons = <Button title={intl.formatMessage(messages.mute)} onClick={this.handleMute} />;
      } else if (defaultAction === 'block') {
        buttons = <Button text={intl.formatMessage(messages.block)} onClick={this.handleBlock} />;
      } else if (!account.get('moved') || following) {
        buttons = <Button text={intl.formatMessage(following ? messages.unfollow : messages.follow)} onClick={this.handleFollow} />;
      }
    }

    let muteTimeRemaining;

    if (account.get('mute_expires_at')) {
      muteTimeRemaining = <>· <RelativeTimestamp timestamp={account.get('mute_expires_at')} futureDate /></>;
    }

    let verification;

    const firstVerifiedField = account.get('fields').find(item => !!item.get('verified_at'));

    if (firstVerifiedField) {
      verification = <VerifiedBadge link={firstVerifiedField.get('value')} />;
    }

    return (
      <div className={classNames('account', { 'account--minimal': minimal })}>
        <div className='account__wrapper'>
          <Link key={account.get('id')} className='account__display-name' title={account.get('acct')} to={`/@${account.get('acct')}`}>
            <div className='account__avatar-wrapper'>
              <Avatar account={account} size={size} />
            </div>

            <div className='account__contents'>
              <DisplayName account={account} />
              {!minimal && (
                <div className='account__details'>
                  <ShortNumber value={account.get('followers_count')} renderer={counterRenderer('followers')} /> {verification} {muteTimeRemaining}
                </div>
              )}
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

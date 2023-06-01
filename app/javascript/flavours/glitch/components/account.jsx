import PropTypes from 'prop-types';

import { defineMessages, injectIntl } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { Skeleton } from 'flavours/glitch/components/skeleton';
import { me } from 'flavours/glitch/initial_state';

import { Avatar } from './avatar';
import { DisplayName } from './display_name';
import { IconButton } from './icon_button';
import Permalink from './permalink';
import { RelativeTimestamp } from './relative_timestamp';


const messages = defineMessages({
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  requested: { id: 'account.requested', defaultMessage: 'Awaiting approval. Click to cancel follow request' },
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
    small: PropTypes.bool,
    actionIcon: PropTypes.string,
    actionTitle: PropTypes.string,
    defaultAction: PropTypes.string,
    onActionClick: PropTypes.func,
  };

  static defaultProps = {
    size: 36,
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
    const {
      account,
      hidden,
      intl,
      small,
      onActionClick,
      actionIcon,
      actionTitle,
      defaultAction,
      size,
    } = this.props;

    if (!account) {
      return (
        <div className='account'>
          <div className='account__wrapper'>
            <div className='account__display-name'>
              <div className='account__avatar-wrapper'><Skeleton width={36} height={36} /></div>
              <DisplayName />
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

    if (onActionClick) {
      if (actionIcon) {
        buttons = <IconButton icon={actionIcon} title={actionTitle} onClick={this.handleAction} />;
      }
    } else if (account.get('id') !== me && !small && account.get('relationship', null) !== null) {
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

    let mute_expires_at;
    if (account.get('mute_expires_at')) {
      mute_expires_at =  <div><RelativeTimestamp timestamp={account.get('mute_expires_at')} futureDate /></div>;
    }

    return small ? (
      <Permalink
        className='account small'
        href={account.get('url')}
        to={`/@${account.get('acct')}`}
      >
        <div className='account__avatar-wrapper'>
          <Avatar
            account={account}
            size={24}
          />
        </div>
        <DisplayName
          account={account}
          inline
        />
      </Permalink>
    ) : (
      <div className='account'>
        <div className='account__wrapper'>
          <Permalink key={account.get('id')} className='account__display-name' title={account.get('acct')} href={account.get('url')} to={`/@${account.get('acct')}`}>
            <div className='account__avatar-wrapper'><Avatar account={account} size={size} /></div>
            {mute_expires_at}
            <DisplayName account={account} />
          </Permalink>
          {buttons ?
            <div className='account__relationship'>
              {buttons}
            </div>
            : null}
        </div>
      </div>
    );
  }

}

export default injectIntl(Account);

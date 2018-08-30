import React, { Fragment } from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { injectIntl, defineMessages, FormattedMessage } from 'react-intl';

import IconButton from './icon_button';

import {
  blockAccount,
  unblockAccount,
  muteAccount,
  unmuteAccount,
  followAccount,
  unfollowAccount,
} from '../actions/accounts';
import { openModal } from '../actions/modal';
import { initMuteModal } from '../actions/mutes';
import { unfollowModal } from '../initial_state';

import { me } from '../initial_state';

const messages = defineMessages({
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  requested: { id: 'account.requested', defaultMessage: 'Awaiting approval' },
  unblock: { id: 'account.unblock', defaultMessage: 'Unblock @{name}' },
  unmute: { id: 'account.unmute', defaultMessage: 'Unmute @{name}' },
  mute_notifications: { id: 'account.mute_notifications', defaultMessage: 'Mute notifications from @{name}' },
  unmute_notifications: { id: 'account.unmute_notifications', defaultMessage: 'Unmute notifications from @{name}' },
  unfollowConfirm: { id: 'confirmations.unfollow.confirm', defaultMessage: 'Unfollow' },
});

@connect()
@injectIntl
export default class OldCascadingControls extends ImmutablePureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    account: ImmutablePropTypes.map.isRequired,
  };

  handleBlocking = () => {
    const { dispatch, account } = this.props;

    if (account.getIn(['relationship', 'blocking'])) {
      dispatch(unblockAccount(account.get('id')));
    } else {
      dispatch(blockAccount(account.get('id')));
    }
  }

  handleFollowing = () => {
    const { dispatch, intl, account } = this.props;

    if (account.getIn(['relationship', 'following']) || account.getIn(['relationship', 'requested'])) {
      if (unfollowModal) {
        dispatch(openModal('CONFIRM', {
          message: <FormattedMessage id='confirmations.unfollow.message' defaultMessage='Are you sure you want to unfollow {name}?' values={{ name: <strong>@{account.get('acct')}</strong> }} />,
          confirm: intl.formatMessage(messages.unfollowConfirm),
          onConfirm: () => dispatch(unfollowAccount(account.get('id'))),
        }));
      } else {
        dispatch(unfollowAccount(account.get('id')));
      }
    } else {
      dispatch(followAccount(account.get('id')));
    }
  }

  handleMuting = () => {
    const { dispatch, account } = this.props;

    if (account.getIn(['relationship', 'muting'])) {
      dispatch(unmuteAccount(account.get('id')));
    } else {
      dispatch(initMuteModal(account));
    }
  }

  handleMuteNotifications = () => {
    this.props.dispatch(muteAccount(this.props.account.get('id'), true));
  }

  handleUnmuteNotifications = () => {
    this.props.dispatch(muteAccount(this.props.account.get('id'), false));
  }

  render () {
    const { intl, account } = this.props;

    if (account.get('id') === me || account.get('relationship', null) === null)
      return null;

    const following = account.getIn(['relationship', 'following']);
    const requested = account.getIn(['relationship', 'requested']);
    const blocking  = account.getIn(['relationship', 'blocking']);
    const muting  = account.getIn(['relationship', 'muting']);

    if (requested) {
      return <IconButton disabled icon='hourglass' title={intl.formatMessage(messages.requested)} />;
    } else if (blocking) {
      return <IconButton active icon='unlock-alt' title={intl.formatMessage(messages.unblock, { name: account.get('username') })} onClick={this.handleBlocking} />;
    } else if (muting) {
      let hidingNotificationsButton;
      if (account.getIn(['relationship', 'muting_notifications'])) {
        hidingNotificationsButton = <IconButton active icon='bell' title={intl.formatMessage(messages.unmute_notifications, { name: account.get('username') })} onClick={this.handleUnmuteNotifications} />;
      } else {
        hidingNotificationsButton = <IconButton active icon='bell-slash' title={intl.formatMessage(messages.mute_notifications, { name: account.get('username')  })} onClick={this.handleMuteNotifications} />;
      }
      return (
        <Fragment>
          <IconButton active icon='volume-up' title={intl.formatMessage(messages.unmute, { name: account.get('username') })} onClick={this.handleMuting} />
          {hidingNotificationsButton}
        </Fragment>
      );
    } else if (!account.get('moved') || following) {
      return <IconButton icon={following ? 'user-times' : 'user-plus'} title={intl.formatMessage(following ? messages.unfollow : messages.follow)} onClick={this.handleFollowing} active={following} />;
    }

    return null;
  }

}

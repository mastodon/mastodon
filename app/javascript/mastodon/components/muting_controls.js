import React, { Fragment } from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { injectIntl, defineMessages } from 'react-intl';
import { muteAccount, unmuteAccount } from '../actions/accounts';
import { initMuteModal } from '../actions/mutes';
import IconButton from './icon_button';

const messages = defineMessages({
  mute: { id: 'account.mute', defaultMessage: 'Mute @{name}' },
  unmute: { id: 'account.unmute', defaultMessage: 'Unmute @{name}' },
  mute_notifications: { id: 'account.mute_notifications', defaultMessage: 'Mute notifications from @{name}' },
  unmute_notifications: { id: 'account.unmute_notifications', defaultMessage: 'Unmute notifications from @{name}' },
});

@connect()
@injectIntl
export default class MutingControls extends ImmutablePureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    account: ImmutablePropTypes.map.isRequired,
  };

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

    const muting = account.getIn(['relationship', 'muting']);
    const notifications = muting && account.getIn(['relationship', 'muting_notifications']);

    const mutingProps = {
      icon: muting ? 'volume-up' : 'volume-off',
      title: intl.formatMessage(muting ? messages.unmute : messages.mute, { name: account.get('username') }),
      onClick: this.handleMuting,
    };

    const notificationProps = muting && {
      icon: notifications ? 'bell' : 'bell-slash',
      title: intl.formatMessage(notifications ? messages.unmute_notifications : messages.mute_notifications, { name: account.get('username') }),
      onClick: notifications? this.handleUnmuteNotifications : this.handleMuteNotifications,
    };

    return (
      <Fragment>
        <IconButton
          active
          icon={mutingProps.icon}
          title={mutingProps.title}
          onClick={mutingProps.onClick}
        />
        {muting && (
          <IconButton
            active
            icon={notificationProps.icon}
            title={notificationProps.title}
            onClick={notificationProps.onClick}
          />
        )}
      </Fragment>
    );
  }

}

//  Package imports  //
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import PropTypes from 'prop-types';

//  Mastodon imports  //

//  Our imports  //
import StatusContainer from '../status/container';
import NotificationFollow from './follow';

export default class Notification extends ImmutablePureComponent {

  static propTypes = {
    notification: ImmutablePropTypes.map.isRequired,
    settings: ImmutablePropTypes.map.isRequired,
    onDeleteNotification: PropTypes.func.isRequired,
  };

  renderFollow (notification) {
    return (
      <NotificationFollow
        id={notification.get('id')}
        account={notification.get('account')}
        onDeleteNotification={this.props.onDeleteNotification}
      />
    );
  }

  renderMention (notification) {
    return (
      <StatusContainer
        id={notification.get('status')}
        notificationId={notification.get('id')}
        withDismiss
      />
    );
  }

  renderFavourite (notification) {
    return (
      <StatusContainer
        id={notification.get('status')}
        account={notification.get('account')}
        prepend='favourite'
        muted
        notificationId={notification.get('id')}
        withDismiss
      />
    );
  }

  renderReblog (notification) {
    return (
      <StatusContainer
        id={notification.get('status')}
        account={notification.get('account')}
        prepend='reblog'
        muted
        notificationId={notification.get('id')}
        withDismiss
      />
    );
  }

  render () {
    const { notification } = this.props;

    switch(notification.get('type')) {
    case 'follow':
      return this.renderFollow(notification);
    case 'mention':
      return this.renderMention(notification);
    case 'favourite':
      return this.renderFavourite(notification);
    case 'reblog':
      return this.renderReblog(notification);
    }

    return null;
  }

}

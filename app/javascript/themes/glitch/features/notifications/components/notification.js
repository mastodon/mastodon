//  Package imports.
import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

//  Our imports,
import StatusContainer from 'themes/glitch/containers/status_container';
import NotificationFollow from './follow';

export default class Notification extends ImmutablePureComponent {

  static propTypes = {
    notification: ImmutablePropTypes.map.isRequired,
    hidden: PropTypes.bool,
    onMoveUp: PropTypes.func.isRequired,
    onMoveDown: PropTypes.func.isRequired,
    onMention: PropTypes.func.isRequired,
    settings: ImmutablePropTypes.map.isRequired,
  };

  renderFollow () {
    const { notification } = this.props;
    return (
      <NotificationFollow
        id={notification.get('id')}
        account={notification.get('account')}
        notification={notification}
      />
    );
  }

  renderMention () {
    const { notification } = this.props;
    return (
      <StatusContainer
        id={notification.get('status')}
        notification={notification}
        withDismiss
      />
    );
  }

  renderFavourite () {
    const { notification } = this.props;
    return (
      <StatusContainer
        id={notification.get('status')}
        account={notification.get('account')}
        prepend='favourite'
        muted
        notification={notification}
        withDismiss
      />
    );
  }

  renderReblog () {
    const { notification } = this.props;
    return (
      <StatusContainer
        id={notification.get('status')}
        account={notification.get('account')}
        prepend='reblog'
        muted
        notification={notification}
        withDismiss
      />
    );
  }

  render () {
    const { notification } = this.props;
    switch(notification.get('type')) {
    case 'follow':
      return this.renderFollow();
    case 'mention':
      return this.renderMention();
    case 'favourite':
      return this.renderFavourite();
    case 'reblog':
      return this.renderReblog();
    default:
      return null;
    }
  }

}

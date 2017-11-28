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
  };

  render () {
    const {
      hidden,
      notification,
      onMoveDown,
      onMoveUp,
      onMention,
    } = this.props;

    switch(notification.get('type')) {
    case 'follow':
      return (
        <NotificationFollow
          hidden={hidden}
          id={notification.get('id')}
          account={notification.get('account')}
          notification={notification}
          onMoveDown={onMoveDown}
          onMoveUp={onMoveUp}
          onMention={onMention}
        />
      );
    case 'mention':
      return (
        <StatusContainer
          containerId={notification.get('id')}
          hidden={hidden}
          id={notification.get('status')}
          notification={notification}
          onMoveDown={onMoveDown}
          onMoveUp={onMoveUp}
          onMention={onMention}
          withDismiss
        />
      );
    case 'favourite':
      return (
        <StatusContainer
          containerId={notification.get('id')}
          hidden={hidden}
          id={notification.get('status')}
          account={notification.get('account')}
          prepend='favourite'
          muted
          notification={notification}
          onMoveDown={onMoveDown}
          onMoveUp={onMoveUp}
          onMention={onMention}
          withDismiss
        />
      );
    case 'reblog':
      return (
        <StatusContainer
          containerId={notification.get('id')}
          hidden={hidden}
          id={notification.get('status')}
          account={notification.get('account')}
          prepend='reblog'
          muted
          notification={notification}
          onMoveDown={onMoveDown}
          onMoveUp={onMoveUp}
          onMention={onMention}
          withDismiss
        />
      );
    default:
      return null;
    }
  }

}

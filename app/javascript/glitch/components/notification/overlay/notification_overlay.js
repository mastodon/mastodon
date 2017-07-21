/**
 * Notification overlay
 */


//  Package imports  //
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { defineMessages, injectIntl } from 'react-intl';

//  Mastodon imports  //

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

const messages = defineMessages({
  markForDeletion: { id: 'notification.markForDeletion', defaultMessage: 'Mark for deletion' },
});

@injectIntl
export default class NotificationOverlay extends ImmutablePureComponent {

  static propTypes = {
    notification    : ImmutablePropTypes.map.isRequired,
    onMarkForDelete : PropTypes.func.isRequired,
    revealed        : PropTypes.bool.isRequired,
    intl            : PropTypes.object.isRequired,
  };

  onToggleMark = () => {
    const mark = !this.props.notification.get('markedForDelete');
    const id = this.props.notification.get('id');
    this.props.onMarkForDelete(id, mark);
  }

  render () {
    const { notification, revealed, intl } = this.props;

    const active = notification.get('markedForDelete');
    const label = intl.formatMessage(messages.markForDeletion);

    return (
      <div
        aria-label={label}
        role='checkbox'
        aria-checked={active}
        tabIndex={0}
        className={`notification__dismiss-overlay ${active ? 'active' : ''} ${revealed ? 'show' : ''}`}
        onClick={this.onToggleMark}
      >
        <div className='notification__dismiss-overlay__ckbox' aria-hidden='true' title={label}>
          {active ? (<i className='fa fa-check' />) : ''}
        </div>
      </div>
    );
  }

}

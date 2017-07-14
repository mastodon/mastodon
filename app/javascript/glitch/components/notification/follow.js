/*

`<NotificationFollow>`
======================

This component renders a follow notification.

__Props:__

 -  __`id` (`PropTypes.number.isRequired`) :__
    This is the id of the notification.

 -  __`onDeleteNotification` (`PropTypes.func.isRequired`) :__
    The function to call when a notification should be
    dismissed/deleted.

 -  __`account` (`PropTypes.object.isRequired`) :__
    The account associated with the follow notification, ie the account
    which followed the user.

 -  __`intl` (`PropTypes.object.isRequired`) :__
    Our internationalization object, inserted by `@injectIntl`.

*/

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Imports:
--------

*/

//  Package imports  //
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { defineMessages, FormattedMessage, injectIntl } from 'react-intl';
import escapeTextContentForBrowser from 'escape-html';
import ImmutablePureComponent from 'react-immutable-pure-component';

//  Mastodon imports  //
import emojify from '../../../mastodon/emoji';
import Permalink from '../../../mastodon/components/permalink';
import AccountContainer from '../../../mastodon/containers/account_container';

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Inital setup:
-------------

The `messages` constant is used to define any messages that we need
from inside props.

*/

const messages = defineMessages({
  deleteNotification :
    { id: 'status.dismiss_notification', defaultMessage: 'Dismiss notification' },
});

/*

Implementation:
---------------

*/

@injectIntl
export default class NotificationFollow extends ImmutablePureComponent {

  static propTypes = {
    id                   : PropTypes.number.isRequired,
    onDeleteNotification : PropTypes.func.isRequired,
    account              : ImmutablePropTypes.map.isRequired,
    intl                 : PropTypes.object.isRequired,
  };

/*

###  `handleNotificationDeleteClick()`

This function just calls our `onDeleteNotification()` prop with the
notification's `id`.

*/

  handleNotificationDeleteClick = () => {
    this.props.onDeleteNotification(this.props.id);
  }

/*

###  `render()`

This actually renders the component.

*/

  render () {
    const { account, intl } = this.props;

/*

`dismiss` creates the notification dismissal button. Its title is given
by `dismissTitle`.

*/

    const dismissTitle = intl.formatMessage(messages.deleteNotification);
    const dismiss = (
      <button
        aria-label={dismissTitle}
        title={dismissTitle}
        onClick={this.handleNotificationDeleteClick}
        className='status__prepend-dismiss-button'
      >
        <i className='fa fa-eraser' />
      </button>
    );

/*

`link` is a container for the account's `displayName`, which links to
the account timeline using a `<Permalink>`.

*/

    const displayName = account.get('display_name') || account.get('username');
    const displayNameHTML = { __html: emojify(escapeTextContentForBrowser(displayName)) };
    const link = (
      <Permalink
        className='notification__display-name'
        href={account.get('url')}
        title={account.get('acct')}
        to={`/accounts/${account.get('id')}`}
        dangerouslySetInnerHTML={displayNameHTML}
      />
    );

/*

We can now render our component.

*/

    return (
      <div className='notification notification-follow'>
        <div className='notification__message'>
          <div className='notification__favourite-icon-wrapper'>
            <i className='fa fa-fw fa-user-plus' />
          </div>

          <FormattedMessage
            id='notification.follow'
            defaultMessage='{name} followed you'
            values={{ name: link }}
          />

          {dismiss}
        </div>

        <AccountContainer id={account.get('id')} withNote={false} />
      </div>
    );
  }

}

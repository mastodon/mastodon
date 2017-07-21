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
import { FormattedMessage } from 'react-intl';
import escapeTextContentForBrowser from 'escape-html';
import ImmutablePureComponent from 'react-immutable-pure-component';

//  Mastodon imports  //
import emojify from '../../../mastodon/emoji';
import Permalink from '../../../mastodon/components/permalink';
import AccountContainer from '../../../mastodon/containers/account_container';

// Our imports //
import NotificationOverlayContainer from '../notification/overlay/container';

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Implementation:
---------------

*/

export default class NotificationFollow extends ImmutablePureComponent {

  static propTypes = {
    id                   : PropTypes.number.isRequired,
    account              : ImmutablePropTypes.map.isRequired,
    notification         : ImmutablePropTypes.map.isRequired,
  };

/*

###  `render()`

This actually renders the component.

*/

  render () {
    const { account, notification } = this.props;

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
        </div>

        <AccountContainer id={account.get('id')} withNote={false} />
        <NotificationOverlayContainer notification={notification} />
      </div>
    );
  }

}

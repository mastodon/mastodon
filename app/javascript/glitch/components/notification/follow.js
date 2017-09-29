//  `<NotificationFollow>`
//  ======================

//  * * * * * * *  //

//  Imports
//  -------

//  Package imports.
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

//  Mastodon imports.
import Permalink from '../../../mastodon/components/permalink';
import AccountContainer from '../../../mastodon/containers/account_container';

// Our imports.
import NotificationOverlayContainer from '../notification/overlay/container';

//  * * * * * * *  //

//  Implementation
//  --------------

export default class NotificationFollow extends ImmutablePureComponent {

  static propTypes = {
    id                   : PropTypes.string.isRequired,
    account              : ImmutablePropTypes.map.isRequired,
    notification         : ImmutablePropTypes.map.isRequired,
  };

  render () {
    const { account, notification } = this.props;

    //  Links to the display name.
    const displayName = account.get('display_name_html') || account.get('username');
    const link = (
      <Permalink
        className='notification__display-name'
        href={account.get('url')}
        title={account.get('acct')}
        to={`/accounts/${account.get('id')}`}
        dangerouslySetInnerHTML={{ __html: displayName }}
      />
    );

    //  Renders.
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

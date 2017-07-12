//  Package imports  //
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage } from 'react-intl';
import escapeTextContentForBrowser from 'escape-html';
import ImmutablePureComponent from 'react-immutable-pure-component';

//  Mastodon imports  //
import AccountContainer from '../../../mastodon/containers/account_container';
import Permalink from '../../../mastodon/components/permalink';
import emojify from '../../../mastodon/emoji';

//  Our imports  //
import StatusContainer from '../../containers/status';

export default class Notification extends ImmutablePureComponent {

  static propTypes = {
    notification: ImmutablePropTypes.map.isRequired,
    settings: ImmutablePropTypes.map.isRequired,
  };

  renderFollow (notification) {
    const account          = notification.get('account');
    const displayName      = account.get('display_name').length > 0 ? account.get('display_name') : account.get('username');
    const displayNameHTML  = { __html: emojify(escapeTextContentForBrowser(displayName)) };
    const link             = <Permalink className='notification__display-name' href={account.get('url')} title={account.get('acct')} to={`/accounts/${account.get('id')}`} dangerouslySetInnerHTML={displayNameHTML} />;
    return (
      <div className='notification notification-follow'>
        <div className='notification__message'>
          <div className='notification__favourite-icon-wrapper'>
            <i className='fa fa-fw fa-user-plus' />
          </div>

          <FormattedMessage id='notification.follow' defaultMessage='{name} followed you' values={{ name: link }} />
        </div>

        <AccountContainer id={account.get('id')} withNote={false} />
      </div>
    );
  }

  renderMention (notification) {
    return (
      <StatusContainer
        id={notification.get('status')}
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

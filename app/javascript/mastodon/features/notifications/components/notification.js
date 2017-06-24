import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import StatusContainer from '../../../containers/status_container';
import AccountContainer from '../../../containers/account_container';
import { FormattedMessage } from 'react-intl';
import Permalink from '../../../components/permalink';
import emojify from '../../../emoji';
import escapeTextContentForBrowser from 'escape-html';
import ImmutablePureComponent from 'react-immutable-pure-component';
import RelativeTimestamp from '../../../components/relative_timestamp';

export default class Notification extends ImmutablePureComponent {

  static propTypes = {
    notification: ImmutablePropTypes.map.isRequired,
  };

  renderFollow (notification, account, link) {
    return (
      <div className='notification notification-follow'>
        <div className='notification__message'>
          <div className='notification__icon-wrapper'>
            <i className='fa fa-fw fa-user-plus' />
          </div>
          <RelativeTimestamp timestamp={notification.get('created_at')} />
          <FormattedMessage id='notification.follow' defaultMessage='{name} followed you' values={{ name: link }} />
        </div>

        <AccountContainer id={account.get('id')} withNote={false} />
      </div>
    );
  }

  renderMention (notification, link) {
    return (
      <div className='notification notification-mention'>
        <div className={`notification__message notification-${notification.get('visibility')}`}>
          <div className='notification__icon-wrapper'>
            <i className='fa fa-fw fa-commenting mention-icon' />
          </div>
          <FormattedMessage id='notification.mention' defaultMessage='{name} mentioned you' values={{ name: link }} />
        </div>

        <StatusContainer id={notification.get('status')} withDismiss />
      </div>
    );
  }

  renderFavourite (notification, link) {
    return (
      <div className='notification notification-favourite'>
        <div className='notification__message'>
          <div className='notification__icon-wrapper'>
            <i className='fa fa-fw fa-star star-icon' />
          </div>
          <RelativeTimestamp timestamp={notification.get('created_at')} />
          <FormattedMessage id='notification.favourite' defaultMessage='{name} favourited your status' values={{ name: link }} />
        </div>

        <StatusContainer id={notification.get('status')} account={notification.get('account')} muted withDismiss />
      </div>
    );
  }

  renderReblog (notification, link) {
    return (
      <div className='notification notification-reblog'>
        <div className='notification__message'>
          <div className='notification__icon-wrapper'>
            <i className='fa fa-fw fa-retweet' />
          </div>
          <RelativeTimestamp timestamp={notification.get('created_at')} />
          <FormattedMessage id='notification.reblog' defaultMessage='{name} boosted your status' values={{ name: link }} />
        </div>

        <StatusContainer id={notification.get('status')} account={notification.get('account')} muted withDismiss />
      </div>
    );
  }

  render () {
    const { notification } = this.props;
    const account          = notification.get('account');
    const displayName      = account.get('display_name').length > 0 ? account.get('display_name') : account.get('username');
    const displayNameHTML  = { __html: emojify(escapeTextContentForBrowser(displayName)) };
    const link             = <Permalink className='notification__display-name' href={account.get('url')} title={account.get('acct')} to={`/accounts/${account.get('id')}`} dangerouslySetInnerHTML={displayNameHTML} />;

    switch(notification.get('type')) {
    case 'follow':
      return this.renderFollow(notification, account, link);
    case 'mention':
      return this.renderMention(notification, link);
    case 'favourite':
      return this.renderFavourite(notification, link);
    case 'reblog':
      return this.renderReblog(notification, link);
    }

    return null;
  }

}

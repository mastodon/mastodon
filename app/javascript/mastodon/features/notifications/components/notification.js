import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import StatusContainer from '../../../containers/status_container';
import AccountContainer from '../../../containers/account_container';
import { FormattedMessage } from 'react-intl';
import Permalink from '../../../components/permalink';
import ImmutablePureComponent from 'react-immutable-pure-component';

export default class Notification extends ImmutablePureComponent {

  static propTypes = {
    notification: ImmutablePropTypes.map.isRequired,
    hidden: PropTypes.bool,
  };

  renderFollow (account, link) {
    return (
      <div className='notification notification-follow'>
        <div className='notification__message'>
          <div className='notification__favourite-icon-wrapper'>
            <i className='fa fa-fw fa-user-plus' />
          </div>

          <FormattedMessage id='notification.follow' defaultMessage='{name} followed you' values={{ name: link }} />
        </div>

        <AccountContainer id={account.get('id')} withNote={false} hidden={this.props.hidden} />
      </div>
    );
  }

  renderMention (notification) {
    return <StatusContainer id={notification.get('status')} withDismiss hidden={this.props.hidden} />;
  }

  renderFavourite (notification, link) {
    return (
      <div className='notification notification-favourite'>
        <div className='notification__message'>
          <div className='notification__favourite-icon-wrapper'>
            <i className='fa fa-fw fa-star star-icon' />
          </div>
          <FormattedMessage id='notification.favourite' defaultMessage='{name} favourited your status' values={{ name: link }} />
        </div>

        <StatusContainer id={notification.get('status')} account={notification.get('account')} muted withDismiss hidden={!!this.props.hidden} />
      </div>
    );
  }

  renderReblog (notification, link) {
    return (
      <div className='notification notification-reblog'>
        <div className='notification__message'>
          <div className='notification__favourite-icon-wrapper'>
            <i className='fa fa-fw fa-retweet' />
          </div>
          <FormattedMessage id='notification.reblog' defaultMessage='{name} boosted your status' values={{ name: link }} />
        </div>

        <StatusContainer id={notification.get('status')} account={notification.get('account')} muted withDismiss hidden={this.props.hidden} />
      </div>
    );
  }

  render () {
    const { notification } = this.props;
    const account          = notification.get('account');
    const displayNameHtml  = { __html: account.get('display_name_html') };
    const link             = <Permalink className='notification__display-name' href={account.get('url')} title={account.get('acct')} to={`/accounts/${account.get('id')}`} dangerouslySetInnerHTML={displayNameHtml} />;

    switch(notification.get('type')) {
    case 'follow':
      return this.renderFollow(account, link);
    case 'mention':
      return this.renderMention(notification);
    case 'favourite':
      return this.renderFavourite(notification, link);
    case 'reblog':
      return this.renderReblog(notification, link);
    }

    return null;
  }

}

import ImmutablePropTypes from 'react-immutable-proptypes';
import StatusContainer from '../../../containers/status_container';
import AccountContainer from '../../../containers/account_container';
import { FormattedMessage } from 'react-intl';
import Permalink from '../../../components/permalink';
import emojify from '../../../emoji';
import escapeTextContentForBrowser from 'escape-html';

class Notification extends React.PureComponent {

  renderFollow (account, link) {
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
    return <StatusContainer id={notification.get('status')} />;
  }

  renderFavourite (notification, link) {
    return (
      <div className='notification notification-favourite'>
        <div className='notification__message'>
          <div className='notification__favourite-icon-wrapper'>
            <i className='fa fa-fw fa-star star-icon'/>
          </div>

          <FormattedMessage id='notification.favourite' defaultMessage='{name} favourited your status' values={{ name: link }} />
        </div>

        <StatusContainer id={notification.get('status')} muted={true} />
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

        <StatusContainer id={notification.get('status')} muted={true} />
      </div>
    );
  }

  render () { // eslint-disable-line consistent-return
    const { notification } = this.props;
    const account          = notification.get('account');
    const displayName      = account.get('display_name').length > 0 ? account.get('display_name') : account.get('username');
    const displayNameHTML = { __html: emojify(escapeTextContentForBrowser(displayName)) };
    const link             = <Permalink className='notification__display-name' href={account.get('url')} title={account.get('acct')} to={`/accounts/${account.get('id')}`} dangerouslySetInnerHTML={displayNameHTML} />;

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
  }

}

Notification.propTypes = {
  notification: ImmutablePropTypes.map.isRequired
};

export default Notification;

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

const messages = defineMessages({
  deleteNotification: { id: 'status.dismiss_notification', defaultMessage: 'Dismiss notification' },
});


@injectIntl
export default class FollowNotification extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    notificationId: PropTypes.number.isRequired,
    onDeleteNotification: PropTypes.func.isRequired,
    account: ImmutablePropTypes.map.isRequired,
    intl: PropTypes.object.isRequired,
  };

  // Avoid checking props that are functions (and whose equality will always
  // evaluate to false. See react-immutable-pure-component for usage.
  updateOnProps = [
    'account',
  ]

  handleNotificationDeleteClick = () => {
    this.props.onDeleteNotification(this.props.notificationId);
  }

  render () {
    const { account, intl } = this.props;

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

          {dismiss}
        </div>

        <AccountContainer id={account.get('id')} withNote={false} />
      </div>
    );
  }

}

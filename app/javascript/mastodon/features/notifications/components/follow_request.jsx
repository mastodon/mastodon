import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { Avatar } from 'mastodon/components/avatar';
import DisplayName from 'mastodon/components/display_name';
import { Link } from 'react-router-dom';
import { IconButton } from 'mastodon/components/icon_button';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  authorize: { id: 'follow_request.authorize', defaultMessage: 'Authorize' },
  reject: { id: 'follow_request.reject', defaultMessage: 'Reject' },
});

class FollowRequest extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    onAuthorize: PropTypes.func.isRequired,
    onReject: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { intl, hidden, account, onAuthorize, onReject } = this.props;

    if (!account) {
      return <div />;
    }

    if (hidden) {
      return (
        <React.Fragment>
          {account.get('display_name')}
          {account.get('username')}
        </React.Fragment>
      );
    }

    return (
      <div className='account'>
        <div className='account__wrapper'>
          <Link key={account.get('id')} className='account__display-name' title={account.get('acct')} to={`/@${account.get('acct')}`}>
            <div className='account__avatar-wrapper'><Avatar account={account} size={36} /></div>
            <DisplayName account={account} />
          </Link>

          <div className='account__relationship'>
            <IconButton title={intl.formatMessage(messages.authorize)} icon='check' onClick={onAuthorize} />
            <IconButton title={intl.formatMessage(messages.reject)} icon='times' onClick={onReject} />
          </div>
        </div>
      </div>
    );
  }

}

export default injectIntl(FollowRequest);

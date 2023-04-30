import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { injectIntl, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

class AccountBadge extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map,
  };

  render () {
    const { account  } = this.props;

    if (!account) {
      return null;
    }

    if (account.get('bot')) {
      return (<div className='account-role bot'><FormattedMessage id='account.badges.bot' defaultMessage='Bot' /></div>);
    } else if (account.get('roles')) {
      let badge = null;
      account.get('roles').forEach(r => {
        badge = (<div className='account-role group' style={{ color: r.get('color'), borderColor: r.get('color') }}>{r.get('name')}</div>);
      });
      return badge;
    } else {
      return null;
    }
  }

}

export default injectIntl(AccountBadge);

import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import AccountRelationshipButtonContainer from '../containers/account_relationship_button_container';
import PropTypes from 'prop-types';
import Avatar from './avatar';
import DisplayName from './display_name';
import Permalink from './permalink';
import { injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

@injectIntl
export default class Account extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    intl: PropTypes.object.isRequired,
    hidden: PropTypes.bool,
  };

  render () {
    const { account, hidden } = this.props;

    if (!account) {
      return <div />;
    }

    if (hidden) {
      return (
        <div>
          {account.get('display_name')}
          {account.get('username')}
        </div>
      );
    }

    return (
      <div className='account'>
        <div className='account__wrapper'>
          <Permalink key={account.get('id')} className='account__display-name' href={account.get('url')} to={`/accounts/${account.get('id')}`}>
            <div className='account__avatar-wrapper'><Avatar account={account} size={36} /></div>
            <DisplayName account={account} />
          </Permalink>

          <div className='account__relationship'>
            <AccountRelationshipButtonContainer id={account.get('id')} />
          </div>
        </div>
      </div>
    );
  }

}

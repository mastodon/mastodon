import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Avatar from './avatar';
import DisplayName from './display_name';
import Permalink from './permalink';
import { injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

@injectIntl
export default class ProfileChange extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    profileChange: ImmutablePropTypes.map.isRequired,
    intl: PropTypes.object.isRequired,
    hidden: PropTypes.bool,
  };

  render () {
    const { account, profileChange, hidden } = this.props;

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

    // TODO: better UI and RTL support
    return (
      <div className='account'>
        <div className='account__wrapper'>
          <Permalink key={account.get('id')+'-old'} className='account__display-name' href={account.get('url')} to={`/accounts/${account.get('id')}`}>
            <div className='account__avatar-wrapper'><Avatar account={profileChange} size={48} /></div>
            <DisplayName account={profileChange} />
          </Permalink>

          <span style={{ margin: 'auto' }}>⇒</span>

          <Permalink key={account.get('id')} className='account__display-name' href={account.get('url')} to={`/accounts/${account.get('id')}`}>
            <div className='account__avatar-wrapper'><Avatar account={account} size={48} /></div>
            <DisplayName account={account} />
          </Permalink>
        </div>
      </div>
    );
  }

}

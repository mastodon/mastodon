import React from 'react';
import Avatar from '../../../components/avatar';
import DisplayName from '../../../components/display_name';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

class AutosuggestAccount extends ImmutablePureComponent {

  render () {
    const { account } = this.props;

    return (
      <div className='autosuggest-account'>
        <div className='autosuggest-account-icon'><Avatar src={account.get('avatar')} staticSrc={account.get('avatar_static')} size={18} /></div>
        <DisplayName account={account} />
      </div>
    );
  }

}

AutosuggestAccount.propTypes = {
  account: ImmutablePropTypes.map.isRequired
};

export default AutosuggestAccount;

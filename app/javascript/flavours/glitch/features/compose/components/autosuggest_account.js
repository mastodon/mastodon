import React from 'react';
import Avatar from 'flavours/glitch/components/avatar';
import DisplayName from 'flavours/glitch/components/display_name';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

export default class AutosuggestAccount extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
  };

  render () {
    const { account } = this.props;

    return (
      <div className='autosuggest-account'>
        <div className='autosuggest-account-icon'><Avatar account={account} size={18} /></div>
        <DisplayName account={account} />
      </div>
    );
  }

}

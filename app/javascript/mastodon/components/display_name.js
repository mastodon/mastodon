import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Emojified from './emojified';

export default class DisplayName extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
  };

  render () {
    return (
      <span className='display-name'>
        <strong className='display-name__html'>
          <Emojified tokens={this.props.account.get('display_name_parsed')} />
        </strong>
        <span className='display-name__account'>@{this.props.account.get('acct')}</span>
      </span>
    );
  }

}

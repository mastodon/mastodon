import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

export default class BotIcon extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
  };

  render () {
    const { account } = this.props;

    if (account.get('bot')) {
      return (
        <i className='fa fa-fw fa-robot bot-icon' />
      );
    }

    return '';
  }

}

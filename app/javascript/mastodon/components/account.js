import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Avatar from './avatar';
import DisplayName from './display_name';
import Permalink from './permalink';
import ImmutablePureComponent from 'react-immutable-pure-component';
import OldCascadingControls from './old_cascading_controls';


export default class Account extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    hidden: PropTypes.bool,
    children: PropTypes.node,
  };

  injectAccountIntoChild = (child) => {
    return React.cloneElement(child, {
      account: this.props.account,
    });
  }

  render () {
    const { account, hidden, children } = this.props;

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

    const contents = children || <OldCascadingControls />;

    return (
      <div className='account'>
        <div className='account__wrapper'>
          <Permalink key={account.get('id')} className='account__display-name' title={account.get('acct')} href={account.get('url')} to={`/accounts/${account.get('id')}`}>
            <div className='account__avatar-wrapper'><Avatar account={account} size={36} /></div>
            <DisplayName account={account} />
          </Permalink>

          <div className='account__relationship'>
            {React.Children.map(contents, this.injectAccountIntoChild)}
          </div>
        </div>
      </div>
    );
  }

}

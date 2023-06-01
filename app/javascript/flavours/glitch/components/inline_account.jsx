import { PureComponent } from 'react';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import { Avatar } from 'flavours/glitch/components/avatar';
import { makeGetAccount } from 'flavours/glitch/selectors';

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, { accountId }) => ({
    account: getAccount(state, accountId),
  });

  return mapStateToProps;
};

class InlineAccount extends PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
  };

  render () {
    const { account } = this.props;

    return (
      <span className='inline-account'>
        <Avatar size={13} account={account} /> <strong>{account.get('username')}</strong>
      </span>
    );
  }

}

export default connect(makeMapStateToProps)(InlineAccount);

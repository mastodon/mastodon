import { injectIntl } from 'react-intl';

import { Link } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { Avatar } from '../../../components/avatar';
import { DisplayName } from '../../../components/display_name';
import { makeGetAccount } from '../../../selectors';

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, { accountId }) => ({
    account: getAccount(state, accountId),
  });

  return mapStateToProps;
};

class Account extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.record.isRequired,
  };

  render () {
    const { account } = this.props;
    return (
      <div className='account'>
        <div className='account__wrapper'>
          <Link key={account.get('id')} className='account__display-name' title={account.get('acct')} to={`/@${account.get('acct')}`}>
            <div className='account__avatar-wrapper'><Avatar account={account} size={36} /></div>
            <div className='account__contents'><DisplayName account={account} /></div>
          </Link>
        </div>
      </div>
    );
  }

}

export default connect(makeMapStateToProps)(injectIntl(Account));

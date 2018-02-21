import { connect } from 'react-redux';
import { injectIntl } from 'react-intl';
import { makeGetAccount } from '../selectors';
import Account from '../components/account';

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, props) => ({
    account: getAccount(state, props.id),
  });

  return mapStateToProps;
};

export default injectIntl(connect(makeMapStateToProps)(Account));

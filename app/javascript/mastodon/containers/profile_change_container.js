import { connect } from 'react-redux';
import { injectIntl } from 'react-intl';
import { makeGetAccount } from '../selectors';
import ProfileChange from '../components/profile_change';

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, props) => ({
    account: getAccount(state, props.id),
  });

  return mapStateToProps;
};

export default injectIntl(connect(makeMapStateToProps)(ProfileChange));

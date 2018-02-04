import { connect } from 'react-redux';
import AutosuggestAccount from '../components/autosuggest_account';
import { makeGetAccount } from '../../../selectors';

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, { id }) => ({
    account: getAccount(state, id),
  });

  return mapStateToProps;
};

export default connect(makeMapStateToProps)(AutosuggestAccount);

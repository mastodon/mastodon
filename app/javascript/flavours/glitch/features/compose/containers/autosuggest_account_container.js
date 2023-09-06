import { connect } from 'react-redux';

import { makeGetAccount } from 'flavours/glitch/selectors';

import AutosuggestAccount from '../components/autosuggest_account';

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, { id }) => ({
    account: getAccount(state, id),
  });

  return mapStateToProps;
};

export default connect(makeMapStateToProps)(AutosuggestAccount);

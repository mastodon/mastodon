import { connect } from 'react-redux';
import { makeGetAccount } from 'flavours/glitch/selectors';
import { injectIntl } from 'react-intl';
import { removeFromListEditor, addToListEditor } from 'flavours/glitch/actions/lists';
import Account from '../components/account';

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, { accountId, added }) => ({
    account: getAccount(state, accountId),
    added: typeof added === 'undefined' ? state.getIn(['listEditor', 'accounts', 'items']).includes(accountId) : added,
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch, { accountId }) => ({
  onRemove: () => dispatch(removeFromListEditor(accountId)),
  onAdd: () => dispatch(addToListEditor(accountId)),
});

export default injectIntl(connect(makeMapStateToProps, mapDispatchToProps)(Account));

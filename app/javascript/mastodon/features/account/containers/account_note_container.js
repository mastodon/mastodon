import { connect } from 'react-redux';

import { submitAccountNote } from 'mastodon/actions/account_notes';

import AccountNote from '../components/account_note';

const mapStateToProps = (state, { accountId }) => ({
  value: state.relationships.getIn([accountId, 'note']),
});

const mapDispatchToProps = (dispatch, { accountId }) => ({

  onSave (value) {
    dispatch(submitAccountNote({ accountId: accountId, note: value }));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(AccountNote);

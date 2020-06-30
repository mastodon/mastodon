import { connect } from 'react-redux';
import { changeAccountNoteComment, submitAccountNote, initEditAccountNote, cancelAccountNote } from 'flavours/glitch/actions/account_notes';
import AccountNote from '../components/account_note';

const mapStateToProps = (state, { account }) => {
  const isEditing = state.getIn(['account_notes', 'edit', 'account_id']) === account.get('id');

  return {
    isSubmitting: state.getIn(['account_notes', 'edit', 'isSubmitting']),
    accountNote: isEditing ? state.getIn(['account_notes', 'edit', 'comment']) : account.getIn(['relationship', 'note']),
    isEditing,
  };
};

const mapDispatchToProps = (dispatch, { account }) => ({

  onEditAccountNote() {
    dispatch(initEditAccountNote(account));
  },

  onSaveAccountNote() {
    dispatch(submitAccountNote());
  },

  onCancelAccountNote() {
    dispatch(cancelAccountNote());
  },

  onChangeAccountNote(comment) {
    dispatch(changeAccountNoteComment(comment));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(AccountNote);

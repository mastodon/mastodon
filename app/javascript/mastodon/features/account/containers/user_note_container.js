import React from 'react';
import { connect } from 'react-redux';
import { changeUserNoteComment, submitUserNote, initEditUserNote, cancelUserNote } from 'mastodon/actions/user_notes';
import UserNote from '../components/user_note';

const mapStateToProps = (state, { account }) => {
  const isEditing = state.getIn(['user_notes', 'edit', 'account_id']) === account.get('id');

  return {
    isSubmitting: state.getIn(['user_notes', 'edit', 'isSubmitting']),
    userNote: isEditing ? state.getIn(['user_notes', 'edit', 'comment']) : account.getIn(['relationship', 'comment']),
    isEditing,
  }
};

const mapDispatchToProps = (dispatch, { account }) => ({

  onEditUserNote() {
    dispatch(initEditUserNote(account));
  },

  onSaveUserNote() {
    dispatch(submitUserNote());
  },

  onCancelUserNote() {
    dispatch(cancelUserNote());
  },

  onChangeUserNote(comment) {
    dispatch(changeUserNoteComment(comment));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(UserNote);

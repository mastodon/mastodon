import { connect } from 'react-redux';
import ComposeForm from '../components/compose_form';
import { changeComposeVisibility, uploadCompose } from '../../../actions/compose';
import {
  changeCompose,
  submitCompose,
  clearComposeSuggestions,
  fetchComposeSuggestions,
  selectComposeSuggestion,
  changeComposeSpoilerText,
  insertEmojiCompose,
} from '../../../actions/compose';

const mapStateToProps = state => ({
  text: state.getIn(['compose', 'text']),
  suggestion_token: state.getIn(['compose', 'suggestion_token']),
  suggestions: state.getIn(['compose', 'suggestions']),
  advanced_options: state.getIn(['compose', 'advanced_options']),
  spoiler: state.getIn(['compose', 'spoiler']),
  spoiler_text: state.getIn(['compose', 'spoiler_text']),
  privacy: state.getIn(['compose', 'privacy']),
  focusDate: state.getIn(['compose', 'focusDate']),
  preselectDate: state.getIn(['compose', 'preselectDate']),
  is_submitting: state.getIn(['compose', 'is_submitting']),
  is_uploading: state.getIn(['compose', 'is_uploading']),
  showSearch: state.getIn(['search', 'submitted']) && !state.getIn(['search', 'hidden']),
  settings: state.get('local_settings'),
  filesAttached: state.getIn(['compose', 'media_attachments']).size > 0,
});

const mapDispatchToProps = (dispatch) => ({

  onChange (text) {
    dispatch(changeCompose(text));
  },

  onPrivacyChange (value) {
    dispatch(changeComposeVisibility(value));
  },

  onSubmit () {
    dispatch(submitCompose());
  },

  onClearSuggestions () {
    dispatch(clearComposeSuggestions());
  },

  onFetchSuggestions (token) {
    dispatch(fetchComposeSuggestions(token));
  },

  onSuggestionSelected (position, token, accountId) {
    dispatch(selectComposeSuggestion(position, token, accountId));
  },

  onChangeSpoilerText (checked) {
    dispatch(changeComposeSpoilerText(checked));
  },

  onPaste (files) {
    dispatch(uploadCompose(files));
  },

  onPickEmoji (position, data) {
    dispatch(insertEmojiCompose(position, data));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(ComposeForm);

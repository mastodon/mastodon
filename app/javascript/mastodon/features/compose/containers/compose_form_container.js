import { connect } from 'react-redux';
import ComposeForm from '../components/compose_form';
import { uploadCompose } from '../../../actions/compose';
import {
  changeCompose,
  submitCompose,
  clearComposeSuggestions,
  fetchComposeSuggestions,
  selectComposeSuggestion,
  changeComposeSpoilerText,
  insertEmojiCompose,
  clearComposeHashTagSuggestions,
  fetchComposeHashTagSuggestions,
  selectComposeHashTagSuggestion,
} from '../../../actions/compose';

const mapStateToProps = state => ({
  text: state.getIn(['compose', 'text']),
  suggestion_token: state.getIn(['compose', 'suggestion_token']),
  suggestions: state.getIn(['compose', 'suggestions']),
  hash_tag_suggestions: state.getIn(['compose', 'hash_tag_suggestions']),
  hash_tag_token: state.getIn(['compose', 'hash_tag_token']),
  spoiler: state.getIn(['compose', 'spoiler']),
  spoiler_text: state.getIn(['compose', 'spoiler_text']),
  privacy: state.getIn(['compose', 'privacy']),
  focusDate: state.getIn(['compose', 'focusDate']),
  preselectDate: state.getIn(['compose', 'preselectDate']),
  is_submitting: state.getIn(['compose', 'is_submitting']),
  is_uploading: state.getIn(['compose', 'is_uploading']),
  me: state.getIn(['compose', 'me']),
  showSearch: state.getIn(['search', 'submitted']) && !state.getIn(['search', 'hidden']),
});

const mapDispatchToProps = (dispatch) => ({

  onChange (text) {
    dispatch(changeCompose(text));
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

  onHashTagSuggestionsClearRequested() {
    dispatch(clearComposeHashTagSuggestions());
  },

  onHashTagSuggestionsFetchRequested(token) {
    dispatch(fetchComposeHashTagSuggestions(token));
  },

  onHashTagSuggestionsSelected(tokenStart, token, value) {
    dispatch(selectComposeHashTagSuggestion(tokenStart, token, value));
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

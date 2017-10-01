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
  clearProfileEmojiSuggestions,
  fetchProfileEmojiSuggestions,
  selectProfileEmojiSuggestion,
} from '../../../actions/compose';

const mapStateToProps = state => ({
  text: state.getIn(['compose', 'text']),
  suggestion_token: state.getIn(['compose', 'suggestion_token']),
  suggestions: state.getIn(['compose', 'suggestions']),
  spoiler: state.getIn(['compose', 'spoiler']),
  spoiler_text: state.getIn(['compose', 'spoiler_text']),
  privacy: state.getIn(['compose', 'privacy']),
  focusDate: state.getIn(['compose', 'focusDate']),
  preselectDate: state.getIn(['compose', 'preselectDate']),
  is_submitting: state.getIn(['compose', 'is_submitting']),
  is_uploading: state.getIn(['compose', 'is_uploading']),
  me: state.getIn(['compose', 'me']),
  showSearch: state.getIn(['search', 'submitted']) && !state.getIn(['search', 'hidden']),
  enquete: state.get('enquetes'),
  profileEmojiSuggestionToken: state.getIn(['compose', 'profile_emoji_suggestion_token']),
  profileEmojiSuggestions: state.getIn(['compose', 'profile_emoji_suggestions']),
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

  onChangeSpoilerText (checked) {
    dispatch(changeComposeSpoilerText(checked));
  },

  onPaste (files) {
    dispatch(uploadCompose(files));
  },

  onPickEmoji (position, data) {
    dispatch(insertEmojiCompose(position, data));
  },

  onClearProfileEmojiSuggestions () {
    dispatch(clearProfileEmojiSuggestions());
  },

  onFetchProfileEmojiSuggestions (token) {
    dispatch(fetchProfileEmojiSuggestions(token));
  },

  onProfileEmojiSuggestionSelected (position, token, completion) {
    dispatch(selectProfileEmojiSuggestion(position, token, completion));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(ComposeForm);

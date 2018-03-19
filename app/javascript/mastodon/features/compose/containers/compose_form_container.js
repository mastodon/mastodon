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
} from '../../../actions/compose';

const mapStateToProps = state => ({
  text: state.compose.get('text'),
  suggestion_token: state.compose.get('suggestion_token'),
  suggestions: state.compose.get('suggestions'),
  spoiler: state.compose.get('spoiler'),
  spoiler_text: state.compose.get('spoiler_text'),
  privacy: state.compose.get('privacy'),
  focusDate: state.compose.get('focusDate'),
  preselectDate: state.compose.get('preselectDate'),
  is_submitting: state.compose.get('is_submitting'),
  is_uploading: state.compose.get('is_uploading'),
  showSearch: state.search.get('submitted') && !state.search.get('hidden'),
  anyMedia: state.compose.get('media_attachments').size > 0,
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

});

export default connect(mapStateToProps, mapDispatchToProps)(ComposeForm);

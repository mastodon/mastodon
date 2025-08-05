import { connect } from 'react-redux';

import {
  changeCompose,
  submitCompose,
  clearComposeSuggestions,
  fetchComposeSuggestions,
  selectComposeSuggestion,
  changeComposeSpoilerText,
  insertEmojiCompose,
  uploadCompose,
} from 'mastodon/actions/compose';
import { openModal } from 'mastodon/actions/modal';

import ComposeForm from '../components/compose_form';

const mapStateToProps = state => ({
  text: state.compose.text,
  suggestions: state.compose.suggestions,
  spoiler: state.compose.spoiler,
  spoilerText: state.compose.spoiler_text,
  privacy: state.compose.privacy,
  focusDate: state.compose.focusDate,
  caretPosition: state.compose.caretPosition,
  preselectDate: state.compose.preselectDate,
  isSubmitting: state.compose.is_submitting,
  isEditing: state.compose.id !== null,
  isChangingUpload: state.compose.is_changing_upload,
  isUploading: state.compose.is_uploading,
  anyMedia: state.compose.media_attachments.size > 0,
  missingAltText: state.compose.media_attachments.some(media => ['image', 'gifv'].includes(media.get('type')) && (media.get('description') ?? '').length === 0),
  isInReply: state.compose.in_reply_to !== null,
  lang: state.compose.language,
  maxChars: state.getIn(['server', 'server', 'configuration', 'statuses', 'max_characters'], 500),
});

const mapDispatchToProps = (dispatch) => ({

  onChange (text) {
    dispatch(changeCompose(text));
  },

  onSubmit (missingAltText) {
    if (missingAltText) {
      dispatch(openModal({
        modalType: 'CONFIRM_MISSING_ALT_TEXT',
        modalProps: {},
      }));
    } else {
      dispatch(submitCompose());
    }
  },

  onClearSuggestions () {
    dispatch(clearComposeSuggestions());
  },

  onFetchSuggestions (token) {
    dispatch(fetchComposeSuggestions(token));
  },

  onSuggestionSelected (position, token, suggestion, path) {
    dispatch(selectComposeSuggestion(position, token, suggestion, path));
  },

  onChangeSpoilerText (checked) {
    dispatch(changeComposeSpoilerText(checked));
  },

  onPaste (files) {
    dispatch(uploadCompose(files));
  },

  onPickEmoji (position, data, needsSpace) {
    dispatch(insertEmojiCompose(position, data, needsSpace));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(ComposeForm);

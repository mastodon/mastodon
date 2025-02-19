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
import { me } from 'mastodon/initial_state';

import ComposeForm from '../components/compose_form';

const mapStateToProps = state => ({
  text: state.getIn(['compose', 'text']),
  suggestions: state.getIn(['compose', 'suggestions']),
  spoiler: state.getIn(['compose', 'spoiler']),
  spoilerText: state.getIn(['compose', 'spoiler_text']),
  privacy: state.getIn(['compose', 'privacy']),
  focusDate: state.getIn(['compose', 'focusDate']),
  caretPosition: state.getIn(['compose', 'caretPosition']),
  preselectDate: state.getIn(['compose', 'preselectDate']),
  isSubmitting: state.getIn(['compose', 'is_submitting']),
  isEditing: state.getIn(['compose', 'id']) !== null,
  isChangingUpload: state.getIn(['compose', 'is_changing_upload']),
  isUploading: state.getIn(['compose', 'is_uploading']),
  anyMedia: state.getIn(['compose', 'media_attachments']).size > 0,
  missingAltText: state.getIn(['compose', 'media_attachments']).some(media => ['image', 'gifv'].includes(media.get('type')) && (media.get('description') ?? '').length === 0),
  isInReply: state.getIn(['compose', 'in_reply_to']) !== null,
  isInReplyToSelf: me === state.getIn(['statuses', state.getIn(['compose', 'in_reply_to']), 'account']),
  lang: state.getIn(['compose', 'language']),
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

import { connect } from 'react-redux';
import { defineMessages, injectIntl } from 'react-intl';
import ComposeForm from '../components/compose_form';
import {
  changeCompose,
  changeComposeSpoilerText,
  changeComposeSpoilerness,
  changeComposeVisibility,
  clearComposeSuggestions,
  fetchComposeSuggestions,
  insertEmojiCompose,
  selectComposeSuggestion,
  submitCompose,
  uploadCompose,
} from 'flavours/glitch/actions/compose';
import {
  openModal,
} from 'flavours/glitch/actions/modal';
import { changeLocalSetting } from 'flavours/glitch/actions/local_settings';

import { privacyPreference } from 'flavours/glitch/utils/privacy_preference';

const messages = defineMessages({
  missingDescriptionMessage: {
    id: 'confirmations.missing_media_description.message',
    defaultMessage: 'At least one media attachment is lacking a description. Consider describing all media attachments for the visually impaired before sending your toot.',
  },
  missingDescriptionConfirm: {
    id: 'confirmations.missing_media_description.confirm',
    defaultMessage: 'Send anyway',
  },
  missingDescriptionEdit: {
    id: 'confirmations.missing_media_description.edit',
    defaultMessage: 'Edit media',
  },
});

//  State mapping.
function mapStateToProps (state) {
  const spoilersAlwaysOn = state.getIn(['local_settings', 'always_show_spoilers_field']);
  const inReplyTo = state.getIn(['compose', 'in_reply_to']);
  const replyPrivacy = inReplyTo ? state.getIn(['statuses', inReplyTo, 'visibility']) : null;
  const sideArmBasePrivacy = state.getIn(['local_settings', 'side_arm']);
  const sideArmRestrictedPrivacy = replyPrivacy ? privacyPreference(replyPrivacy, sideArmBasePrivacy) : null;
  let sideArmPrivacy = null;
  switch (state.getIn(['local_settings', 'side_arm_reply_mode'])) {
  case 'copy':
    sideArmPrivacy = replyPrivacy;
    break;
  case 'restrict':
    sideArmPrivacy = sideArmRestrictedPrivacy;
    break;
  }
  sideArmPrivacy = sideArmPrivacy || sideArmBasePrivacy;
  return {
    advancedOptions: state.getIn(['compose', 'advanced_options']),
    focusDate: state.getIn(['compose', 'focusDate']),
    caretPosition: state.getIn(['compose', 'caretPosition']),
    isSubmitting: state.getIn(['compose', 'is_submitting']),
    isEditing: state.getIn(['compose', 'id']) !== null,
    isChangingUpload: state.getIn(['compose', 'is_changing_upload']),
    isUploading: state.getIn(['compose', 'is_uploading']),
    layout: state.getIn(['local_settings', 'layout']),
    media: state.getIn(['compose', 'media_attachments']),
    preselectDate: state.getIn(['compose', 'preselectDate']),
    privacy: state.getIn(['compose', 'privacy']),
    sideArm: sideArmPrivacy,
    sensitive: state.getIn(['compose', 'sensitive']),
    showSearch: state.getIn(['search', 'submitted']) && !state.getIn(['search', 'hidden']),
    spoiler: spoilersAlwaysOn || state.getIn(['compose', 'spoiler']),
    spoilerText: state.getIn(['compose', 'spoiler_text']),
    suggestions: state.getIn(['compose', 'suggestions']),
    text: state.getIn(['compose', 'text']),
    anyMedia: state.getIn(['compose', 'media_attachments']).size > 0,
    spoilersAlwaysOn: spoilersAlwaysOn,
    mediaDescriptionConfirmation: state.getIn(['local_settings', 'confirm_missing_media_description']),
    preselectOnReply: state.getIn(['local_settings', 'preselect_on_reply']),
    isInReply: state.getIn(['compose', 'in_reply_to']) !== null,
    lang: state.getIn(['compose', 'language']),
  };
}

//  Dispatch mapping.
const mapDispatchToProps = (dispatch, { intl }) => ({

  onChange(text) {
    dispatch(changeCompose(text));
  },

  onSubmit(routerHistory) {
    dispatch(submitCompose(routerHistory));
  },

  onClearSuggestions() {
    dispatch(clearComposeSuggestions());
  },

  onFetchSuggestions(token) {
    dispatch(fetchComposeSuggestions(token));
  },

  onSuggestionSelected(position, token, suggestion, path) {
    dispatch(selectComposeSuggestion(position, token, suggestion, path));
  },

  onChangeSpoilerText(text) {
    dispatch(changeComposeSpoilerText(text));
  },

  onPaste(files) {
    dispatch(uploadCompose(files));
  },

  onPickEmoji(position, emoji) {
    dispatch(insertEmojiCompose(position, emoji));
  },

  onChangeSpoilerness() {
    dispatch(changeComposeSpoilerness());
  },

  onChangeVisibility(value) {
    dispatch(changeComposeVisibility(value));
  },

  onMediaDescriptionConfirm(routerHistory, mediaId, overriddenVisibility = null) {
    dispatch(openModal('CONFIRM', {
      message: intl.formatMessage(messages.missingDescriptionMessage),
      confirm: intl.formatMessage(messages.missingDescriptionConfirm),
      onConfirm: () => {
        if (overriddenVisibility) {
          dispatch(changeComposeVisibility(overriddenVisibility));
        }
        dispatch(submitCompose(routerHistory));
      },
      secondary: intl.formatMessage(messages.missingDescriptionEdit),
      onSecondary: () => dispatch(openModal('FOCAL_POINT', { id: mediaId })),
      onDoNotAsk: () => dispatch(changeLocalSetting(['confirm_missing_media_description'], false)),
    }));
  },

});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(ComposeForm));

import { defineMessages, injectIntl } from 'react-intl';

import { connect } from 'react-redux';

import { privacyPreference } from 'flavours/glitch/utils/privacy_preference';

import {
  changeCompose,
  submitCompose,
  clearComposeSuggestions,
  fetchComposeSuggestions,
  selectComposeSuggestion,
  changeComposeSpoilerText,
  changeComposeSpoilerness,
  changeComposeVisibility,
  insertEmojiCompose,
  uploadCompose,
} from '../../../actions/compose';
import { changeLocalSetting } from '../../../actions/local_settings';
import {
  openModal,
} from '../../../actions/modal';
import ComposeForm from '../components/compose_form';

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

const sideArmPrivacy = state => {
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
  return sideArmPrivacy || sideArmBasePrivacy;
};

const mapStateToProps = state => ({
  text: state.getIn(['compose', 'text']),
  suggestions: state.getIn(['compose', 'suggestions']),
  spoiler: state.getIn(['local_settings', 'always_show_spoilers_field']) || state.getIn(['compose', 'spoiler']),
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
  isInReply: state.getIn(['compose', 'in_reply_to']) !== null,
  lang: state.getIn(['compose', 'language']),
  advancedOptions: state.getIn(['compose', 'advanced_options']),
  media: state.getIn(['compose', 'media_attachments']),
  sideArm: sideArmPrivacy(state),
  sensitive: state.getIn(['compose', 'sensitive']),
  showSearch: state.getIn(['search', 'submitted']) && !state.getIn(['search', 'hidden']),
  spoilersAlwaysOn: state.getIn(['local_settings', 'always_show_spoilers_field']),
  mediaDescriptionConfirmation: state.getIn(['local_settings', 'confirm_missing_media_description']),
  preselectOnReply: state.getIn(['local_settings', 'preselect_on_reply']),
});

const mapDispatchToProps = (dispatch, { intl }) => ({

  onChange (text) {
    dispatch(changeCompose(text));
  },

  onSubmit (router) {
    dispatch(submitCompose(router));
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

  onChangeSpoilerText (text) {
    dispatch(changeComposeSpoilerText(text));
  },

  onPaste (files) {
    dispatch(uploadCompose(files));
  },

  onPickEmoji (position, emoji) {
    dispatch(insertEmojiCompose(position, emoji));
  },

  onChangeSpoilerness() {
    dispatch(changeComposeSpoilerness());
  },

  onChangeVisibility(value) {
    dispatch(changeComposeVisibility(value));
  },

  onMediaDescriptionConfirm(routerHistory, mediaId, overriddenVisibility = null) {
    dispatch(openModal({
      modalType: 'CONFIRM',
      modalProps: {
        message: intl.formatMessage(messages.missingDescriptionMessage),
        confirm: intl.formatMessage(messages.missingDescriptionConfirm),
        onConfirm: () => {
          if (overriddenVisibility) {
            dispatch(changeComposeVisibility(overriddenVisibility));
          }
          dispatch(submitCompose(routerHistory));
        },
        secondary: intl.formatMessage(messages.missingDescriptionEdit),
        onSecondary: () => dispatch(openModal({
          modalType: 'FOCAL_POINT',
          modalProps: { id: mediaId },
        })),
        onDoNotAsk: () => dispatch(changeLocalSetting(['confirm_missing_media_description'], false)),
      },
    }));
  },

});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(ComposeForm));

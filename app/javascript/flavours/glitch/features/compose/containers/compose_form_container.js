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
  spoilerAlwaysOn: state.getIn(['local_settings', 'always_show_spoilers_field']),
  spoilerText: state.getIn(['compose', 'spoiler_text']),
  privacy: state.getIn(['compose', 'privacy']),
  focusDate: state.getIn(['compose', 'focusDate']),
  caretPosition: state.getIn(['compose', 'caretPosition']),
  preselectDate: state.getIn(['compose', 'preselectDate']),
  preselectOnReply: state.getIn(['local_settings', 'preselect_on_reply']),
  isSubmitting: state.getIn(['compose', 'is_submitting']),
  isEditing: state.getIn(['compose', 'id']) !== null,
  isChangingUpload: state.getIn(['compose', 'is_changing_upload']),
  isUploading: state.getIn(['compose', 'is_uploading']),
  anyMedia: state.getIn(['compose', 'media_attachments']).size > 0,
  isInReply: state.getIn(['compose', 'in_reply_to']) !== null,
  lang: state.getIn(['compose', 'language']),
  sideArm: sideArmPrivacy(state),
  media: state.getIn(['compose', 'media_attachments']),
  mediaDescriptionConfirmation: state.getIn(['local_settings', 'confirm_missing_media_description']),
  maxChars: state.getIn(['server', 'server', 'configuration', 'statuses', 'max_characters'], 500),
});

const mapDispatchToProps = (dispatch, { intl }) => ({

  onChange (text) {
    dispatch(changeCompose(text));
  },

  onSubmit (router, overridePrivacy = null) {
    dispatch(submitCompose(router, overridePrivacy));
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

  onMediaDescriptionConfirm (routerHistory, mediaId, overridePrivacy = null) {
    dispatch(openModal({
      modalType: 'CONFIRM',
      modalProps: {
        message: intl.formatMessage(messages.missingDescriptionMessage),
        confirm: intl.formatMessage(messages.missingDescriptionConfirm),
        onConfirm: () => {
          dispatch(submitCompose(routerHistory, overridePrivacy));
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

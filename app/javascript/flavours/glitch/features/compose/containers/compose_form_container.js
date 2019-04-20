import { connect } from 'react-redux';
import ComposeForm from '../components/compose_form';
import {
  cancelReplyCompose,
  changeCompose,
  changeComposeAdvancedOption,
  changeComposeSensitivity,
  changeComposeSpoilerText,
  changeComposeSpoilerness,
  changeComposeVisibility,
  changeUploadCompose,
  clearComposeSuggestions,
  fetchComposeSuggestions,
  insertEmojiCompose,
  mountCompose,
  selectComposeSuggestion,
  submitCompose,
  undoUploadCompose,
  unmountCompose,
  uploadCompose,
} from 'flavours/glitch/actions/compose';
import {
  closeModal,
  openModal,
} from 'flavours/glitch/actions/modal';
import { changeLocalSetting } from 'flavours/glitch/actions/local_settings';
import { addPoll, removePoll } from 'flavours/glitch/actions/compose';

import { privacyPreference } from 'flavours/glitch/util/privacy_preference';
import { me } from 'flavours/glitch/util/initial_state';

const messages = defineMessages({
  missingDescriptionMessage: {  id: 'confirmations.missing_media_description.message',
                                defaultMessage: 'At least one media attachment is lacking a description. Consider describing all media attachments for the visually impaired before sending your toot.' },
  missingDescriptionConfirm: {  id: 'confirmations.missing_media_description.confirm',
                                defaultMessage: 'Send anyway' },
});
import { defineMessages } from 'react-intl';

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
    acceptContentTypes: state.getIn(['media_attachments', 'accept_content_types']).toArray().join(','),
    advancedOptions: state.getIn(['compose', 'advanced_options']),
    amUnlocked: !state.getIn(['accounts', me, 'locked']),
    focusDate: state.getIn(['compose', 'focusDate']),
    caretPosition: state.getIn(['compose', 'caretPosition']),
    isSubmitting: state.getIn(['compose', 'is_submitting']),
    isChangingUpload: state.getIn(['compose', 'is_changing_upload']),
    isUploading: state.getIn(['compose', 'is_uploading']),
    layout: state.getIn(['local_settings', 'layout']),
    media: state.getIn(['compose', 'media_attachments']),
    preselectDate: state.getIn(['compose', 'preselectDate']),
    privacy: state.getIn(['compose', 'privacy']),
    progress: state.getIn(['compose', 'progress']),
    inReplyTo: inReplyTo ? state.getIn(['statuses', inReplyTo]) : null,
    replyAccount: inReplyTo ? state.getIn(['statuses', inReplyTo, 'account']) : null,
    replyContent: inReplyTo ? state.getIn(['statuses', inReplyTo, 'contentHtml']) : null,
    resetFileKey: state.getIn(['compose', 'resetFileKey']),
    sideArm: sideArmPrivacy,
    sensitive: state.getIn(['compose', 'sensitive']),
    showSearch: state.getIn(['search', 'submitted']) && !state.getIn(['search', 'hidden']),
    spoiler: spoilersAlwaysOn || state.getIn(['compose', 'spoiler']),
    spoilerText: state.getIn(['compose', 'spoiler_text']),
    suggestionToken: state.getIn(['compose', 'suggestion_token']),
    suggestions: state.getIn(['compose', 'suggestions']),
    text: state.getIn(['compose', 'text']),
    anyMedia: state.getIn(['compose', 'media_attachments']).size > 0,
    poll: state.getIn(['compose', 'poll']),
    spoilersAlwaysOn: spoilersAlwaysOn,
    mediaDescriptionConfirmation: state.getIn(['local_settings', 'confirm_missing_media_description']),
    preselectOnReply: state.getIn(['local_settings', 'preselect_on_reply']),
  };
};

//  Dispatch mapping.
const mapDispatchToProps = (dispatch, { intl }) => ({
  onCancelReply() {
    dispatch(cancelReplyCompose());
  },
  onChangeAdvancedOption(option, value) {
    dispatch(changeComposeAdvancedOption(option, value));
  },
  onChangeDescription(id, description) {
    dispatch(changeUploadCompose(id, { description }));
  },
  onChangeSensitivity() {
    dispatch(changeComposeSensitivity());
  },
  onChangeSpoilerText(text) {
    dispatch(changeComposeSpoilerText(text));
  },
  onChangeSpoilerness() {
    dispatch(changeComposeSpoilerness());
  },
  onChangeText(text) {
    dispatch(changeCompose(text));
  },
  onChangeVisibility(value) {
    dispatch(changeComposeVisibility(value));
  },
  onTogglePoll() {
    dispatch((_, getState) => {
      if (getState().getIn(['compose', 'poll'])) {
        dispatch(removePoll());
      } else {
        dispatch(addPoll());
      }
    });
  },
  onClearSuggestions() {
    dispatch(clearComposeSuggestions());
  },
  onCloseModal() {
    dispatch(closeModal());
  },
  onFetchSuggestions(token) {
    dispatch(fetchComposeSuggestions(token));
  },
  onInsertEmoji(position, emoji) {
    dispatch(insertEmojiCompose(position, emoji));
  },
  onMount() {
    dispatch(mountCompose());
  },
  onOpenActionsModal(props) {
    dispatch(openModal('ACTIONS', props));
  },
  onOpenDoodleModal() {
    dispatch(openModal('DOODLE', { noEsc: true }));
  },
  onOpenFocalPointModal(id) {
    dispatch(openModal('FOCAL_POINT', { id }));
  },
  onSelectSuggestion(position, token, suggestion) {
    dispatch(selectComposeSuggestion(position, token, suggestion));
  },
  onMediaDescriptionConfirm(routerHistory) {
    dispatch(openModal('CONFIRM', {
      message: intl.formatMessage(messages.missingDescriptionMessage),
      confirm: intl.formatMessage(messages.missingDescriptionConfirm),
      onConfirm: () => dispatch(submitCompose(routerHistory)),
      onDoNotAsk: () => dispatch(changeLocalSetting(['confirm_missing_media_description'], false)),
    }));
  },
  onSubmit(routerHistory) {
    dispatch(submitCompose(routerHistory));
  },
  onUndoUpload(id) {
    dispatch(undoUploadCompose(id));
  },
  onUnmount() {
    dispatch(unmountCompose());
  },
  onUpload(files) {
    dispatch(uploadCompose(files));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(ComposeForm);

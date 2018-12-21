//  Package imports.
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages } from 'react-intl';

const APPROX_HASHTAG_RE = /(?:^|[^\/\)\w])#(\S+)/i;

//  Actions.
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

//  Components.
import ComposerOptions from './options';
import ComposerPublisher from './publisher';
import ComposerReply from './reply';
import ComposerSpoiler from './spoiler';
import ComposerTextarea from './textarea';
import ComposerUploadForm from './upload_form';
import ComposerWarning from './warning';
import ComposerHashtagWarning from './hashtag_warning';
import ComposerDirectWarning from './direct_warning';

//  Utils.
import { countableText } from 'flavours/glitch/util/counter';
import { me } from 'flavours/glitch/util/initial_state';
import { isMobile } from 'flavours/glitch/util/is_mobile';
import { assignHandlers } from 'flavours/glitch/util/react_helpers';
import { wrap } from 'flavours/glitch/util/redux_helpers';
import { privacyPreference } from 'flavours/glitch/util/privacy_preference';

const messages = defineMessages({
  missingDescriptionMessage: {  id: 'confirmations.missing_media_description.message',
                                defaultMessage: 'At least one media attachment is lacking a description. Consider describing all media attachments for the visually impaired before sending your toot.' },
  missingDescriptionConfirm: {  id: 'confirmations.missing_media_description.confirm',
                                defaultMessage: 'Send anyway' },
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

//  Handlers.
const handlers = {

  //  Changes the text value of the spoiler.
  handleChangeSpoiler ({ target: { value } }) {
    const { onChangeSpoilerText } = this.props;
    if (onChangeSpoilerText) {
      onChangeSpoilerText(value);
    }
  },

  //  Inserts an emoji at the caret.
  handleEmoji (data) {
    const { textarea: { selectionStart } } = this;
    const { onInsertEmoji } = this.props;
    if (onInsertEmoji) {
      onInsertEmoji(selectionStart, data);
    }
  },

  //  Handles the secondary submit button.
  handleSecondarySubmit () {
    const { handleSubmit } = this.handlers;
    const {
      onChangeVisibility,
      sideArm,
    } = this.props;
    if (sideArm !== 'none' && onChangeVisibility) {
      onChangeVisibility(sideArm);
    }
    handleSubmit();
  },

  //  Selects a suggestion from the autofill.
  handleSelect (tokenStart, token, value) {
    const { onSelectSuggestion } = this.props;
    if (onSelectSuggestion) {
      onSelectSuggestion(tokenStart, token, value);
    }
  },

  //  Submits the status.
  handleSubmit () {
    const { textarea: { value }, uploadForm } = this;
    const {
      onChangeText,
      onSubmit,
      isSubmitting,
      isChangingUpload,
      isUploading,
      media,
      anyMedia,
      text,
      mediaDescriptionConfirmation,
      onMediaDescriptionConfirm,
    } = this.props;

    //  If something changes inside the textarea, then we update the
    //  state before submitting.
    if (onChangeText && text !== value) {
      onChangeText(value);
    }

    // Submit disabled:
    if (isSubmitting || isUploading || isChangingUpload || (!text.trim().length && !anyMedia)) {
      return;
    }

    // Submit unless there are media with missing descriptions
    if (mediaDescriptionConfirmation && onMediaDescriptionConfirm && media && media.some(item => !item.get('description'))) {
      const firstWithoutDescription = media.findIndex(item => !item.get('description'));
      if (uploadForm) {
        const inputs = uploadForm.querySelectorAll('.composer--upload_form--item input');
        if (inputs.length == media.size && firstWithoutDescription !== -1) {
          inputs[firstWithoutDescription].focus();
        }
      }
      onMediaDescriptionConfirm(this.context.router ? this.context.router.history : null);
    } else if (onSubmit) {
      onSubmit(this.context.router ? this.context.router.history : null);
    }
  },

  //  Sets a reference to the upload form.
  handleRefUploadForm (uploadFormComponent) {
    this.uploadForm = uploadFormComponent;
  },

  //  Sets a reference to the textarea.
  handleRefTextarea (textareaComponent) {
    if (textareaComponent) {
      this.textarea = textareaComponent.textarea;
    }
  },

  //  Sets a reference to the CW field.
  handleRefSpoilerText (spoilerComponent) {
    if (spoilerComponent) {
      this.spoilerText = spoilerComponent.spoilerText;
    }
  }
};

//  The component.
class Composer extends React.Component {

  //  Constructor.
  constructor (props) {
    super(props);
    assignHandlers(this, handlers);

    //  Instance variables.
    this.textarea = null;
    this.spoilerText = null;
  }

  //  Tells our state the composer has been mounted.
  componentDidMount () {
    const { onMount } = this.props;
    if (onMount) {
      onMount();
    }
  }

  //  Tells our state the composer has been unmounted.
  componentWillUnmount () {
    const { onUnmount } = this.props;
    if (onUnmount) {
      onUnmount();
    }
  }

  //  This statement does several things:
  //  - If we're beginning a reply, and,
  //      - Replying to zero or one users, places the cursor at the end
  //        of the textbox.
  //      - Replying to more than one user, selects any usernames past
  //        the first; this provides a convenient shortcut to drop
  //        everyone else from the conversation.
  componentDidUpdate (prevProps) {
    const {
      textarea,
      spoilerText,
    } = this;
    const {
      focusDate,
      caretPosition,
      isSubmitting,
      preselectDate,
      text,
      preselectOnReply,
    } = this.props;
    let selectionEnd, selectionStart;

    //  Caret/selection handling.
    if (focusDate !== prevProps.focusDate) {
      switch (true) {
      case preselectDate !== prevProps.preselectDate && preselectOnReply:
        selectionStart = text.search(/\s/) + 1;
        selectionEnd = text.length;
        break;
      case !isNaN(caretPosition) && caretPosition !== null:
        selectionStart = selectionEnd = caretPosition;
        break;
      default:
        selectionStart = selectionEnd = text.length;
      }
      if (textarea) {
        textarea.setSelectionRange(selectionStart, selectionEnd);
        textarea.focus();
        textarea.scrollIntoView();
      }

    //  Refocuses the textarea after submitting.
    } else if (textarea && prevProps.isSubmitting && !isSubmitting) {
      textarea.focus();
    } else if (this.props.spoiler !== prevProps.spoiler) {
      if (this.props.spoiler) {
        if (spoilerText) {
          spoilerText.focus();
        }
      } else {
        if (textarea) {
          textarea.focus();
        }
      }
    }
  }

  render () {
    const {
      handleChangeSpoiler,
      handleEmoji,
      handleSecondarySubmit,
      handleSelect,
      handleSubmit,
      handleRefUploadForm,
      handleRefTextarea,
      handleRefSpoilerText,
    } = this.handlers;
    const {
      acceptContentTypes,
      advancedOptions,
      amUnlocked,
      anyMedia,
      intl,
      isSubmitting,
      isChangingUpload,
      isUploading,
      layout,
      media,
      onCancelReply,
      onChangeAdvancedOption,
      onChangeDescription,
      onChangeSensitivity,
      onChangeSpoilerness,
      onChangeText,
      onChangeVisibility,
      onClearSuggestions,
      onCloseModal,
      onFetchSuggestions,
      onOpenActionsModal,
      onOpenDoodleModal,
      onOpenFocalPointModal,
      onUndoUpload,
      onUpload,
      privacy,
      progress,
      inReplyTo,
      resetFileKey,
      sensitive,
      showSearch,
      sideArm,
      spoiler,
      spoilerText,
      suggestions,
      text,
      spoilersAlwaysOn,
    } = this.props;

    let disabledButton = isSubmitting || isUploading || isChangingUpload || (!text.trim().length && !anyMedia);

    return (
      <div className='composer'>
        {privacy === 'direct' ? <ComposerDirectWarning /> : null}
        {privacy === 'private' && amUnlocked ? <ComposerWarning /> : null}
        {privacy !== 'public' && APPROX_HASHTAG_RE.test(text) ? <ComposerHashtagWarning /> : null}
        {inReplyTo && (
          <ComposerReply
            status={inReplyTo}
            intl={intl}
            onCancel={onCancelReply}
          />
        )}
        <ComposerSpoiler
          hidden={!spoiler}
          intl={intl}
          onChange={handleChangeSpoiler}
          onSubmit={handleSubmit}
          onSecondarySubmit={handleSecondarySubmit}
          text={spoilerText}
          ref={handleRefSpoilerText}
        />
        <ComposerTextarea
          advancedOptions={advancedOptions}
          autoFocus={!showSearch && !isMobile(window.innerWidth, layout)}
          disabled={isSubmitting}
          intl={intl}
          onChange={onChangeText}
          onPaste={onUpload}
          onPickEmoji={handleEmoji}
          onSubmit={handleSubmit}
          onSecondarySubmit={handleSecondarySubmit}
          onSuggestionsClearRequested={onClearSuggestions}
          onSuggestionsFetchRequested={onFetchSuggestions}
          onSuggestionSelected={handleSelect}
          ref={handleRefTextarea}
          suggestions={suggestions}
          value={text}
        />
        {isUploading || media && media.size ? (
          <ComposerUploadForm
            intl={intl}
            media={media}
            onChangeDescription={onChangeDescription}
            onOpenFocalPointModal={onOpenFocalPointModal}
            onRemove={onUndoUpload}
            progress={progress}
            uploading={isUploading}
            handleRef={handleRefUploadForm}
          />
        ) : null}
        <ComposerOptions
          acceptContentTypes={acceptContentTypes}
          advancedOptions={advancedOptions}
          disabled={isSubmitting}
          full={media ? media.size >= 4 || media.some(
            item => item.get('type') === 'video'
          ) : false}
          hasMedia={media && !!media.size}
          intl={intl}
          onChangeAdvancedOption={onChangeAdvancedOption}
          onChangeSensitivity={onChangeSensitivity}
          onChangeVisibility={onChangeVisibility}
          onDoodleOpen={onOpenDoodleModal}
          onModalClose={onCloseModal}
          onModalOpen={onOpenActionsModal}
          onToggleSpoiler={spoilersAlwaysOn ? null : onChangeSpoilerness}
          onUpload={onUpload}
          privacy={privacy}
          resetFileKey={resetFileKey}
          sensitive={sensitive || (spoilersAlwaysOn && spoilerText && spoilerText.length > 0)}
          spoiler={spoilersAlwaysOn ? (spoilerText && spoilerText.length > 0) : spoiler}
        />
        <ComposerPublisher
          countText={`${spoilerText}${countableText(text)}${advancedOptions && advancedOptions.get('do_not_federate') ? ' 👁️' : ''}`}
          disabled={disabledButton}
          intl={intl}
          onSecondarySubmit={handleSecondarySubmit}
          onSubmit={handleSubmit}
          privacy={privacy}
          sideArm={sideArm}
        />
      </div>
    );
  }

}

//  Props.
Composer.propTypes = {
  intl: PropTypes.object.isRequired,

  //  State props.
  acceptContentTypes: PropTypes.string,
  advancedOptions: ImmutablePropTypes.map,
  amUnlocked: PropTypes.bool,
  focusDate: PropTypes.instanceOf(Date),
  caretPosition: PropTypes.number,
  isSubmitting: PropTypes.bool,
  isChangingUpload: PropTypes.bool,
  isUploading: PropTypes.bool,
  layout: PropTypes.string,
  media: ImmutablePropTypes.list,
  preselectDate: PropTypes.instanceOf(Date),
  privacy: PropTypes.string,
  progress: PropTypes.number,
  inReplyTo: ImmutablePropTypes.map,
  resetFileKey: PropTypes.number,
  sideArm: PropTypes.string,
  sensitive: PropTypes.bool,
  showSearch: PropTypes.bool,
  spoiler: PropTypes.bool,
  spoilerText: PropTypes.string,
  suggestionToken: PropTypes.string,
  suggestions: ImmutablePropTypes.list,
  text: PropTypes.string,
  anyMedia: PropTypes.bool,
  spoilersAlwaysOn: PropTypes.bool,
  mediaDescriptionConfirmation: PropTypes.bool,
  preselectOnReply: PropTypes.bool,

  //  Dispatch props.
  onCancelReply: PropTypes.func,
  onChangeAdvancedOption: PropTypes.func,
  onChangeDescription: PropTypes.func,
  onChangeSensitivity: PropTypes.func,
  onChangeSpoilerText: PropTypes.func,
  onChangeSpoilerness: PropTypes.func,
  onChangeText: PropTypes.func,
  onChangeVisibility: PropTypes.func,
  onClearSuggestions: PropTypes.func,
  onCloseModal: PropTypes.func,
  onFetchSuggestions: PropTypes.func,
  onInsertEmoji: PropTypes.func,
  onMount: PropTypes.func,
  onOpenActionsModal: PropTypes.func,
  onOpenDoodleModal: PropTypes.func,
  onSelectSuggestion: PropTypes.func,
  onSubmit: PropTypes.func,
  onUndoUpload: PropTypes.func,
  onUnmount: PropTypes.func,
  onUpload: PropTypes.func,
  onMediaDescriptionConfirm: PropTypes.func,
};

Composer.contextTypes = {
  router: PropTypes.object,
};

//  Connecting and export.
export { Composer as WrappedComponent };
export default wrap(Composer, mapStateToProps, mapDispatchToProps, true);

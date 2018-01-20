//  Package imports.
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';

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

//  Components.
import ComposerOptions from './options';
import ComposerPublisher from './publisher';
import ComposerReply from './reply';
import ComposerSpoiler from './spoiler';
import ComposerTextarea from './textarea';
import ComposerUploadForm from './upload_form';
import ComposerWarning from './warning';
import ComposerHashtagWarning from './hashtag_warning';

//  Utils.
import { countableText } from 'flavours/glitch/util/counter';
import { me } from 'flavours/glitch/util/initial_state';
import { isMobile } from 'flavours/glitch/util/is_mobile';
import { assignHandlers } from 'flavours/glitch/util/react_helpers';
import { wrap } from 'flavours/glitch/util/redux_helpers';

//  State mapping.
function mapStateToProps (state) {
  const inReplyTo = state.getIn(['compose', 'in_reply_to']);
  return {
    acceptContentTypes: state.getIn(['media_attachments', 'accept_content_types']).toArray().join(','),
    advancedOptions: state.getIn(['compose', 'advanced_options']),
    amUnlocked: !state.getIn(['accounts', me, 'locked']),
    focusDate: state.getIn(['compose', 'focusDate']),
    isSubmitting: state.getIn(['compose', 'is_submitting']),
    isUploading: state.getIn(['compose', 'is_uploading']),
    layout: state.getIn(['local_settings', 'layout']),
    media: state.getIn(['compose', 'media_attachments']),
    preselectDate: state.getIn(['compose', 'preselectDate']),
    privacy: state.getIn(['compose', 'privacy']),
    progress: state.getIn(['compose', 'progress']),
    replyAccount: inReplyTo ? state.getIn(['statuses', inReplyTo, 'account']) : null,
    replyContent: inReplyTo ? state.getIn(['statuses', inReplyTo, 'contentHtml']) : null,
    resetFileKey: state.getIn(['compose', 'resetFileKey']),
    sideArm: state.getIn(['local_settings', 'side_arm']),
    sensitive: state.getIn(['compose', 'sensitive']),
    showSearch: state.getIn(['search', 'submitted']) && !state.getIn(['search', 'hidden']),
    spoiler: state.getIn(['compose', 'spoiler']),
    spoilerText: state.getIn(['compose', 'spoiler_text']),
    suggestionToken: state.getIn(['compose', 'suggestion_token']),
    suggestions: state.getIn(['compose', 'suggestions']),
    text: state.getIn(['compose', 'text']),
  };
};

//  Dispatch mapping.
const mapDispatchToProps = {
  onCancelReply: cancelReplyCompose,
  onChangeAdvancedOption: changeComposeAdvancedOption,
  onChangeDescription: changeUploadCompose,
  onChangeSensitivity: changeComposeSensitivity,
  onChangeSpoilerText: changeComposeSpoilerText,
  onChangeSpoilerness: changeComposeSpoilerness,
  onChangeText: changeCompose,
  onChangeVisibility: changeComposeVisibility,
  onClearSuggestions: clearComposeSuggestions,
  onCloseModal: closeModal,
  onFetchSuggestions: fetchComposeSuggestions,
  onInsertEmoji: insertEmojiCompose,
  onMount: mountCompose,
  onOpenActionsModal: openModal.bind(null, 'ACTIONS'),
  onOpenDoodleModal: openModal.bind(null, 'DOODLE', { noEsc: true }),
  onSelectSuggestion: selectComposeSuggestion,
  onSubmit: submitCompose,
  onUndoUpload: undoUploadCompose,
  onUnmount: unmountCompose,
  onUpload: uploadCompose,
};

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
    this.caretPos = selectionStart + data.native.length + 1;
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
    this.caretPos = null;
    if (onSelectSuggestion) {
      onSelectSuggestion(tokenStart, token, value);
    }
  },

  //  Submits the status.
  handleSubmit () {
    const { textarea: { value } } = this;
    const {
      onChangeText,
      onSubmit,
      text,
    } = this.props;

    //  If something changes inside the textarea, then we update the
    //  state before submitting.
    if (onChangeText && text !== value) {
      onChangeText(value);
    }

    //  Submits the status.
    if (onSubmit) {
      onSubmit();
    }
  },

  //  Sets a reference to the textarea.
  handleRefTextarea (textareaComponent) {
    if (textareaComponent) {
      this.textarea = textareaComponent.textarea;
    }
  },
};

//  The component.
class Composer extends React.Component {

  //  Constructor.
  constructor (props) {
    super(props);
    assignHandlers(this, handlers);

    //  Instance variables.
    this.caretPos = null;
    this.textarea = null;
  }

  //  If this is the update where we've finished uploading,
  //  save the last caret position so we can restore it below!
  componentWillReceiveProps (nextProps) {
    const { textarea } = this;
    const { isUploading } = this.props;
    if (textarea && isUploading && !nextProps.isUploading) {
      this.caretPos = textarea.selectionStart;
    }
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
  // - If we've just finished uploading an image, and have a saved
  //   caret position, restores the cursor to that position after the
  //   text changes.
  componentDidUpdate (prevProps) {
    const {
      caretPos,
      textarea,
    } = this;
    const {
      focusDate,
      isUploading,
      isSubmitting,
      preselectDate,
      text,
    } = this.props;
    let selectionEnd, selectionStart;

    //  Caret/selection handling.
    if (focusDate !== prevProps.focusDate || (prevProps.isUploading && !isUploading && !isNaN(caretPos) && caretPos !== null)) {
      switch (true) {
      case preselectDate !== prevProps.preselectDate:
        selectionStart = text.search(/\s/) + 1;
        selectionEnd = text.length;
        break;
      case !isNaN(caretPos) && caretPos !== null:
        selectionStart = selectionEnd = caretPos;
        break;
      default:
        selectionStart = selectionEnd = text.length;
      }
      if (textarea) {
        textarea.setSelectionRange(selectionStart, selectionEnd);
        textarea.focus();
      }

    //  Refocuses the textarea after submitting.
    } else if (textarea && prevProps.isSubmitting && !isSubmitting) {
      textarea.focus();
    }
  }

  render () {
    const {
      handleChangeSpoiler,
      handleEmoji,
      handleSecondarySubmit,
      handleSelect,
      handleSubmit,
      handleRefTextarea,
    } = this.handlers;
    const {
      acceptContentTypes,
      advancedOptions,
      amUnlocked,
      intl,
      isSubmitting,
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
      onUndoUpload,
      onUpload,
      privacy,
      progress,
      replyAccount,
      replyContent,
      resetFileKey,
      sensitive,
      showSearch,
      sideArm,
      spoiler,
      spoilerText,
      suggestions,
      text,
    } = this.props;

    return (
      <div className='composer'>
        <ComposerSpoiler
          hidden={!spoiler}
          intl={intl}
          onChange={handleChangeSpoiler}
          onSubmit={handleSubmit}
          text={spoilerText}
        />
        {privacy === 'private' && amUnlocked ? <ComposerWarning /> : null}
        {privacy !== 'public' && APPROX_HASHTAG_RE.test(text) ? <ComposerHashtagWarning /> : null}
        {replyContent ? (
          <ComposerReply
            account={replyAccount}
            content={replyContent}
            intl={intl}
            onCancel={onCancelReply}
          />
        ) : null}
        <ComposerTextarea
          advancedOptions={advancedOptions}
          autoFocus={!showSearch && !isMobile(window.innerWidth, layout)}
          disabled={isSubmitting}
          intl={intl}
          onChange={onChangeText}
          onPaste={onUpload}
          onPickEmoji={handleEmoji}
          onSubmit={handleSubmit}
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
            onRemove={onUndoUpload}
            progress={progress}
            uploading={isUploading}
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
          onToggleSpoiler={onChangeSpoilerness}
          onUpload={onUpload}
          privacy={privacy}
          resetFileKey={resetFileKey}
          sensitive={sensitive}
          spoiler={spoiler}
        />
        <ComposerPublisher
          countText={`${spoilerText}${countableText(text)}${advancedOptions && advancedOptions.get('do_not_federate') ? ' 👁️' : ''}`}
          disabled={isSubmitting || isUploading || !!text.length && !text.trim().length}
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
  isSubmitting: PropTypes.bool,
  isUploading: PropTypes.bool,
  layout: PropTypes.string,
  media: ImmutablePropTypes.list,
  preselectDate: PropTypes.instanceOf(Date),
  privacy: PropTypes.string,
  progress: PropTypes.number,
  replyAccount: PropTypes.string,
  replyContent: PropTypes.string,
  resetFileKey: PropTypes.number,
  sideArm: PropTypes.string,
  sensitive: PropTypes.bool,
  showSearch: PropTypes.bool,
  spoiler: PropTypes.bool,
  spoilerText: PropTypes.string,
  suggestionToken: PropTypes.string,
  suggestions: ImmutablePropTypes.list,
  text: PropTypes.string,

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
};

//  Connecting and export.
export { Composer as WrappedComponent };
export default wrap(Composer, mapStateToProps, mapDispatchToProps, true);

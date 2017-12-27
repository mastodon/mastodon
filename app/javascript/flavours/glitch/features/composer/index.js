//  Package imports.
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';

//  Actions.
import {
  cancelReplyCompose,
  changeCompose,
  changeComposeSensitivity,
  changeComposeSpoilerText,
  changeComposeSpoilerness,
  changeComposeVisibility,
  changeUploadCompose,
  clearComposeSuggestions,
  fetchComposeSuggestions,
  insertEmojiCompose,
  selectComposeSuggestion,
  submitCompose,
  toggleComposeAdvancedOption,
  undoUploadCompose,
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
    amUnlocked: !state.getIn(['accounts', me, 'locked']),
    doNotFederate: state.getIn(['compose', 'advanced_options', 'do_not_federate']),
    focusDate: state.getIn(['compose', 'focusDate']),
    isSubmitting: state.getIn(['compose', 'is_submitting']),
    isUploading: state.getIn(['compose', 'is_uploading']),
    media: state.getIn(['compose', 'media_attachments']),
    preselectDate: state.getIn(['compose', 'preselectDate']),
    privacy: state.getIn(['compose', 'privacy']),
    progress: state.getIn(['compose', 'progress']),
    replyAccount: inReplyTo ? state.getIn(['accounts', state.getIn(['statuses', inReplyTo, 'account'])]) : null,
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
const mapDispatchToProps = dispatch => ({
  cancelReply () {
    dispatch(cancelReplyCompose());
  },
  changeDescription (mediaId, description) {
    dispatch(changeUploadCompose(mediaId, description));
  },
  changeSensitivity () {
    dispatch(changeComposeSensitivity());
  },
  changeSpoilerText (checked) {
    dispatch(changeComposeSpoilerText(checked));
  },
  changeSpoilerness () {
    dispatch(changeComposeSpoilerness());
  },
  changeText (text) {
    dispatch(changeCompose(text));
  },
  changeVisibility (value) {
    dispatch(changeComposeVisibility(value));
  },
  clearSuggestions () {
    dispatch(clearComposeSuggestions());
  },
  closeModal () {
    dispatch(closeModal());
  },
  fetchSuggestions (token) {
    dispatch(fetchComposeSuggestions(token));
  },
  insertEmoji (position, data) {
    dispatch(insertEmojiCompose(position, data));
  },
  openActionsModal (data) {
    dispatch(openModal('ACTIONS', data));
  },
  openDoodleModal () {
    dispatch(openModal('DOODLE', { noEsc: true }));
  },
  selectSuggestion (position, token, accountId) {
    dispatch(selectComposeSuggestion(position, token, accountId));
  },
  submit () {
    dispatch(submitCompose());
  },
  toggleAdvancedOption (option) {
    dispatch(toggleComposeAdvancedOption(option));
  },
  undoUpload (mediaId) {
    dispatch(undoUploadCompose(mediaId));
  },
  upload (files) {
    dispatch(uploadCompose(files));
  },
});

//  Handlers.
const handlers = {

  //  Changes the text value of the spoiler.
  changeSpoiler ({ target: { value } }) {
    const { dispatch: { changeSpoilerText } } = this.props;
    if (changeSpoilerText) {
      changeSpoilerText(value);
    }
  },

  //  Inserts an emoji at the caret.
  emoji (data) {
    const { textarea: { selectionStart } } = this;
    const { dispatch: { insertEmoji } } = this.props;
    this.caretPos = selectionStart + data.native.length + 1;
    if (insertEmoji) {
      insertEmoji(selectionStart, data);
    }
  },

  //  Handles the secondary submit button.
  secondarySubmit () {
    const { submit } = this.handlers;
    const {
      dispatch: { changeVisibility },
      side_arm,
    } = this.props;
    if (changeVisibility) {
      changeVisibility(side_arm);
    }
    submit();
  },

  //  Selects a suggestion from the autofill.
  select (tokenStart, token, value) {
    const { dispatch: { selectSuggestion } } = this.props;
    this.caretPos = null;
    if (selectSuggestion) {
      selectSuggestion(tokenStart, token, value);
    }
  },

  //  Submits the status.
  submit () {
    const { textarea: { value } } = this;
    const {
      dispatch: {
        changeText,
        submit,
      },
      state: { text },
    } = this.props;

    //  If something changes inside the textarea, then we update the
    //  state before submitting.
    if (changeText && text !== value) {
      changeText(value);
    }

    //  Submits the status.
    if (submit) {
      submit();
    }
  },

  //  Sets a reference to the textarea.
  refTextarea ({ textarea }) {
    this.textarea = textarea;
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
    const { textarea: { selectionStart } } = this;
    const { state: { isUploading } } = this.props;
    if (isUploading && !nextProps.state.isUploading) {
      this.caretPos = selectionStart;
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
      state: {
        focusDate,
        isUploading,
        isSubmitting,
        preselectDate,
        text,
      },
    } = this.props;
    let selectionEnd, selectionStart;

    //  Caret/selection handling.
    if (focusDate !== prevProps.state.focusDate || (prevProps.state.isUploading && !isUploading && !isNaN(caretPos) && caretPos !== null)) {
      switch (true) {
      case preselectDate !== prevProps.state.preselectDate:
        selectionStart = text.search(/\s/) + 1;
        selectionEnd = text.length;
        break;
      case !isNaN(caretPos) && caretPos !== null:
        selectionStart = selectionEnd = caretPos;
        break;
      default:
        selectionStart = selectionEnd = text.length;
      }
      textarea.setSelectionRange(selectionStart, selectionEnd);
      textarea.focus();

    //  Refocuses the textarea after submitting.
    } else if (prevProps.state.isSubmitting && !isSubmitting) {
      textarea.focus();
    }
  }

  render () {
    const {
      changeSpoiler,
      emoji,
      secondarySubmit,
      select,
      submit,
      refTextarea,
    } = this.handlers;
    const { history } = this.context;
    const {
      dispatch: {
        cancelReply,
        changeDescription,
        changeSensitivity,
        changeText,
        changeVisibility,
        clearSuggestions,
        closeModal,
        fetchSuggestions,
        openActionsModal,
        openDoodleModal,
        toggleAdvancedOption,
        undoUpload,
        upload,
      },
      intl,
      state: {
        acceptContentTypes,
        amUnlocked,
        doNotFederate,
        isSubmitting,
        isUploading,
        media,
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
      },
    } = this.props;

    return (
      <div className='compose'>
        <ComposerSpoiler
          hidden={!spoiler}
          intl={intl}
          onChange={changeSpoiler}
          onSubmit={submit}
          text={spoilerText}
        />
        {privacy === 'private' && amUnlocked ? <ComposerWarning /> : null}
        {replyContent ? (
          <ComposerReply
            account={replyAccount}
            content={replyContent}
            history={history}
            intl={intl}
            onCancel={cancelReply}
          />
        ) : null}
        <ComposerTextarea
          autoFocus={!showSearch && !isMobile(window.innerWidth)}
          disabled={isSubmitting}
          intl={intl}
          onChange={changeText}
          onPaste={upload}
          onPickEmoji={emoji}
          onSubmit={submit}
          onSuggestionsClearRequested={clearSuggestions}
          onSuggestionsFetchRequested={fetchSuggestions}
          onSuggestionSelected={select}
          ref={refTextarea}
          suggestions={suggestions}
          value={text}
        />
        {media && media.size ? (
          <ComposerUploadForm
            active={isUploading}
            intl={intl}
            media={media}
            onChangeDescription={changeDescription}
            onRemove={undoUpload}
            progress={progress}
          />
        ) : null}
        <ComposerOptions
          acceptContentTypes={acceptContentTypes}
          disabled={isSubmitting}
          doNotFederate={doNotFederate}
          full={media.size >= 4 || media.some(
            item => item.get('type') === 'video'
          )}
          hasMedia={!!media.size}
          intl={intl}
          onChangeSensitivity={changeSensitivity}
          onChangeVisibility={changeVisibility}
          onDoodleOpen={openDoodleModal}
          onModalClose={closeModal}
          onModalOpen={openActionsModal}
          onToggleAdvancedOption={toggleAdvancedOption}
          onUpload={upload}
          privacy={privacy}
          resetFileKey={resetFileKey}
          sensitive={sensitive}
          spoiler={spoiler}
        />
        <ComposerPublisher
          countText={`${spoilerText}${countableText(text)}${doNotFederate ? ' 👁️' : ''}`}
          disabled={isSubmitting || isUploading || text.length && text.trim().length === 0}
          intl={intl}
          onSecondarySubmit={secondarySubmit}
          onSubmit={submit}
          privacy={privacy}
          sideArm={sideArm}
        />
      </div>
    );
  }

}

//  Context
Composer.contextTypes = {
  history: PropTypes.object,
};

//  Props.
Composer.propTypes = {
  dispatch: PropTypes.objectOf(PropTypes.func).isRequired,
  intl: PropTypes.object.isRequired,
  state: PropTypes.shape({
    acceptContentTypes: PropTypes.string,
    amUnlocked: PropTypes.bool,
    doNotFederate: PropTypes.bool,
    focusDate: PropTypes.instanceOf(Date),
    isSubmitting: PropTypes.bool,
    isUploading: PropTypes.bool,
    media: PropTypes.list,
    preselectDate: PropTypes.instanceOf(Date),
    privacy: PropTypes.string,
    progress: PropTypes.number,
    replyAccount: ImmutablePropTypes.map,
    replyContent: PropTypes.string,
    resetFileKey: PropTypes.string,
    sideArm: PropTypes.string,
    sensitive: PropTypes.bool,
    showSearch: PropTypes.bool,
    spoiler: PropTypes.bool,
    spoilerText: PropTypes.string,
    suggestionToken: PropTypes.string,
    suggestions: ImmutablePropTypes.list,
    text: PropTypes.string,
  }).isRequired,
};

//  Default props.
Composer.defaultProps = {
  dispatch: {},
  state: {},
};

//  Connecting and export.
export { Composer as WrappedComponent };
export default wrap(Composer, mapStateToProps, mapDispatchToProps, true);

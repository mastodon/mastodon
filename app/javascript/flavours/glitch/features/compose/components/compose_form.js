import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import ReplyIndicatorContainer from '../containers/reply_indicator_container';
import AutosuggestTextarea from '../../../components/autosuggest_textarea';
import AutosuggestInput from '../../../components/autosuggest_input';
import { defineMessages, injectIntl } from 'react-intl';
import EmojiPicker from 'flavours/glitch/features/emoji_picker';
import PollFormContainer from '../containers/poll_form_container';
import UploadFormContainer from '../containers/upload_form_container';
import WarningContainer from '../containers/warning_container';
import { isMobile } from 'flavours/glitch/util/is_mobile';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { countableText } from 'flavours/glitch/util/counter';
import OptionsContainer from '../containers/options_container';
import Publisher from './publisher';
import TextareaIcons from './textarea_icons';
import { maxChars } from 'flavours/glitch/util/initial_state';
import CharacterCounter from './character_counter';

const messages = defineMessages({
  placeholder: { id: 'compose_form.placeholder', defaultMessage: 'What is on your mind?' },
  missingDescriptionMessage: {  id: 'confirmations.missing_media_description.message',
                                defaultMessage: 'At least one media attachment is lacking a description. Consider describing all media attachments for the visually impaired before sending your toot.' },
  missingDescriptionConfirm: {  id: 'confirmations.missing_media_description.confirm',
                                defaultMessage: 'Send anyway' },
  spoiler_placeholder: { id: 'compose_form.spoiler_placeholder', defaultMessage: 'Write your warning here' },
});

export default @injectIntl
class ComposeForm extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    intl: PropTypes.object.isRequired,
    text: PropTypes.string,
    suggestions: ImmutablePropTypes.list,
    spoiler: PropTypes.bool,
    privacy: PropTypes.string,
    spoilerText: PropTypes.string,
    focusDate: PropTypes.instanceOf(Date),
    caretPosition: PropTypes.number,
    preselectDate: PropTypes.instanceOf(Date),
    isSubmitting: PropTypes.bool,
    isChangingUpload: PropTypes.bool,
    isUploading: PropTypes.bool,
    onChange: PropTypes.func,
    onSubmit: PropTypes.func,
    onClearSuggestions: PropTypes.func,
    onFetchSuggestions: PropTypes.func,
    onSuggestionSelected: PropTypes.func,
    onChangeSpoilerText: PropTypes.func,
    onPaste: PropTypes.func,
    onPickEmoji: PropTypes.func,
    showSearch: PropTypes.bool,
    anyMedia: PropTypes.bool,
    singleColumn: PropTypes.bool,

    advancedOptions: ImmutablePropTypes.map,
    layout: PropTypes.string,
    media: ImmutablePropTypes.list,
    sideArm: PropTypes.string,
    sensitive: PropTypes.bool,
    spoilersAlwaysOn: PropTypes.bool,
    mediaDescriptionConfirmation: PropTypes.bool,
    preselectOnReply: PropTypes.bool,
    onChangeSpoilerness: PropTypes.func,
    onChangeVisibility: PropTypes.func,
    onPaste: PropTypes.func,
    onMediaDescriptionConfirm: PropTypes.func,
  };

  static defaultProps = {
    showSearch: false,
  };

  handleChange = (e) => {
    this.props.onChange(e.target.value);
  }

  handleKeyDown = ({ ctrlKey, keyCode, metaKey, altKey }) => {
    //  We submit the status on control/meta + enter.
    if (keyCode === 13 && (ctrlKey || metaKey)) {
      this.handleSubmit();
    }

    // Submit the status with secondary visibility on alt + enter.
    if (keyCode === 13 && altKey) {
      this.handleSecondarySubmit();
    }
  }

  handleSubmit = () => {
    const { textarea: { value }, uploadForm } = this;
    const {
      onChange,
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
    if (onChange && text !== value) {
      onChange(value);
    }

    // Submit disabled:
    if (isSubmitting || isUploading || isChangingUpload || (!text.trim().length && !anyMedia)) {
      return;
    }

    // Submit unless there are media with missing descriptions
    if (mediaDescriptionConfirmation && onMediaDescriptionConfirm && media && media.some(item => !item.get('description'))) {
      const firstWithoutDescription = media.find(item => !item.get('description'));
      onMediaDescriptionConfirm(this.context.router ? this.context.router.history : null, firstWithoutDescription.get('id'));
    } else if (onSubmit) {
      onSubmit(this.context.router ? this.context.router.history : null);
    }
  }

  //  Changes the text value of the spoiler.
  handleChangeSpoiler = ({ target: { value } }) => {
    const { onChangeSpoilerText } = this.props;
    if (onChangeSpoilerText) {
      onChangeSpoilerText(value);
    }
  }

  setRef = c => {
    this.composeForm = c;
  };

  //  Inserts an emoji at the caret.
  handleEmoji = (data) => {
    const { textarea: { selectionStart } } = this;
    const { onPickEmoji } = this.props;
    if (onPickEmoji) {
      onPickEmoji(selectionStart, data);
    }
  }

  //  Handles the secondary submit button.
  handleSecondarySubmit = () => {
    const {
      onChangeVisibility,
      sideArm,
    } = this.props;
    if (sideArm !== 'none' && onChangeVisibility) {
      onChangeVisibility(sideArm);
    }
    this.handleSubmit();
  }

  //  Selects a suggestion from the autofill.
  onSuggestionSelected = (tokenStart, token, value) => {
    this.props.onSuggestionSelected(tokenStart, token, value, ['text']);
  }

  onSpoilerSuggestionSelected = (tokenStart, token, value) => {
    this.props.onSuggestionSelected(tokenStart, token, value, ['spoiler_text']);
  }

  //  When the escape key is released, we focus the UI.
  handleKeyUp = ({ key }) => {
    if (key === 'Escape') {
      document.querySelector('.ui').parentElement.focus();
    }
  }

  //  Sets a reference to the textarea.
  setAutosuggestTextarea = (textareaComponent) => {
    if (textareaComponent) {
      this.textarea = textareaComponent.textarea;
    }
  }

  //  Sets a reference to the CW field.
  handleRefSpoilerText = (spoilerComponent) => {
    if (spoilerComponent) {
      this.spoilerText = spoilerComponent.input;
    }
  }

  handleFocus = () => {
    if (this.composeForm && !this.props.singleColumn) {
      const { left, right } = this.composeForm.getBoundingClientRect();
      if (left < 0 || right > (window.innerWidth || document.documentElement.clientWidth)) {
        this.composeForm.scrollIntoView();
      }
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
      singleColumn,
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
        if (!singleColumn) textarea.scrollIntoView();
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
      handleEmoji,
      handleSecondarySubmit,
      handleSelect,
      handleSubmit,
      handleRefTextarea,
    } = this;
    const {
      advancedOptions,
      anyMedia,
      intl,
      isSubmitting,
      isChangingUpload,
      isUploading,
      layout,
      media,
      onChangeSpoilerness,
      onChangeVisibility,
      onClearSuggestions,
      onFetchSuggestions,
      onPaste,
      privacy,
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

    const countText = `${spoilerText}${countableText(text)}${advancedOptions && advancedOptions.get('do_not_federate') ? ' 👁️' : ''}`;

    return (
      <div className='composer'>
        <WarningContainer />

        <ReplyIndicatorContainer />

        <div className={`composer--spoiler ${spoiler ? 'composer--spoiler--visible' : ''}`} ref={this.setRef}>
          <AutosuggestInput
            placeholder={intl.formatMessage(messages.spoiler_placeholder)}
            value={spoilerText}
            onChange={this.handleChangeSpoiler}
            onKeyDown={this.handleKeyDown}
            onKeyUp={this.handleKeyUp}
            disabled={!spoiler}
            ref={this.handleRefSpoilerText}
            suggestions={this.props.suggestions}
            onSuggestionsFetchRequested={onFetchSuggestions}
            onSuggestionsClearRequested={onClearSuggestions}
            onSuggestionSelected={this.onSpoilerSuggestionSelected}
            searchTokens={[':']}
            id='glitch.composer.spoiler.input'
            className='spoiler-input__input'
            autoFocus={false}
          />
        </div>

        <AutosuggestTextarea
          ref={this.setAutosuggestTextarea}
          placeholder={intl.formatMessage(messages.placeholder)}
          disabled={isSubmitting}
          value={this.props.text}
          onChange={this.handleChange}
          suggestions={this.props.suggestions}
          onFocus={this.handleFocus}
          onKeyDown={this.handleKeyDown}
          onSuggestionsFetchRequested={onFetchSuggestions}
          onSuggestionsClearRequested={onClearSuggestions}
          onSuggestionSelected={this.onSuggestionSelected}
          onPaste={onPaste}
          autoFocus={!showSearch && !isMobile(window.innerWidth, layout)}
        >
          <EmojiPicker onPickEmoji={handleEmoji} />
          <TextareaIcons advancedOptions={advancedOptions} />
          <div className='compose-form__modifiers'>
            <UploadFormContainer />
            <PollFormContainer />
          </div>
        </AutosuggestTextarea>

        <div className='composer--options-wrapper'>
          <OptionsContainer
            advancedOptions={advancedOptions}
            disabled={isSubmitting}
            onChangeVisibility={onChangeVisibility}
            onToggleSpoiler={spoilersAlwaysOn ? null : onChangeSpoilerness}
            onUpload={onPaste}
            privacy={privacy}
            sensitive={sensitive || (spoilersAlwaysOn && spoilerText && spoilerText.length > 0)}
            spoiler={spoilersAlwaysOn ? (spoilerText && spoilerText.length > 0) : spoiler}
          />
          <div className='compose--counter-wrapper'>
            <CharacterCounter text={countText} max={maxChars} />
          </div>
        </div>

        <Publisher
          countText={countText}
          disabled={disabledButton}
          onSecondarySubmit={handleSecondarySubmit}
          onSubmit={handleSubmit}
          privacy={privacy}
          sideArm={sideArm}
        />
      </div>
    );
  }

}

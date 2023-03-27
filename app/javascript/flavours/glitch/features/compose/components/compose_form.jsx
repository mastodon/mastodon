import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import ReplyIndicatorContainer from '../containers/reply_indicator_container';
import AutosuggestTextarea from '../../../components/autosuggest_textarea';
import AutosuggestInput from '../../../components/autosuggest_input';
import { defineMessages, injectIntl } from 'react-intl';
import EmojiPickerDropdown from '../containers/emoji_picker_dropdown_container';
import PollFormContainer from '../containers/poll_form_container';
import UploadFormContainer from '../containers/upload_form_container';
import WarningContainer from '../containers/warning_container';
import { isMobile } from 'flavours/glitch/is_mobile';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { countableText } from '../util/counter';
import OptionsContainer from '../containers/options_container';
import Publisher from './publisher';
import TextareaIcons from './textarea_icons';
import { maxChars } from 'flavours/glitch/initial_state';
import CharacterCounter from './character_counter';
import { length } from 'stringz';

const messages = defineMessages({
  placeholder: { id: 'compose_form.placeholder', defaultMessage: 'What is on your mind?' },
  missingDescriptionMessage: {
    id: 'confirmations.missing_media_description.message',
    defaultMessage: 'At least one media attachment is lacking a description. Consider describing all media attachments for the visually impaired before sending your toot.',
  },
  missingDescriptionConfirm: {
    id: 'confirmations.missing_media_description.confirm',
    defaultMessage: 'Send anyway',
  },
  spoiler_placeholder: { id: 'compose_form.spoiler_placeholder', defaultMessage: 'Write your warning here' },
});

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
    isEditing: PropTypes.bool,
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
    isInReply: PropTypes.bool,
    singleColumn: PropTypes.bool,
    lang: PropTypes.string,

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
  };

  getFulltextForCharacterCounting = () => {
    return [
      this.props.spoiler? this.props.spoilerText: '',
      countableText(this.props.text),
      this.props.advancedOptions && this.props.advancedOptions.get('do_not_federate') ? ' 👁️' : '',
    ].join('');
  };

  canSubmit = () => {
    const { isSubmitting, isChangingUpload, isUploading, anyMedia } = this.props;
    const fulltext = this.getFulltextForCharacterCounting();

    return !(isSubmitting || isUploading || isChangingUpload || length(fulltext) > maxChars || (!fulltext.trim().length && !anyMedia));
  };

  handleSubmit = (overriddenVisibility = null) => {
    const {
      onSubmit,
      media,
      mediaDescriptionConfirmation,
      onMediaDescriptionConfirm,
      onChangeVisibility,
    } = this.props;

    if (this.props.text !== this.textarea.value) {
      // Something changed the text inside the textarea (e.g. browser extensions like Grammarly)
      // Update the state to match the current text
      this.props.onChange(this.textarea.value);
    }

    if (!this.canSubmit()) {
      return;
    }

    // Submit unless there are media with missing descriptions
    if (mediaDescriptionConfirmation && onMediaDescriptionConfirm && media && media.some(item => !item.get('description'))) {
      const firstWithoutDescription = media.find(item => !item.get('description'));
      onMediaDescriptionConfirm(this.context.router ? this.context.router.history : null, firstWithoutDescription.get('id'), overriddenVisibility);
    } else if (onSubmit) {
      if (onChangeVisibility && overriddenVisibility) {
        onChangeVisibility(overriddenVisibility);
      }
      onSubmit(this.context.router ? this.context.router.history : null);
    }
  };

  //  Changes the text value of the spoiler.
  handleChangeSpoiler = ({ target: { value } }) => {
    const { onChangeSpoilerText } = this.props;
    if (onChangeSpoilerText) {
      onChangeSpoilerText(value);
    }
  };

  setRef = c => {
    this.composeForm = c;
  };

  //  Inserts an emoji at the caret.
  handleEmojiPick = (data) => {
    const { textarea: { selectionStart } } = this;
    const { onPickEmoji } = this.props;
    if (onPickEmoji) {
      onPickEmoji(selectionStart, data);
    }
  };

  //  Handles the secondary submit button.
  handleSecondarySubmit = () => {
    const {
      sideArm,
    } = this.props;
    this.handleSubmit(sideArm === 'none' ? null : sideArm);
  };

  //  Selects a suggestion from the autofill.
  onSuggestionSelected = (tokenStart, token, value) => {
    this.props.onSuggestionSelected(tokenStart, token, value, ['text']);
  };

  onSpoilerSuggestionSelected = (tokenStart, token, value) => {
    this.props.onSuggestionSelected(tokenStart, token, value, ['spoiler_text']);
  };

  handleKeyDown = (e) => {
    if (e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
      this.handleSubmit();
    }

    if (e.keyCode == 13 && e.altKey) {
      this.handleSecondarySubmit();
    }
  };

  //  Sets a reference to the textarea.
  setAutosuggestTextarea = (textareaComponent) => {
    if (textareaComponent) {
      this.textarea = textareaComponent.textarea;
    }
  };

  //  Sets a reference to the CW field.
  handleRefSpoilerText = (spoilerComponent) => {
    if (spoilerComponent) {
      this.spoilerText = spoilerComponent.input;
    }
  };

  handleFocus = () => {
    if (this.composeForm && !this.props.singleColumn) {
      const { left, right } = this.composeForm.getBoundingClientRect();
      if (left < 0 || right > (window.innerWidth || document.documentElement.clientWidth)) {
        this.composeForm.scrollIntoView();
      }
    }
  };

  componentDidMount () {
    this._updateFocusAndSelection({ });
  }

  componentDidUpdate (prevProps) {
    this._updateFocusAndSelection(prevProps);
  }

  //  This statement does several things:
  //  - If we're beginning a reply, and,
  //      - Replying to zero or one users, places the cursor at the end
  //        of the textbox.
  //      - Replying to more than one user, selects any usernames past
  //        the first; this provides a convenient shortcut to drop
  //        everyone else from the conversation.
  _updateFocusAndSelection = (prevProps) => {
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
      case preselectDate !== prevProps.preselectDate && this.props.isInReply && preselectOnReply:
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
        // Because of the wicg-inert polyfill, the activeElement may not be
        // immediately selectable, we have to wait for observers to run, as
        // described in https://github.com/WICG/inert#performance-and-gotchas
        Promise.resolve().then(() => {
          textarea.setSelectionRange(selectionStart, selectionEnd);
          textarea.focus();
          if (!singleColumn) textarea.scrollIntoView();
        }).catch(console.error);
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
  };


  render () {
    const {
      handleEmojiPick,
      handleSecondarySubmit,
      handleSelect,
      handleSubmit,
      handleRefTextarea,
    } = this;
    const {
      advancedOptions,
      intl,
      isSubmitting,
      layout,
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
      spoilersAlwaysOn,
      isEditing,
    } = this.props;

    const countText = this.getFulltextForCharacterCounting();

    return (
      <div className='compose-form'>
        <WarningContainer />

        <ReplyIndicatorContainer />

        <div className={`spoiler-input ${spoiler ? 'spoiler-input--visible' : ''}`} ref={this.setRef} aria-hidden={!this.props.spoiler}>
          <AutosuggestInput
            placeholder={intl.formatMessage(messages.spoiler_placeholder)}
            value={spoilerText}
            onChange={this.handleChangeSpoiler}
            onKeyDown={this.handleKeyDown}
            disabled={!spoiler}
            ref={this.handleRefSpoilerText}
            suggestions={this.props.suggestions}
            onSuggestionsFetchRequested={onFetchSuggestions}
            onSuggestionsClearRequested={onClearSuggestions}
            onSuggestionSelected={this.onSpoilerSuggestionSelected}
            searchTokens={[':']}
            id='glitch.composer.spoiler.input'
            className='spoiler-input__input'
            lang={this.props.lang}
            autoFocus={false}
            spellCheck
          />
        </div>

        <AutosuggestTextarea
          ref={this.setAutosuggestTextarea}
          placeholder={intl.formatMessage(messages.placeholder)}
          disabled={isSubmitting}
          value={this.props.text}
          onChange={this.handleChange}
          onKeyDown={this.handleKeyDown}
          suggestions={this.props.suggestions}
          onFocus={this.handleFocus}
          onSuggestionsFetchRequested={onFetchSuggestions}
          onSuggestionsClearRequested={onClearSuggestions}
          onSuggestionSelected={this.onSuggestionSelected}
          onPaste={onPaste}
          autoFocus={!showSearch && !isMobile(window.innerWidth, layout)}
          lang={this.props.lang}
        >
          <EmojiPickerDropdown onPickEmoji={handleEmojiPick} />
          <TextareaIcons advancedOptions={advancedOptions} />
          <div className='compose-form__modifiers'>
            <UploadFormContainer />
            <PollFormContainer />
          </div>
        </AutosuggestTextarea>

        <div className='compose-form__buttons-wrapper'>
          <OptionsContainer
            advancedOptions={advancedOptions}
            disabled={isSubmitting}
            onToggleSpoiler={spoilersAlwaysOn ? null : onChangeSpoilerness}
            onUpload={onPaste}
            isEditing={isEditing}
            sensitive={sensitive || (spoilersAlwaysOn && spoilerText && spoilerText.length > 0)}
            spoiler={spoilersAlwaysOn ? (spoilerText && spoilerText.length > 0) : spoiler}
          />
          <div className='character-counter__wrapper'>
            <CharacterCounter text={countText} max={maxChars} />
          </div>
        </div>

        <Publisher
          countText={countText}
          disabled={!this.canSubmit()}
          isEditing={isEditing}
          onSecondarySubmit={handleSecondarySubmit}
          onSubmit={handleSubmit}
          privacy={privacy}
          sideArm={sideArm}
        />
      </div>
    );
  }

}

export default injectIntl(ComposeForm);

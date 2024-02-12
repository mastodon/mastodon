import PropTypes from 'prop-types';
import { createRef } from 'react';

import { defineMessages, injectIntl } from 'react-intl';

import classNames from 'classnames';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { length } from 'stringz';

import { maxChars } from 'flavours/glitch/initial_state';
import { isMobile } from 'flavours/glitch/is_mobile';
import { WithOptionalRouterPropTypes, withOptionalRouter } from 'flavours/glitch/utils/react_router';

import AutosuggestInput from '../../../components/autosuggest_input';
import AutosuggestTextarea from '../../../components/autosuggest_textarea';
import EmojiPickerDropdown from '../containers/emoji_picker_dropdown_container';
import OptionsContainer from '../containers/options_container';
import PollFormContainer from '../containers/poll_form_container';
import ReplyIndicatorContainer from '../containers/reply_indicator_container';
import UploadFormContainer from '../containers/upload_form_container';
import WarningContainer from '../containers/warning_container';
import { countableText } from '../util/counter';

import CharacterCounter from './character_counter';
import Publisher from './publisher';
import TextareaIcons from './textarea_icons';

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
  static propTypes = {
    intl: PropTypes.object.isRequired,
    text: PropTypes.string.isRequired,
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
    onChange: PropTypes.func.isRequired,
    onSubmit: PropTypes.func.isRequired,
    onClearSuggestions: PropTypes.func.isRequired,
    onFetchSuggestions: PropTypes.func.isRequired,
    onSuggestionSelected: PropTypes.func.isRequired,
    onChangeSpoilerText: PropTypes.func.isRequired,
    onPaste: PropTypes.func.isRequired,
    onPickEmoji: PropTypes.func.isRequired,
    showSearch: PropTypes.bool,
    anyMedia: PropTypes.bool,
    isInReply: PropTypes.bool,
    singleColumn: PropTypes.bool,
    lang: PropTypes.string,
    advancedOptions: ImmutablePropTypes.map,
    media: ImmutablePropTypes.list,
    sideArm: PropTypes.string,
    sensitive: PropTypes.bool,
    spoilersAlwaysOn: PropTypes.bool,
    mediaDescriptionConfirmation: PropTypes.bool,
    preselectOnReply: PropTypes.bool,
    onChangeSpoilerness: PropTypes.func.isRequired,
    onChangeVisibility: PropTypes.func.isRequired,
    onMediaDescriptionConfirm: PropTypes.func.isRequired,
    ...WithOptionalRouterPropTypes
  };

  static defaultProps = {
    showSearch: false,
  };

  state = {
    highlighted: false,
  };

  constructor(props) {
    super(props);
    this.textareaRef = createRef(null);
  }

  handleChange = (e) => {
    this.props.onChange(e.target.value);
  };

  handleKeyDown = (e) => {
    if (e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
      this.handleSubmit();
    }

    if (e.keyCode === 13 && e.altKey) {
      this.handleSecondarySubmit();
    }
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

  handleSubmit = (e, overriddenVisibility = null) => {
    if (this.props.text !== this.textareaRef.current.value) {
      // Something changed the text inside the textarea (e.g. browser extensions like Grammarly)
      // Update the state to match the current text
      this.props.onChange(this.textareaRef.current.value);
    }

    if (!this.canSubmit()) {
      return;
    }

    if (e) {
      e.preventDefault();
    }

    // Submit unless there are media with missing descriptions
    if (this.props.mediaDescriptionConfirmation && this.props.media && this.props.media.some(item => !item.get('description'))) {
      const firstWithoutDescription = this.props.media.find(item => !item.get('description'));
      this.props.onMediaDescriptionConfirm(this.props.history || null, firstWithoutDescription.get('id'), overriddenVisibility);
    } else {
      if (overriddenVisibility) {
        this.props.onChangeVisibility(overriddenVisibility);
      }
      this.props.onSubmit(this.props.history || null);
    }
  };

  //  Handles the secondary submit button.
  handleSecondarySubmit = () => {
    const { sideArm } = this.props;
    this.handleSubmit(null, sideArm === 'none' ? null : sideArm);
  };

  onSuggestionsClearRequested = () => {
    this.props.onClearSuggestions();
  };

  onSuggestionsFetchRequested = (token) => {
    this.props.onFetchSuggestions(token);
  };

  onSuggestionSelected = (tokenStart, token, value) => {
    this.props.onSuggestionSelected(tokenStart, token, value, ['text']);
  };

  onSpoilerSuggestionSelected = (tokenStart, token, value) => {
    this.props.onSuggestionSelected(tokenStart, token, value, ['spoiler_text']);
  };

  handleChangeSpoilerText = (e) => {
    this.props.onChangeSpoilerText(e.target.value);
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

  componentWillUnmount () {
    if (this.timeout) clearTimeout(this.timeout);
  }

  componentDidUpdate (prevProps) {
    this._updateFocusAndSelection(prevProps);
  }

  _updateFocusAndSelection = (prevProps) => {
    // This statement does several things:
    // - If we're beginning a reply, and,
    //     - Replying to zero or one users, places the cursor at the end of the textbox.
    //     - Replying to more than one user, selects any usernames past the first;
    //       this provides a convenient shortcut to drop everyone else from the conversation.
    if (this.props.focusDate && this.props.focusDate !== prevProps.focusDate) {
      let selectionEnd, selectionStart;

      if (this.props.preselectDate !== prevProps.preselectDate && this.props.isInReply && this.props.preselectOnReply) {
        selectionEnd   = this.props.text.length;
        selectionStart = this.props.text.search(/\s/) + 1;
      } else if (typeof this.props.caretPosition === 'number') {
        selectionStart = this.props.caretPosition;
        selectionEnd   = this.props.caretPosition;
      } else {
        selectionEnd   = this.props.text.length;
        selectionStart = selectionEnd;
      }

      // Because of the wicg-inert polyfill, the activeElement may not be
      // immediately selectable, we have to wait for observers to run, as
      // described in https://github.com/WICG/inert#performance-and-gotchas
      Promise.resolve().then(() => {
        this.textareaRef.current.setSelectionRange(selectionStart, selectionEnd);
        this.textareaRef.current.focus();
        if (!this.props.singleColumn) this.textareaRef.current.scrollIntoView();
        this.setState({ highlighted: true });
        this.timeout = setTimeout(() => this.setState({ highlighted: false }), 700);
      }).catch(console.error);
    } else if(prevProps.isSubmitting && !this.props.isSubmitting) {
      this.textareaRef.current.focus();
    } else if (this.props.spoiler !== prevProps.spoiler) {
      if (this.props.spoiler) {
        this.spoilerText.input.focus();
      } else if (prevProps.spoiler) {
        this.textareaRef.current.focus();
      }
    }
  };

  setSpoilerText = (c) => {
    this.spoilerText = c;
  };

  setRef = c => {
    this.composeForm = c;
  };

  handleEmojiPick = (data) => {
    const position = this.textareaRef.current.selectionStart;

    this.props.onPickEmoji(position, data);
  };

  render () {
    const {
      intl,
      advancedOptions,
      isSubmitting,
      onChangeSpoilerness,
      onPaste,
      privacy,
      sensitive,
      showSearch,
      sideArm,
      spoilersAlwaysOn,
      isEditing,
    } = this.props;
    const { highlighted } = this.state;
    const disabled = this.props.isSubmitting;

    return (
      <form className='compose-form' onSubmit={this.handleSubmit}>
        <WarningContainer />

        <ReplyIndicatorContainer />

        <div className={`spoiler-input ${this.props.spoiler ? 'spoiler-input--visible' : ''}`} ref={this.setRef} aria-hidden={!this.props.spoiler}>
          <AutosuggestInput
            placeholder={intl.formatMessage(messages.spoiler_placeholder)}
            value={this.props.spoilerText}
            onChange={this.handleChangeSpoilerText}
            onKeyDown={this.handleKeyDown}
            disabled={!this.props.spoiler}
            ref={this.setSpoilerText}
            suggestions={this.props.suggestions}
            onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
            onSuggestionsClearRequested={this.onSuggestionsClearRequested}
            onSuggestionSelected={this.onSpoilerSuggestionSelected}
            searchTokens={[':']}
            id='cw-spoiler-input'
            className='spoiler-input__input'
            lang={this.props.lang}
            autoFocus={false}
            spellCheck
          />
        </div>

        <div className={classNames('compose-form__highlightable', { active: highlighted })}>
          <AutosuggestTextarea
            ref={this.textareaRef}
            placeholder={intl.formatMessage(messages.placeholder)}
            disabled={disabled}
            value={this.props.text}
            onChange={this.handleChange}
            suggestions={this.props.suggestions}
            onFocus={this.handleFocus}
            onKeyDown={this.handleKeyDown}
            onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
            onSuggestionsClearRequested={this.onSuggestionsClearRequested}
            onSuggestionSelected={this.onSuggestionSelected}
            onPaste={onPaste}
            autoFocus={!showSearch && !isMobile(window.innerWidth)}
            lang={this.props.lang}
          >
            <TextareaIcons advancedOptions={advancedOptions} />
            <div className='compose-form__modifiers'>
              <UploadFormContainer />
              <PollFormContainer />
            </div>
          </AutosuggestTextarea>
          <EmojiPickerDropdown onPickEmoji={this.handleEmojiPick} />

          <div className='compose-form__buttons-wrapper'>
            <OptionsContainer
              advancedOptions={advancedOptions}
              disabled={isSubmitting}
              onToggleSpoiler={this.props.spoilersAlwaysOn ? null : onChangeSpoilerness}
              onUpload={onPaste}
              isEditing={isEditing}
              sensitive={sensitive || (spoilersAlwaysOn && this.props.spoilerText && this.props.spoilerText.length > 0)}
              spoiler={spoilersAlwaysOn ? (this.props.spoilerText && this.props.spoilerText.length > 0) : this.props.spoiler}
            />
            <div className='character-counter__wrapper'>
              <CharacterCounter max={maxChars} text={this.getFulltextForCharacterCounting()} />
            </div>
          </div>
        </div>

        <Publisher
          disabled={!this.canSubmit()}
          isEditing={isEditing}
          onSecondarySubmit={this.handleSecondarySubmit}
          privacy={privacy}
          sideArm={sideArm}
        />
      </form>
    );
  }

}

export default withOptionalRouter(injectIntl(ComposeForm));

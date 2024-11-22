import PropTypes from 'prop-types';
import { createRef } from 'react';

import { defineMessages, injectIntl } from 'react-intl';

import classNames from 'classnames';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { length } from 'stringz';

import AutosuggestInput from '../../../components/autosuggest_input';
import AutosuggestTextarea from '../../../components/autosuggest_textarea';
import { Button } from '../../../components/button';
import EmojiPickerDropdown from '../containers/emoji_picker_dropdown_container';
import LanguageDropdown from '../containers/language_dropdown_container';
import PollButtonContainer from '../containers/poll_button_container';
import PrivacyDropdownContainer from '../containers/privacy_dropdown_container';
import SpoilerButtonContainer from '../containers/spoiler_button_container';
import UploadButtonContainer from '../containers/upload_button_container';
import WarningContainer from '../containers/warning_container';
import { countableText } from '../util/counter';

import { CharacterCounter } from './character_counter';
import { EditIndicator } from './edit_indicator';
import { NavigationBar } from './navigation_bar';
import { PollForm } from "./poll_form";
import { ReplyIndicator } from './reply_indicator';
import { UploadForm } from './upload_form';

const allowedAroundShortCode = '><\u0085\u0020\u00a0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200a\u202f\u205f\u3000\u2028\u2029\u0009\u000a\u000b\u000c\u000d';

const messages = defineMessages({
  placeholder: { id: 'compose_form.placeholder', defaultMessage: 'What is on your mind?' },
  spoiler_placeholder: { id: 'compose_form.spoiler_placeholder', defaultMessage: 'Content warning (optional)' },
  publish: { id: 'compose_form.publish', defaultMessage: 'Post' },
  saveChanges: { id: 'compose_form.save_changes', defaultMessage: 'Update' },
  reply: { id: 'compose_form.reply', defaultMessage: 'Reply' },
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
    autoFocus: PropTypes.bool,
    withoutNavigation: PropTypes.bool,
    anyMedia: PropTypes.bool,
    isInReply: PropTypes.bool,
    singleColumn: PropTypes.bool,
    lang: PropTypes.string,
    maxChars: PropTypes.number,
  };

  static defaultProps = {
    autoFocus: false,
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
  };

  getFulltextForCharacterCounting = () => {
    return [this.props.spoiler? this.props.spoilerText: '', countableText(this.props.text)].join('');
  };

  canSubmit = () => {
    const { isSubmitting, isChangingUpload, isUploading, anyMedia, maxChars } = this.props;
    const fulltext = this.getFulltextForCharacterCounting();
    const isOnlyWhitespace = fulltext.length !== 0 && fulltext.trim().length === 0;

    return !(isSubmitting || isUploading || isChangingUpload || length(fulltext) > maxChars || (isOnlyWhitespace && !anyMedia));
  };

  handleSubmit = (e) => {
    if (this.props.text !== this.textareaRef.current.value) {
      // Something changed the text inside the textarea (e.g. browser extensions like Grammarly)
      // Update the state to match the current text
      this.props.onChange(this.textareaRef.current.value);
    }

    if (!this.canSubmit()) {
      return;
    }

    this.props.onSubmit();

    if (e) {
      e.preventDefault();
    }
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

      if (this.props.preselectDate !== prevProps.preselectDate && this.props.isInReply) {
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
    const { text }     = this.props;
    const position     = this.textareaRef.current.selectionStart;
    const needsSpace   = data.custom && position > 0 && !allowedAroundShortCode.includes(text[position - 1]);

    this.props.onPickEmoji(position, data, needsSpace);
  };

  render () {
    const { intl, onPaste, autoFocus, withoutNavigation, maxChars } = this.props;
    const { highlighted } = this.state;
    const disabled = this.props.isSubmitting;

    return (
      <form className='compose-form' onSubmit={this.handleSubmit}>
        <ReplyIndicator />
        {!withoutNavigation && <NavigationBar />}
        <WarningContainer />

        <div className={classNames('compose-form__highlightable', { active: highlighted })} ref={this.setRef}>
          <div className='compose-form__scrollable'>
            <EditIndicator />

            {this.props.spoiler && (
              <div className='spoiler-input'>
                <div className='spoiler-input__border' />

                <AutosuggestInput
                  placeholder={intl.formatMessage(messages.spoiler_placeholder)}
                  value={this.props.spoilerText}
                  disabled={disabled}
                  onChange={this.handleChangeSpoilerText}
                  onKeyDown={this.handleKeyDown}
                  ref={this.setSpoilerText}
                  suggestions={this.props.suggestions}
                  onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
                  onSuggestionsClearRequested={this.onSuggestionsClearRequested}
                  onSuggestionSelected={this.onSpoilerSuggestionSelected}
                  searchTokens={[':']}
                  id='cw-spoiler-input'
                  className='spoiler-input__input'
                  lang={this.props.lang}
                  spellCheck
                />

                <div className='spoiler-input__border' />
              </div>
            )}

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
              autoFocus={autoFocus}
              lang={this.props.lang}
            />
          </div>

          <UploadForm />
          <PollForm />

          <div className='compose-form__footer'>
            <div className='compose-form__dropdowns'>
              <PrivacyDropdownContainer disabled={this.props.isEditing} />
              <LanguageDropdown />
            </div>

            <div className='compose-form__actions'>
              <div className='compose-form__buttons'>
                <UploadButtonContainer />
                <PollButtonContainer />
                <SpoilerButtonContainer />
                <EmojiPickerDropdown onPickEmoji={this.handleEmojiPick} />
                <CharacterCounter max={maxChars} text={this.getFulltextForCharacterCounting()} />
              </div>

              <div className='compose-form__submit'>
                <Button
                  type='submit'
                  text={intl.formatMessage(this.props.isEditing ? messages.saveChanges : (this.props.isInReply ? messages.reply : messages.publish))}
                  disabled={!this.canSubmit()}
                />
              </div>
            </div>
          </div>
        </div>
      </form>
    );
  }

}

export default injectIntl(ComposeForm);

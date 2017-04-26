import CharacterCounter from './character_counter';
import Button from '../../../components/button';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import ReplyIndicatorContainer from '../containers/reply_indicator_container';
import AutosuggestTextarea from '../../../components/autosuggest_textarea';
import { debounce } from 'react-decoration';
import UploadButtonContainer from '../containers/upload_button_container';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import Toggle from 'react-toggle';
import Collapsable from '../../../components/collapsable';
import SpoilerButtonContainer from '../containers/spoiler_button_container';
import PrivacyDropdownContainer from '../containers/privacy_dropdown_container';
import SensitiveButtonContainer from '../containers/sensitive_button_container';
import EmojiPickerDropdown from './emoji_picker_dropdown';
import UploadFormContainer from '../containers/upload_form_container';
import TextIconButton from './text_icon_button';
import WarningContainer from '../containers/warning_container';

const messages = defineMessages({
  placeholder: { id: 'compose_form.placeholder', defaultMessage: 'What is on your mind?' },
  spoiler_placeholder: { id: 'compose_form.spoiler_placeholder', defaultMessage: 'Content warning' },
  publish: { id: 'compose_form.publish', defaultMessage: 'Toot' }
});

class ComposeForm extends React.PureComponent {

  constructor (props, context) {
    super(props, context);
    this.handleChange = this.handleChange.bind(this);
    this.handleKeyDown = this.handleKeyDown.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.onSuggestionsClearRequested = this.onSuggestionsClearRequested.bind(this);
    this.onSuggestionsFetchRequested = this.onSuggestionsFetchRequested.bind(this);
    this.onSuggestionSelected = this.onSuggestionSelected.bind(this);
    this.handleChangeSpoilerText = this.handleChangeSpoilerText.bind(this);
    this.setAutosuggestTextarea = this.setAutosuggestTextarea.bind(this);
    this.handleEmojiPick = this.handleEmojiPick.bind(this);
  }

  handleChange (e) {
    this.props.onChange(e.target.value);
  }

  handleKeyDown (e) {
    if (e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
      this.props.onSubmit();
    }
  }

  handleSubmit () {
    this.autosuggestTextarea.textarea.style.height = "auto";
    this.props.onSubmit();
  }

  onSuggestionsClearRequested () {
    this.props.onClearSuggestions();
  }

  @debounce(500)
  onSuggestionsFetchRequested (token) {
    this.props.onFetchSuggestions(token);
  }

  onSuggestionSelected (tokenStart, token, value) {
    this._restoreCaret = null;
    this.props.onSuggestionSelected(tokenStart, token, value);
  }

  handleChangeSpoilerText (e) {
    this.props.onChangeSpoilerText(e.target.value);
  }

  componentWillReceiveProps (nextProps) {
    // If this is the update where we've finished uploading,
    // save the last caret position so we can restore it below!
    if (!nextProps.is_uploading && this.props.is_uploading) {
      this._restoreCaret = this.autosuggestTextarea.textarea.selectionStart;
    }
  }

  componentDidUpdate (prevProps) {
    // This statement does several things:
    // - If we're beginning a reply, and,
    //     - Replying to zero or one users, places the cursor at the end of the textbox.
    //     - Replying to more than one user, selects any usernames past the first;
    //       this provides a convenient shortcut to drop everyone else from the conversation.
    // - If we've just finished uploading an image, and have a saved caret position,
    //   restores the cursor to that position after the text changes!
    if (this.props.focusDate !== prevProps.focusDate || (prevProps.is_uploading && !this.props.is_uploading && typeof this._restoreCaret === 'number')) {
      let selectionEnd, selectionStart;

      if (this.props.preselectDate !== prevProps.preselectDate) {
        selectionEnd   = this.props.text.length;
        selectionStart = this.props.text.search(/\s/) + 1;
      } else if (typeof this._restoreCaret === 'number') {
        selectionStart = this._restoreCaret;
        selectionEnd   = this._restoreCaret;
      } else {
        selectionEnd   = this.props.text.length;
        selectionStart = selectionEnd;
      }

      this.autosuggestTextarea.textarea.setSelectionRange(selectionStart, selectionEnd);
      this.autosuggestTextarea.textarea.focus();
    }
  }

  setAutosuggestTextarea (c) {
    this.autosuggestTextarea = c;
  }

  handleEmojiPick (data) {
    const position     = this.autosuggestTextarea.textarea.selectionStart;
    this._restoreCaret = position + data.shortname.length + 1;
    this.props.onPickEmoji(position, data);
  }

  render () {
    const { intl, onPaste } = this.props;
    const disabled = this.props.is_submitting;
    const text = [this.props.spoiler_text, this.props.text].join('');

    let publishText    = '';
    let reply_to_other = false;

    if (this.props.privacy === 'private' || this.props.privacy === 'direct') {
      publishText = <span className='compose-form__publish-private'><i className='fa fa-lock' /> {intl.formatMessage(messages.publish)}</span>;
    } else {
      publishText = intl.formatMessage(messages.publish) + (this.props.privacy !== 'unlisted' ? '!' : '');
    }

    return (
      <div className='compose-form'>
        <Collapsable isVisible={this.props.spoiler} fullHeight={50}>
          <div className="spoiler-input">
            <input placeholder={intl.formatMessage(messages.spoiler_placeholder)} value={this.props.spoiler_text} onChange={this.handleChangeSpoilerText} onKeyDown={this.handleKeyDown} type="text" className="spoiler-input__input"  id='cw-spoiler-input'/>
          </div>
        </Collapsable>

        <WarningContainer />

        <ReplyIndicatorContainer />

        <div className='compose-form__autosuggest-wrapper'>
          <AutosuggestTextarea
            ref={this.setAutosuggestTextarea}
            placeholder={intl.formatMessage(messages.placeholder)}
            disabled={disabled}
            value={this.props.text}
            onChange={this.handleChange}
            suggestions={this.props.suggestions}
            onKeyDown={this.handleKeyDown}
            onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
            onSuggestionsClearRequested={this.onSuggestionsClearRequested}
            onSuggestionSelected={this.onSuggestionSelected}
            onPaste={onPaste}
          />

          <EmojiPickerDropdown onPickEmoji={this.handleEmojiPick} />
        </div>

        <div className='compose-form__modifiers'>
          <UploadFormContainer />
        </div>

        <div className='compose-form__buttons-wrapper'>
          <div className='compose-form__buttons'>
            <UploadButtonContainer />
            <PrivacyDropdownContainer />
            <SensitiveButtonContainer />
            <SpoilerButtonContainer />
          </div>

          <div className='compose-form__publish'>
            <div className='character-counter__wrapper'><CharacterCounter max={500} text={text} /></div>
            <div className='compose-form__publish-button-wrapper'><Button text={publishText} onClick={this.handleSubmit} disabled={disabled || text.replace(/[\uD800-\uDBFF][\uDC00-\uDFFF]/g, "_").length > 500 || (text.length !==0 && text.trim().length === 0)} block /></div>
          </div>
        </div>
      </div>
    );
  }

}

ComposeForm.propTypes = {
  intl: PropTypes.object.isRequired,
  text: PropTypes.string.isRequired,
  suggestion_token: PropTypes.string,
  suggestions: ImmutablePropTypes.list,
  spoiler: PropTypes.bool,
  privacy: PropTypes.string,
  spoiler_text: PropTypes.string,
  focusDate: PropTypes.instanceOf(Date),
  preselectDate: PropTypes.instanceOf(Date),
  is_submitting: PropTypes.bool,
  is_uploading: PropTypes.bool,
  me: PropTypes.number,
  onChange: PropTypes.func.isRequired,
  onSubmit: PropTypes.func.isRequired,
  onClearSuggestions: PropTypes.func.isRequired,
  onFetchSuggestions: PropTypes.func.isRequired,
  onSuggestionSelected: PropTypes.func.isRequired,
  onChangeSpoilerText: PropTypes.func.isRequired,
  onPaste: PropTypes.func.isRequired,
  onPickEmoji: PropTypes.func.isRequired
};

export default injectIntl(ComposeForm);

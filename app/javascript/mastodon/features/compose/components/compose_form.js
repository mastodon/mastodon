import React from 'react';
import CharacterCounter from './character_counter';
import Button from '../../../components/button';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import ReplyIndicatorContainer from '../containers/reply_indicator_container';
import AutosuggestTextarea from '../../../components/autosuggest_textarea';
import { defineMessages, injectIntl } from 'react-intl';
import Collapsable from '../../../components/collapsable';
import SpoilerButtonContainer from '../containers/spoiler_button_container';
import PrivacyDropdownContainer from '../containers/privacy_dropdown_container';
import ComposeAdvancedOptionsContainer from '../../../../glitch/components/compose/advanced_options/container';
import SensitiveButtonContainer from '../containers/sensitive_button_container';
import EmojiPickerDropdown from '../containers/emoji_picker_dropdown_container';
import UploadFormContainer from '../containers/upload_form_container';
import WarningContainer from '../containers/warning_container';
import { isMobile } from '../../../is_mobile';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { length } from 'stringz';
import { countableText } from '../util/counter';
import ComposeAttachOptions from '../../../../glitch/components/compose/attach_options/index';

const messages = defineMessages({
  placeholder: { id: 'compose_form.placeholder', defaultMessage: 'What is on your mind?' },
  spoiler_placeholder: { id: 'compose_form.spoiler_placeholder', defaultMessage: 'Write your warning here' },
  publish: { id: 'compose_form.publish', defaultMessage: 'Toot' },
  publishLoud: { id: 'compose_form.publish_loud', defaultMessage: '{publish}!' },
});

@injectIntl
export default class ComposeForm extends ImmutablePureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    text: PropTypes.string.isRequired,
    suggestion_token: PropTypes.string,
    suggestions: ImmutablePropTypes.list,
    spoiler: PropTypes.bool,
    privacy: PropTypes.string,
    advanced_options: ImmutablePropTypes.contains({
      do_not_federate: PropTypes.bool,
    }),
    spoiler_text: PropTypes.string,
    focusDate: PropTypes.instanceOf(Date),
    preselectDate: PropTypes.instanceOf(Date),
    is_submitting: PropTypes.bool,
    is_uploading: PropTypes.bool,
    onChange: PropTypes.func.isRequired,
    onSubmit: PropTypes.func.isRequired,
    onClearSuggestions: PropTypes.func.isRequired,
    onFetchSuggestions: PropTypes.func.isRequired,
    onPrivacyChange: PropTypes.func.isRequired,
    onSuggestionSelected: PropTypes.func.isRequired,
    onChangeSpoilerText: PropTypes.func.isRequired,
    onPaste: PropTypes.func.isRequired,
    onPickEmoji: PropTypes.func.isRequired,
    showSearch: PropTypes.bool,
    settings : ImmutablePropTypes.map.isRequired,
  };

  static defaultProps = {
    showSearch: false,
  };

  handleChange = (e) => {
    this.props.onChange(e.target.value);
  }

  handleKeyDown = (e) => {
    if (e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
      this.handleSubmit();
    }
  }

  handleSubmit2 = () => {
    this.props.onPrivacyChange(this.props.settings.get('side_arm'));
    this.handleSubmit();
  }

  handleSubmit = () => {
    if (this.props.text !== this.autosuggestTextarea.textarea.value) {
      // Something changed the text inside the textarea (e.g. browser extensions like Grammarly)
      // Update the state to match the current text
      this.props.onChange(this.autosuggestTextarea.textarea.value);
    }

    this.props.onSubmit();
  }

  onSuggestionsClearRequested = () => {
    this.props.onClearSuggestions();
  }

  onSuggestionsFetchRequested = (token) => {
    this.props.onFetchSuggestions(token);
  }

  onSuggestionSelected = (tokenStart, token, value) => {
    this._restoreCaret = null;
    this.props.onSuggestionSelected(tokenStart, token, value);
  }

  handleChangeSpoilerText = (e) => {
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
    } else if(prevProps.is_submitting && !this.props.is_submitting) {
      this.autosuggestTextarea.textarea.focus();
    }
  }

  setAutosuggestTextarea = (c) => {
    this.autosuggestTextarea = c;
  }

  handleEmojiPick = (data) => {
    const position     = this.autosuggestTextarea.textarea.selectionStart;
    const emojiChar    = data.native;
    this._restoreCaret = position + emojiChar.length + 1;
    this.props.onPickEmoji(position, data);
  }

  render () {
    const { intl, onPaste, showSearch } = this.props;
    const disabled = this.props.is_submitting;
    const maybeEye = (this.props.advanced_options && this.props.advanced_options.do_not_federate) ? ' 👁️' : '';
    const text     = [this.props.spoiler_text, countableText(this.props.text), maybeEye].join('');

    const secondaryVisibility = this.props.settings.get('side_arm');
    let showSideArm = secondaryVisibility !== 'none';

    let publishText = '';
    let publishText2 = '';
    let title = '';
    let title2 = '';

    const privacyIcons = {
      none: '',
      public: 'globe',
      unlisted: 'unlock-alt',
      private: 'lock',
      direct: 'envelope',
    };

    title = `${intl.formatMessage(messages.publish)}: ${intl.formatMessage({ id: `privacy.${this.props.privacy}.short` })}`;

    if (showSideArm) {
      // Enhanced behavior with dual toot buttons
      publishText = (
        <span>
          {
            <i
              className={`fa fa-${privacyIcons[this.props.privacy]}`}
              style={{ paddingRight: '5px' }}
            />
          }{intl.formatMessage(messages.publish)}
        </span>
      );

      title2 = `${intl.formatMessage(messages.publish)}: ${intl.formatMessage({ id: `privacy.${secondaryVisibility}.short` })}`;
      publishText2 = (
        <i
          className={`fa fa-${privacyIcons[secondaryVisibility]}`}
          aria-label={title2}
        />
      );
    } else {
      // Original vanilla behavior - no icon if public or unlisted
      if (this.props.privacy === 'private' || this.props.privacy === 'direct') {
        publishText = <span className='compose-form__publish-private'><i className='fa fa-lock' /> {intl.formatMessage(messages.publish)}</span>;
      } else {
        publishText = this.props.privacy !== 'unlisted' ? intl.formatMessage(messages.publishLoud, { publish: intl.formatMessage(messages.publish) }) : intl.formatMessage(messages.publish);
      }
    }

    const submitDisabled = disabled || this.props.is_uploading || length(text) > 500 || (text.length !== 0 && text.trim().length === 0);

    return (
      <div className='compose-form'>
        <Collapsable isVisible={this.props.spoiler} fullHeight={50}>
          <div className='spoiler-input'>
            <label>
              <span style={{ display: 'none' }}>{intl.formatMessage(messages.spoiler_placeholder)}</span>
              <input placeholder={intl.formatMessage(messages.spoiler_placeholder)} value={this.props.spoiler_text} onChange={this.handleChangeSpoilerText} onKeyDown={this.handleKeyDown} type='text' className='spoiler-input__input'  id='cw-spoiler-input' />
            </label>
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
            autoFocus={!showSearch && !isMobile(window.innerWidth)}
          />

          <EmojiPickerDropdown onPickEmoji={this.handleEmojiPick} />
        </div>

        <div className='compose-form__modifiers'>
          <UploadFormContainer />
        </div>

        <div className='compose-form__buttons'>
          <ComposeAttachOptions />
          <SensitiveButtonContainer />
          <div className='compose-form__buttons-separator' />
          <PrivacyDropdownContainer />
          <SpoilerButtonContainer />
          <ComposeAdvancedOptionsContainer />
        </div>

        <div className='compose-form__publish'>
          <div className='character-counter__wrapper'><CharacterCounter max={500} text={text} /></div>
          <div className='compose-form__publish-button-wrapper'>
            {
              showSideArm ?
                <Button
                  className='compose-form__publish__side-arm'
                  text={publishText2}
                  title={title2}
                  onClick={this.handleSubmit2}
                  disabled={submitDisabled}
                /> : ''
            }
            <Button
              className='compose-form__publish__primary'
              text={publishText}
              title={title}
              onClick={this.handleSubmit}
              disabled={submitDisabled}
            />
          </div>
        </div>
      </div>
    );
  }

}

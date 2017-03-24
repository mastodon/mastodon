import CharacterCounter from './character_counter';
import Button from '../../../components/button';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ReplyIndicatorContainer from '../containers/reply_indicator_container';
import UploadButton from './upload_button';
import AutosuggestTextarea from '../../../components/autosuggest_textarea';
import AutosuggestAccountContainer from '../../compose/containers/autosuggest_account_container';
import { debounce } from 'react-decoration';
import UploadButtonContainer from '../containers/upload_button_container';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import Toggle from 'react-toggle';
import Collapsable from '../../../components/collapsable';
import UnlistedToggleContainer from '../containers/unlisted_toggle_container';
import SpoilerToggleContainer from '../containers/spoiler_toggle_container';
import PrivateToggleContainer from '../containers/private_toggle_container';
import SensitiveToggleContainer from '../containers/sensitive_toggle_container';
import EmojiPickerDropdown from './emoji_picker_dropdown';

const messages = defineMessages({
  placeholder: { id: 'compose_form.placeholder', defaultMessage: 'What is on your mind?' },
  spoiler_placeholder: { id: 'compose_form.spoiler_placeholder', defaultMessage: 'Content warning' },
  publish: { id: 'compose_form.publish', defaultMessage: 'Publish' }
});

const ComposeForm = React.createClass({

  propTypes: {
    intl: React.PropTypes.object.isRequired,
    text: React.PropTypes.string.isRequired,
    suggestion_token: React.PropTypes.string,
    suggestions: ImmutablePropTypes.list,
    spoiler: React.PropTypes.bool,
    private: React.PropTypes.bool,
    unlisted: React.PropTypes.bool,
    spoiler_text: React.PropTypes.string,
    focusDate: React.PropTypes.instanceOf(Date),
    preselectDate: React.PropTypes.instanceOf(Date),
    is_submitting: React.PropTypes.bool,
    is_uploading: React.PropTypes.bool,
    me: React.PropTypes.number,
    needsPrivacyWarning: React.PropTypes.bool,
    mentionedDomains: React.PropTypes.array.isRequired,
    onChange: React.PropTypes.func.isRequired,
    onSubmit: React.PropTypes.func.isRequired,
    onClearSuggestions: React.PropTypes.func.isRequired,
    onFetchSuggestions: React.PropTypes.func.isRequired,
    onSuggestionSelected: React.PropTypes.func.isRequired,
    onChangeSpoilerText: React.PropTypes.func.isRequired,
    onPaste: React.PropTypes.func.isRequired,
    onPickEmoji: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  handleChange (e) {
    this.props.onChange(e.target.value);
  },

  handleKeyDown (e) {
    if (e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
      this.props.onSubmit();
    }
  },

  handleSubmit () {
    this.props.onSubmit();
  },

  onSuggestionsClearRequested () {
    this.props.onClearSuggestions();
  },

  @debounce(500)
  onSuggestionsFetchRequested (token) {
    this.props.onFetchSuggestions(token);
  },

  onSuggestionSelected (tokenStart, token, value) {
    this._restoreCaret = null;
    this.props.onSuggestionSelected(tokenStart, token, value);
  },

  handleChangeSpoilerText (e) {
    this.props.onChangeSpoilerText(e.target.value);
  },

  componentDidUpdate (prevProps) {
    if (this.props.focusDate !== prevProps.focusDate) {
      // If replying to zero or one users, places the cursor at the end of the textbox.
      // If replying to more than one user, selects any usernames past the first;
      // this provides a convenient shortcut to drop everyone else from the conversation.
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
  },

  setAutosuggestTextarea (c) {
    this.autosuggestTextarea = c;
  },

  handleEmojiPick (data) {
    const position     = this.autosuggestTextarea.textarea.selectionStart;
    this._restoreCaret = position + data.shortname.length + 1;
    this.props.onPickEmoji(position, data);
  },

  render () {
    const { intl, needsPrivacyWarning, mentionedDomains, onPaste } = this.props;
    const disabled = this.props.is_submitting || this.props.is_uploading;

    let publishText    = '';
    let privacyWarning = '';
    let reply_to_other = false;

    if (needsPrivacyWarning) {
      privacyWarning = (
        <div className='compose-form__warning'>
          <FormattedMessage
            id='compose_form.privacy_disclaimer'
            defaultMessage='Your private status will be delivered to mentioned users on {domains}. Do you trust {domainsCount, plural, one {that server} other {those servers}} to not leak your status?'
            values={{ domains: <strong>{mentionedDomains.join(', ')}</strong>, domainsCount: mentionedDomains.length }}
          />
        </div>
      );
    }

    if (this.props.private) {
      publishText = <span><i className='fa fa-lock' /> {intl.formatMessage(messages.publish)}</span>;
    } else {
      publishText = intl.formatMessage(messages.publish) + (!this.props.unlisted ? '!' : '');
    }

    return (
      <div style={{ padding: '10px' }}>
        <Collapsable isVisible={this.props.spoiler} fullHeight={50}>
          <div className="spoiler-input">
            <input placeholder={intl.formatMessage(messages.spoiler_placeholder)} value={this.props.spoiler_text} onChange={this.handleChangeSpoilerText} type="text" className="spoiler-input__input" />
          </div>
        </Collapsable>

        {privacyWarning}

        <ReplyIndicatorContainer />

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

        <div style={{ marginTop: '10px', overflow: 'hidden' }}>
          <div style={{ float: 'right' }}><Button text={publishText} onClick={this.handleSubmit} disabled={disabled} /></div>
          <div style={{ float: 'right', marginRight: '16px', lineHeight: '36px' }}><CharacterCounter max={500} text={[this.props.spoiler_text, this.props.text].join('')} /></div>
          <div style={{ display: 'flex', paddingTop: '4px' }}>
            <UploadButtonContainer />
            <EmojiPickerDropdown onPickEmoji={this.handleEmojiPick} />
          </div>
        </div>

        <SpoilerToggleContainer />
        <PrivateToggleContainer />
        <UnlistedToggleContainer />
        <SensitiveToggleContainer />
      </div>
    );
  }

});

export default injectIntl(ComposeForm);

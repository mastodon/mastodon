import CharacterCounter from './character_counter';
import Button from '../../../components/button';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ReplyIndicator from './reply_indicator';
import UploadButton from './upload_button';
import Autosuggest from 'react-autosuggest';
import AutosuggestAccountContainer from '../../compose/containers/autosuggest_account_container';
import { debounce } from 'react-decoration';
import UploadButtonContainer from '../containers/upload_button_container';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import Toggle from 'react-toggle';

const messages = defineMessages({
  placeholder: { id: 'compose_form.placeholder', defaultMessage: 'What is on your mind?' },
  publish: { id: 'compose_form.publish', defaultMessage: 'Publish' }
});

const getTokenForSuggestions = (str, caretPosition) => {
  let word;

  let left  = str.slice(0, caretPosition).search(/\S+$/);
  let right = str.slice(caretPosition).search(/\s/);

  if (right < 0) {
    word = str.slice(left);
  } else {
    word = str.slice(left, right + caretPosition);
  }

  if (!word || word.trim().length < 2 || word[0] !== '@') {
    return null;
  }

  word = word.trim().toLowerCase().slice(1);

  if (word.length > 0) {
    return word;
  } else {
    return null;
  }
};

const getSuggestionValue = suggestionId => suggestionId;
const renderSuggestion   = suggestionId => <AutosuggestAccountContainer id={suggestionId} />;

const textareaStyle = {
  display: 'block',
  boxSizing: 'border-box',
  width: '100%',
  height: '100px',
  resize: 'none',
  border: 'none',
  color: '#282c37',
  padding: '10px',
  fontFamily: 'Roboto',
  fontSize: '14px',
  margin: '0',
  resize: 'vertical'
};

const renderInputComponent = inputProps => (
  <textarea {...inputProps} className='compose-form__textarea' style={textareaStyle} />
);

const ComposeForm = React.createClass({

  propTypes: {
    text: React.PropTypes.string.isRequired,
    suggestion_token: React.PropTypes.string,
    suggestions: React.PropTypes.array,
    sensitive: React.PropTypes.bool,
    unlisted: React.PropTypes.bool,
    is_submitting: React.PropTypes.bool,
    is_uploading: React.PropTypes.bool,
    in_reply_to: ImmutablePropTypes.map,
    onChange: React.PropTypes.func.isRequired,
    onSubmit: React.PropTypes.func.isRequired,
    onCancelReply: React.PropTypes.func.isRequired,
    onClearSuggestions: React.PropTypes.func.isRequired,
    onFetchSuggestions: React.PropTypes.func.isRequired,
    onSuggestionSelected: React.PropTypes.func.isRequired,
    onChangeSensitivity: React.PropTypes.func.isRequired,
    onChangeVisibility: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  handleChange (e) {
    if (typeof e.target.value === 'undefined' || typeof e.target.value === 'number') {
      return;
    }

    this.props.onChange(e.target.value);
  },

  handleKeyUp (e) {
    if (e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
      this.props.onSubmit();
    }
  },

  handleSubmit () {
    this.props.onSubmit();
  },

  componentDidUpdate (prevProps) {
    if (prevProps.text !== this.props.text || prevProps.in_reply_to !== this.props.in_reply_to) {
      const textarea = this.autosuggest.input;

      if (textarea) {
        textarea.focus();
      }
    }
  },

  onSuggestionsClearRequested () {
    this.props.onClearSuggestions();
  },

  @debounce(500)
  onSuggestionsFetchRequested ({ value }) {
    const textarea = this.autosuggest.input;

    if (textarea) {
      const token = getTokenForSuggestions(value, textarea.selectionStart);

      if (token !== null) {
        this.props.onFetchSuggestions(token);
      } else {
        this.props.onClearSuggestions();
      }
    }
  },

  onSuggestionSelected (e, { suggestionValue }) {
    const textarea = this.autosuggest.input;

    if (textarea) {
      this.props.onSuggestionSelected(textarea.selectionStart, suggestionValue);
    }
  },

  setRef (c) {
    this.autosuggest = c;
  },

  handleChangeSensitivity (e) {
    this.props.onChangeSensitivity(e.target.checked);
  },

  handleChangeVisibility (e) {
    this.props.onChangeVisibility(e.target.checked);
  },

  render () {
    const { intl } = this.props;
    let replyArea  = '';
    const disabled = this.props.is_submitting || this.props.is_uploading;

    if (this.props.in_reply_to) {
      replyArea = <ReplyIndicator status={this.props.in_reply_to} onCancel={this.props.onCancelReply} />;
    }

    const inputProps = {
      placeholder: intl.formatMessage(messages.placeholder),
      value: this.props.text,
      onKeyUp: this.handleKeyUp,
      onChange: this.handleChange,
      disabled: disabled
    };

    return (
      <div style={{ padding: '10px' }}>
        {replyArea}

        <Autosuggest
          ref={this.setRef}
          suggestions={this.props.suggestions}
          focusFirstSuggestion={true}
          onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
          onSuggestionsClearRequested={this.onSuggestionsClearRequested}
          onSuggestionSelected={this.onSuggestionSelected}
          getSuggestionValue={getSuggestionValue}
          renderSuggestion={renderSuggestion}
          renderInputComponent={renderInputComponent}
          inputProps={inputProps}
        />

        <div style={{ marginTop: '10px', overflow: 'hidden' }}>
          <div style={{ float: 'right' }}><Button text={intl.formatMessage(messages.publish)} onClick={this.handleSubmit} disabled={disabled} /></div>
          <div style={{ float: 'right', marginRight: '16px', lineHeight: '36px' }}><CharacterCounter max={500} text={this.props.text} /></div>
          <UploadButtonContainer style={{ paddingTop: '4px' }} />
        </div>

        <label style={{ display: 'block', lineHeight: '24px', verticalAlign: 'middle', marginTop: '10px', borderTop: '1px solid #282c37', paddingTop: '10px' }}>
          <Toggle checked={this.props.unlisted} onChange={this.handleChangeVisibility} />
          <span style={{ display: 'inline-block', verticalAlign: 'middle', marginBottom: '14px', marginLeft: '8px', color: '#9baec8' }}><FormattedMessage id='compose_form.unlisted' defaultMessage='Do not show on public timeline' /></span>
        </label>

        <label style={{ display: 'block', lineHeight: '24px', verticalAlign: 'middle' }}>
          <Toggle checked={this.props.sensitive} onChange={this.handleChangeSensitivity} />
          <span style={{ display: 'inline-block', verticalAlign: 'middle', marginBottom: '14px', marginLeft: '8px', color: '#9baec8' }}><FormattedMessage id='compose_form.sensitive' defaultMessage='Mark content as sensitive' /></span>
        </label>
      </div>
    );
  }

});

export default injectIntl(ComposeForm);

import CharacterCounter from './character_counter';
import Button from '../../../components/button';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ReplyIndicator from './reply_indicator';
import UploadButton from './upload_button';
import AutosuggestTextarea from '../../../components/autosuggest_textarea';
import AutosuggestAccountContainer from '../../compose/containers/autosuggest_account_container';
import { debounce } from 'react-decoration';
import UploadButtonContainer from '../containers/upload_button_container';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import Toggle from 'react-toggle';

const messages = defineMessages({
  placeholder: { id: 'compose_form.placeholder', defaultMessage: 'What is on your mind?' },
  publish: { id: 'compose_form.publish', defaultMessage: 'Publish' }
});

const ComposeForm = React.createClass({

  propTypes: {
    text: React.PropTypes.string.isRequired,
    suggestion_token: React.PropTypes.string,
    suggestions: ImmutablePropTypes.list,
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

  onSuggestionsClearRequested () {
    this.props.onClearSuggestions();
  },

  @debounce(500)
  onSuggestionsFetchRequested (token) {
    this.props.onFetchSuggestions(token);
  },

  onSuggestionSelected (tokenStart, token, value) {
    this.props.onSuggestionSelected(tokenStart, token, value);
  },

  handleChangeSensitivity (e) {
    this.props.onChangeSensitivity(e.target.checked);
  },

  handleChangeVisibility (e) {
    this.props.onChangeVisibility(e.target.checked);
  },

  componentDidUpdate (prevProps) {
    if (prevProps.in_reply_to !== this.props.in_reply_to) {
      this.autosuggestTextarea.textarea.focus();
    }
  },

  setAutosuggestTextarea (c) {
    this.autosuggestTextarea = c;
  },

  render () {
    const { intl } = this.props;
    let replyArea  = '';
    const disabled = this.props.is_submitting || this.props.is_uploading;

    if (this.props.in_reply_to) {
      replyArea = <ReplyIndicator status={this.props.in_reply_to} onCancel={this.props.onCancelReply} />;
    }

    return (
      <div style={{ padding: '10px' }}>
        {replyArea}

        <AutosuggestTextarea
          ref={this.setAutosuggestTextarea}
          placeholder={intl.formatMessage(messages.placeholder)}
          disabled={disabled}
          value={this.props.text}
          onChange={this.handleChange}
          suggestions={this.props.suggestions}
          onKeyUp={this.handleKeyUp}
          onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
          onSuggestionsClearRequested={this.onSuggestionsClearRequested}
          onSuggestionSelected={this.onSuggestionSelected}
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

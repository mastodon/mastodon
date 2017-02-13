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
import Collapsable from '../../../components/collapsable';

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
    sensitive: React.PropTypes.bool,
    spoiler: React.PropTypes.bool,
    spoiler_text: React.PropTypes.string,
    unlisted: React.PropTypes.bool,
    private: React.PropTypes.bool,
    fileDropDate: React.PropTypes.instanceOf(Date),
    is_submitting: React.PropTypes.bool,
    is_uploading: React.PropTypes.bool,
    in_reply_to: ImmutablePropTypes.map,
    media_count: React.PropTypes.number,
    me: React.PropTypes.number,
    onChange: React.PropTypes.func.isRequired,
    onSubmit: React.PropTypes.func.isRequired,
    onCancelReply: React.PropTypes.func.isRequired,
    onClearSuggestions: React.PropTypes.func.isRequired,
    onFetchSuggestions: React.PropTypes.func.isRequired,
    onSuggestionSelected: React.PropTypes.func.isRequired,
    onChangeSensitivity: React.PropTypes.func.isRequired,
    onChangeSpoilerness: React.PropTypes.func.isRequired,
    onChangeSpoilerText: React.PropTypes.func.isRequired,
    onChangeVisibility: React.PropTypes.func.isRequired,
    onChangeListability: React.PropTypes.func.isRequired,
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
    this.props.onSuggestionSelected(tokenStart, token, value);
  },

  handleChangeSensitivity (e) {
    this.props.onChangeSensitivity(e.target.checked);
  },

  handleChangeSpoilerness (e) {
    this.props.onChangeSpoilerness(e.target.checked);
    this.props.onChangeSpoilerText('');
  },

  handleChangeSpoilerText (e) {
    this.props.onChangeSpoilerText(e.target.value);
  },

  handleChangeVisibility (e) {
    this.props.onChangeVisibility(e.target.checked);
  },

  handleChangeListability (e) {
    this.props.onChangeListability(e.target.checked);
  },

  componentDidUpdate (prevProps) {
    if ((prevProps.in_reply_to === null && this.props.in_reply_to !== null) || (prevProps.in_reply_to !== null && this.props.in_reply_to !== null && prevProps.in_reply_to.get('id') !== this.props.in_reply_to.get('id'))) {
      // If replying to zero or one users, places the cursor at the end of the textbox.
      // If replying to more than one user, selects any usernames past the first;
      // this provides a convenient shortcut to drop everyone else from the conversation.
      const selectionStart = this.props.text.search(/\s/) + 1;
      const selectionEnd   = this.props.text.length;

      this.autosuggestTextarea.textarea.setSelectionRange(selectionStart, selectionEnd);
      this.autosuggestTextarea.textarea.focus();
    }
  },

  setAutosuggestTextarea (c) {
    this.autosuggestTextarea = c;
  },

  render () {
    const { intl }  = this.props;
    let replyArea   = '';
    let publishText = '';
    const disabled  = this.props.is_submitting || this.props.is_uploading;

    if (this.props.in_reply_to) {
      replyArea = <ReplyIndicator status={this.props.in_reply_to} onCancel={this.props.onCancelReply} />;
    }

    let reply_to_other = !!this.props.in_reply_to && (this.props.in_reply_to.getIn(['account', 'id']) !== this.props.me);

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

        {replyArea}

        <AutosuggestTextarea
          ref={this.setAutosuggestTextarea}
          placeholder={intl.formatMessage(messages.placeholder)}
          disabled={disabled}
          fileDropDate={this.props.fileDropDate}
          value={this.props.text}
          onChange={this.handleChange}
          suggestions={this.props.suggestions}
          onKeyDown={this.handleKeyDown}
          onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
          onSuggestionsClearRequested={this.onSuggestionsClearRequested}
          onSuggestionSelected={this.onSuggestionSelected}
        />

        <div style={{ marginTop: '10px', overflow: 'hidden' }}>
          <div style={{ float: 'right' }}><Button text={publishText} onClick={this.handleSubmit} disabled={disabled} /></div>
          <div style={{ float: 'right', marginRight: '16px', lineHeight: '36px' }}><CharacterCounter max={500} text={[this.props.spoiler_text, this.props.text].join('')} /></div>
          <UploadButtonContainer style={{ paddingTop: '4px' }} />
        </div>

        <label className='compose-form__label with-border' style={{ marginTop: '10px' }}>
          <Toggle checked={this.props.spoiler} onChange={this.handleChangeSpoilerness} />
          <span className='compose-form__label__text'><FormattedMessage id='compose_form.spoiler' defaultMessage='Hide text behind warning' /></span>
        </label>

        <label className='compose-form__label with-border'>
          <Toggle checked={this.props.private} onChange={this.handleChangeVisibility} />
          <span className='compose-form__label__text'><FormattedMessage id='compose_form.private' defaultMessage='Mark as private' /></span>
        </label>
       
        <Motion defaultStyle={{ opacity: 0, height: 0 }}, style={{ opacity: spring((this.props.private || reply_to_other) ? 0 : 100), height: spring((this.props.private || reply_to_other) ? 0 : 39.5) }}>
            <label className='compose-form__label' style={{ height: `${height}px`, overflow: 'hidden', opacity: opacity / 100 }}>
              <span className='compose-form__label__text'><FormattedMessage id='compose_form.privacy_disclaimer' defaultMessage='Warning: Private posts are not encrypted, and could be read or boosted by instances or people who do not respect post privacy. This is not true privacy. Do not post senstive information.' /></span>
            </label>
          }
        </Motion>

        <Collapsable isVisible={!(this.props.private || reply_to_other)} fullHeight={39.5}>
          <label className='compose-form__label'>
            <Toggle checked={this.props.unlisted} onChange={this.handleChangeListability} />
            <span className='compose-form__label__text'><FormattedMessage id='compose_form.unlisted' defaultMessage='Do not display in public timeline' /></span>
          </label>
        </Collapsable>

        <Collapsable isVisible={this.props.media_count > 0} fullHeight={39.5}>
          <label className='compose-form__label'>
            <Toggle checked={this.props.sensitive} onChange={this.handleChangeSensitivity} />
            <span className='compose-form__label__text'><FormattedMessage id='compose_form.sensitive' defaultMessage='Mark media as sensitive' /></span>
          </label>
        </Collapsable>
      </div>
    );
  }

});

export default injectIntl(ComposeForm);

import CharacterCounter   from './character_counter';
import Button             from '../../../components/button';
import PureRenderMixin    from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ReplyIndicator     from './reply_indicator';
import UploadButton       from './upload_button';
import Autosuggest        from 'react-autosuggest';

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

const getSuggestionValue = suggestion => suggestion.completion;

const renderSuggestion = suggestion => (
  <span>{suggestion.label}</span>
);

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
  margin: '0'
};

const renderInputComponent = inputProps => (
  <textarea {...inputProps} placeholder='What is on your mind?'  className='compose-form__textarea' style={textareaStyle} />
);

const ComposeForm = React.createClass({

  propTypes: {
    text: React.PropTypes.string.isRequired,
    suggestions: React.PropTypes.array,
    is_submitting: React.PropTypes.bool,
    is_uploading: React.PropTypes.bool,
    in_reply_to: ImmutablePropTypes.map,
    onChange: React.PropTypes.func.isRequired,
    onSubmit: React.PropTypes.func.isRequired,
    onCancelReply: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  handleChange (e) {
    this.props.onChange(e.target.value);
  },

  handleKeyUp (e) {
    if (e.keyCode === 13 && e.ctrlKey) {
      this.props.onSubmit();
    }
  },

  handleSubmit () {
    this.props.onSubmit();
  },

  componentDidUpdate (prevProps) {
    if (prevProps.text !== this.props.text || prevProps.in_reply_to !== this.props.in_reply_to) {
      const node     = ReactDOM.findDOMNode(this.refs.autosuggest);
      const textarea = node.querySelector('textarea');

      if (textarea) {
        textarea.focus();
      }
    }
  },

  onSuggestionsClearRequested () {
    this.props.onClearSuggestions();
  },

  onSuggestionsFetchRequested ({ value }) {
    const node     = ReactDOM.findDOMNode(this.refs.autosuggest);
    const textarea = node.querySelector('textarea');

    if (textarea) {
      const token = getTokenForSuggestions(value, textarea.selectionStart);

      if (token !== null) {
        this.props.onFetchSuggestions(token);
      }
    }
  },

  onSuggestionSelected (e, { suggestionValue, method }) {
    const node     = ReactDOM.findDOMNode(this.refs.autosuggest);
    const textarea = node.querySelector('textarea');

    if (textarea) {
      const str = this.props.text;
      this.props.onChange([str.slice(0, textarea.selectionStart), suggestionValue, str.slice(textarea.selectionStart)].join(''));
    }
  },

  render () {
    let replyArea  = '';
    const disabled = this.props.is_submitting || this.props.is_uploading;

    if (this.props.in_reply_to) {
      replyArea = <ReplyIndicator status={this.props.in_reply_to} onCancel={this.props.onCancelReply} />;
    }

    const inputProps = {
      placeholder: 'What is on your mind?',
      ariaLabel: 'What is on your mind?',
      value: this.props.text,
      onKeyUp: this.handleKeyUp,
      onChange: this.handleChange,
      disabled: disabled
    };

    return (
      <div style={{ padding: '10px' }}>
        {replyArea}

        <Autosuggest
          ref='autosuggest'
          suggestions={this.props.suggestions}
          onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
          onSuggestionsClearRequested={this.onSuggestionsClearRequested}
          onSuggestionSelected={this.onSuggestionSelected}
          getSuggestionValue={getSuggestionValue}
          renderSuggestion={renderSuggestion}
          renderInputComponent={renderInputComponent}
          inputProps={inputProps}
        />

        <div style={{ marginTop: '10px', overflow: 'hidden' }}>
          <div style={{ float: 'right' }}><Button text='Publish' onClick={this.handleSubmit} disabled={disabled} /></div>
          <div style={{ float: 'right', marginRight: '16px', lineHeight: '36px' }}><CharacterCounter max={500} text={this.props.text} /></div>
        </div>
      </div>
    );
  }

});

export default ComposeForm;

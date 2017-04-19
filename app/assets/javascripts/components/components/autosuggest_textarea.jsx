import AutosuggestAccountContainer from '../features/compose/containers/autosuggest_account_container';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { isRtl } from '../rtl';

const textAtCursorMatchesToken = (str, caretPosition) => {
  let word;

  let left  = str.slice(0, caretPosition).search(/\S+$/);
  let right = str.slice(caretPosition).search(/\s/);

  if (right < 0) {
    word = str.slice(left);
  } else {
    word = str.slice(left, right + caretPosition);
  }

  if (!word || word.trim().length < 2 || word[0] !== '@') {
    return [null, null];
  }

  word = word.trim().toLowerCase().slice(1);

  if (word.length > 0) {
    return [left + 1, word];
  } else {
    return [null, null];
  }
};

const AutosuggestTextarea = React.createClass({

  propTypes: {
    value: React.PropTypes.string,
    suggestions: ImmutablePropTypes.list,
    disabled: React.PropTypes.bool,
    placeholder: React.PropTypes.string,
    onSuggestionSelected: React.PropTypes.func.isRequired,
    onSuggestionsClearRequested: React.PropTypes.func.isRequired,
    onSuggestionsFetchRequested: React.PropTypes.func.isRequired,
    onChange: React.PropTypes.func.isRequired,
    onKeyUp: React.PropTypes.func,
    onKeyDown: React.PropTypes.func,
    onPaste: React.PropTypes.func.isRequired,
  },

  getInitialState () {
    return {
      suggestionsHidden: false,
      selectedSuggestion: 0,
      lastToken: null,
      tokenStart: 0
    };
  },

  onChange (e) {
    const [ tokenStart, token ] = textAtCursorMatchesToken(e.target.value, e.target.selectionStart);

    if (token !== null && this.state.lastToken !== token) {
      this.setState({ lastToken: token, selectedSuggestion: 0, tokenStart });
      this.props.onSuggestionsFetchRequested(token);
    } else if (token === null) {
      this.setState({ lastToken: null });
      this.props.onSuggestionsClearRequested();
    }

    // auto-resize textarea
    e.target.style.height = 'auto';
    e.target.style.height = `${e.target.scrollHeight}px`;

    this.props.onChange(e);
  },

  onKeyDown (e) {
    const { suggestions, disabled } = this.props;
    const { selectedSuggestion, suggestionsHidden } = this.state;

    if (disabled) {
      e.preventDefault();
      return;
    }

    switch(e.key) {
    case 'Escape':
      if (!suggestionsHidden) {
        e.preventDefault();
        this.setState({ suggestionsHidden: true });
      }

      break;
    case 'ArrowDown':
      if (suggestions.size > 0 && !suggestionsHidden) {
        e.preventDefault();
        this.setState({ selectedSuggestion: Math.min(selectedSuggestion + 1, suggestions.size - 1) });
      }

      break;
    case 'ArrowUp':
      if (suggestions.size > 0 && !suggestionsHidden) {
        e.preventDefault();
        this.setState({ selectedSuggestion: Math.max(selectedSuggestion - 1, 0) });
      }

      break;
    case 'Enter':
    case 'Tab':
      // Select suggestion
      if (this.state.lastToken !== null && suggestions.size > 0 && !suggestionsHidden) {
        e.preventDefault();
        e.stopPropagation();
        this.props.onSuggestionSelected(this.state.tokenStart, this.state.lastToken, suggestions.get(selectedSuggestion));
      }

      break;
    }

    if (e.defaultPrevented || !this.props.onKeyDown) {
      return;
    }

    this.props.onKeyDown(e);
  },

  onBlur () {
    // If we hide the suggestions immediately, then this will prevent the
    // onClick for the suggestions themselves from firing.
    // Setting a short window for that to take place before hiding the
    // suggestions ensures that can't happen.
    setTimeout(() => {
      this.setState({ suggestionsHidden: true });
    }, 100);
  },

  onSuggestionClick (suggestion, e) {
    e.preventDefault();
    this.props.onSuggestionSelected(this.state.tokenStart, this.state.lastToken, suggestion);
    this.textarea.focus();
  },

  componentWillReceiveProps (nextProps) {
    if (nextProps.suggestions !== this.props.suggestions && nextProps.suggestions.size > 0 && this.state.suggestionsHidden) {
      this.setState({ suggestionsHidden: false });
    }
  },

  setTextarea (c) {
    this.textarea = c;
  },

  onPaste (e) {
    if (e.clipboardData && e.clipboardData.files.length === 1) {
      this.props.onPaste(e.clipboardData.files)
      e.preventDefault();
    }
  },

  render () {
    const { value, suggestions, disabled, placeholder, onKeyUp } = this.props;
    const { suggestionsHidden, selectedSuggestion } = this.state;
    const className = 'autosuggest-textarea__textarea';
    const style     = { direction: 'ltr' };

    if (isRtl(value)) {
      style.direction = 'rtl';
    }

    return (
      <div className='autosuggest-textarea'>
        <textarea
          ref={this.setTextarea}
          className={className}
          disabled={disabled}
          placeholder={placeholder}
          autoFocus={true}
          value={value}
          onChange={this.onChange}
          onKeyDown={this.onKeyDown}
          onKeyUp={onKeyUp}
          onBlur={this.onBlur}
          onPaste={this.onPaste}
          style={style}
        />

        <div style={{ display: (suggestions.size > 0 && !suggestionsHidden) ? 'block' : 'none' }} className='autosuggest-textarea__suggestions'>
          {suggestions.map((suggestion, i) => (
            <div
              role='button'
              tabIndex='0'
              key={suggestion}
              className={`autosuggest-textarea__suggestions__item ${i === selectedSuggestion ? 'selected' : ''}`}
              onClick={this.onSuggestionClick.bind(this, suggestion)}>
              <AutosuggestAccountContainer id={suggestion} />
            </div>
          ))}
        </div>
      </div>
    );
  }

});

export default AutosuggestTextarea;

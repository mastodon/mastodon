import React from 'react';
import AutosuggestAccountContainer from '../features/compose/containers/autosuggest_account_container';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { isRtl } from '../rtl';
import ImmutablePureComponent from 'react-immutable-pure-component';

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

class AutosuggestTextarea extends ImmutablePureComponent {

  constructor (props, context) {
    super(props, context);
    this.state = {
      suggestionsHidden: false,
      selectedSuggestion: 0,
      lastToken: null,
      tokenStart: 0
    };
    this.onChange = this.onChange.bind(this);
    this.onKeyDown = this.onKeyDown.bind(this);
    this.onBlur = this.onBlur.bind(this);
    this.onSuggestionClick = this.onSuggestionClick.bind(this);
    this.setTextarea = this.setTextarea.bind(this);
    this.onPaste = this.onPaste.bind(this);
  }

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
    e.target.style.height = `${e.target.scrollHeight}px`;

    this.props.onChange(e);
  }

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
  }

  onBlur () {
    // If we hide the suggestions immediately, then this will prevent the
    // onClick for the suggestions themselves from firing.
    // Setting a short window for that to take place before hiding the
    // suggestions ensures that can't happen.
    setTimeout(() => {
      this.setState({ suggestionsHidden: true });
    }, 100);
  }

  onSuggestionClick (suggestion, e) {
    e.preventDefault();
    this.props.onSuggestionSelected(this.state.tokenStart, this.state.lastToken, suggestion);
    this.textarea.focus();
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.suggestions !== this.props.suggestions && nextProps.suggestions.size > 0 && this.state.suggestionsHidden) {
      this.setState({ suggestionsHidden: false });
    }
  }

  setTextarea (c) {
    this.textarea = c;
  }

  onPaste (e) {
    if (e.clipboardData && e.clipboardData.files.length === 1) {
      this.props.onPaste(e.clipboardData.files)
      e.preventDefault();
    }
  }

  reset () {
    this.textarea.style.height = 'auto';
  }

  render () {
    const { value, suggestions, disabled, placeholder, onKeyUp, autoFocus } = this.props;
    const { suggestionsHidden, selectedSuggestion } = this.state;
    const style = { direction: 'ltr' };

    if (isRtl(value)) {
      style.direction = 'rtl';
    }

    return (
      <div className='autosuggest-textarea'>
        <textarea
          ref={this.setTextarea}
          className='autosuggest-textarea__textarea'
          disabled={disabled}
          placeholder={placeholder}
          autoFocus={autoFocus}
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

};

AutosuggestTextarea.propTypes = {
  value: PropTypes.string,
  suggestions: ImmutablePropTypes.list,
  disabled: PropTypes.bool,
  placeholder: PropTypes.string,
  onSuggestionSelected: PropTypes.func.isRequired,
  onSuggestionsClearRequested: PropTypes.func.isRequired,
  onSuggestionsFetchRequested: PropTypes.func.isRequired,
  onChange: PropTypes.func.isRequired,
  onKeyUp: PropTypes.func,
  onKeyDown: PropTypes.func,
  onPaste: PropTypes.func.isRequired,
  autoFocus: PropTypes.bool
};

AutosuggestTextarea.defaultProps = {
  autoFucus: true,
};

export default AutosuggestTextarea;

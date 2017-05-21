import React from 'react';
import AutosuggestAccountContainer from '../features/compose/containers/autosuggest_account_container';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { isRtl } from '../rtl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import Textarea from 'react-textarea-autosize';

const textAtCursorMatchesToken = (str, caretPosition, prefix) => {
  let word;

  let left  = str.slice(0, caretPosition).search(/\S+$/);
  let right = str.slice(caretPosition).search(/\s/);

  if (right < 0) {
    word = str.slice(left);
  } else {
    word = str.slice(left, right + caretPosition);
  }

  if (!word || word.trim().length < 2 || word[0] !== prefix) {
    return [null, null];
  }

  word = word.trim().slice(1);

  if (word.length > 0) {
    return [left + 1, word];
  } else {
    return [null, null];
  }
};

const textAtCursorMatchesHashToken = (str, caretPosition) => {
  return textAtCursorMatchesToken(str, caretPosition, '#');
};

const textAtCursorMatchesMentionToken = (str, caretPosition) => {
  const token = textAtCursorMatchesToken(str, caretPosition, '@');
  const start = token[0];
  const word = token[1] === null ? null : token[1].toLowerCase();
  return [start, word];
};

class AutosuggestTextarea extends ImmutablePureComponent {

  static propTypes = {
    value: PropTypes.string,
    suggestions: ImmutablePropTypes.list,
    hash_tag_suggestions: ImmutablePropTypes.list,
    disabled: PropTypes.bool,
    placeholder: PropTypes.string,
    onSuggestionSelected: PropTypes.func.isRequired,
    onSuggestionsClearRequested: PropTypes.func.isRequired,
    onSuggestionsFetchRequested: PropTypes.func.isRequired,
    onHashTagSuggestionsSelected: PropTypes.func.isRequired,
    onHashTagSuggestionsClearRequested: PropTypes.func.isRequired,
    onHashTagSuggestionsFetchRequested: PropTypes.func.isRequired,
    onChange: PropTypes.func.isRequired,
    onKeyUp: PropTypes.func,
    onKeyDown: PropTypes.func,
    onPaste: PropTypes.func.isRequired,
    autoFocus: PropTypes.bool,
  };

  static defaultProps = {
    autoFocus: true,
  };

  state = {
    suggestionsHidden: false,
    selectedSuggestion: 0,
    lastToken: null,
    tokenStart: 0,
    ashTagSuggestionsHidden: false,
    selectedHashTagSuggestion: 0,
    lastHashTagToken: null,
    hashTagTokenStart: 0,
  };

  onChange = (e) => {
    const [ tokenStart, token ] = textAtCursorMatchesMentionToken(e.target.value, e.target.selectionStart);

    if (token !== null && this.state.lastToken !== token) {
      this.setState({ lastToken: token, selectedSuggestion: 0, tokenStart });
      this.props.onSuggestionsFetchRequested(token);
    } else if (token === null) {
      this.setState({ lastToken: null });
      this.props.onSuggestionsClearRequested();
    }

    const [hashTagTokenStart, hashToken] = textAtCursorMatchesHashToken(e.target.value, e.target.selectionStart);
    if (hashToken !== null && this.state.lastHashTagToken !== hashToken) {
      this.setState({lastHashTagToken: hashToken, selectedHashTagSuggestion: 0, hashTagTokenStart});
      this.props.onHashTagSuggestionsFetchRequested(hashToken);
    } else if (hashToken === null) {
      this.setState({lastHashTagToken: null});
      this.props.onHashTagSuggestionsClearRequested();
    }
    this.props.onChange(e);
  }

  onKeyDown = (e) => {
    const { suggestions, disabled, hash_tag_suggestions } = this.props;
    const { selectedSuggestion, suggestionsHidden, hashTagSuggestionsHidden, selectedHashTagSuggestion } = this.state;

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

      if (!hashTagSuggestionsHidden) {
        e.preventDefault();
        this.setState({ hashTagSuggestionsHidden: true });
      }

      break;
    case 'ArrowDown':
      if (suggestions.size > 0 && !suggestionsHidden) {
        e.preventDefault();
        this.setState({ selectedSuggestion: Math.min(selectedSuggestion + 1, suggestions.size - 1) });
      }

      if (hash_tag_suggestions.size > 0 && !hashTagSuggestionsHidden) {
        e.preventDefault();
        this.setState({ selectedHashTagSuggestion: Math.min(selectedHashTagSuggestion + 1, hash_tag_suggestions.size - 1)});
      }

      break;
    case 'ArrowUp':
      if (suggestions.size > 0 && !suggestionsHidden) {
        e.preventDefault();
        this.setState({ selectedSuggestion: Math.max(selectedSuggestion - 1, 0) });
      }

      if (hash_tag_suggestions.size > 0 && !hashTagSuggestionsHidden) {
        e.preventDefault();
        this.setState({ selectedHashTagSuggestion: Math.max(selectedHashTagSuggestion -1, 0)});
      }

      break;
    case 'Enter':
    case 'Tab':
      // Note: Ignore the event of Confirm Conversion of IME
      if (e.keyCode === 229) {
        break;
      }

      // Select suggestion
      if (this.state.lastToken !== null && suggestions.size > 0 && !suggestionsHidden) {
        e.preventDefault();
        e.stopPropagation();
        this.props.onSuggestionSelected(this.state.tokenStart, this.state.lastToken, suggestions.get(selectedSuggestion));
      }

      if (this.state.lastHashTagToken !== null && hash_tag_suggestions.size > 0 && !hashTagSuggestionsHidden) {
        e.preventDefault();
        e.stopPropagation();
        this.props.onHashTagSuggestionsSelected(this.state.hashTagTokenStart,
          this.state.lastHashTagToken, hash_tag_suggestions.get(selectedHashTagSuggestion));
      }

      break;
    }

    if (e.defaultPrevented || !this.props.onKeyDown) {
      return;
    }

    this.props.onKeyDown(e);
  }

  onBlur = () => {
    // If we hide the suggestions immediately, then this will prevent the
    // onClick for the suggestions themselves from firing.
    // Setting a short window for that to take place before hiding the
    // suggestions ensures that can't happen.
    setTimeout(() => {
      this.setState({ suggestionsHidden: true });
    }, 100);
  }

  onSuggestionClick = (e) => {
    const suggestion = Number(e.currentTarget.getAttribute('data-index'));
    e.preventDefault();
    this.props.onSuggestionSelected(this.state.tokenStart, this.state.lastToken, suggestion);
    this.textarea.focus();
  }

  onHashTagSuggestionClick(tag, e) {
    e.preventDefault();
    this.props.onHashTagSuggestionsSelected(this.state.hashTagTokenStart, this.state.lastHashTagToken, tag);
    this.textarea.focus();
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.suggestions !== this.props.suggestions && nextProps.suggestions.size > 0 && this.state.suggestionsHidden) {
      this.setState({ suggestionsHidden: false });
    }

    if (nextProps.hash_tag_suggestions !== this.props.hash_tag_suggestions &&
      nextProps.hash_tag_suggestions.size > 0 && this.state.hashTagSuggestionsHidden) {
      this.setState({hashTagSuggestionsHidden: false});
    }
  }

  setTextarea = (c) => {
    this.textarea = c;
  }

  onPaste = (e) => {
    if (e.clipboardData && e.clipboardData.files.length === 1) {
      this.props.onPaste(e.clipboardData.files);
      e.preventDefault();
    }
  }

  renderHashTagSuggestion(tag, i) {
    const {selectedHashTagSuggestion} = this.state;
    const onClick = this.onHashTagSuggestionClick.bind(this, tag);

    return (
      <div
        role='button'
        tabIndex='0'
        key={tag}
        className={`autosuggest-textarea__suggestions__item ${i === selectedHashTagSuggestion ? 'selected' : ''}`}
        onClick={onClick}>
        #{tag}
      </div>
    );
  }

  render () {
    const { value, suggestions, hash_tag_suggestions, disabled, placeholder, onKeyUp, autoFocus } = this.props;
    const { suggestionsHidden, selectedSuggestion, hashTagSuggestionsHidden } = this.state;
    const style = { direction: 'ltr' };
    const renderHashTagSuggestion = (tag, i) => this.renderHashTagSuggestion(tag, i);

    if (isRtl(value)) {
      style.direction = 'rtl';
    }

    return (
      <div className='autosuggest-textarea'>
        <Textarea
          inputRef={this.setTextarea}
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

        <div className={`autosuggest-textarea__suggestions ${suggestionsHidden || suggestions.isEmpty() ? '' : 'autosuggest-textarea__suggestions--visible'}`}>
          {suggestions.map((suggestion, i) => (
            <div
              role='button'
              tabIndex='0'
              key={suggestion}
              data-index={suggestion}
              className={`autosuggest-textarea__suggestions__item ${i === selectedSuggestion ? 'selected' : ''}`}
              onClick={this.onSuggestionClick}>
              <AutosuggestAccountContainer id={suggestion} />
            </div>
          ))}
        </div>

        <div style={{display: (hash_tag_suggestions.size > 0 && !hashTagSuggestionsHidden) ? 'block' : 'none'}}
             className='autosuggest-textarea__suggestions'>
          {hash_tag_suggestions.map(renderHashTagSuggestion)}
        </div>
      </div>
    );
  }

}

export default AutosuggestTextarea;

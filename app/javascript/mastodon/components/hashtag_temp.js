import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';

const getHashtagWord = (value) => {
  if (!value) {
    return '';
  }

  const trimmed = value.trim();
  return (trimmed[0] === '#') ? trimmed.slice(1) : trimmed;
};

export default class HashtagTemp extends ImmutablePureComponent {

  static propTypes = {
    disabled: PropTypes.bool,
    value: PropTypes.string,
    placeholder: PropTypes.string,
    onSuggestionsClearRequested: PropTypes.func.isRequired,
    onSuggestionsFetchRequested: PropTypes.func.isRequired,
    onKeyUp: PropTypes.func,
    onKeyDown: PropTypes.func,
    suggestions: ImmutablePropTypes.list,
    onChangeTagTemplate: PropTypes.func,
  };

  state = {
    suggestionsHidden: false,
    selectedSuggestion: 0,
    lastToken: null,
  };

  onChange = (e) => {
    const { value } = e.target;
    const hashtag = getHashtagWord(value);
    this.props.onChangeTagTemplate(hashtag);
    if (hashtag) {
      this.setState({ value, lastToken: hashtag });
      this.props.onSuggestionsFetchRequested(hashtag);
    } else {
      this.setState({ value, lastToken: null });
      this.props.onSuggestionsClearRequested();
    }
  }

  onKeyDown = (e) => {
    const { disabled, suggestions } = this.props;
    const { value, suggestionsHidden, selectedSuggestion } = this.state;

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
        this.setState({ selectedSuggestion: Math.max(selectedSuggestion -1, 0) });
      }

      break;
    case 'Enter':
    case 'Tab':
      // Note: Ignore the event of Confirm Conversion of IME
      if (e.keyCode === 229) {
        break;
      }

      if (this.state.lastToken !== null && suggestions.size > 0 && !suggestionsHidden) {
        e.preventDefault();
        this.insertHashtag(suggestions.get(selectedSuggestion));
      } else if (e.keyCode === 13) {
        e.preventDefault();
        this.insertHashtag(value);
      }

      break;
    }

    if (e.defaultPrevented || !this.props.onKeyDown) {
      return;
    }

    this.props.onKeyDown(e);
  }

  onBlur = () => {
    this.setState({ suggestionsHidden: true });
  }

  insertHashtag = (value) => {
    const hashtag = getHashtagWord(value);
    this.props.onChangeTagTemplate(hashtag);
    if (hashtag) {
      this.props.onSuggestionsClearRequested();
      this.setState({
	      value: hashtag,
        suggestionsHidden: true,
        selectedSuggestion: 0,
        lastToken: null,
      });
    }
  }

  onSuggestionClick = (e) => {
    e.preventDefault();
    const { suggestions } = this.props;
    const index = e.currentTarget.getAttribute('data-index');
    this.insertHashtag(suggestions.get(index));
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.suggestions !== this.props.suggestions &&
      nextProps.suggestions.size > 0 && this.state.suggestionsHidden) {
      this.setState({ suggestionsHidden: false });
    }
  }

  renderHashTagSuggestion = (tag, i) => {
    const { selectedSuggestion } = this.state;

    return (
      <div
        role='button'
        tabIndex='0'
        key={tag}
        className={`autosuggest-textarea__suggestions__item ${i === selectedSuggestion ? 'selected' : ''}`}
        data-index={i}
        onMouseDown={this.onSuggestionClick}
      >
        {tag}
      </div>
    );
  }

  render () {
    const { value, suggestions, disabled, placeholder, onKeyUp } = this.props;
    const { suggestionsHidden } = this.state;

    return (
      <div className='hashtag-temp'>
        <i className='fa fa-fw fa-hashtag' />
        <input
          className='hastag-temp__input'
          disabled={disabled}
          placeholder={placeholder}
          value={value}
          onChange={this.onChange}
          onKeyDown={this.onKeyDown}
          onKeyUp={onKeyUp}
          onBlur={this.onBlur}
        />

        <div style={{ display: (suggestions.size > 0 && !suggestionsHidden) ? 'block' : 'none' }}  className='autosuggest-textarea__suggestions'>
          {suggestions.map(this.renderHashTagSuggestion)}
        </div>
      </div>
    );
  }

}

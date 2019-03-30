import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';
import IconButton from '../../../components/icon_button';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import Immutable from 'immutable';

const messages = defineMessages({
  hashtag_temp_placeholder: { id: 'compose_form.hashtag_temp_placeholder', defaultMessage: 'Append tag (Enter to add more)' },
});

const getHashtagWord = (value) => {
  if (!value) {
    return '';
  }

  const trimmed = value.trim();
  return (trimmed[0] === '#') ? trimmed.slice(1) : trimmed;
};

const iconStyle = {
  height: null,
  lineHeight: '27px',
};

@injectIntl
class Form extends React.PureComponent {

  static propTypes = {
    value: PropTypes.string,
    active: PropTypes.bool,
    placeholder: PropTypes.string,
    onSuggestionsClearRequested: PropTypes.func.isRequired,
    onSuggestionsFetchRequested: PropTypes.func.isRequired,
    onKeyUp: PropTypes.func,
    onKeyDown: PropTypes.func,
    suggestions: ImmutablePropTypes.list,
    onChangeTagTemplate: PropTypes.func,
    onAddTagTemplate: PropTypes.func,
    onDeleteTagTemplate: PropTypes.func,
    onEnableTagTemplate: PropTypes.func,
    onDisableTagTemplate: PropTypes.func,
    index: PropTypes.number
  };

  state = {
    suggestionsHidden: false,
    selectedSuggestion: 0,
    lastToken: null,
  };

  onChange = (e) => {
    const { value } = e.target;
    const hashtag = getHashtagWord(value);
    this.props.onChangeTagTemplate(hashtag, this.props.index);
    if (hashtag) {
      this.setState({ value, lastToken: hashtag });
      this.props.onSuggestionsFetchRequested(hashtag, this.props.index);
    } else {
      this.setState({ value, lastToken: null });
      this.props.onSuggestionsClearRequested();
    }
  }

  onKeyDown = (e) => {
    const { value, suggestions } = this.props;
    const { suggestionsHidden, selectedSuggestion } = this.state;

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
      this.props.onAddTagTemplate(this.props.index);
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
    case 'Backspace':
      if (value.length === 0) {
        e.preventDefault();
        this.props.onDeleteTagTemplate(this.props.index);
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
    this.props.onChangeTagTemplate(hashtag, this.props.index);
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

  handleClick = (e) => {
    e.preventDefault();
    if (this.props.active) {
      this.props.onDisableTagTemplate(this.props.index);
    } else {
      this.props.onEnableTagTemplate(this.props.index);
    }
  }

  handleRemove = () => {
    this.props.onDeleteTagTemplate(this.props.index);
  }

  render () {
    const { value, active, suggestions, placeholder, onKeyUp, index } = this.props;
    const { suggestionsHidden } = this.state;

    return (
      <div className='hashtag-temp'>
        <IconButton icon='hashtag' title={''} onClick={this.handleClick} className='hashtag-temp__button-icon' active={active} size={15} inverted style={iconStyle} />
        <input
          className='hastag-temp__input'
          placeholder={placeholder}
          value={value}
          onChange={this.onChange}
          onKeyDown={this.onKeyDown}
          onKeyUp={onKeyUp}
          onBlur={this.onBlur}
        />
        <div className='hashtag-temp__cancel'>
          <IconButton disabled={index <= 0} title={''} icon='times' onClick={this.handleRemove} />
        </div>
        <div style={{ display: (suggestions.size > 0 && !suggestionsHidden) ? 'block' : 'none' }}  className='autosuggest-textarea__suggestions'>
          {suggestions.map(this.renderHashTagSuggestion)}
        </div>
      </div>
    );
  }

}

export default
@injectIntl
class HashtagTemp extends ImmutablePureComponent {
  static propTypes = {
    tagTemplate: ImmutablePropTypes.list,
    onChangeTagTemplate: PropTypes.func,
    onAddTagTemplate: PropTypes.func,
    onDeleteTagTemplate: PropTypes.func,
    onEnableTagTemplate: PropTypes.func,
    onDisableTagTemplate: PropTypes.func,
    onSuggestionsClearRequested: PropTypes.func.isRequired,
    onSuggestionsFetchRequested: PropTypes.func.isRequired,
    suggestions: ImmutablePropTypes.list,
    tagSuggestionFrom: PropTypes.string,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { 
      tagTemplate,
      tagSuggestionFrom,
      suggestions,
      intl,
    } = this.props;

    if (!tagTemplate) {
      return null;
    }
    
    return (
      <div ref={this.setRef}>
        {tagTemplate.map((tag, i) => <Form
          key={i}
          value={tag.get('text')}
          active={tag.get('active')}
          placeholder={intl.formatMessage(messages.hashtag_temp_placeholder)}
          onSuggestionsClearRequested={this.props.onSuggestionsClearRequested}
          onSuggestionsFetchRequested={this.props.onSuggestionsFetchRequested}
          suggestions={tagSuggestionFrom === 'hashtag-temp-'+i.toString() ? suggestions : Immutable.List()}
          onChangeTagTemplate={this.props.onChangeTagTemplate}
          onAddTagTemplate={this.props.onAddTagTemplate}
          onDeleteTagTemplate={this.props.onDeleteTagTemplate}
          onEnableTagTemplate={this.props.onEnableTagTemplate}
          onDisableTagTemplate={this.props.onDisableTagTemplate}
          index={i}
         />)}
      </div>
    );
  }
}
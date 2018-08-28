//  Package imports.
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import {
  defineMessages,
  FormattedMessage,
} from 'react-intl';
import Textarea from 'react-textarea-autosize';

//  Components.
import EmojiPicker from 'flavours/glitch/features/emoji_picker';
import ComposerTextareaIcons from './icons';
import ComposerTextareaSuggestions from './suggestions';

//  Utils.
import { isRtl } from 'flavours/glitch/util/rtl';
import {
  assignHandlers,
  hiddenComponent,
} from 'flavours/glitch/util/react_helpers';

//  Messages.
const messages = defineMessages({
  placeholder: {
    defaultMessage: 'What is on your mind?',
    id: 'compose_form.placeholder',
  },
});

//  Handlers.
const handlers = {

  //  When blurring the textarea, suggestions are hidden.
  handleBlur () {
    this.setState({ suggestionsHidden: true });
  },

  //  When the contents of the textarea change, we have to pull up new
  //  autosuggest suggestions if applicable, and also change the value
  //  of the textarea in our store.
  handleChange ({
    target: {
      selectionStart,
      value,
    },
  }) {
    const {
      onChange,
      onSuggestionsFetchRequested,
      onSuggestionsClearRequested,
    } = this.props;
    const { lastToken } = this.state;

    //  This gets the token at the caret location, if it begins with an
    //  `@` (mentions) or `:` (shortcodes).
    const left = value.slice(0, selectionStart).search(/[^\s\u200B]+$/);
    const right = value.slice(selectionStart).search(/[\s\u200B]/);
    const token = function () {
      switch (true) {
      case left < 0 || !/[@:#]/.test(value[left]):
        return null;
      case right < 0:
        return value.slice(left);
      default:
        return value.slice(left, right + selectionStart).trim().toLowerCase();
      }
    }();

    //  We only request suggestions for tokens which are at least 3
    //  characters long.
    if (onSuggestionsFetchRequested && token && token.length >= 3) {
      if (lastToken !== token) {
        this.setState({
          lastToken: token,
          selectedSuggestion: 0,
          tokenStart: left,
        });
        onSuggestionsFetchRequested(token);
      }
    } else {
      this.setState({ lastToken: null });
      if (onSuggestionsClearRequested) {
        onSuggestionsClearRequested();
      }
    }

    //  Updates the value of the textarea.
    if (onChange) {
      onChange(value);
    }
  },

  //  Handles a click on an autosuggestion.
  handleClickSuggestion (index) {
    const { textarea } = this;
    const {
      onSuggestionSelected,
      suggestions,
    } = this.props;
    const {
      lastToken,
      tokenStart,
    } = this.state;
    onSuggestionSelected(tokenStart, lastToken, suggestions.get(index));
    textarea.focus();
  },

  //  Handles a keypress.  If the autosuggestions are visible, we need
  //  to allow keypresses to navigate and sleect them.
  handleKeyDown (e) {
    const {
      disabled,
      onSubmit,
      onSecondarySubmit,
      onSuggestionSelected,
      suggestions,
    } = this.props;
    const {
      lastToken,
      suggestionsHidden,
      selectedSuggestion,
      tokenStart,
    } = this.state;

    //  Keypresses do nothing if the composer is disabled.
    if (disabled) {
      e.preventDefault();
      return;
    }

    //  We submit the status on control/meta + enter.
    if (onSubmit && e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
      onSubmit();
    }

    // Submit the status with secondary visibility on alt + enter.
    if (onSecondarySubmit && e.keyCode === 13 && e.altKey) {
      onSecondarySubmit();
    }

    //  Switches over the pressed key.
    switch(e.key) {

    //  On arrow down, we pick the next suggestion.
    case 'ArrowDown':
      if (suggestions && suggestions.size > 0 && !suggestionsHidden) {
        e.preventDefault();
        this.setState({ selectedSuggestion: Math.min(selectedSuggestion + 1, suggestions.size - 1) });
      }
      return;

    //  On arrow up, we pick the previous suggestion.
    case 'ArrowUp':
      if (suggestions && suggestions.size > 0 && !suggestionsHidden) {
        e.preventDefault();
        this.setState({ selectedSuggestion: Math.max(selectedSuggestion - 1, 0) });
      }
      return;

    //  On enter or tab, we select the suggestion.
    case 'Enter':
    case 'Tab':
      if (onSuggestionSelected && lastToken !== null && suggestions && suggestions.size > 0 && !suggestionsHidden) {
        e.preventDefault();
        e.stopPropagation();
        onSuggestionSelected(tokenStart, lastToken, suggestions.get(selectedSuggestion));
      }
      return;
    }
  },

  //  When the escape key is released, we either close the suggestions
  //  window or focus the UI.
  handleKeyUp ({ key }) {
    const { suggestionsHidden } = this.state;
    if (key === 'Escape') {
      if (!suggestionsHidden) {
        this.setState({ suggestionsHidden: true });
      } else {
        document.querySelector('.ui').parentElement.focus();
      }
    }
  },

  //  Handles the pasting of images into the composer.
  handlePaste (e) {
    const { onPaste } = this.props;
    let d;
    if (onPaste && (d = e.clipboardData) && (d = d.files).length === 1) {
      onPaste(d);
      e.preventDefault();
    }
  },

  //  Saves a reference to the textarea.
  handleRefTextarea (textarea) {
    this.textarea = textarea;
  },
};

//  The component.
export default class ComposerTextarea extends React.Component {

  //  Constructor.
  constructor (props) {
    super(props);
    assignHandlers(this, handlers);
    this.state = {
      suggestionsHidden: false,
      selectedSuggestion: 0,
      lastToken: null,
      tokenStart: 0,
    };

    //  Instance variables.
    this.textarea = null;
  }

  //  When we receive new suggestions, we unhide the suggestions window
  //  if we didn't have any suggestions before.
  componentWillReceiveProps (nextProps) {
    const { suggestions } = this.props;
    const { suggestionsHidden } = this.state;
    if (nextProps.suggestions && nextProps.suggestions !== suggestions && nextProps.suggestions.size > 0 && suggestionsHidden) {
      this.setState({ suggestionsHidden: false });
    }
  }

  //  Rendering.
  render () {
    const {
      handleBlur,
      handleChange,
      handleClickSuggestion,
      handleKeyDown,
      handleKeyUp,
      handlePaste,
      handleRefTextarea,
    } = this.handlers;
    const {
      advancedOptions,
      autoFocus,
      disabled,
      intl,
      onPickEmoji,
      suggestions,
      value,
    } = this.props;
    const {
      selectedSuggestion,
      suggestionsHidden,
    } = this.state;

    //  The result.
    return (
      <div className='composer--textarea'>
        <label>
          <span {...hiddenComponent}><FormattedMessage {...messages.placeholder} /></span>
          <ComposerTextareaIcons
            advancedOptions={advancedOptions}
            intl={intl}
          />
          <Textarea
            aria-autocomplete='list'
            autoFocus={autoFocus}
            className='textarea'
            disabled={disabled}
            inputRef={handleRefTextarea}
            onBlur={handleBlur}
            onChange={handleChange}
            onKeyDown={handleKeyDown}
            onKeyUp={handleKeyUp}
            onPaste={handlePaste}
            placeholder={intl.formatMessage(messages.placeholder)}
            value={value}
            style={{ direction: isRtl(value) ? 'rtl' : 'ltr' }}
          />
        </label>
        <EmojiPicker onPickEmoji={onPickEmoji} />
        <ComposerTextareaSuggestions
          hidden={suggestionsHidden}
          onSuggestionClick={handleClickSuggestion}
          suggestions={suggestions}
          value={selectedSuggestion}
        />
      </div>
    );
  }

}

//  Props.
ComposerTextarea.propTypes = {
  advancedOptions: ImmutablePropTypes.map,
  autoFocus: PropTypes.bool,
  disabled: PropTypes.bool,
  intl: PropTypes.object.isRequired,
  onChange: PropTypes.func,
  onPaste: PropTypes.func,
  onPickEmoji: PropTypes.func,
  onSubmit: PropTypes.func,
  onSecondarySubmit: PropTypes.func,
  onSuggestionsClearRequested: PropTypes.func,
  onSuggestionsFetchRequested: PropTypes.func,
  onSuggestionSelected: PropTypes.func,
  suggestions: ImmutablePropTypes.list,
  value: PropTypes.string,
};

//  Default props.
ComposerTextarea.defaultProps = { autoFocus: true };

import PropTypes from 'prop-types';
import { useCallback, useRef, useState, useEffect, forwardRef } from 'react';

import classNames from 'classnames';

import ImmutablePropTypes from 'react-immutable-proptypes';

import Overlay from 'react-overlays/Overlay';
import Textarea from 'react-textarea-autosize';

import AutosuggestAccountContainer from '../features/compose/containers/autosuggest_account_container';

import AutosuggestEmoji from './autosuggest_emoji';
import { AutosuggestHashtag } from './autosuggest_hashtag';

const textAtCursorMatchesToken = (str, caretPosition) => {
  let word;

  let left  = str.slice(0, caretPosition).search(/\S+$/);
  let right = str.slice(caretPosition).search(/\s/);

  if (right < 0) {
    word = str.slice(left);
  } else {
    word = str.slice(left, right + caretPosition);
  }

  if (!word || word.trim().length < 3 || ['@', ':', '#'].indexOf(word[0]) === -1) {
    return [null, null];
  }

  word = word.trim().toLowerCase();

  if (word.length > 0) {
    return [left + 1, word];
  } else {
    return [null, null];
  }
};

const AutosuggestTextarea = forwardRef(({
  value,
  suggestions,
  disabled,
  placeholder,
  onSuggestionSelected,
  onSuggestionsClearRequested,
  onSuggestionsFetchRequested,
  onChange,
  onKeyUp,
  onKeyDown,
  onPaste,
  onFocus,
  autoFocus = true,
  lang,
}, textareaRef) => {

  const [suggestionsHidden, setSuggestionsHidden] = useState(true);
  const [selectedSuggestion, setSelectedSuggestion] = useState(0);
  const lastTokenRef = useRef(null);
  const tokenStartRef = useRef(0);

  const handleChange = useCallback((e) => {
    const [ tokenStart, token ] = textAtCursorMatchesToken(e.target.value, e.target.selectionStart);

    if (token !== null && lastTokenRef.current !== token) {
      tokenStartRef.current = tokenStart;
      lastTokenRef.current = token;
      setSelectedSuggestion(0);
      onSuggestionsFetchRequested(token);
    } else if (token === null) {
      lastTokenRef.current = null;
      onSuggestionsClearRequested();
    }

    onChange(e);
  }, [onSuggestionsFetchRequested, onSuggestionsClearRequested, onChange, setSelectedSuggestion]);

  const handleKeyDown = useCallback((e) => {
    if (disabled) {
      e.preventDefault();
      return;
    }

    if (e.which === 229 || e.isComposing) {
      // Ignore key events during text composition
      // e.key may be a name of the physical key even in this case (e.x. Safari / Chrome on Mac)
      return;
    }

    switch(e.key) {
    case 'Escape':
      if (suggestions.size === 0 || suggestionsHidden) {
        document.querySelector('.ui').parentElement.focus();
      } else {
        e.preventDefault();
        setSuggestionsHidden(true);
      }

      break;
    case 'ArrowDown':
      if (suggestions.size > 0 && !suggestionsHidden) {
        e.preventDefault();
        setSelectedSuggestion(Math.min(selectedSuggestion + 1, suggestions.size - 1));
      }

      break;
    case 'ArrowUp':
      if (suggestions.size > 0 && !suggestionsHidden) {
        e.preventDefault();
        setSelectedSuggestion(Math.max(selectedSuggestion - 1, 0));
      }

      break;
    case 'Enter':
    case 'Tab':
      // Select suggestion
      if (lastTokenRef.current !== null && suggestions.size > 0 && !suggestionsHidden) {
        e.preventDefault();
        e.stopPropagation();
        onSuggestionSelected(tokenStartRef.current, lastTokenRef.current, suggestions.get(selectedSuggestion));
      }

      break;
    }

    if (e.defaultPrevented || !onKeyDown) {
      return;
    }

    onKeyDown(e);
  }, [disabled, suggestions, suggestionsHidden, selectedSuggestion, setSelectedSuggestion, setSuggestionsHidden, onSuggestionSelected, onKeyDown]);

  const handleBlur = useCallback(() => {
    setSuggestionsHidden(true);
  }, [setSuggestionsHidden]);

  const handleFocus = useCallback((e) => {
    if (onFocus) {
      onFocus(e);
    }
  }, [onFocus]);

  const handleSuggestionClick = useCallback((e) => {
    const suggestion = suggestions.get(e.currentTarget.getAttribute('data-index'));
    e.preventDefault();
    onSuggestionSelected(tokenStartRef.current, lastTokenRef.current, suggestion);
    textareaRef.current?.focus();
  }, [suggestions, onSuggestionSelected, textareaRef]);

  const handlePaste = useCallback((e) => {
    if (e.clipboardData && e.clipboardData.files.length === 1) {
      onPaste(e.clipboardData.files);
      e.preventDefault();
    }
  }, [onPaste]);

  // Show the suggestions again whenever they change and the textarea is focused
  useEffect(() => {
    if (suggestions.size > 0 && textareaRef.current === document.activeElement) {
      setSuggestionsHidden(false);
    }
  }, [suggestions, textareaRef, setSuggestionsHidden]);

  const renderSuggestion = (suggestion, i) => {
    let inner, key;

    if (suggestion.type === 'emoji') {
      inner = <AutosuggestEmoji emoji={suggestion} />;
      key   = suggestion.id;
    } else if (suggestion.type === 'hashtag') {
      inner = <AutosuggestHashtag tag={suggestion} />;
      key   = suggestion.name;
    } else if (suggestion.type === 'account') {
      inner = <AutosuggestAccountContainer id={suggestion.id} />;
      key   = suggestion.id;
    }

    return (
      <div role='button' tabIndex={0} key={key} data-index={i} className={classNames('autosuggest-textarea__suggestions__item', { selected: i === selectedSuggestion })} onMouseDown={handleSuggestionClick}>
        {inner}
      </div>
    );
  };

  return (
    <div className='autosuggest-textarea'>
      <Textarea
        ref={textareaRef}
        className='autosuggest-textarea__textarea'
        disabled={disabled}
        placeholder={placeholder}
        autoFocus={autoFocus}
        value={value}
        onChange={handleChange}
        onKeyDown={handleKeyDown}
        onKeyUp={onKeyUp}
        onFocus={handleFocus}
        onBlur={handleBlur}
        onPaste={handlePaste}
        dir='auto'
        aria-autocomplete='list'
        aria-label={placeholder}
        lang={lang}
      />

      <Overlay show={!(suggestionsHidden || suggestions.isEmpty())} offset={[0, 0]} placement='bottom' target={textareaRef} popperConfig={{ strategy: 'fixed' }}>
        {({ props }) => (
          <div {...props}>
            <div className='autosuggest-textarea__suggestions' style={{ width: textareaRef.current?.clientWidth }}>
              {suggestions.map(renderSuggestion)}
            </div>
          </div>
        )}
      </Overlay>
    </div>
  );
});

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
  onFocus:PropTypes.func,
  autoFocus: PropTypes.bool,
  lang: PropTypes.string,
};

export default AutosuggestTextarea;

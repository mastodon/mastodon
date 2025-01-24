import PropTypes from 'prop-types';
import { useCallback, useRef, useState, useEffect, useMemo } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import classNames from 'classnames';

import { createSelector } from '@reduxjs/toolkit';
import { Map as ImmutableMap } from 'immutable';

import { supportsPassiveEvents } from 'detect-passive-events';
import fuzzysort from 'fuzzysort';
import Overlay from 'react-overlays/Overlay';

import CancelIcon from '@/material-icons/400-24px/cancel-fill.svg?react';
import SearchIcon from '@/material-icons/400-24px/search.svg?react';
import TranslateIcon from '@/material-icons/400-24px/translate.svg?react';
import { changeComposeLanguage } from 'mastodon/actions/compose';
import { Icon } from 'mastodon/components/icon';
import { languages as preloadedLanguages } from 'mastodon/initial_state';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { debouncedGuess } from '../util/language_detection';

const messages = defineMessages({
  changeLanguage: { id: 'compose.language.change', defaultMessage: 'Change language' },
  search: { id: 'compose.language.search', defaultMessage: 'Search languages...' },
  clear: { id: 'emoji_button.clear', defaultMessage: 'Clear' },
});

const listenerOptions = supportsPassiveEvents ? { passive: true, capture: true } : true;

const getFrequentlyUsedLanguages = createSelector([
  state => state.getIn(['settings', 'frequentlyUsedLanguages'], ImmutableMap()),
], languageCounters => (
  languageCounters.keySeq()
    .sort((a, b) => languageCounters.get(a) - languageCounters.get(b))
    .reverse()
    .toArray()
));

const LanguageDropdownMenu = ({ value, guess, onClose, onChange, languages = preloadedLanguages, intl }) => {
  const [searchValue, setSearchValue] = useState('');
  const nodeRef = useRef(null);
  const listNodeRef = useRef(null);

  const frequentlyUsedLanguages = useAppSelector(getFrequentlyUsedLanguages);

  const handleSearchChange = useCallback(({ target }) => {
    setSearchValue(target.value);
  }, [setSearchValue]);

  const handleClick = useCallback((e) => {
    const value = e.currentTarget.getAttribute('data-index');

    e.preventDefault();

    onClose();
    onChange(value);
  }, [onClose, onChange]);

  const handleKeyDown = useCallback(e => {
    const index = Array.from(listNodeRef.current.childNodes).findIndex(node => node === e.currentTarget);

    let element = null;

    switch(e.key) {
    case 'Escape':
      onClose();
      break;
    case ' ':
    case 'Enter':
      handleClick(e);
      break;
    case 'ArrowDown':
      element = listNodeRef.current.childNodes[index + 1] || listNodeRef.current.firstChild;
      break;
    case 'ArrowUp':
      element = listNodeRef.current.childNodes[index - 1] || listNodeRef.current.lastChild;
      break;
    case 'Tab':
      if (e.shiftKey) {
        element = listNodeRef.current.childNodes[index - 1] || listNodeRef.current.lastChild;
      } else {
        element = listNodeRef.current.childNodes[index + 1] || listNodeRef.current.firstChild;
      }
      break;
    case 'Home':
      element = listNodeRef.current.firstChild;
      break;
    case 'End':
      element = listNodeRef.current.lastChild;
      break;
    }

    if (element) {
      element.focus();
      e.preventDefault();
      e.stopPropagation();
    }
  }, [onClose, handleClick]);

  const handleSearchKeyDown = useCallback(e => {
    let element = null;

    switch(e.key) {
    case 'Tab':
    case 'ArrowDown':
      element = listNodeRef.current.firstChild;

      if (element) {
        element.focus();
        e.preventDefault();
        e.stopPropagation();
      }

      break;
    case 'Enter':
      element = listNodeRef.current.firstChild;

      if (element) {
        onChange(element.getAttribute('data-index'));
        onClose();
      }
      break;
    case 'Escape':
      if (searchValue !== '') {
        e.preventDefault();
        this.handleClear();
      }

      break;
    }
  }, [onChange, onClose, searchValue]);

  const handleClear = useCallback(() => {
    setSearchValue('');
  }, [setSearchValue]);

  const isSearching = searchValue !== '';

  useEffect(() => {
    const handleDocumentClick = (e) => {
      if (nodeRef.current && !nodeRef.current.contains(e.target)) {
        onClose();
        e.stopPropagation();
      }
    };

    document.addEventListener('click', handleDocumentClick, { capture: true });
    document.addEventListener('touchend', handleDocumentClick, listenerOptions);

    // Because of https://github.com/react-bootstrap/react-bootstrap/issues/2614 we need
    // to wait for a frame before focusing
    requestAnimationFrame(() => {
      if (nodeRef.current) {
        const element = nodeRef.current.querySelector('input[type="search"]');
        if (element) element.focus();
      }
    });

    return () => {
      document.removeEventListener('click', handleDocumentClick, { capture: true });
      document.removeEventListener('touchend', handleDocumentClick, listenerOptions);
    };
  }, [onClose]);

  const results = useMemo(() => {
    if (searchValue === '') {
      return [...languages].sort((a, b) => {

        if (guess && a[0] === guess) { // Push guessed language higher than current selection
          return -1;
        } else if (guess && b[0] === guess) {
          return 1;
        } else if (a[0] === value) { // Push current selection to the top of the list
          return -1;
        } else if (b[0] === value) {
          return 1;
        } else {
          // Sort according to frequently used languages

          const indexOfA = frequentlyUsedLanguages.indexOf(a[0]);
          const indexOfB = frequentlyUsedLanguages.indexOf(b[0]);

          return ((indexOfA > -1 ? indexOfA : Infinity) - (indexOfB > -1 ? indexOfB : Infinity));
        }
      });
    }

    return fuzzysort.go(searchValue, languages, {
      keys: ['0', '1', '2'],
      limit: 5,
      threshold: -10000,
    }).map(result => result.obj);
  }, [searchValue, languages, guess, frequentlyUsedLanguages, value]);

  return (
    <div ref={nodeRef}>
      <div className='emoji-mart-search'>
        <input type='search' value={searchValue} onChange={handleSearchChange} onKeyDown={handleSearchKeyDown} placeholder={intl.formatMessage(messages.search)} />
        <button type='button' className='emoji-mart-search-icon' disabled={!isSearching} aria-label={intl.formatMessage(messages.clear)} onClick={handleClear}><Icon icon={!isSearching ? SearchIcon : CancelIcon} /></button>
      </div>

      <div className='language-dropdown__dropdown__results emoji-mart-scroll' role='listbox' ref={listNodeRef}>
        {results.map((lang) => (
          <div key={lang[0]} role='option' tabIndex={0} data-index={lang[0]} className={classNames('language-dropdown__dropdown__results__item', { active: lang[0] === value })} aria-selected={lang[0] === value} onClick={handleClick} onKeyDown={handleKeyDown}>
            <span className='language-dropdown__dropdown__results__item__native-name' lang={lang[0]}>{lang[2]}</span> <span className='language-dropdown__dropdown__results__item__common-name'>({lang[1]})</span>
          </div>
        ))}
      </div>
    </div>
  );
};

LanguageDropdownMenu.propTypes = {
  value: PropTypes.string.isRequired,
  guess: PropTypes.string,
  onClose: PropTypes.func.isRequired,
  onChange: PropTypes.func.isRequired,
  languages: PropTypes.arrayOf(PropTypes.arrayOf(PropTypes.string)),
  intl: PropTypes.object,
};

export const LanguageDropdown = () => {
  const [open, setOpen] = useState(false);
  const [placement, setPlacement] = useState('bottom');
  const [guess, setGuess] = useState('');
  const activeElementRef = useRef(null);
  const targetRef = useRef(null);

  const intl = useIntl();

  const dispatch = useAppDispatch();
  const value = useAppSelector((state) => state.compose.get('language'));
  const text = useAppSelector((state) => state.compose.get('text'));

  const current = preloadedLanguages.find(lang => lang[0] === value) ?? [];

  const handleToggle = useCallback(() => {
    if (open && activeElementRef.current)
      activeElementRef.current.focus({ preventScroll: true });

    setOpen(!open);
  }, [open, setOpen]);

  const handleClose = useCallback(() => {
    if (open && activeElementRef.current)
      activeElementRef.current.focus({ preventScroll: true });

    setOpen(false);
  }, [open, setOpen]);

  const handleChange = useCallback((value) => {
    dispatch(changeComposeLanguage(value));
  }, [dispatch]);

  const handleOverlayEnter = useCallback(({ placement }) => {
    setPlacement(placement);
  }, [setPlacement]);

  useEffect(() => {
    if (text.length > 20) {
      debouncedGuess(text, setGuess);
    } else {
      setGuess('');
    }
  }, [text, setGuess]);

  return (
    <div ref={targetRef}>
      <button
        type='button'
        title={intl.formatMessage(messages.changeLanguage)}
        aria-expanded={open}
        onClick={handleToggle}
        className={classNames('dropdown-button', { active: open, warning: guess !== '' && guess !== value })}
      >
        <Icon icon={TranslateIcon} />
        <span className='dropdown-button__label'>{current[2] ?? value}</span>
      </button>

      <Overlay show={open} offset={[5, 5]} placement={placement} flip target={targetRef} popperConfig={{ strategy: 'fixed', onFirstUpdate: handleOverlayEnter }}>
        {({ props, placement }) => (
          <div {...props}>
            <div className={`dropdown-animation language-dropdown__dropdown ${placement}`} >
              <LanguageDropdownMenu
                value={value}
                guess={guess}
                onClose={handleClose}
                onChange={handleChange}
              />
            </div>
          </div>
        )}
      </Overlay>
    </div>
  );
};

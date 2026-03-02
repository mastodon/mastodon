import { useCallback, useRef, useState, useEffect, useMemo } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import classNames from 'classnames';

import { createSelector } from '@reduxjs/toolkit';
import { Map as ImmutableMap } from 'immutable';

import fuzzysort from 'fuzzysort';
import Overlay from 'react-overlays/Overlay';
import type { State, Placement } from 'react-overlays/usePopper';

import CancelIcon from '@/material-icons/400-24px/cancel-fill.svg?react';
import SearchIcon from '@/material-icons/400-24px/search.svg?react';
import TranslateIcon from '@/material-icons/400-24px/translate.svg?react';
import { changeComposeLanguage } from 'mastodon/actions/compose';
import { Icon } from 'mastodon/components/icon';
import { languages as preloadedLanguages } from 'mastodon/initial_state';
import type { RootState } from 'mastodon/store';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { debouncedGuess } from '../util/language_detection';

const messages = defineMessages({
  changeLanguage: {
    id: 'compose.language.change',
    defaultMessage: 'Change language',
  },
  search: {
    id: 'compose.language.search',
    defaultMessage: 'Search languages...',
  },
  clear: { id: 'emoji_button.clear', defaultMessage: 'Clear' },
});

type Language = [string, string, string];

const getFrequentlyUsedLanguages = createSelector(
  [
    (state: RootState) =>
      (state.settings as ImmutableMap<string, unknown>).get(
        'frequentlyUsedLanguages',
        ImmutableMap(),
      ) as ImmutableMap<string, number>,
  ],
  (languageCounters) =>
    languageCounters
      .keySeq()
      .sort(
        (a, b) =>
          (languageCounters.get(a) ?? 0) - (languageCounters.get(b) ?? 0),
      )
      .reverse()
      .toArray(),
);

const isTextLongEnoughForGuess = (text: string) => text.length > 20;

const LanguageDropdownMenu: React.FC<{
  value: string;
  guess?: string;
  onClose: () => void;
  onChange: (arg0: string) => void;
}> = ({ value, guess, onClose, onChange }) => {
  const languages = preloadedLanguages as Language[];
  const intl = useIntl();
  const [searchValue, setSearchValue] = useState('');
  const nodeRef = useRef<HTMLDivElement>(null);
  const listNodeRef = useRef<HTMLDivElement>(null);

  const frequentlyUsedLanguages = useAppSelector(getFrequentlyUsedLanguages);

  const handleSearchChange = useCallback(
    ({ target }: React.ChangeEvent<HTMLInputElement>) => {
      setSearchValue(target.value);
    },
    [setSearchValue],
  );

  const handleClick = useCallback(
    (e: React.MouseEvent | React.KeyboardEvent) => {
      const value = e.currentTarget.getAttribute('data-index');

      if (!value) {
        return;
      }

      e.preventDefault();

      onClose();
      onChange(value);
    },
    [onClose, onChange],
  );

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      if (!listNodeRef.current) {
        return;
      }

      const index = Array.from(listNodeRef.current.childNodes).findIndex(
        (node) => node === e.currentTarget,
      );

      let element = null;

      switch (e.key) {
        case 'Escape':
          onClose();
          break;
        case ' ':
        case 'Enter':
          handleClick(e);
          break;
        case 'ArrowDown':
          element =
            listNodeRef.current.childNodes[index + 1] ??
            listNodeRef.current.firstChild;
          break;
        case 'ArrowUp':
          element =
            listNodeRef.current.childNodes[index - 1] ??
            listNodeRef.current.lastChild;
          break;
        case 'Tab':
          if (e.shiftKey) {
            element =
              listNodeRef.current.childNodes[index - 1] ??
              listNodeRef.current.lastChild;
          } else {
            element =
              listNodeRef.current.childNodes[index + 1] ??
              listNodeRef.current.firstChild;
          }
          break;
        case 'Home':
          element = listNodeRef.current.firstChild;
          break;
        case 'End':
          element = listNodeRef.current.lastChild;
          break;
      }

      if (element && element instanceof HTMLElement) {
        element.focus();
        e.preventDefault();
        e.stopPropagation();
      }
    },
    [onClose, handleClick],
  );

  const handleSearchKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      let element = null;

      if (!listNodeRef.current) {
        return;
      }

      switch (e.key) {
        case 'Tab':
        case 'ArrowDown':
          element = listNodeRef.current.firstChild;

          if (element && element instanceof HTMLElement) {
            element.focus();
            e.preventDefault();
            e.stopPropagation();
          }

          break;
        case 'Enter':
          element = listNodeRef.current.firstChild;

          if (element && element instanceof HTMLElement) {
            const value = element.getAttribute('data-index');

            if (value) {
              onChange(value);
              onClose();
            }
          }
          break;
        case 'Escape':
          if (searchValue !== '') {
            e.preventDefault();
            setSearchValue('');
          }

          break;
      }
    },
    [setSearchValue, onChange, onClose, searchValue],
  );

  const handleClear = useCallback(() => {
    setSearchValue('');
  }, [setSearchValue]);

  const isSearching = searchValue !== '';

  useEffect(() => {
    const handleDocumentClick = (e: MouseEvent) => {
      if (
        nodeRef.current &&
        e.target instanceof HTMLElement &&
        !nodeRef.current.contains(e.target)
      ) {
        onClose();
        e.stopPropagation();
      }
    };

    document.addEventListener('click', handleDocumentClick, { capture: true });

    // Because of https://github.com/react-bootstrap/react-bootstrap/issues/2614 we need
    // to wait for a frame before focusing
    requestAnimationFrame(() => {
      if (nodeRef.current) {
        const element = nodeRef.current.querySelector<HTMLInputElement>(
          'input[type="search"]',
        );
        if (element) element.focus();
      }
    });

    return () => {
      document.removeEventListener('click', handleDocumentClick);
    };
  }, [onClose]);

  const results = useMemo(() => {
    if (searchValue === '') {
      return [...languages].sort((a, b) => {
        if (guess && a[0] === guess) {
          // Push guessed language higher than current selection
          return -1;
        } else if (guess && b[0] === guess) {
          return 1;
        } else if (a[0] === value) {
          // Push current selection to the top of the list
          return -1;
        } else if (b[0] === value) {
          return 1;
        } else {
          // Sort according to frequently used languages

          const indexOfA = frequentlyUsedLanguages.indexOf(a[0]);
          const indexOfB = frequentlyUsedLanguages.indexOf(b[0]);

          return (
            (indexOfA > -1 ? indexOfA : Infinity) -
            (indexOfB > -1 ? indexOfB : Infinity)
          );
        }
      });
    }

    return fuzzysort
      .go(searchValue, languages, {
        keys: ['0', '1', '2'],
        limit: 5,
        threshold: -10000,
      })
      .map((result) => result.obj);
  }, [searchValue, languages, guess, frequentlyUsedLanguages, value]);

  return (
    <div ref={nodeRef}>
      <div className='emoji-mart-search'>
        <input
          type='search'
          value={searchValue}
          onChange={handleSearchChange}
          onKeyDown={handleSearchKeyDown}
          placeholder={intl.formatMessage(messages.search)}
        />
        <button
          type='button'
          className='emoji-mart-search-icon'
          disabled={!isSearching}
          aria-label={intl.formatMessage(messages.clear)}
          onClick={handleClear}
        >
          <Icon id='' icon={!isSearching ? SearchIcon : CancelIcon} />
        </button>
      </div>

      <div
        className='language-dropdown__dropdown__results emoji-mart-scroll'
        role='listbox'
        ref={listNodeRef}
      >
        {results.map((lang) => (
          <div
            key={lang[0]}
            role='option'
            tabIndex={0}
            data-index={lang[0]}
            className={classNames(
              'language-dropdown__dropdown__results__item',
              { active: lang[0] === value },
            )}
            aria-selected={lang[0] === value}
            onClick={handleClick}
            onKeyDown={handleKeyDown}
          >
            <span
              className='language-dropdown__dropdown__results__item__native-name'
              lang={lang[0]}
            >
              {lang[2]}
            </span>{' '}
            <span className='language-dropdown__dropdown__results__item__common-name'>
              ({lang[1]})
            </span>
          </div>
        ))}
      </div>
    </div>
  );
};

export const LanguageDropdown: React.FC = () => {
  const [open, setOpen] = useState(false);
  const [placement, setPlacement] = useState<Placement | undefined>('bottom');
  const [guess, setGuess] = useState('');
  const activeElementRef = useRef<HTMLElement | null>(null);
  const targetRef = useRef(null);

  const intl = useIntl();

  const dispatch = useAppDispatch();
  const value = useAppSelector(
    (state) => state.compose.get('language') as string,
  );
  const text = useAppSelector((state) => state.compose.get('text') as string);

  const current =
    (preloadedLanguages as Language[]).find((lang) => lang[0] === value) ?? [];

  const handleMouseDown = useCallback(() => {
    if (!open && document.activeElement instanceof HTMLElement) {
      activeElementRef.current = document.activeElement;
    }
  }, [open]);

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

  const handleChange = useCallback(
    (value: string) => {
      dispatch(changeComposeLanguage(value));
    },
    [dispatch],
  );

  const handleOverlayEnter = useCallback(
    (state: Partial<State>) => {
      setPlacement(state.placement);
    },
    [setPlacement],
  );

  useEffect(() => {
    if (isTextLongEnoughForGuess(text)) {
      debouncedGuess(text, setGuess);
    } else {
      debouncedGuess.cancel();
    }
  }, [text, setGuess]);

  // Keeping track of the previous render's text length here
  // to be able to reset the guess when the text length drops
  // below the threshold needed to make a guess
  const [wasLongText, setWasLongText] = useState(() =>
    isTextLongEnoughForGuess(text),
  );
  if (wasLongText !== isTextLongEnoughForGuess(text)) {
    setWasLongText(isTextLongEnoughForGuess(text));

    if (wasLongText) {
      setGuess('');
    }
  }

  return (
    <>
      <button
        type='button'
        ref={targetRef}
        title={intl.formatMessage(messages.changeLanguage)}
        aria-expanded={open}
        onClick={handleToggle}
        onMouseDown={handleMouseDown}
        className={classNames('dropdown-button', {
          active: open,
          warning: guess !== '' && guess !== value,
        })}
      >
        <Icon id='translate' icon={TranslateIcon} />
        <span className='dropdown-button__label'>{current[2] ?? value}</span>
      </button>

      <Overlay
        show={open}
        offset={[5, 5]}
        placement={placement}
        flip
        target={targetRef}
        popperConfig={{ strategy: 'fixed', onFirstUpdate: handleOverlayEnter }}
      >
        {({ props, placement }) => (
          <div {...props}>
            <div
              className={`dropdown-animation language-dropdown__dropdown ${placement}`}
            >
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
    </>
  );
};

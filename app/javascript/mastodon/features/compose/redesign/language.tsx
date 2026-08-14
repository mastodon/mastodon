import type React from 'react';
import { useCallback, useEffect, useRef, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import { TranslateIcon } from '@phosphor-icons/react';

import { changeComposeLanguage } from '@/mastodon/actions/compose';
import { IconButton } from '@/mastodon/components/button/redesign';
import { DropdownPopover } from '@/mastodon/components/dropdown/redesign';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { LanguageDropdownMenu } from '../components/language_dropdown';

import classes from './styles.module.scss';

export const LanguageButton: React.FC = () => {
  const [open, setOpen] = useState(false);
  const [trigger, setTrigger] = useState<HTMLElement | null>(null);
  const activeElementRef = useRef<HTMLElement | null>(null);

  const handleMouseDown = useCallback(() => {
    if (!open && document.activeElement instanceof HTMLElement) {
      activeElementRef.current = document.activeElement;
    }
  }, [open]);

  const handleToggle = useCallback(() => {
    if (open && activeElementRef.current)
      activeElementRef.current.focus({ preventScroll: true });

    setOpen(!open);
  }, [open]);

  const handleClose = useCallback(() => {
    if (open && activeElementRef.current)
      activeElementRef.current.focus({ preventScroll: true });

    setOpen(false);
  }, [open]);

  return (
    <>
      <IconButton
        icon={TranslateIcon}
        size='sm'
        ref={setTrigger}
        aria-expanded={open}
        onClick={handleToggle}
        onMouseDown={handleMouseDown}
      >
        <FormattedMessage
          id='compose.language.change'
          defaultMessage='Change language'
        />
      </IconButton>

      <DropdownPopover
        isOpen={open}
        onClose={handleClose}
        offset={4}
        placement='bottom-end'
        reference={trigger}
        className={classes.languageMenu}
        maxWidth={280}
      >
        <LanguageDropdown onClose={handleClose} />
      </DropdownPopover>
    </>
  );
};

export const LanguageDropdown: React.FC<{ onClose: () => void }> = ({
  onClose,
}) => {
  const language = useAppSelector(
    (state) => state.compose.get('language') as string,
  );
  const guess = useLanguageGuess();

  const dispatch = useAppDispatch();
  const handleChange = useCallback(
    (newLanguage: string) => {
      dispatch(changeComposeLanguage(newLanguage));
      onClose();
    },
    [dispatch, onClose],
  );

  return (
    <LanguageDropdownMenu
      value={language}
      guess={guess}
      onChange={handleChange}
      onClose={onClose}
    />
  );
};

function useLanguageGuess() {
  const text = useAppSelector((state) => state.compose.get('text') as string);
  const [guess, setGuess] = useState('');

  useEffect(() => {
    void import('../util/language_detection').then(({ debouncedGuess }) => {
      if (text.length > 20) {
        debouncedGuess(text, setGuess);
      } else {
        debouncedGuess.cancel();
      }
    });
  }, [text]);

  // Keeping track of the previous render's text length here
  // to be able to reset the guess when the text length drops
  // below the threshold needed to make a guess
  const isLongText = text.length > 20;
  const [wasLongText, setWasLongText] = useState(() => isLongText);
  if (wasLongText !== isLongText) {
    setWasLongText(isLongText);

    if (wasLongText) {
      setGuess('');
    }
  }

  return guess;
}

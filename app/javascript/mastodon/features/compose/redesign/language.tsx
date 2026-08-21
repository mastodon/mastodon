import type React from 'react';
import { useCallback, useRef, useState } from 'react';

import { TranslateIcon } from '@phosphor-icons/react';

import { changeComposeLanguage } from '@/mastodon/actions/compose';
import { Button } from '@/mastodon/components/button/redesign';
import { PopoverMenuCard } from '@/mastodon/components/menu/card';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { LanguageDropdownMenu } from '../components/language_dropdown';

import { languageName, useLanguageGuess } from './hooks';
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

  const langCode = useAppSelector(
    (state) => state.compose.get('language') as string,
  );
  const language = languageName(langCode);

  return (
    <>
      <Button
        leadingIcon={TranslateIcon}
        size='sm'
        ref={setTrigger}
        aria-expanded={open}
        onClick={handleToggle}
        onMouseDown={handleMouseDown}
      >
        {language}
      </Button>

      <PopoverMenuCard
        isOpen={open}
        onClose={handleClose}
        offset={4}
        placement='bottom-end'
        reference={trigger}
        className={classes.languageMenu}
        maxWidth={280}
      >
        <LanguageDropdown onClose={handleClose} />
      </PopoverMenuCard>
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

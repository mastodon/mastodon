import type React from 'react';
import { useCallback, useId, useMemo, useState } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { MagnifyingGlassIcon, TranslateIcon } from '@phosphor-icons/react';

import { changeComposeLanguage } from '@/mastodon/actions/compose';
import { Button } from '@/mastodon/components/button/redesign';
import { Combobox } from '@/mastodon/components/form_fields';
import { ComboboxMenuItem } from '@/mastodon/components/form_fields/combobox_field';
import { PopoverMenuCard } from '@/mastodon/components/menu/card';
import { useToggle } from '@/mastodon/hooks/useToggle';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { useLanguageList } from './hooks';
import classes from './styles.module.scss';

const messages = defineMessages({
  searchPlaceholder: {
    id: 'compose.language.search',
    defaultMessage: 'Search languages...',
  },
});

export const LanguageButton: React.FC = () => {
  const langCode = useAppSelector(
    (state) => state.compose.get('language') as string,
  );

  const [isOpen, { onToggle: toggle, onFalse: close }] = useToggle(false);
  const [triggerElement, setTriggerElement] =
    useState<HTMLButtonElement | null>(null);

  return (
    <>
      <Button
        ref={setTriggerElement}
        size='sm'
        leadingIcon={TranslateIcon}
        aria-expanded={isOpen}
        onClick={toggle}
      >
        {langCode.toLocaleUpperCase()}
      </Button>

      <PopoverMenuCard
        isOpen={isOpen}
        placement='bottom-end'
        reference={triggerElement}
        container={null}
        className={classes.languageMenu}
        maxWidth={280}
        onClose={close}
      >
        <LanguageDropdown onClose={close} />
      </PopoverMenuCard>
    </>
  );
};

interface LanguageObject {
  id: string;
  code: string;
  name: string;
  localName: string;
}

export const LanguageDropdown: React.FC<{ onClose: () => void }> = ({
  onClose,
}) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const [inputValue, setInputValue] = useState('');
  const { languages, onSearch } = useLanguageList();

  const handleSearch: React.ChangeEventHandler<HTMLInputElement> = useCallback(
    (event) => {
      setInputValue(event.target.value);
      onSearch(event.target.value);
    },
    [onSearch],
  );
  const handleSelectLanguage = useCallback(
    ({ code }: LanguageObject) => {
      if (code) {
        dispatch(changeComposeLanguage(code));
        onClose();
      }
    },
    [dispatch, onClose],
  );

  const uniqueId = useId();
  const languageObjects = useMemo(
    () =>
      languages.map(([code, name, localName]) => ({
        id: `${uniqueId}-${code}`,
        code,
        name,
        localName,
      })),
    [languages, uniqueId],
  );

  return (
    <Combobox
      autoFocus
      listBoxType='in-place'
      value={inputValue}
      onChange={handleSearch}
      placeholder={intl.formatMessage(messages.searchPlaceholder)}
      icon={MagnifyingGlassIcon}
      items={languageObjects}
      renderItem={renderLanguageItem}
      onSelectItem={handleSelectLanguage}
    />
  );
};

function renderLanguageItem(language: LanguageObject) {
  return (
    <ComboboxMenuItem>
      <span>
        <strong>{language.localName}</strong> ({language.name})
      </span>
    </ComboboxMenuItem>
  );
}

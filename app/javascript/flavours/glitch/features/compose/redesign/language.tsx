import type React from 'react';
import { useCallback, useId, useMemo, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { MagnifyingGlassIcon, TranslateIcon } from '@phosphor-icons/react';

import { changeComposeLanguage } from '@/flavours/glitch/actions/compose';
import { Button } from '@/flavours/glitch/components/button/redesign';
import { Combobox } from '@/flavours/glitch/components/form_fields';
import { ComboboxMenuItem } from '@/flavours/glitch/components/form_fields/combobox_field';
import { PopoverMenuCard } from '@/flavours/glitch/components/menu/card';
import { useToggle } from '@/flavours/glitch/hooks/useToggle';
import { languages as initialStateLanguages } from '@/flavours/glitch/initial_state';
import { useAppDispatch, useAppSelector } from '@/flavours/glitch/store';

import { useLanguageList } from './hooks';
import classes from './styles.module.scss';

const messages = defineMessages({
  searchPlaceholder: {
    id: 'compose.language.search',
    defaultMessage: 'Search languages...',
  },
});

function getLanguageNameFromCode(code: string) {
  const language = initialStateLanguages?.find(
    ([languageCode]) => code === languageCode,
  );
  return language ? language[1] : undefined;
}

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
        tooltip={{
          type: 'description',
          text: (
            <FormattedMessage
              id='compose.language.change'
              defaultMessage='Change language'
            />
          ),
        }}
        onClick={toggle}
      >
        {langCode.toLocaleUpperCase()}
        <span className='sr-only'>({getLanguageNameFromCode(langCode)})</span>
      </Button>

      <PopoverMenuCard
        isOpen={isOpen}
        placement='bottom-end'
        strategy='fixed'
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
      wrapperClassName={classes.languageComboboxWrapper}
      listBoxClassName={classes.languageListBox}
    />
  );
};

function renderLanguageItem({ code, name, localName }: LanguageObject) {
  return (
    <ComboboxMenuItem>
      <span>
        <strong lang={code}>{localName}</strong> ({name})
      </span>
    </ComboboxMenuItem>
  );
}

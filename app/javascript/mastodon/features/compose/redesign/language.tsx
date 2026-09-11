import type React from 'react';
import { useCallback } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { MagnifyingGlassIcon } from '@phosphor-icons/react';

import { changeComposeLanguage } from '@/mastodon/actions/compose';
import { CaretIcon } from '@/mastodon/components/button/redesign';
import { TextInput } from '@/mastodon/components/form_fields/redesign';
import {
  Menu,
  MenuItem,
  MenuList,
  MenuTrigger,
} from '@/mastodon/components/menu';
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

  return (
    <Menu>
      <MenuTrigger size='sm' trailingIcon={CaretIcon}>
        {langCode.toLocaleUpperCase()}
      </MenuTrigger>

      <MenuList
        placement='bottom-end'
        className={classes.languageMenu}
        maxWidth={280}
      >
        <LanguageDropdown />
      </MenuList>
    </Menu>
  );
};

export const LanguageDropdown = () => {
  const { languages, onSearch } = useLanguageList();

  const dispatch = useAppDispatch();
  const handleChange: React.MouseEventHandler<HTMLButtonElement> = useCallback(
    (event) => {
      const newLanguage = event.currentTarget.dataset.language;
      if (newLanguage) {
        dispatch(changeComposeLanguage(newLanguage));
      }
    },
    [dispatch],
  );

  const intl = useIntl();
  const handleSearch: React.ChangeEventHandler<HTMLInputElement> = useCallback(
    (event) => {
      onSearch(event.target.value);
    },
    [onSearch],
  );

  return (
    <>
      <TextInput
        type='search'
        onChange={handleSearch}
        placeholder={intl.formatMessage(messages.searchPlaceholder)}
        icon={MagnifyingGlassIcon}
      />
      <div className={classes.languageList}>
        {languages.map((lang) => (
          <MenuItem
            key={lang[0]}
            onClick={handleChange}
            data-language={lang[0]}
            className={classes.languageItem}
          >
            <strong>{lang[2]}</strong>&nbsp;<span>({lang[1]})</span>
          </MenuItem>
        ))}

        {languages.length === 0 && (
          <FormattedMessage
            id='compose.language.not-found'
            defaultMessage='No language found'
          />
        )}
      </div>
    </>
  );
};

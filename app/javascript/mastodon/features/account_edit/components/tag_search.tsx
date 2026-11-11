import type { ChangeEventHandler, FC } from 'react';
import { useCallback, useId, useState } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { MagnifyingGlassIcon } from '@phosphor-icons/react';

import { Combobox } from '@/mastodon/components/form_fields';
import { ComboboxMenuItem } from '@/mastodon/components/form_fields/combobox_field';
import { useSearchTags } from '@/mastodon/hooks/useSearchTags';
import type { TagSearchResult } from '@/mastodon/hooks/useSearchTags';
import { addFeaturedTags } from '@/mastodon/reducers/slices/profile_edit';
import { useAppDispatch } from '@/mastodon/store';

import classes from '../styles.module.scss';

const messages = defineMessages({
  placeholder: {
    id: 'account_edit_tags.search_placeholder',
    defaultMessage: 'Enter a hashtag…',
  },
});

export const AccountEditTagSearch: FC = () => {
  const intl = useIntl();

  const [query, setQuery] = useState('');
  const {
    tags: suggestedTags,
    searchTags,
    resetSearch,
    isLoading,
  } = useSearchTags({
    query,
    // Remove existing featured tags from suggestions
    filterResults: (tag) => !tag.featuring,
  });

  const handleSearchChange: ChangeEventHandler<HTMLInputElement> = useCallback(
    (e) => {
      setQuery(e.target.value);
      searchTags(e.target.value);
    },
    [searchTags],
  );

  const dispatch = useAppDispatch();
  const handleSelect = useCallback(
    (item: TagSearchResult) => {
      resetSearch();
      setQuery('');
      void dispatch(addFeaturedTags({ names: [item.name] }));
    },
    [dispatch, resetSearch],
  );

  const inputId = useId();
  const inputLabel = intl.formatMessage(messages.placeholder);

  return (
    <>
      <label htmlFor={inputId} className='sr-only'>
        {inputLabel}
      </label>
      <Combobox
        id={inputId}
        value={query}
        onChange={handleSearchChange}
        placeholder={inputLabel}
        items={suggestedTags}
        isLoading={isLoading}
        renderItem={renderItem}
        onSelectItem={handleSelect}
        className={classes.autoComplete}
        icon={MagnifyingGlassIcon}
        type='search'
      />
    </>
  );
};

const renderItem = (item: TagSearchResult) => (
  <ComboboxMenuItem>{item.label ?? `#${item.name}`}</ComboboxMenuItem>
);

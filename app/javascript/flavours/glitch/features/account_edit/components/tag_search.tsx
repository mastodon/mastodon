import type { ChangeEventHandler, FC } from 'react';
import { useCallback, useMemo } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import type { ApiHashtagJSON } from '@/flavours/glitch/api_types/tags';
import { Combobox } from '@/flavours/glitch/components/form_fields';
import {
  addFeaturedTag,
  clearSearch,
  updateSearchQuery,
} from '@/flavours/glitch/reducers/slices/profile_edit';
import { useAppDispatch, useAppSelector } from '@/flavours/glitch/store';
import SearchIcon from '@/material-icons/400-24px/search.svg?react';

import classes from '../styles.module.scss';

type SearchResult = Omit<ApiHashtagJSON, 'url' | 'history'> & {
  label?: string;
};

const messages = defineMessages({
  placeholder: {
    id: 'account_edit_tags.search_placeholder',
    defaultMessage: 'Enter a hashtag…',
  },
  addTag: {
    id: 'account_edit_tags.add_tag',
    defaultMessage: 'Add #{tagName}',
  },
});

export const AccountEditTagSearch: FC = () => {
  const intl = useIntl();

  const {
    query,
    isLoading,
    results: rawResults,
  } = useAppSelector((state) => state.profileEdit.search);
  const results = useMemo(() => {
    if (!rawResults) {
      return [];
    }

    const results: SearchResult[] = [...rawResults]; // Make array mutable
    const trimmedQuery = query.trim();
    if (
      trimmedQuery.length > 0 &&
      results.every(
        (result) => result.name.toLowerCase() !== trimmedQuery.toLowerCase(),
      )
    ) {
      results.push({
        id: 'new',
        name: trimmedQuery,
        label: intl.formatMessage(messages.addTag, { tagName: trimmedQuery }),
      });
    }
    return results;
  }, [intl, query, rawResults]);

  const dispatch = useAppDispatch();
  const handleSearchChange: ChangeEventHandler<HTMLInputElement> = useCallback(
    (e) => {
      void dispatch(updateSearchQuery(e.target.value));
    },
    [dispatch],
  );

  const handleSelect = useCallback(
    (item: SearchResult) => {
      void dispatch(clearSearch());
      void dispatch(addFeaturedTag({ name: item.name }));
    },
    [dispatch],
  );

  return (
    <Combobox
      value={query}
      onChange={handleSearchChange}
      placeholder={intl.formatMessage(messages.placeholder)}
      items={results}
      isLoading={isLoading}
      renderItem={renderItem}
      onSelectItem={handleSelect}
      className={classes.autoComplete}
      icon={SearchIcon}
      type='search'
    />
  );
};

const renderItem = (item: SearchResult) => item.label ?? `#${item.name}`;

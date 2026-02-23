import type { ChangeEventHandler, FC } from 'react';
import { useCallback } from 'react';

import { useIntl } from 'react-intl';

import type { ApiFeaturedTagJSON } from '@/mastodon/api_types/tags';
import { Combobox } from '@/mastodon/components/form_fields';
import {
  addFeaturedTag,
  clearSearch,
  updateSearchQuery,
} from '@/mastodon/reducers/slices/profile_edit';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import SearchIcon from '@/material-icons/400-24px/search.svg?react';

import classes from '../styles.module.scss';

export const AccountEditTagSearch: FC = () => {
  const { query, isLoading, results } = useAppSelector(
    (state) => state.profileEdit.search,
  );

  const dispatch = useAppDispatch();
  const handleSearchChange: ChangeEventHandler<HTMLInputElement> = useCallback(
    (e) => {
      void dispatch(updateSearchQuery(e.target.value));
    },
    [dispatch],
  );

  const intl = useIntl();

  const handleSelect = useCallback(
    (item: ApiFeaturedTagJSON) => {
      void dispatch(clearSearch());
      void dispatch(addFeaturedTag({ name: item.name }));
    },
    [dispatch],
  );

  return (
    <Combobox
      value={query}
      onChange={handleSearchChange}
      placeholder={intl.formatMessage({
        id: 'account_edit_tags.search_placeholder',
        defaultMessage: 'Enter a hashtag…',
      })}
      items={results ?? []}
      isLoading={isLoading}
      renderItem={renderItem}
      onSelectItem={handleSelect}
      className={classes.autoComplete}
      icon={SearchIcon}
      type='search'
    />
  );
};

const renderItem = (item: ApiFeaturedTagJSON) => <p>#{item.name}</p>;

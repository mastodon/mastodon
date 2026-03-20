import { useCallback, useMemo, useRef, useState } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { useDebouncedCallback } from 'use-debounce';

import { apiGetSearch } from '../api/search';
import type { ApiHashtagJSON } from '../api_types/tags';

export type TagSearchResult = Omit<ApiHashtagJSON, 'url' | 'history'> & {
  label?: string;
};

const messages = defineMessages({
  addTag: {
    id: 'account_edit_tags.add_tag',
    defaultMessage: 'Add #{tagName}',
  },
});

const fetchHashtagSuggestions = ({
  q,
  limit,
  signal,
}: {
  q: string;
  limit: number;
  signal: AbortSignal;
}) => apiGetSearch({ q, type: 'hashtags', limit }, { signal });

export function useSearchTags({
  query,
  limit = 11,
  filterResults,
}: {
  query?: string;
  limit?: number;
  filterResults?: (account: ApiHashtagJSON) => boolean;
} = {}) {
  const intl = useIntl();
  const [fetchedTags, setFetchedTags] = useState<ApiHashtagJSON[]>([]);
  const [loadingState, setLoadingState] = useState<
    'idle' | 'loading' | 'error'
  >('idle');

  const searchRequestRef = useRef<AbortController | null>(null);

  const searchTags = useDebouncedCallback(
    (value: string) => {
      if (searchRequestRef.current) {
        searchRequestRef.current.abort();
      }

      if (value.trim().length === 0) {
        setFetchedTags([]);
        return;
      }

      setLoadingState('loading');

      searchRequestRef.current = new AbortController();

      void fetchHashtagSuggestions({
        q: value,
        limit,
        signal: searchRequestRef.current.signal,
      })
        .then(({ hashtags }) => {
          const tags = filterResults
            ? hashtags.filter(filterResults)
            : hashtags;
          setFetchedTags(tags);
          setLoadingState('idle');
        })
        .catch(() => {
          setLoadingState('error');
        });
    },
    500,
    { leading: true, trailing: true },
  );

  const resetSearch = useCallback(() => {
    setFetchedTags([]);
    setLoadingState('idle');
  }, []);

  // Add dedicated item for adding the current query
  const tags = useMemo(() => {
    if (!query?.trim() || !fetchedTags.length) {
      return fetchedTags;
    }

    const results: TagSearchResult[] = [...fetchedTags]; // Make array mutable
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
  }, [fetchedTags, query, intl]);

  return {
    tags,
    searchTags,
    resetSearch,
    isLoading: loadingState === 'loading',
    isError: loadingState === 'error',
  };
}

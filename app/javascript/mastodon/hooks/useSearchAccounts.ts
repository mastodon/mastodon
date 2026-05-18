import { useCallback, useRef, useState } from 'react';

import { useDebouncedCallback } from 'use-debounce';

import { fetchRelationships } from 'mastodon/actions/accounts';
import { importFetchedAccounts } from 'mastodon/actions/importer';
import { apiRequest } from 'mastodon/api';
import type { ApiAccountJSON } from 'mastodon/api_types/accounts';
import { useAppDispatch } from 'mastodon/store';

export function useSearchAccounts({
  onSettled,
  filterResults,
  resetOnInputClear = true,
  withRelationships = false,
}: {
  onSettled?: (value: string) => void;
  filterResults?: (account: ApiAccountJSON) => boolean;
  resetOnInputClear?: boolean;
  withRelationships?: boolean;
} = {}) {
  const dispatch = useAppDispatch();

  const [accounts, setAccounts] = useState<ApiAccountJSON[]>([]);
  const [loadingState, setLoadingState] = useState<
    'idle' | 'loading' | 'error'
  >('idle');

  const searchRequestRef = useRef<AbortController | null>(null);

  const searchAccounts = useDebouncedCallback(
    (value: string) => {
      if (searchRequestRef.current) {
        searchRequestRef.current.abort();
      }

      if (value.trim().length === 0) {
        onSettled?.('');
        if (resetOnInputClear) {
          setAccounts([]);
        }
        return;
      }

      setLoadingState('loading');

      searchRequestRef.current = new AbortController();

      void apiRequest<ApiAccountJSON[]>('GET', 'v1/accounts/search', {
        signal: searchRequestRef.current.signal,
        params: {
          q: value,
          resolve: true,
        },
      })
        .then((data) => {
          const accounts = filterResults ? data.filter(filterResults) : data;
          const accountIds = accounts.map((a) => a.id);
          dispatch(importFetchedAccounts(accounts));
          if (withRelationships) {
            dispatch(fetchRelationships(accountIds));
          }
          setAccounts(accounts);
          setLoadingState('idle');
          onSettled?.(value);
        })
        .catch(() => {
          setLoadingState('error');
          onSettled?.(value);
        });
    },
    500,
    { leading: true, trailing: true },
  );

  const resetAccounts = useCallback(() => {
    setAccounts([]);
  }, []);

  return {
    searchAccounts,
    resetAccounts,
    accounts,
    isLoading: loadingState === 'loading',
    isError: loadingState === 'error',
  };
}

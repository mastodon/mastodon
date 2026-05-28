import { useCallback, useEffect, useRef, useState } from 'react';

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
    async (value: string) => {
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

      try {
        const data = await apiRequest<ApiAccountJSON[]>(
          'GET',
          'v1/accounts/search',
          {
            signal: searchRequestRef.current.signal,
            params: {
              q: value,
              resolve: true,
            },
          },
        );
        const accounts = filterResults ? data.filter(filterResults) : data;
        const accountIds = accounts.map((a) => a.id);
        dispatch(importFetchedAccounts(accounts));
        if (withRelationships) {
          dispatch(fetchRelationships(accountIds));
        }
        setAccounts(accounts);
        setLoadingState('idle');
        onSettled?.(value);
      } catch {
        setLoadingState('error');
        onSettled?.(value);
      }
    },
    500,
    { leading: true, trailing: true },
  );

  const startSearch = useCallback(
    (value: string) => {
      void searchAccounts(value);
    },
    [searchAccounts],
  );

  const resetAccounts = useCallback(() => {
    setAccounts([]);
  }, []);

  return {
    searchAccounts: startSearch,
    resetAccounts,
    accounts,
    isLoading: loadingState === 'loading',
    isError: loadingState === 'error',
  };
}

export function useFollowingAccounts({
  accountId,
  filterResults,
  withRelationships = false,
}: {
  accountId: string | null;
  filterResults?: (account: ApiAccountJSON) => boolean;
  withRelationships?: boolean;
}) {
  const dispatch = useAppDispatch();

  const [accounts, setAccounts] = useState<ApiAccountJSON[] | null>(null);
  const [loadingState, setLoadingState] = useState<
    'idle' | 'loading' | 'error'
  >('idle');

  const requestRef = useRef<AbortController | null>(null);

  useEffect(() => {
    if (
      !accountId ||
      loadingState !== 'idle' ||
      accounts !== null ||
      requestRef.current
    ) {
      return;
    }

    async function doRequest() {
      requestRef.current = new AbortController();
      setLoadingState('loading');
      try {
        const data = await apiRequest<ApiAccountJSON[]>(
          'GET',
          `v1/accounts/${accountId}/following`,
          { params: { limit: 40 }, signal: requestRef.current.signal },
        );
        const accounts = filterResults ? data.filter(filterResults) : data;
        const accountIds = accounts.map((a) => a.id);
        dispatch(importFetchedAccounts(accounts));
        if (withRelationships) {
          dispatch(fetchRelationships(accountIds));
        }
        setAccounts(accounts);
        setLoadingState('idle');
      } catch {
        setLoadingState('error');
      }
    }
    void doRequest();
  }, [
    accountId,
    accounts,
    dispatch,
    filterResults,
    loadingState,
    withRelationships,
  ]);

  return {
    accounts: accounts ?? [],
    isLoading: loadingState === 'loading',
    isError: loadingState === 'error',
  };
}

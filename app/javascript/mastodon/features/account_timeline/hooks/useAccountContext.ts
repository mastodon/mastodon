import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useState,
} from 'react';

import { useStorageState } from '@/mastodon/hooks/useStorage';

interface AccountTimelineContextValue {
  accountId: string | null;
  boosts: boolean;
  replies: boolean;
  showAllPinned: boolean;
  setBoosts: (value: boolean) => void;
  setReplies: (value: boolean) => void;
  onShowAllPinned: () => void;
}

export const AccountTimelineContext =
  createContext<AccountTimelineContextValue | null>(null);

export function useAccountContext() {
  const values = useContext(AccountTimelineContext);
  if (!values) {
    throw new Error(
      'useAccountFilters must be used within an AccountTimelineProvider',
    );
  }
  return values;
}

export const useAccountContextValue = (accountId?: string | null) => {
  const storageOptions = {
    type: 'local',
    prefix: 'account-filters',
  } as const;

  const [boosts, setBoosts] = useStorageState<boolean>(
    'boosts',
    true,
    storageOptions,
  );

  const [replies, setReplies] = useStorageState<boolean>(
    'replies',
    false,
    storageOptions,
  );

  const handleSetBoosts = useCallback(
    (value: boolean) => {
      setBoosts(value);
    },
    [setBoosts],
  );
  const handleSetReplies = useCallback(
    (value: boolean) => {
      setReplies(value);
    },
    [setReplies],
  );

  const [showAllPinned, setShowAllPinned] = useState(false);
  const handleShowAllPinned = useCallback(() => {
    setShowAllPinned(true);
  }, []);

  // Memoize the context value to avoid unnecessary re-renders.
  return useMemo(
    () => ({
      accountId: accountId ?? null,
      boosts,
      replies,
      showAllPinned,
      setBoosts: handleSetBoosts,
      setReplies: handleSetReplies,
      onShowAllPinned: handleShowAllPinned,
    }),
    [
      accountId,
      boosts,
      handleSetBoosts,
      handleSetReplies,
      handleShowAllPinned,
      replies,
      showAllPinned,
    ],
  );
};

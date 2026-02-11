import type { FC, ReactNode } from 'react';
import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useState,
} from 'react';

import { useStorageState } from '@/mastodon/hooks/useStorage';

interface AccountTimelineContextValue {
  accountId: string;
  boosts: boolean;
  replies: boolean;
  showAllPinned: boolean;
  setBoosts: (value: boolean) => void;
  setReplies: (value: boolean) => void;
  onShowAllPinned: () => void;
}

const AccountTimelineContext =
  createContext<AccountTimelineContextValue | null>(null);

export const AccountTimelineProvider: FC<{
  accountId: string;
  children: ReactNode;
}> = ({ accountId, children }) => {
  const storageOptions = {
    type: 'session',
    prefix: `filters-${accountId}:`,
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
  const value = useMemo(
    () => ({
      accountId,
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

  return (
    <AccountTimelineContext.Provider value={value}>
      {children}
    </AccountTimelineContext.Provider>
  );
};

export function useAccountContext() {
  const values = useContext(AccountTimelineContext);
  if (!values) {
    throw new Error(
      'useAccountFilters must be used within an AccountTimelineProvider',
    );
  }
  return values;
}

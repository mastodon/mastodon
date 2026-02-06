import { useCallback, useState } from 'react';

import { useAccountId } from '@/mastodon/hooks/useAccountId';
import { useStorage } from '@/mastodon/hooks/useStorage';

export function useFilters() {
  const accountId = useAccountId();
  const { getItem, setItem } = useStorage({
    type: 'session',
    prefix: `filters-${accountId}:`,
  });
  const [boosts, setBoosts] = useState(
    () => (getItem('boosts') === '0' ? false : true), // Default to enabled.
  );
  const [replies, setReplies] = useState(() =>
    getItem('replies') === '1' ? true : false,
  );

  const handleSetBoosts = useCallback(
    (value: boolean) => {
      setBoosts(value);
      setItem('boosts', value ? '1' : '0');
    },
    [setBoosts, setItem],
  );
  const handleSetReplies = useCallback(
    (value: boolean) => {
      setReplies(value);
      setItem('replies', value ? '1' : '0');
    },
    [setReplies, setItem],
  );

  return {
    boosts,
    replies,
    setBoosts: handleSetBoosts,
    setReplies: handleSetReplies,
  };
}

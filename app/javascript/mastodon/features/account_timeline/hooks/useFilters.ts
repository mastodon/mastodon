import { useCallback } from 'react';

import { useSearchParam } from '@/mastodon/hooks/useSearchParam';

export function useFilters() {
  const [boosts, setBoosts] = useSearchParam('boosts');
  const [replies, setReplies] = useSearchParam('replies');

  const handleSetBoosts = useCallback(
    (value: boolean) => {
      setBoosts(value ? '1' : null);
    },
    [setBoosts],
  );
  const handleSetReplies = useCallback(
    (value: boolean) => {
      setReplies(value ? '1' : null);
    },
    [setReplies],
  );

  return {
    boosts: boosts === '1',
    replies: replies === '1',
    setBoosts: handleSetBoosts,
    setReplies: handleSetReplies,
  };
}

import { useLocation } from 'react-router-dom';

import type { LocationState } from '../components/router';

/**
 * Gets the current `reference` state from location state if present,
 * otherwise returns the passed-in fallback reference.
 *
 * `reference` is a string that we use to anonymously & locally track
 * where a follow is coming from, helping us understand which UI features
 * people actually use to discover people.
 */
export function useFollowReference(fallbackReference: string) {
  const { state } = useLocation<LocationState>();

  return state?.reference ?? fallbackReference;
}

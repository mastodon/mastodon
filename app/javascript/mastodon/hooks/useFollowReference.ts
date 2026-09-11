import { useLocation } from 'react-router-dom';

import type { LocationState } from '../components/router';

export function useFollowReference(fallbackReference: string) {
  const { state } = useLocation<LocationState>();

  return state?.reference ?? fallbackReference;
}

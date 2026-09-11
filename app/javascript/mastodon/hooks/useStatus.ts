import { selectExpandedStatus, selectPlainStatus } from '../selectors/statuses';
import { useAppSelector } from '../store';

export function useStatus(id?: string | null) {
  return useAppSelector((state) => selectPlainStatus(state, id));
}

/** Adds reblog status and account information to standard Status */
export function useExpandedStatus(id?: string | null) {
  return useAppSelector((state) =>
    selectExpandedStatus(state, id ?? undefined),
  );
}

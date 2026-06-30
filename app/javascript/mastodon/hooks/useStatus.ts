import { selectExpandedStatus, selectPlainStatus } from '../selectors/statuses';
import { useAppSelector } from '../store';

export function useStatus(id: string) {
  return useAppSelector((state) => selectPlainStatus(state, id));
}

export function useExpandedStatus(id: string) {
  return useAppSelector((state) => selectExpandedStatus(state, id));
}

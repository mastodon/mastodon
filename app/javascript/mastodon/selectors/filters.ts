import { createAppSelector } from 'mastodon/store';
import { toServerSideType } from 'mastodon/utils/filters';

import type { StatusContextType } from '../components/status/types';

import { selectExpandedStatus } from './statuses';

export interface FilterShape {
  id: string;
  title: string;
  context: string[];
  expires_at: string | null;
  filter_action: 'hide' | 'blur' | 'warn';
}

// TODO: move to `app/javascript/mastodon/models` and use more globally
type Filter = Immutable.Map<string, unknown>;

// TODO: move to `app/javascript/mastodon/models` and use more globally
type FilterResult = Immutable.Map<string, unknown>;

export const getFilters = createAppSelector(
  [
    (state) => state.filters as Immutable.Map<string, Filter>,
    (_, { contextType }: { contextType?: string }) => contextType,
  ],
  (filters, contextType) => {
    if (!contextType) {
      return null;
    }

    const now = new Date();
    const serverSideType = toServerSideType(contextType);

    return filters.filter((filter) => {
      const context = filter.get('context') as Immutable.List<string>;
      const expiration = filter.get('expires_at') as Date | null;
      return (
        context.includes(serverSideType) &&
        (expiration === null || expiration > now)
      );
    });
  },
);

export const selectPlainFilters = createAppSelector([getFilters], (filters) => {
  if (!filters) {
    return null;
  }
  return filters.toJS() as unknown as Record<string, FilterShape>;
});

export const selectStatusFilters = createAppSelector(
  [
    (state, { statusId }: { statusId?: string | null }) =>
      selectExpandedStatus(state, statusId ?? undefined),
    selectPlainFilters,
    (_, { warnInsteadOfHide }: { warnInsteadOfHide?: boolean }) =>
      warnInsteadOfHide,
  ],
  (status, filters) => {
    const results: FilterShape[] = [];
    if (!status || !filters) {
      return results;
    }
    const filtered = status.reblog?.filtered ?? status.filtered;
    for (const result of filtered) {
      const filter = filters[result.filter];
      if (!filter) {
        continue;
      }

      results.push(filter);
    }

    return results;
  },
);

export const selectStatusLoadingState = createAppSelector(
  [
    (state, { statusId }: { statusId?: string | null }) =>
      selectExpandedStatus(state, statusId ?? undefined),
    selectStatusFilters,
    (_, { warnInsteadOfHide }: { warnInsteadOfHide?: boolean }) =>
      warnInsteadOfHide,
  ],
  (status, filters, warnInsteadOfHide) => {
    if (!status) {
      return { state: 'not-found', status: null };
    }

    if (status.isLoading) {
      return { state: 'loading', status: null };
    }

    if (
      !warnInsteadOfHide &&
      filters.some((filter) => filter.filter_action === 'hide')
    ) {
      return { state: 'filtered', status: null };
    }

    return { state: 'loaded', status };
  },
);

export const selectMediaFilters = createAppSelector(
  [selectStatusFilters],
  (filters) =>
    filters
      .filter((filter) => filter.filter_action === 'blur')
      .map((filter) => filter.title),
);

export const getStatusHidden = createAppSelector(
  [
    (state, { contextType }: { contextType: StatusContextType }) =>
      getFilters(state, { contextType }),
    (state, { id }: { id: string }) =>
      state.statuses.getIn([id, 'filtered']) as
        | Immutable.List<FilterResult>
        | undefined,
  ],
  (filters, filtered) => {
    if (!filters) {
      return false;
    }

    return filtered?.some(
      (result) =>
        filters.getIn([result.get('filter'), 'filter_action']) === 'hide',
    );
  },
);

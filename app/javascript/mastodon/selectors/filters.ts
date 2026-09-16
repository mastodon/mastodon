import type { StatusContextType } from '@/mastodon/components/status/types';
import { createAppSelector } from '@/mastodon/store/typed_functions';
import { toServerSideType } from '@/mastodon/utils/filters';

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
    (state) => state.meta.get('me') as string | undefined,
    (_, { contextType }: { contextType?: StatusContextType }) => contextType,
  ],
  (status, filters, currentAccountId, contextType) => {
    const results: FilterShape[] = [];
    let filterAction: 'warn' | 'hide' | null = null;
    if (!status || !filters || status.account.acct === currentAccountId) {
      return { filters: results, filterAction };
    }

    const warnInsteadOfHide =
      !!contextType &&
      ['detailed', 'bookmarks', 'favourites', 'search'].includes(contextType);

    const filtered = status.reblog?.filtered ?? status.filtered;
    for (const result of filtered) {
      const filter = filters[result.filter];
      if (!filter) {
        continue;
      }

      if (filter.filter_action === 'hide' && !warnInsteadOfHide) {
        filterAction = 'hide';
      } else {
        filterAction ??= 'warn';
      }

      results.push(filter);
    }

    return { filters: results, filterAction };
  },
);

export const selectMediaFilters = createAppSelector(
  [selectStatusFilters],
  ({ filters }) =>
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

import { FILTERS_IMPORT } from '../actions/importer';
import { FILTERS_FETCH_SUCCESS } from '../actions/filters';
import { Map as ImmutableMap, is, fromJS } from 'immutable';

const normalizeFilter = (state, filter) => {
  const oldFilter = state.get(filter.id);

  // Do not overwrite already-known filters with partial information
  if (oldFilter && (oldFilter.get('keywords') && !filter.keywords)) {
    return state;
  }

  const normalizedFilter = fromJS({
    id: filter.id,
    title: filter.title,
    context: filter.context,
    filter_action: filter.filter_action,
    expires_at: filter.expires_at ? Date.parse(filter.expires_at) : null,
    keywords: filter.keywords,
  });

  if (is(oldFilter, normalizedFilter)) {
    return state;
  } else {
    return state.set(filter.id, normalizedFilter);
  }
};

const normalizeFilters = (state, filters) => {
  filters.forEach(filter => {
    state = normalizeFilter(state, filter);
  });

  return state;
};

export default function filters(state = ImmutableMap(), action) {
  switch(action.type) {
  case FILTERS_FETCH_SUCCESS:
    return normalizeFilters(ImmutableMap(), action.filters);
  case FILTERS_IMPORT:
    return normalizeFilters(state, action.filters);
  default:
    return state;
  }
};

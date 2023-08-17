import { Map as ImmutableMap, is, fromJS } from 'immutable';

import { FILTERS_FETCH_SUCCESS, FILTERS_CREATE_SUCCESS } from '../actions/filters';
import { FILTERS_IMPORT } from '../actions/importer';

const normalizeFilter = (state, filter) => {
  const normalizedFilter = fromJS({
    id: filter.id,
    title: filter.title,
    context: filter.context,
    filter_action: filter.filter_action,
    keywords: filter.keywords,
    expires_at: filter.expires_at ? Date.parse(filter.expires_at) : null,
  });

  if (is(state.get(filter.id), normalizedFilter)) {
    return state;
  } else {
    // Do not overwrite keywords when receiving a partial filter
    return state.update(filter.id, ImmutableMap(), (old) => (
      old.mergeWith(((old_value, new_value) => (new_value === undefined ? old_value : new_value)), normalizedFilter)
    ));
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
  case FILTERS_CREATE_SUCCESS:
    return normalizeFilter(state, action.filter);
  case FILTERS_FETCH_SUCCESS:
    return normalizeFilters(ImmutableMap(), action.filters);
  case FILTERS_IMPORT:
    return normalizeFilters(state, action.filters);
  default:
    return state;
  }
}

import type { Reducer } from '@reduxjs/toolkit';
import { Map as ImmutableMap } from 'immutable';

import {
  createList,
  updateList,
  fetchLists,
} from 'mastodon/actions/lists_typed';
import type { ApiListJSON } from 'mastodon/api_types/lists';
import { createList as createListFromJSON } from 'mastodon/models/list';
import type { List } from 'mastodon/models/list';

import {
  LIST_FETCH_SUCCESS,
  LIST_FETCH_FAIL,
  LIST_DELETE_SUCCESS,
} from '../actions/lists';

const initialState = ImmutableMap<string, List | null>();
type State = typeof initialState;

const normalizeList = (state: State, list: ApiListJSON) =>
  state.set(list.id, createListFromJSON(list));

const normalizeLists = (state: State, lists: ApiListJSON[]) => {
  lists.forEach((list) => {
    state = normalizeList(state, list);
  });

  return state;
};

export const listsReducer: Reducer<State> = (state = initialState, action) => {
  if (
    createList.fulfilled.match(action) ||
    updateList.fulfilled.match(action)
  ) {
    return normalizeList(state, action.payload);
  } else if (fetchLists.fulfilled.match(action)) {
    return normalizeLists(state, action.payload);
  } else {
    switch (action.type) {
      case LIST_FETCH_SUCCESS:
        return normalizeList(state, action.list as ApiListJSON);
      case LIST_DELETE_SUCCESS:
      case LIST_FETCH_FAIL:
        return state.set(action.id as string, null);
      default:
        return state;
    }
  }
};

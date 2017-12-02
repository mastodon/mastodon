import api from '../api';

export const LIST_FETCH_REQUEST = 'LIST_FETCH_REQUEST';
export const LIST_FETCH_SUCCESS = 'LIST_FETCH_SUCCESS';
export const LIST_FETCH_FAIL    = 'LIST_FETCH_FAIL';

export const LISTS_FETCH_REQUEST = 'LISTS_FETCH_REQUEST';
export const LISTS_FETCH_SUCCESS = 'LISTS_FETCH_SUCCESS';
export const LISTS_FETCH_FAIL    = 'LISTS_FETCH_FAIL';

export const LIST_EDITOR_TITLE_CHANGE = 'LIST_EDITOR_TITLE_CHANGE';
export const LIST_EDITOR_RESET        = 'LIST_EDITOR_RESET';

export const LIST_CREATE_REQUEST = 'LIST_CREATE_REQUEST';
export const LIST_CREATE_SUCCESS = 'LIST_CREATE_SUCCESS';
export const LIST_CREATE_FAIL    = 'LIST_CREATE_FAIL';

export const LIST_UPDATE_REQUEST = 'LIST_UPDATE_REQUEST';
export const LIST_UPDATE_SUCCESS = 'LIST_UPDATE_SUCCESS';
export const LIST_UPDATE_FAIL    = 'LIST_UPDATE_FAIL';

export const fetchList = id => (dispatch, getState) => {
  if (getState().getIn(['lists', id])) {
    return;
  }

  dispatch(fetchListRequest(id));

  api(getState).get(`/api/v1/lists/${id}`)
    .then(({ data }) => dispatch(fetchListSuccess(data)))
    .catch(err => dispatch(fetchListFail(err)));
};

export const fetchListRequest = id => ({
  type: LIST_FETCH_REQUEST,
  id,
});

export const fetchListSuccess = list => ({
  type: LIST_FETCH_SUCCESS,
  list,
});

export const fetchListFail = error => ({
  type: LIST_FETCH_FAIL,
  error,
});

export const fetchLists = () => (dispatch, getState) => {
  dispatch(fetchListsRequest());

  api(getState).get('/api/v1/lists')
    .then(({ data }) => dispatch(fetchListsSuccess(data)))
    .catch(err => dispatch(fetchListsFail(err)));
};

export const fetchListsRequest = () => ({
  type: LISTS_FETCH_REQUEST,
});

export const fetchListsSuccess = lists => ({
  type: LISTS_FETCH_SUCCESS,
  lists,
});

export const fetchListsFail = error => ({
  type: LISTS_FETCH_FAIL,
  error,
});

export const submitListEditor = () => (dispatch, getState) => {
  const listId = getState().getIn(['listEditor', 'listId']);
  const title  = getState().getIn(['listEditor', 'title']);

  if (listId === null) {
    dispatch(createList(title));
  } else {
    dispatch(updateList(listId, title));
  }
};

export const changeListEditorTitle = value => ({
  type: LIST_EDITOR_TITLE_CHANGE,
  value,
});

export const createList = title => (dispatch, getState) => {
  dispatch(createListRequest());

  api(getState).post('/api/v1/lists', { title })
    .then(({ data }) => dispatch(createListSuccess(data)))
    .catch(err => dispatch(createListFail(err)));
};

export const createListRequest = () => ({
  type: LIST_CREATE_REQUEST,
});

export const createListSuccess = list => ({
  type: LIST_CREATE_SUCCESS,
  list,
});

export const createListFail = error => ({
  type: LIST_CREATE_FAIL,
  error,
});

export const updateList = (id, title) => (dispatch, getState) => {
  // TODO
};

export const resetListEditor = () => ({
  type: LIST_EDITOR_RESET,
});

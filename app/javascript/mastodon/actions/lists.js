import api from '../api';

export const LIST_FETCH_REQUEST = 'LIST_FETCH_REQUEST';
export const LIST_FETCH_SUCCESS = 'LIST_FETCH_SUCCESS';
export const LIST_FETCH_FAIL    = 'LIST_FETCH_FAIL';

export const LIST_DELETE_REQUEST = 'LIST_DELETE_REQUEST';
export const LIST_DELETE_SUCCESS = 'LIST_DELETE_SUCCESS';
export const LIST_DELETE_FAIL    = 'LIST_DELETE_FAIL';

export * from './lists_typed';

export const fetchList = id => (dispatch, getState) => {
  if (getState().getIn(['lists', id])) {
    return;
  }

  dispatch(fetchListRequest(id));

  api().get(`/api/v1/lists/${id}`)
    .then(({ data }) => dispatch(fetchListSuccess(data)))
    .catch(err => dispatch(fetchListFail(id, err)));
};

export const fetchListRequest = id => ({
  type: LIST_FETCH_REQUEST,
  id,
});

export const fetchListSuccess = list => ({
  type: LIST_FETCH_SUCCESS,
  list,
});

export const fetchListFail = (id, error) => ({
  type: LIST_FETCH_FAIL,
  id,
  error,
});

export const deleteList = id => (dispatch) => {
  dispatch(deleteListRequest(id));

  api().delete(`/api/v1/lists/${id}`)
    .then(() => dispatch(deleteListSuccess(id)))
    .catch(err => dispatch(deleteListFail(id, err)));
};

export const deleteListRequest = id => ({
  type: LIST_DELETE_REQUEST,
  id,
});

export const deleteListSuccess = id => ({
  type: LIST_DELETE_SUCCESS,
  id,
});

export const deleteListFail = (id, error) => ({
  type: LIST_DELETE_FAIL,
  id,
  error,
});

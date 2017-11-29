import api from '../api';

export const LIST_FETCH_REQUEST = 'LIST_FETCH_REQUEST';
export const LIST_FETCH_SUCCESS = 'LIST_FETCH_SUCCESS';
export const LIST_FETCH_FAIL    = 'LIST_FETCH_FAIL';

export const fetchList = id => (dispatch, getState) => {
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

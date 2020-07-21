import api from '../api';
import { importFetchedAccounts } from './importer';
import { showAlertForError } from './alerts';

export const CIRCLE_FETCH_REQUEST = 'CIRCLE_FETCH_REQUEST';
export const CIRCLE_FETCH_SUCCESS = 'CIRCLE_FETCH_SUCCESS';
export const CIRCLE_FETCH_FAIL    = 'CIRCLE_FETCH_FAIL';

export const CIRCLES_FETCH_REQUEST = 'CIRCLES_FETCH_REQUEST';
export const CIRCLES_FETCH_SUCCESS = 'CIRCLES_FETCH_SUCCESS';
export const CIRCLES_FETCH_FAIL    = 'CIRCLES_FETCH_FAIL';

export const CIRCLE_EDITOR_TITLE_CHANGE = 'CIRCLE_EDITOR_TITLE_CHANGE';
export const CIRCLE_EDITOR_RESET        = 'CIRCLE_EDITOR_RESET';
export const CIRCLE_EDITOR_SETUP        = 'CIRCLE_EDITOR_SETUP';

export const CIRCLE_CREATE_REQUEST = 'CIRCLE_CREATE_REQUEST';
export const CIRCLE_CREATE_SUCCESS = 'CIRCLE_CREATE_SUCCESS';
export const CIRCLE_CREATE_FAIL    = 'CIRCLE_CREATE_FAIL';

export const CIRCLE_UPDATE_REQUEST = 'CIRCLE_UPDATE_REQUEST';
export const CIRCLE_UPDATE_SUCCESS = 'CIRCLE_UPDATE_SUCCESS';
export const CIRCLE_UPDATE_FAIL    = 'CIRCLE_UPDATE_FAIL';

export const CIRCLE_DELETE_REQUEST = 'CIRCLE_DELETE_REQUEST';
export const CIRCLE_DELETE_SUCCESS = 'CIRCLE_DELETE_SUCCESS';
export const CIRCLE_DELETE_FAIL    = 'CIRCLE_DELETE_FAIL';

export const CIRCLE_ACCOUNTS_FETCH_REQUEST = 'CIRCLE_ACCOUNTS_FETCH_REQUEST';
export const CIRCLE_ACCOUNTS_FETCH_SUCCESS = 'CIRCLE_ACCOUNTS_FETCH_SUCCESS';
export const CIRCLE_ACCOUNTS_FETCH_FAIL    = 'CIRCLE_ACCOUNTS_FETCH_FAIL';

export const CIRCLE_EDITOR_SUGGESTIONS_CHANGE = 'CIRCLE_EDITOR_SUGGESTIONS_CHANGE';
export const CIRCLE_EDITOR_SUGGESTIONS_READY  = 'CIRCLE_EDITOR_SUGGESTIONS_READY';
export const CIRCLE_EDITOR_SUGGESTIONS_CLEAR  = 'CIRCLE_EDITOR_SUGGESTIONS_CLEAR';

export const CIRCLE_EDITOR_ADD_REQUEST = 'CIRCLE_EDITOR_ADD_REQUEST';
export const CIRCLE_EDITOR_ADD_SUCCESS = 'CIRCLE_EDITOR_ADD_SUCCESS';
export const CIRCLE_EDITOR_ADD_FAIL    = 'CIRCLE_EDITOR_ADD_FAIL';

export const CIRCLE_EDITOR_REMOVE_REQUEST = 'CIRCLE_EDITOR_REMOVE_REQUEST';
export const CIRCLE_EDITOR_REMOVE_SUCCESS = 'CIRCLE_EDITOR_REMOVE_SUCCESS';
export const CIRCLE_EDITOR_REMOVE_FAIL    = 'CIRCLE_EDITOR_REMOVE_FAIL';

export const CIRCLE_ADDER_RESET = 'CIRCLE_ADDER_RESET';
export const CIRCLE_ADDER_SETUP = 'CIRCLE_ADDER_SETUP';

export const CIRCLE_ADDER_CIRCLES_FETCH_REQUEST = 'CIRCLE_ADDER_CIRCLES_FETCH_REQUEST';
export const CIRCLE_ADDER_CIRCLES_FETCH_SUCCESS = 'CIRCLE_ADDER_CIRCLES_FETCH_SUCCESS';
export const CIRCLE_ADDER_CIRCLES_FETCH_FAIL    = 'CIRCLE_ADDER_CIRCLES_FETCH_FAIL';

export const fetchCircle = id => (dispatch, getState) => {
  if (getState().getIn(['circles', id])) {
    return;
  }

  dispatch(fetchCircleRequest(id));

  api(getState).get(`/api/v1/circles/${id}`)
    .then(({ data }) => dispatch(fetchCircleSuccess(data)))
    .catch(err => dispatch(fetchCircleFail(id, err)));
};

export const fetchCircleRequest = id => ({
  type: CIRCLE_FETCH_REQUEST,
  id,
});

export const fetchCircleSuccess = circle => ({
  type: CIRCLE_FETCH_SUCCESS,
  circle,
});

export const fetchCircleFail = (id, error) => ({
  type: CIRCLE_FETCH_FAIL,
  id,
  error,
});

export const fetchCircles = () => (dispatch, getState) => {
  dispatch(fetchCirclesRequest());

  api(getState).get('/api/v1/circles')
    .then(({ data }) => dispatch(fetchCirclesSuccess(data)))
    .catch(err => dispatch(fetchCirclesFail(err)));
};

export const fetchCirclesRequest = () => ({
  type: CIRCLES_FETCH_REQUEST,
});

export const fetchCirclesSuccess = circles => ({
  type: CIRCLES_FETCH_SUCCESS,
  circles,
});

export const fetchCirclesFail = error => ({
  type: CIRCLES_FETCH_FAIL,
  error,
});

export const submitCircleEditor = shouldReset => (dispatch, getState) => {
  const circleId = getState().getIn(['circleEditor', 'circleId']);
  const title  = getState().getIn(['circleEditor', 'title']);

  if (circleId === null) {
    dispatch(createCircle(title, shouldReset));
  } else {
    dispatch(updateCircle(circleId, title, shouldReset));
  }
};

export const setupCircleEditor = circleId => (dispatch, getState) => {
  dispatch({
    type: CIRCLE_EDITOR_SETUP,
    circle: getState().getIn(['circles', circleId]),
  });

  dispatch(fetchCircleAccounts(circleId));
};

export const changeCircleEditorTitle = value => ({
  type: CIRCLE_EDITOR_TITLE_CHANGE,
  value,
});

export const createCircle = (title, shouldReset) => (dispatch, getState) => {
  dispatch(createCircleRequest());

  api(getState).post('/api/v1/circles', { title }).then(({ data }) => {
    dispatch(createCircleSuccess(data));

    if (shouldReset) {
      dispatch(resetCircleEditor());
    }
  }).catch(err => dispatch(createCircleFail(err)));
};

export const createCircleRequest = () => ({
  type: CIRCLE_CREATE_REQUEST,
});

export const createCircleSuccess = circle => ({
  type: CIRCLE_CREATE_SUCCESS,
  circle,
});

export const createCircleFail = error => ({
  type: CIRCLE_CREATE_FAIL,
  error,
});

export const updateCircle = (id, title, shouldReset) => (dispatch, getState) => {
  dispatch(updateCircleRequest(id));

  api(getState).put(`/api/v1/circles/${id}`, { title }).then(({ data }) => {
    dispatch(updateCircleSuccess(data));

    if (shouldReset) {
      dispatch(resetCircleEditor());
    }
  }).catch(err => dispatch(updateCircleFail(id, err)));
};

export const updateCircleRequest = id => ({
  type: CIRCLE_UPDATE_REQUEST,
  id,
});

export const updateCircleSuccess = circle => ({
  type: CIRCLE_UPDATE_SUCCESS,
  circle,
});

export const updateCircleFail = (id, error) => ({
  type: CIRCLE_UPDATE_FAIL,
  id,
  error,
});

export const resetCircleEditor = () => ({
  type: CIRCLE_EDITOR_RESET,
});

export const deleteCircle = id => (dispatch, getState) => {
  dispatch(deleteCircleRequest(id));

  api(getState).delete(`/api/v1/circles/${id}`)
    .then(() => dispatch(deleteCircleSuccess(id)))
    .catch(err => dispatch(deleteCircleFail(id, err)));
};

export const deleteCircleRequest = id => ({
  type: CIRCLE_DELETE_REQUEST,
  id,
});

export const deleteCircleSuccess = id => ({
  type: CIRCLE_DELETE_SUCCESS,
  id,
});

export const deleteCircleFail = (id, error) => ({
  type: CIRCLE_DELETE_FAIL,
  id,
  error,
});

export const fetchCircleAccounts = circleId => (dispatch, getState) => {
  dispatch(fetchCircleAccountsRequest(circleId));

  api(getState).get(`/api/v1/circles/${circleId}/accounts`, { params: { limit: 0 } }).then(({ data }) => {
    dispatch(importFetchedAccounts(data));
    dispatch(fetchCircleAccountsSuccess(circleId, data));
  }).catch(err => dispatch(fetchCircleAccountsFail(circleId, err)));
};

export const fetchCircleAccountsRequest = id => ({
  type: CIRCLE_ACCOUNTS_FETCH_REQUEST,
  id,
});

export const fetchCircleAccountsSuccess = (id, accounts, next) => ({
  type: CIRCLE_ACCOUNTS_FETCH_SUCCESS,
  id,
  accounts,
  next,
});

export const fetchCircleAccountsFail = (id, error) => ({
  type: CIRCLE_ACCOUNTS_FETCH_FAIL,
  id,
  error,
});

export const fetchCircleSuggestions = q => (dispatch, getState) => {
  const params = {
    q,
    resolve: false,
    limit: 4,
    followers: true,
  };

  api(getState).get('/api/v1/accounts/search', { params }).then(({ data }) => {
    dispatch(importFetchedAccounts(data));
    dispatch(fetchCircleSuggestionsReady(q, data));
  }).catch(error => dispatch(showAlertForError(error)));
};

export const fetchCircleSuggestionsReady = (query, accounts) => ({
  type: CIRCLE_EDITOR_SUGGESTIONS_READY,
  query,
  accounts,
});

export const clearCircleSuggestions = () => ({
  type: CIRCLE_EDITOR_SUGGESTIONS_CLEAR,
});

export const changeCircleSuggestions = value => ({
  type: CIRCLE_EDITOR_SUGGESTIONS_CHANGE,
  value,
});

export const addToCircleEditor = accountId => (dispatch, getState) => {
  dispatch(addToCircle(getState().getIn(['circleEditor', 'circleId']), accountId));
};

export const addToCircle = (circleId, accountId) => (dispatch, getState) => {
  dispatch(addToCircleRequest(circleId, accountId));

  api(getState).post(`/api/v1/circles/${circleId}/accounts`, { account_ids: [accountId] })
    .then(() => dispatch(addToCircleSuccess(circleId, accountId)))
    .catch(err => dispatch(addToCircleFail(circleId, accountId, err)));
};

export const addToCircleRequest = (circleId, accountId) => ({
  type: CIRCLE_EDITOR_ADD_REQUEST,
  circleId,
  accountId,
});

export const addToCircleSuccess = (circleId, accountId) => ({
  type: CIRCLE_EDITOR_ADD_SUCCESS,
  circleId,
  accountId,
});

export const addToCircleFail = (circleId, accountId, error) => ({
  type: CIRCLE_EDITOR_ADD_FAIL,
  circleId,
  accountId,
  error,
});

export const removeFromCircleEditor = accountId => (dispatch, getState) => {
  dispatch(removeFromCircle(getState().getIn(['circleEditor', 'circleId']), accountId));
};

export const removeFromCircle = (circleId, accountId) => (dispatch, getState) => {
  dispatch(removeFromCircleRequest(circleId, accountId));

  api(getState).delete(`/api/v1/circles/${circleId}/accounts`, { params: { account_ids: [accountId] } })
    .then(() => dispatch(removeFromCircleSuccess(circleId, accountId)))
    .catch(err => dispatch(removeFromCircleFail(circleId, accountId, err)));
};

export const removeFromCircleRequest = (circleId, accountId) => ({
  type: CIRCLE_EDITOR_REMOVE_REQUEST,
  circleId,
  accountId,
});

export const removeFromCircleSuccess = (circleId, accountId) => ({
  type: CIRCLE_EDITOR_REMOVE_SUCCESS,
  circleId,
  accountId,
});

export const removeFromCircleFail = (circleId, accountId, error) => ({
  type: CIRCLE_EDITOR_REMOVE_FAIL,
  circleId,
  accountId,
  error,
});

export const resetCircleAdder = () => ({
  type: CIRCLE_ADDER_RESET,
});

export const setupCircleAdder = accountId => (dispatch, getState) => {
  dispatch({
    type: CIRCLE_ADDER_SETUP,
    account: getState().getIn(['accounts', accountId]),
  });
  dispatch(fetchCircles());
  dispatch(fetchAccountCircles(accountId));
};

export const fetchAccountCircles = accountId => (dispatch, getState) => {
  dispatch(fetchAccountCirclesRequest(accountId));

  api(getState).get(`/api/v1/accounts/${accountId}/circles`)
    .then(({ data }) => dispatch(fetchAccountCirclesSuccess(accountId, data)))
    .catch(err => dispatch(fetchAccountCirclesFail(accountId, err)));
};

export const fetchAccountCirclesRequest = id => ({
  type:CIRCLE_ADDER_CIRCLES_FETCH_REQUEST,
  id,
});

export const fetchAccountCirclesSuccess = (id, circles) => ({
  type: CIRCLE_ADDER_CIRCLES_FETCH_SUCCESS,
  id,
  circles,
});

export const fetchAccountCirclesFail = (id, err) => ({
  type: CIRCLE_ADDER_CIRCLES_FETCH_FAIL,
  id,
  err,
});

export const addToCircleAdder = circleId => (dispatch, getState) => {
  dispatch(addToCircle(circleId, getState().getIn(['circleAdder', 'accountId'])));
};

export const removeFromCircleAdder = circleId => (dispatch, getState) => {
  dispatch(removeFromCircle(circleId, getState().getIn(['circleAdder', 'accountId'])));
};


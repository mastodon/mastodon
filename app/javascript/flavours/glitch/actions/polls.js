import api from 'flavours/glitch/util/api';
import { importFetchedPoll } from './importer';

export const POLL_VOTE_REQUEST = 'POLL_VOTE_REQUEST';
export const POLL_VOTE_SUCCESS = 'POLL_VOTE_SUCCESS';
export const POLL_VOTE_FAIL    = 'POLL_VOTE_FAIL';

export const POLL_FETCH_REQUEST = 'POLL_FETCH_REQUEST';
export const POLL_FETCH_SUCCESS = 'POLL_FETCH_SUCCESS';
export const POLL_FETCH_FAIL    = 'POLL_FETCH_FAIL';

export const vote = (pollId, choices) => (dispatch, getState) => {
  dispatch(voteRequest());

  api(getState).post(`/api/v1/polls/${pollId}/votes`, { choices })
    .then(({ data }) => {
      dispatch(importFetchedPoll(data));
      dispatch(voteSuccess(data));
    })
    .catch(err => dispatch(voteFail(err)));
};

export const fetchPoll = pollId => (dispatch, getState) => {
  dispatch(fetchPollRequest());

  api(getState).get(`/api/v1/polls/${pollId}`)
    .then(({ data }) => {
      dispatch(importFetchedPoll(data));
      dispatch(fetchPollSuccess(data));
    })
    .catch(err => dispatch(fetchPollFail(err)));
};

export const voteRequest = () => ({
  type: POLL_VOTE_REQUEST,
});

export const voteSuccess = poll => ({
  type: POLL_VOTE_SUCCESS,
  poll,
});

export const voteFail = error => ({
  type: POLL_VOTE_FAIL,
  error,
});

export const fetchPollRequest = () => ({
  type: POLL_FETCH_REQUEST,
});

export const fetchPollSuccess = poll => ({
  type: POLL_FETCH_SUCCESS,
  poll,
});

export const fetchPollFail = error => ({
  type: POLL_FETCH_FAIL,
  error,
});

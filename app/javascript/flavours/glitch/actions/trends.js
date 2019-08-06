import api from 'flavours/glitch/util/api';

export const TRENDS_FETCH_REQUEST = 'TRENDS_FETCH_REQUEST';
export const TRENDS_FETCH_SUCCESS = 'TRENDS_FETCH_SUCCESS';
export const TRENDS_FETCH_FAIL    = 'TRENDS_FETCH_FAIL';

export const fetchTrends = () => (dispatch, getState) => {
  dispatch(fetchTrendsRequest());

  api(getState)
    .get('/api/v1/trends')
    .then(({ data }) => dispatch(fetchTrendsSuccess(data)))
    .catch(err => dispatch(fetchTrendsFail(err)));
};

export const fetchTrendsRequest = () => ({
  type: TRENDS_FETCH_REQUEST,
  skipLoading: true,
});

export const fetchTrendsSuccess = trends => ({
  type: TRENDS_FETCH_SUCCESS,
  trends,
  skipLoading: true,
});

export const fetchTrendsFail = error => ({
  type: TRENDS_FETCH_FAIL,
  error,
  skipLoading: true,
  skipAlert: true,
});

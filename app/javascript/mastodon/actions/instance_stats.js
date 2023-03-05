import api from 'mastodon/api';

export const INSTANCE_STATS_FETCH_REQUEST = 'InstanceStats_FETCH_REQUEST';
export const INSTNACE_STATS_FETCH_SUCCESS = 'InstanceStats_FETCH_SUCCESS';
export const INSTNACE_STATS_FETCH_FAIL = 'InstanceStats_FETCH_FAIL';

export const fetchInstanceStats = (domain) => (dispatch, getState) => {
  dispatch(fetchInstanceStatsRequest());

  api(getState)
    .get(`/api/v2/instance_stats/${domain}`).then(({ data }) => {
      dispatch(fetchInstanceStatsSuccess(data));
    }).catch(err => dispatch(fetchInstanceStatsFail(err)));
};

const fetchInstanceStatsRequest = () => ({
  type: INSTANCE_STATS_FETCH_REQUEST,
});

const fetchInstanceStatsSuccess = data => ({
  type: INSTNACE_STATS_FETCH_SUCCESS,
  data,
});

const fetchInstanceStatsFail = error => ({
  type: INSTNACE_STATS_FETCH_FAIL,
  error,
});

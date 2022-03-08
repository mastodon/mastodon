import api from '../api';

export const RULES_FETCH_REQUEST = 'RULES_FETCH_REQUEST';
export const RULES_FETCH_SUCCESS = 'RULES_FETCH_SUCCESS';
export const RULES_FETCH_FAIL    = 'RULES_FETCH_FAIL';

export const fetchRules = () => (dispatch, getState) => {
  dispatch(fetchRulesRequest());

  api(getState)
    .get('/api/v1/instance').then(({ data }) => dispatch(fetchRulesSuccess(data.rules)))
    .catch(err => dispatch(fetchRulesFail(err)));
};

const fetchRulesRequest = () => ({
  type: RULES_FETCH_REQUEST,
});

const fetchRulesSuccess = rules => ({
  type: RULES_FETCH_SUCCESS,
  rules,
});

const fetchRulesFail = error => ({
  type: RULES_FETCH_FAIL,
  error,
});

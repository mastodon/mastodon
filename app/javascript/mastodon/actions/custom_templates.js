import api from '../api';

export const CUSTOM_TEMPLATES_FETCH_REQUEST = 'CUSTOM_TEMPLATES_FETCH_REQUEST';
export const CUSTOM_TEMPLATES_FETCH_SUCCESS = 'CUSTOM_TEMPLATES_FETCH_SUCCESS';
export const CUSTOM_TEMPLATES_FETCH_FAIL = 'CUSTOM_TEMPLATES_FETCH_FAIL';

export function fetchCustomTemplates() {
  return (dispatch, getState) => {
    dispatch(fetchCustomTemplatesRequest());

    api(getState).get('/api/v1/custom_templates').then(response => {
      dispatch(fetchCustomTemplatesSuccess(response.data));
    }).catch(error => {
      dispatch(fetchCustomTemplatesFail(error));
    });
  };
}

export function fetchCustomTemplatesRequest() {
  return {
    type: CUSTOM_TEMPLATES_FETCH_REQUEST,
  };
}

export function fetchCustomTemplatesSuccess(custom_templates) {
  return {
    type: CUSTOM_TEMPLATES_FETCH_SUCCESS,
    custom_templates,
  };
}

export function fetchCustomTemplatesFail(error) {
  return {
    type: CUSTOM_TEMPLATES_FETCH_FAIL,
    error,
  };
}

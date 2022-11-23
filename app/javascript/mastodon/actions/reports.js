import api from '../api';
import { openModal } from './modal';

export const REPORT_SUBMIT_REQUEST = 'REPORT_SUBMIT_REQUEST';
export const REPORT_SUBMIT_SUCCESS = 'REPORT_SUBMIT_SUCCESS';
export const REPORT_SUBMIT_FAIL    = 'REPORT_SUBMIT_FAIL';

export const initReport = (account, status) => dispatch =>
  dispatch(openModal('REPORT', {
    accountId: account.get('id'),
    statusId: status?.get('id'),
  }));

export const submitReport = (params, onSuccess, onFail) => (dispatch, getState) => {
  dispatch(submitReportRequest());

  api(getState).post('/api/v1/reports', params).then(response => {
    dispatch(submitReportSuccess(response.data));
    if (onSuccess) onSuccess();
  }).catch(error => {
    dispatch(submitReportFail(error));
    if (onFail) onFail();
  });
};

export const submitReportRequest = () => ({
  type: REPORT_SUBMIT_REQUEST,
});

export const submitReportSuccess = report => ({
  type: REPORT_SUBMIT_SUCCESS,
  report,
});

export const submitReportFail = error => ({
  type: REPORT_SUBMIT_FAIL,
  error,
});

import api from '../api';
import { openModal, closeModal } from './modal';

export const REPORT_INIT   = 'REPORT_INIT';
export const REPORT_CANCEL = 'REPORT_CANCEL';

export const REPORT_SUBMIT_REQUEST = 'REPORT_SUBMIT_REQUEST';
export const REPORT_SUBMIT_SUCCESS = 'REPORT_SUBMIT_SUCCESS';
export const REPORT_SUBMIT_FAIL    = 'REPORT_SUBMIT_FAIL';

export const REPORT_STATUS_TOGGLE  = 'REPORT_STATUS_TOGGLE';
export const REPORT_COMMENT_CHANGE = 'REPORT_COMMENT_CHANGE';
export const REPORT_FORWARD_CHANGE = 'REPORT_FORWARD_CHANGE';

export function initReport(account, status) {
  return dispatch => {
    dispatch({
      type: REPORT_INIT,
      account,
      status,
    });

    dispatch(openModal('REPORT'));
  };
};

export function cancelReport() {
  return {
    type: REPORT_CANCEL,
  };
};

export function toggleStatusReport(statusId, checked) {
  return {
    type: REPORT_STATUS_TOGGLE,
    statusId,
    checked,
  };
};

export function submitReport() {
  return (dispatch, getState) => {
    dispatch(submitReportRequest());

    api(getState).post('/api/v1/reports', {
      account_id: getState().getIn(['reports', 'new', 'account_id']),
      status_ids: getState().getIn(['reports', 'new', 'status_ids']),
      comment: getState().getIn(['reports', 'new', 'comment']),
      forward: getState().getIn(['reports', 'new', 'forward']),
    }).then(response => {
      dispatch(closeModal());
      dispatch(submitReportSuccess(response.data));
    }).catch(error => dispatch(submitReportFail(error)));
  };
};

export function submitReportRequest() {
  return {
    type: REPORT_SUBMIT_REQUEST,
  };
};

export function submitReportSuccess(report) {
  return {
    type: REPORT_SUBMIT_SUCCESS,
    report,
  };
};

export function submitReportFail(error) {
  return {
    type: REPORT_SUBMIT_FAIL,
    error,
  };
};

export function changeReportComment(comment) {
  return {
    type: REPORT_COMMENT_CHANGE,
    comment,
  };
};

export function changeReportForward(forward) {
  return {
    type: REPORT_FORWARD_CHANGE,
    forward,
  };
};

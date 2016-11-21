import api from '../api'

import { updateTimeline } from './timelines';

export const COMPOSE_CHANGE          = 'COMPOSE_CHANGE';
export const COMPOSE_SUBMIT_REQUEST  = 'COMPOSE_SUBMIT_REQUEST';
export const COMPOSE_SUBMIT_SUCCESS  = 'COMPOSE_SUBMIT_SUCCESS';
export const COMPOSE_SUBMIT_FAIL     = 'COMPOSE_SUBMIT_FAIL';
export const COMPOSE_REPLY           = 'COMPOSE_REPLY';
export const COMPOSE_REPLY_CANCEL    = 'COMPOSE_REPLY_CANCEL';
export const COMPOSE_MENTION         = 'COMPOSE_MENTION';
export const COMPOSE_UPLOAD_REQUEST  = 'COMPOSE_UPLOAD_REQUEST';
export const COMPOSE_UPLOAD_SUCCESS  = 'COMPOSE_UPLOAD_SUCCESS';
export const COMPOSE_UPLOAD_FAIL     = 'COMPOSE_UPLOAD_FAIL';
export const COMPOSE_UPLOAD_PROGRESS = 'COMPOSE_UPLOAD_PROGRESS';
export const COMPOSE_UPLOAD_UNDO     = 'COMPOSE_UPLOAD_UNDO';

export const COMPOSE_SUGGESTIONS_CLEAR = 'COMPOSE_SUGGESTIONS_CLEAR';
export const COMPOSE_SUGGESTIONS_READY = 'COMPOSE_SUGGESTIONS_READY';
export const COMPOSE_SUGGESTION_SELECT = 'COMPOSE_SUGGESTION_SELECT';

export const COMPOSE_MOUNT   = 'COMPOSE_MOUNT';
export const COMPOSE_UNMOUNT = 'COMPOSE_UNMOUNT';

export function changeCompose(text) {
  return {
    type: COMPOSE_CHANGE,
    text: text
  };
};

export function replyCompose(status, router) {
  return (dispatch, getState) => {
    dispatch({
      type: COMPOSE_REPLY,
      status: status
    });

    if (!getState().getIn(['compose', 'mounted'])) {
      router.push('/statuses/new');
    }
  };
};

export function cancelReplyCompose() {
  return {
    type: COMPOSE_REPLY_CANCEL
  };
};

export function mentionCompose(account) {
  return {
    type: COMPOSE_MENTION,
    account: account
  };
};

export function submitCompose() {
  return function (dispatch, getState) {
    dispatch(submitComposeRequest());

    api(getState).post('/api/v1/statuses', {
      status: getState().getIn(['compose', 'text'], ''),
      in_reply_to_id: getState().getIn(['compose', 'in_reply_to'], null),
      media_ids: getState().getIn(['compose', 'media_attachments']).map(item => item.get('id'))
    }).then(function (response) {
      dispatch(submitComposeSuccess(response.data));
      dispatch(updateTimeline('home', response.data));
    }).catch(function (error) {
      dispatch(submitComposeFail(error));
    });
  };
};

export function submitComposeRequest() {
  return {
    type: COMPOSE_SUBMIT_REQUEST
  };
};

export function submitComposeSuccess(status) {
  return {
    type: COMPOSE_SUBMIT_SUCCESS,
    status: status
  };
};

export function submitComposeFail(error) {
  return {
    type: COMPOSE_SUBMIT_FAIL,
    error: error
  };
};

export function uploadCompose(files) {
  return function (dispatch, getState) {
    dispatch(uploadComposeRequest());

    let data = new FormData();
    data.append('file', files[0]);

    api(getState).post('/api/v1/media', data, {
      onUploadProgress: function (e) {
        dispatch(uploadComposeProgress(e.loaded, e.total));
      }
    }).then(function (response) {
      dispatch(uploadComposeSuccess(response.data));
    }).catch(function (error) {
      dispatch(uploadComposeFail(error));
    });
  };
};

export function uploadComposeRequest() {
  return {
    type: COMPOSE_UPLOAD_REQUEST
  };
};

export function uploadComposeProgress(loaded, total) {
  return {
    type: COMPOSE_UPLOAD_PROGRESS,
    loaded: loaded,
    total: total
  };
};

export function uploadComposeSuccess(media) {
  return {
    type: COMPOSE_UPLOAD_SUCCESS,
    media: media
  };
};

export function uploadComposeFail(error) {
  return {
    type: COMPOSE_UPLOAD_FAIL,
    error: error
  };
};

export function undoUploadCompose(media_id) {
  return {
    type: COMPOSE_UPLOAD_UNDO,
    media_id: media_id
  };
};

export function clearComposeSuggestions() {
  return {
    type: COMPOSE_SUGGESTIONS_CLEAR
  };
};

export function fetchComposeSuggestions(token) {
  return (dispatch, getState) => {
    api(getState).get('/api/v1/accounts/search', {
      params: {
        q: token,
        resolve: false,
        limit: 4
      }
    }).then(response => {
      dispatch(readyComposeSuggestions(token, response.data));
    });
  };
};

export function readyComposeSuggestions(token, accounts) {
  return {
    type: COMPOSE_SUGGESTIONS_READY,
    token,
    accounts
  };
};

export function selectComposeSuggestion(position, accountId) {
  return (dispatch, getState) => {
    const completion = getState().getIn(['accounts', accountId, 'acct']);

    dispatch({
      type: COMPOSE_SUGGESTION_SELECT,
      position,
      completion
    });
  };
};

export function mountCompose() {
  return {
    type: COMPOSE_MOUNT
  };
};

export function unmountCompose() {
  return {
    type: COMPOSE_UNMOUNT
  };
};

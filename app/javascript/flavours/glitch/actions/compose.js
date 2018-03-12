import api from 'flavours/glitch/util/api';
import { throttle } from 'lodash';
import { search as emojiSearch } from 'flavours/glitch/util/emoji/emoji_mart_search_light';
import { useEmoji } from './emojis';

import {
  updateTimeline,
  refreshHomeTimeline,
  refreshCommunityTimeline,
  refreshPublicTimeline,
  refreshDirectTimeline,
} from './timelines';

export const COMPOSE_CHANGE          = 'COMPOSE_CHANGE';
export const COMPOSE_CYCLE_ELEFRIEND = 'COMPOSE_CYCLE_ELEFRIEND';
export const COMPOSE_SUBMIT_REQUEST  = 'COMPOSE_SUBMIT_REQUEST';
export const COMPOSE_SUBMIT_SUCCESS  = 'COMPOSE_SUBMIT_SUCCESS';
export const COMPOSE_SUBMIT_FAIL     = 'COMPOSE_SUBMIT_FAIL';
export const COMPOSE_REPLY           = 'COMPOSE_REPLY';
export const COMPOSE_REPLY_CANCEL    = 'COMPOSE_REPLY_CANCEL';
export const COMPOSE_MENTION         = 'COMPOSE_MENTION';
export const COMPOSE_RESET           = 'COMPOSE_RESET';
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

export const COMPOSE_ADVANCED_OPTIONS_CHANGE = 'COMPOSE_ADVANCED_OPTIONS_CHANGE';
export const COMPOSE_SENSITIVITY_CHANGE = 'COMPOSE_SENSITIVITY_CHANGE';
export const COMPOSE_SPOILERNESS_CHANGE = 'COMPOSE_SPOILERNESS_CHANGE';
export const COMPOSE_SPOILER_TEXT_CHANGE = 'COMPOSE_SPOILER_TEXT_CHANGE';
export const COMPOSE_VISIBILITY_CHANGE  = 'COMPOSE_VISIBILITY_CHANGE';
export const COMPOSE_LISTABILITY_CHANGE = 'COMPOSE_LISTABILITY_CHANGE';

export const COMPOSE_EMOJI_INSERT = 'COMPOSE_EMOJI_INSERT';

export const COMPOSE_UPLOAD_CHANGE_REQUEST     = 'COMPOSE_UPLOAD_UPDATE_REQUEST';
export const COMPOSE_UPLOAD_CHANGE_SUCCESS     = 'COMPOSE_UPLOAD_UPDATE_SUCCESS';
export const COMPOSE_UPLOAD_CHANGE_FAIL        = 'COMPOSE_UPLOAD_UPDATE_FAIL';

export const COMPOSE_DOODLE_SET        = 'COMPOSE_DOODLE_SET';

export function changeCompose(text) {
  return {
    type: COMPOSE_CHANGE,
    text: text,
  };
};

export function cycleElefriendCompose() {
  return {
    type: COMPOSE_CYCLE_ELEFRIEND,
  };
};

export function replyCompose(status, router) {
  return (dispatch, getState) => {
    dispatch({
      type: COMPOSE_REPLY,
      status: status,
    });

    if (router && !getState().getIn(['compose', 'mounted'])) {
      router.push('/statuses/new');
    }
  };
};

export function cancelReplyCompose() {
  return {
    type: COMPOSE_REPLY_CANCEL,
  };
};

export function resetCompose() {
  return {
    type: COMPOSE_RESET,
  };
};

export function mentionCompose(account, router) {
  return (dispatch, getState) => {
    dispatch({
      type: COMPOSE_MENTION,
      account: account,
    });

    if (!getState().getIn(['compose', 'mounted'])) {
      router.push('/statuses/new');
    }
  };
};

export function submitCompose() {
  return function (dispatch, getState) {
    let status = getState().getIn(['compose', 'text'], '');
    let media  = getState().getIn(['compose', 'media_attachments']);

    if ((!status || !status.length) && media.size === 0) {
      return;
    }

    dispatch(submitComposeRequest());
    if (getState().getIn(['compose', 'advanced_options', 'do_not_federate'])) {
      status = status + ' 👁️';
    }
    api(getState).post('/api/v1/statuses', {
      status,
      in_reply_to_id: getState().getIn(['compose', 'in_reply_to'], null),
      media_ids: media.map(item => item.get('id')),
      sensitive: getState().getIn(['compose', 'sensitive']),
      spoiler_text: getState().getIn(['compose', 'spoiler_text'], ''),
      visibility: getState().getIn(['compose', 'privacy']),
    }, {
      headers: {
        'Idempotency-Key': getState().getIn(['compose', 'idempotencyKey']),
      },
    }).then(function (response) {
      dispatch(submitComposeSuccess({ ...response.data }));

      //  If the response has no data then we can't do anything else.
      if (!response.data) {
        return;
      }

      // To make the app more responsive, immediately get the status into the columns

      const insertOrRefresh = (timelineId, refreshAction) => {
        if (getState().getIn(['timelines', timelineId, 'online'])) {
          dispatch(updateTimeline(timelineId, { ...response.data }));
        } else if (getState().getIn(['timelines', timelineId, 'loaded'])) {
          dispatch(refreshAction());
        }
      };

      insertOrRefresh('home', refreshHomeTimeline);

      if (response.data.in_reply_to_id === null && response.data.visibility === 'public') {
        insertOrRefresh('community', refreshCommunityTimeline);
        insertOrRefresh('public', refreshPublicTimeline);
      } else if (response.data.visibility === 'direct') {
        insertOrRefresh('direct', refreshDirectTimeline);
      }
    }).catch(function (error) {
      dispatch(submitComposeFail(error));
    });
  };
};

export function submitComposeRequest() {
  return {
    type: COMPOSE_SUBMIT_REQUEST,
  };
};

export function submitComposeSuccess(status) {
  return {
    type: COMPOSE_SUBMIT_SUCCESS,
    status: status,
  };
};

export function submitComposeFail(error) {
  return {
    type: COMPOSE_SUBMIT_FAIL,
    error: error,
  };
};

export function doodleSet(options) {
  return {
    type: COMPOSE_DOODLE_SET,
    options: options,
  };
};

export function uploadCompose(files) {
  return function (dispatch, getState) {
    if (getState().getIn(['compose', 'media_attachments']).size > 3) {
      return;
    }

    dispatch(uploadComposeRequest());

    let data = new FormData();
    data.append('file', files[0]);

    api(getState).post('/api/v1/media', data, {
      onUploadProgress: function (e) {
        dispatch(uploadComposeProgress(e.loaded, e.total));
      },
    }).then(function (response) {
      dispatch(uploadComposeSuccess(response.data));
    }).catch(function (error) {
      dispatch(uploadComposeFail(error));
    });
  };
};

export function changeUploadCompose(id, description) {
  return (dispatch, getState) => {
    dispatch(changeUploadComposeRequest());

    api(getState).put(`/api/v1/media/${id}`, { description }).then(response => {
      dispatch(changeUploadComposeSuccess(response.data));
    }).catch(error => {
      dispatch(changeUploadComposeFail(id, error));
    });
  };
};

export function changeUploadComposeRequest() {
  return {
    type: COMPOSE_UPLOAD_CHANGE_REQUEST,
    skipLoading: true,
  };
};
export function changeUploadComposeSuccess(media) {
  return {
    type: COMPOSE_UPLOAD_CHANGE_SUCCESS,
    media: media,
    skipLoading: true,
  };
};

export function changeUploadComposeFail(error) {
  return {
    type: COMPOSE_UPLOAD_CHANGE_FAIL,
    error: error,
    skipLoading: true,
  };
};

export function uploadComposeRequest() {
  return {
    type: COMPOSE_UPLOAD_REQUEST,
    skipLoading: true,
  };
};

export function uploadComposeProgress(loaded, total) {
  return {
    type: COMPOSE_UPLOAD_PROGRESS,
    loaded: loaded,
    total: total,
  };
};

export function uploadComposeSuccess(media) {
  return {
    type: COMPOSE_UPLOAD_SUCCESS,
    media: media,
    skipLoading: true,
  };
};

export function uploadComposeFail(error) {
  return {
    type: COMPOSE_UPLOAD_FAIL,
    error: error,
    skipLoading: true,
  };
};

export function undoUploadCompose(media_id) {
  return {
    type: COMPOSE_UPLOAD_UNDO,
    media_id: media_id,
  };
};

export function clearComposeSuggestions() {
  return {
    type: COMPOSE_SUGGESTIONS_CLEAR,
  };
};

const fetchComposeSuggestionsAccounts = throttle((dispatch, getState, token) => {
  api(getState).get('/api/v1/accounts/search', {
    params: {
      q: token.slice(1),
      resolve: false,
      limit: 4,
    },
  }).then(response => {
    dispatch(readyComposeSuggestionsAccounts(token, response.data));
  });
}, 200, { leading: true, trailing: true });

const fetchComposeSuggestionsEmojis = (dispatch, getState, token) => {
  const results = emojiSearch(token.replace(':', ''), { maxResults: 5 });
  dispatch(readyComposeSuggestionsEmojis(token, results));
};

export function fetchComposeSuggestions(token) {
  return (dispatch, getState) => {
    if (token[0] === ':') {
      fetchComposeSuggestionsEmojis(dispatch, getState, token);
    } else {
      fetchComposeSuggestionsAccounts(dispatch, getState, token);
    }
  };
};

export function readyComposeSuggestionsEmojis(token, emojis) {
  return {
    type: COMPOSE_SUGGESTIONS_READY,
    token,
    emojis,
  };
};

export function readyComposeSuggestionsAccounts(token, accounts) {
  return {
    type: COMPOSE_SUGGESTIONS_READY,
    token,
    accounts,
  };
};

export function selectComposeSuggestion(position, token, suggestion) {
  return (dispatch, getState) => {
    const completion = typeof suggestion === 'object' && suggestion.id ? (
      dispatch(useEmoji(suggestion)),
      suggestion.native || suggestion.colons
    ) : '@' + getState().getIn(['accounts', suggestion, 'acct']);

    dispatch({
      type: COMPOSE_SUGGESTION_SELECT,
      position,
      token,
      completion,
    });
  };
};

export function mountCompose() {
  return {
    type: COMPOSE_MOUNT,
  };
};

export function unmountCompose() {
  return {
    type: COMPOSE_UNMOUNT,
  };
};

export function changeComposeAdvancedOption(option, value) {
  return {
    option,
    type: COMPOSE_ADVANCED_OPTIONS_CHANGE,
    value,
  };
}

export function changeComposeSensitivity() {
  return {
    type: COMPOSE_SENSITIVITY_CHANGE,
  };
};

export function changeComposeSpoilerness() {
  return {
    type: COMPOSE_SPOILERNESS_CHANGE,
  };
};

export function changeComposeSpoilerText(text) {
  return {
    type: COMPOSE_SPOILER_TEXT_CHANGE,
    text,
  };
};

export function changeComposeVisibility(value) {
  return {
    type: COMPOSE_VISIBILITY_CHANGE,
    value,
  };
};

export function insertEmojiCompose(position, emoji) {
  return {
    type: COMPOSE_EMOJI_INSERT,
    position,
    emoji,
  };
};

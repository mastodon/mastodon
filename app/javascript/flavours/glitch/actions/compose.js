import api from 'flavours/glitch/util/api';
import { CancelToken, isCancel } from 'axios';
import { throttle } from 'lodash';
import { search as emojiSearch } from 'flavours/glitch/util/emoji/emoji_mart_search_light';
import { useEmoji } from './emojis';
import { tagHistory } from 'flavours/glitch/util/settings';
import { recoverHashtags } from 'flavours/glitch/util/hashtag';
import resizeImage from 'flavours/glitch/util/resize_image';
import { importFetchedAccounts } from './importer';
import { updateTimeline } from './timelines';
import { showAlertForError } from './alerts';
import { showAlert } from './alerts';
import { defineMessages } from 'react-intl';

let cancelFetchComposeSuggestionsAccounts, cancelFetchComposeSuggestionsTags;

export const COMPOSE_CHANGE          = 'COMPOSE_CHANGE';
export const COMPOSE_CYCLE_ELEFRIEND = 'COMPOSE_CYCLE_ELEFRIEND';
export const COMPOSE_SUBMIT_REQUEST  = 'COMPOSE_SUBMIT_REQUEST';
export const COMPOSE_SUBMIT_SUCCESS  = 'COMPOSE_SUBMIT_SUCCESS';
export const COMPOSE_SUBMIT_FAIL     = 'COMPOSE_SUBMIT_FAIL';
export const COMPOSE_REPLY           = 'COMPOSE_REPLY';
export const COMPOSE_REPLY_CANCEL    = 'COMPOSE_REPLY_CANCEL';
export const COMPOSE_DIRECT          = 'COMPOSE_DIRECT';
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
export const COMPOSE_SUGGESTION_TAGS_UPDATE = 'COMPOSE_SUGGESTION_TAGS_UPDATE';

export const COMPOSE_TAG_HISTORY_UPDATE = 'COMPOSE_TAG_HISTORY_UPDATE';

export const COMPOSE_MOUNT   = 'COMPOSE_MOUNT';
export const COMPOSE_UNMOUNT = 'COMPOSE_UNMOUNT';

export const COMPOSE_ADVANCED_OPTIONS_CHANGE = 'COMPOSE_ADVANCED_OPTIONS_CHANGE';
export const COMPOSE_SENSITIVITY_CHANGE = 'COMPOSE_SENSITIVITY_CHANGE';
export const COMPOSE_SPOILERNESS_CHANGE = 'COMPOSE_SPOILERNESS_CHANGE';
export const COMPOSE_SPOILER_TEXT_CHANGE = 'COMPOSE_SPOILER_TEXT_CHANGE';
export const COMPOSE_VISIBILITY_CHANGE  = 'COMPOSE_VISIBILITY_CHANGE';
export const COMPOSE_LISTABILITY_CHANGE = 'COMPOSE_LISTABILITY_CHANGE';
export const COMPOSE_CONTENT_TYPE_CHANGE = 'COMPOSE_CONTENT_TYPE_CHANGE';

export const COMPOSE_EMOJI_INSERT = 'COMPOSE_EMOJI_INSERT';

export const COMPOSE_UPLOAD_CHANGE_REQUEST     = 'COMPOSE_UPLOAD_UPDATE_REQUEST';
export const COMPOSE_UPLOAD_CHANGE_SUCCESS     = 'COMPOSE_UPLOAD_UPDATE_SUCCESS';
export const COMPOSE_UPLOAD_CHANGE_FAIL        = 'COMPOSE_UPLOAD_UPDATE_FAIL';

export const COMPOSE_DOODLE_SET        = 'COMPOSE_DOODLE_SET';

export const COMPOSE_POLL_ADD             = 'COMPOSE_POLL_ADD';
export const COMPOSE_POLL_REMOVE          = 'COMPOSE_POLL_REMOVE';
export const COMPOSE_POLL_OPTION_ADD      = 'COMPOSE_POLL_OPTION_ADD';
export const COMPOSE_POLL_OPTION_CHANGE   = 'COMPOSE_POLL_OPTION_CHANGE';
export const COMPOSE_POLL_OPTION_REMOVE   = 'COMPOSE_POLL_OPTION_REMOVE';
export const COMPOSE_POLL_SETTINGS_CHANGE = 'COMPOSE_POLL_SETTINGS_CHANGE';

const messages = defineMessages({
  uploadErrorLimit: { id: 'upload_error.limit', defaultMessage: 'File upload limit exceeded.' },
  uploadErrorPoll:  { id: 'upload_error.poll', defaultMessage: 'File upload not allowed with polls.' },
});

const COMPOSE_PANEL_BREAKPOINT = 600 + (285 * 1) + (10 * 1);

export const ensureComposeIsVisible = (getState, routerHistory) => {
  if (!getState().getIn(['compose', 'mounted']) && window.innerWidth < COMPOSE_PANEL_BREAKPOINT) {
    routerHistory.push('/statuses/new');
  }
};

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

export function replyCompose(status, routerHistory) {
  return (dispatch, getState) => {
    const prependCWRe = getState().getIn(['local_settings', 'prepend_cw_re']);
    dispatch({
      type: COMPOSE_REPLY,
      status: status,
      prependCWRe: prependCWRe,
    });

    ensureComposeIsVisible(getState, routerHistory);
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

export function mentionCompose(account, routerHistory) {
  return (dispatch, getState) => {
    dispatch({
      type: COMPOSE_MENTION,
      account: account,
    });

    ensureComposeIsVisible(getState, routerHistory);
  };
};

export function directCompose(account, routerHistory) {
  return (dispatch, getState) => {
    dispatch({
      type: COMPOSE_DIRECT,
      account: account,
    });

    ensureComposeIsVisible(getState, routerHistory);
  };
};

export function submitCompose(routerHistory) {
  return function (dispatch, getState) {
    let status = getState().getIn(['compose', 'text'], '');
    let media  = getState().getIn(['compose', 'media_attachments']);
    const spoilers = getState().getIn(['compose', 'spoiler']) || getState().getIn(['local_settings', 'always_show_spoilers_field']);
    let spoilerText = spoilers ? getState().getIn(['compose', 'spoiler_text'], '') : '';

    if ((!status || !status.length) && media.size === 0) {
      return;
    }

    dispatch(submitComposeRequest());
    if (getState().getIn(['compose', 'advanced_options', 'do_not_federate'])) {
      status = status + ' 👁️';
    }
    api(getState).post('/api/v1/statuses', {
      status,
      content_type: getState().getIn(['compose', 'content_type']),
      in_reply_to_id: getState().getIn(['compose', 'in_reply_to'], null),
      media_ids: media.map(item => item.get('id')),
      sensitive: getState().getIn(['compose', 'sensitive']) || (spoilerText.length > 0 && media.size !== 0),
      spoiler_text: spoilerText,
      visibility: getState().getIn(['compose', 'privacy']),
      poll: getState().getIn(['compose', 'poll'], null),
    }, {
      headers: {
        'Idempotency-Key': getState().getIn(['compose', 'idempotencyKey']),
      },
    }).then(function (response) {
      if (routerHistory && routerHistory.location.pathname === '/statuses/new'
          && window.history.state
          && !getState().getIn(['compose', 'advanced_options', 'threaded_mode'])) {
        routerHistory.goBack();
      }

      dispatch(insertIntoTagHistory(response.data.tags, status));
      dispatch(submitComposeSuccess({ ...response.data }));

      //  If the response has no data then we can't do anything else.
      if (!response.data) {
        return;
      }

      // To make the app more responsive, immediately get the status into the columns

      const insertIfOnline = (timelineId) => {
        const timeline = getState().getIn(['timelines', timelineId]);

        if (timeline && timeline.get('items').size > 0 && timeline.getIn(['items', 0]) !== null && timeline.get('online')) {
          dispatch(updateTimeline(timelineId, { ...response.data }));
        }
      };

      insertIfOnline('home');

      if (response.data.in_reply_to_id === null && response.data.visibility === 'public') {
        insertIfOnline('community');
        insertIfOnline('public');
      } else if (response.data.visibility === 'direct') {
        insertIfOnline('direct');
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
    const uploadLimit = 4;
    const media  = getState().getIn(['compose', 'media_attachments']);
    const pending  = getState().getIn(['compose', 'pending_media_attachments']);
    const progress = new Array(files.length).fill(0);
    let total = Array.from(files).reduce((a, v) => a + v.size, 0);

    if (files.length + media.size + pending > uploadLimit) {
      dispatch(showAlert(undefined, messages.uploadErrorLimit));
      return;
    }

    if (getState().getIn(['compose', 'poll'])) {
      dispatch(showAlert(undefined, messages.uploadErrorPoll));
      return;
    }

    dispatch(uploadComposeRequest());

    for (const [i, f] of Array.from(files).entries()) {
      if (media.size + i > 3) break;

      resizeImage(f).then(file => {
        const data = new FormData();
        data.append('file', file);
        // Account for disparity in size of original image and resized data
        total += file.size - f.size;

        return api(getState).post('/api/v2/media', data, {
          onUploadProgress: function({ loaded }){
            progress[i] = loaded;
            dispatch(uploadComposeProgress(progress.reduce((a, v) => a + v, 0), total));
          },
        }).then(({ status, data }) => {
          // If server-side processing of the media attachment has not completed yet,
          // poll the server until it is, before showing the media attachment as uploaded

          if (status === 200) {
            dispatch(uploadComposeSuccess(data, f));
          } else if (status === 202) {
            const poll = () => {
              api(getState).get(`/api/v1/media/${data.id}`).then(response => {
                if (response.status === 200) {
                  dispatch(uploadComposeSuccess(response.data, f));
                } else if (response.status === 206) {
                  setTimeout(() => poll(), 1000);
                }
              }).catch(error => dispatch(uploadComposeFail(error)));
            };

            poll();
          }
        });
      }).catch(error => dispatch(uploadComposeFail(error)));
    };
  };
};

export function changeUploadCompose(id, params) {
  return (dispatch, getState) => {
    dispatch(changeUploadComposeRequest());

    api(getState).put(`/api/v1/media/${id}`, params).then(response => {
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

export function uploadComposeSuccess(media, file) {
  return {
    type: COMPOSE_UPLOAD_SUCCESS,
    media: media,
    file: file,
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
  if (cancelFetchComposeSuggestionsAccounts) {
    cancelFetchComposeSuggestionsAccounts();
  }
  return {
    type: COMPOSE_SUGGESTIONS_CLEAR,
  };
};

const fetchComposeSuggestionsAccounts = throttle((dispatch, getState, token) => {
  if (cancelFetchComposeSuggestionsAccounts) {
    cancelFetchComposeSuggestionsAccounts();
  }

  api(getState).get('/api/v1/accounts/search', {
    cancelToken: new CancelToken(cancel => {
      cancelFetchComposeSuggestionsAccounts = cancel;
    }),

    params: {
      q: token.slice(1),
      resolve: false,
      limit: 4,
    },
  }).then(response => {
    dispatch(importFetchedAccounts(response.data));
    dispatch(readyComposeSuggestionsAccounts(token, response.data));
  }).catch(error => {
    if (!isCancel(error)) {
      dispatch(showAlertForError(error));
    }
  });
}, 200, { leading: true, trailing: true });

const fetchComposeSuggestionsEmojis = (dispatch, getState, token) => {
  const results = emojiSearch(token.replace(':', ''), { maxResults: 5 });
  dispatch(readyComposeSuggestionsEmojis(token, results));
};

const fetchComposeSuggestionsTags = throttle((dispatch, getState, token) => {
  if (cancelFetchComposeSuggestionsTags) {
    cancelFetchComposeSuggestionsTags();
  }

  dispatch(updateSuggestionTags(token));

  api(getState).get('/api/v2/search', {
    cancelToken: new CancelToken(cancel => {
      cancelFetchComposeSuggestionsTags = cancel;
    }),

    params: {
      type: 'hashtags',
      q: token.slice(1),
      resolve: false,
      limit: 4,
    },
  }).then(({ data }) => {
    dispatch(readyComposeSuggestionsTags(token, data.hashtags));
  }).catch(error => {
    if (!isCancel(error)) {
      dispatch(showAlertForError(error));
    }
  });
}, 200, { leading: true, trailing: true });

export function fetchComposeSuggestions(token) {
  return (dispatch, getState) => {
    switch (token[0]) {
    case ':':
      fetchComposeSuggestionsEmojis(dispatch, getState, token);
      break;
    case '#':
      fetchComposeSuggestionsTags(dispatch, getState, token);
      break;
    default:
      fetchComposeSuggestionsAccounts(dispatch, getState, token);
      break;
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

export const readyComposeSuggestionsTags = (token, tags) => ({
  type: COMPOSE_SUGGESTIONS_READY,
  token,
  tags,
});

export function selectComposeSuggestion(position, token, suggestion, path) {
  return (dispatch, getState) => {
    let completion;
    if (suggestion.type === 'emoji') {
      dispatch(useEmoji(suggestion));
      completion = suggestion.native || suggestion.colons;
    } else if (suggestion.type === 'hashtag') {
      completion = `#${suggestion.name}`;
    } else if (suggestion.type === 'account') {
      completion = '@' + getState().getIn(['accounts', suggestion.id, 'acct']);
    }

    dispatch({
      type: COMPOSE_SUGGESTION_SELECT,
      position,
      token,
      completion,
      path,
    });
  };
};

export function updateSuggestionTags(token) {
  return {
    type: COMPOSE_SUGGESTION_TAGS_UPDATE,
    token,
  };
}

export function updateTagHistory(tags) {
  return {
    type: COMPOSE_TAG_HISTORY_UPDATE,
    tags,
  };
}

export function hydrateCompose() {
  return (dispatch, getState) => {
    const me = getState().getIn(['meta', 'me']);
    const history = tagHistory.get(me);

    if (history !== null) {
      dispatch(updateTagHistory(history));
    }
  };
}

function insertIntoTagHistory(recognizedTags, text) {
  return (dispatch, getState) => {
    const state = getState();
    const oldHistory = state.getIn(['compose', 'tagHistory']);
    const me = state.getIn(['meta', 'me']);
    const names = recoverHashtags(recognizedTags, text);
    const intersectedOldHistory = oldHistory.filter(name => names.findIndex(newName => newName.toLowerCase() === name.toLowerCase()) === -1);

    names.push(...intersectedOldHistory.toJS());

    const newHistory = names.slice(0, 1000);

    tagHistory.set(me, newHistory);
    dispatch(updateTagHistory(newHistory));
  };
}

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

export function changeComposeContentType(value) {
  return {
    type: COMPOSE_CONTENT_TYPE_CHANGE,
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

export function addPoll() {
  return {
    type: COMPOSE_POLL_ADD,
  };
};

export function removePoll() {
  return {
    type: COMPOSE_POLL_REMOVE,
  };
};

export function addPollOption(title) {
  return {
    type: COMPOSE_POLL_OPTION_ADD,
    title,
  };
};

export function changePollOption(index, title) {
  return {
    type: COMPOSE_POLL_OPTION_CHANGE,
    index,
    title,
  };
};

export function removePollOption(index) {
  return {
    type: COMPOSE_POLL_OPTION_REMOVE,
    index,
  };
};

export function changePollSettings(expiresIn, isMultiple) {
  return {
    type: COMPOSE_POLL_SETTINGS_CHANGE,
    expiresIn,
    isMultiple,
  };
};

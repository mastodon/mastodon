import { defineMessages } from 'react-intl';

import axios from 'axios';
import { throttle } from 'lodash';

import api from 'mastodon/api';
import { browserHistory } from 'mastodon/components/router';
import { search as emojiSearch } from 'mastodon/features/emoji/emoji_mart_search_light';
import { tagHistory } from 'mastodon/settings';

import { showAlert, showAlertForError } from './alerts';
import { useEmoji } from './emojis';
import { importFetchedAccounts, importFetchedStatus } from './importer';
import { openModal } from './modal';
import { updateTimeline } from './timelines';

/** @type {AbortController | undefined} */
let fetchComposeSuggestionsAccountsController;
/** @type {AbortController | undefined} */
let fetchComposeSuggestionsTagsController;

export const COMPOSE_CHANGE          = 'COMPOSE_CHANGE';
export const COMPOSE_SUBMIT_REQUEST  = 'COMPOSE_SUBMIT_REQUEST';
export const COMPOSE_SUBMIT_SUCCESS  = 'COMPOSE_SUBMIT_SUCCESS';
export const COMPOSE_SUBMIT_FAIL     = 'COMPOSE_SUBMIT_FAIL';
export const COMPOSE_REPLY           = 'COMPOSE_REPLY';
export const COMPOSE_REPLY_CANCEL    = 'COMPOSE_REPLY_CANCEL';
export const COMPOSE_DIRECT          = 'COMPOSE_DIRECT';
export const COMPOSE_MENTION         = 'COMPOSE_MENTION';
export const COMPOSE_RESET           = 'COMPOSE_RESET';

export const COMPOSE_UPLOAD_REQUEST    = 'COMPOSE_UPLOAD_REQUEST';
export const COMPOSE_UPLOAD_SUCCESS    = 'COMPOSE_UPLOAD_SUCCESS';
export const COMPOSE_UPLOAD_FAIL       = 'COMPOSE_UPLOAD_FAIL';
export const COMPOSE_UPLOAD_PROGRESS   = 'COMPOSE_UPLOAD_PROGRESS';
export const COMPOSE_UPLOAD_PROCESSING = 'COMPOSE_UPLOAD_PROCESSING';
export const COMPOSE_UPLOAD_UNDO       = 'COMPOSE_UPLOAD_UNDO';

export const THUMBNAIL_UPLOAD_REQUEST  = 'THUMBNAIL_UPLOAD_REQUEST';
export const THUMBNAIL_UPLOAD_SUCCESS  = 'THUMBNAIL_UPLOAD_SUCCESS';
export const THUMBNAIL_UPLOAD_FAIL     = 'THUMBNAIL_UPLOAD_FAIL';
export const THUMBNAIL_UPLOAD_PROGRESS = 'THUMBNAIL_UPLOAD_PROGRESS';

export const COMPOSE_SUGGESTIONS_CLEAR = 'COMPOSE_SUGGESTIONS_CLEAR';
export const COMPOSE_SUGGESTIONS_READY = 'COMPOSE_SUGGESTIONS_READY';
export const COMPOSE_SUGGESTION_SELECT = 'COMPOSE_SUGGESTION_SELECT';
export const COMPOSE_SUGGESTION_IGNORE = 'COMPOSE_SUGGESTION_IGNORE';
export const COMPOSE_SUGGESTION_TAGS_UPDATE = 'COMPOSE_SUGGESTION_TAGS_UPDATE';

export const COMPOSE_TAG_HISTORY_UPDATE = 'COMPOSE_TAG_HISTORY_UPDATE';

export const COMPOSE_MOUNT   = 'COMPOSE_MOUNT';
export const COMPOSE_UNMOUNT = 'COMPOSE_UNMOUNT';

export const COMPOSE_SENSITIVITY_CHANGE  = 'COMPOSE_SENSITIVITY_CHANGE';
export const COMPOSE_SPOILERNESS_CHANGE  = 'COMPOSE_SPOILERNESS_CHANGE';
export const COMPOSE_SPOILER_TEXT_CHANGE = 'COMPOSE_SPOILER_TEXT_CHANGE';
export const COMPOSE_VISIBILITY_CHANGE   = 'COMPOSE_VISIBILITY_CHANGE';
export const COMPOSE_COMPOSING_CHANGE    = 'COMPOSE_COMPOSING_CHANGE';
export const COMPOSE_LANGUAGE_CHANGE     = 'COMPOSE_LANGUAGE_CHANGE';

export const COMPOSE_EMOJI_INSERT = 'COMPOSE_EMOJI_INSERT';

export const COMPOSE_UPLOAD_CHANGE_REQUEST     = 'COMPOSE_UPLOAD_UPDATE_REQUEST';
export const COMPOSE_UPLOAD_CHANGE_SUCCESS     = 'COMPOSE_UPLOAD_UPDATE_SUCCESS';
export const COMPOSE_UPLOAD_CHANGE_FAIL        = 'COMPOSE_UPLOAD_UPDATE_FAIL';

export const COMPOSE_POLL_ADD             = 'COMPOSE_POLL_ADD';
export const COMPOSE_POLL_REMOVE          = 'COMPOSE_POLL_REMOVE';
export const COMPOSE_POLL_OPTION_ADD      = 'COMPOSE_POLL_OPTION_ADD';
export const COMPOSE_POLL_OPTION_CHANGE   = 'COMPOSE_POLL_OPTION_CHANGE';
export const COMPOSE_POLL_OPTION_REMOVE   = 'COMPOSE_POLL_OPTION_REMOVE';
export const COMPOSE_POLL_SETTINGS_CHANGE = 'COMPOSE_POLL_SETTINGS_CHANGE';

export const INIT_MEDIA_EDIT_MODAL = 'INIT_MEDIA_EDIT_MODAL';

export const COMPOSE_CHANGE_MEDIA_DESCRIPTION = 'COMPOSE_CHANGE_MEDIA_DESCRIPTION';
export const COMPOSE_CHANGE_MEDIA_FOCUS       = 'COMPOSE_CHANGE_MEDIA_FOCUS';
export const COMPOSE_CHANGE_MEDIA_ORDER       = 'COMPOSE_CHANGE_MEDIA_ORDER';

export const COMPOSE_SET_STATUS = 'COMPOSE_SET_STATUS';
export const COMPOSE_FOCUS = 'COMPOSE_FOCUS';

const messages = defineMessages({
  uploadErrorLimit: { id: 'upload_error.limit', defaultMessage: 'File upload limit exceeded.' },
  uploadErrorPoll:  { id: 'upload_error.poll', defaultMessage: 'File upload not allowed with polls.' },
  open: { id: 'compose.published.open', defaultMessage: 'Open' },
  published: { id: 'compose.published.body', defaultMessage: 'Post published.' },
  saved: { id: 'compose.saved.body', defaultMessage: 'Post saved.' },
});

export const ensureComposeIsVisible = (getState) => {
  if (!getState().getIn(['compose', 'mounted'])) {
    browserHistory.push('/publish');
  }
};

export function setComposeToStatus(status, text, spoiler_text) {
  return{
    type: COMPOSE_SET_STATUS,
    status,
    text,
    spoiler_text,
  };
}

export function changeCompose(text) {
  return {
    type: COMPOSE_CHANGE,
    text: text,
  };
}

export function replyCompose(status) {
  return (dispatch, getState) => {
    dispatch({
      type: COMPOSE_REPLY,
      status: status,
    });

    ensureComposeIsVisible(getState);
  };
}

export function replyComposeById(statusId) {
  return (dispatch, getState) => {
    const state = getState();
    const status = state.statuses.get(statusId);

    if (status) {
      const account = state.accounts.get(status.get('account'));
      dispatch(replyCompose(status.set('account', account)));
    }
  };
}

export function cancelReplyCompose() {
  return {
    type: COMPOSE_REPLY_CANCEL,
  };
}

export function resetCompose() {
  return {
    type: COMPOSE_RESET,
  };
}

export const focusCompose = (defaultText) => (dispatch, getState) => {
  dispatch({
    type: COMPOSE_FOCUS,
    defaultText,
  });

  ensureComposeIsVisible(getState);
};

export function mentionCompose(account) {
  return (dispatch, getState) => {
    dispatch({
      type: COMPOSE_MENTION,
      account: account,
    });

    ensureComposeIsVisible(getState);
  };
}

export function mentionComposeById(accountId) {
  return (dispatch, getState) => {
    dispatch(mentionCompose(getState().accounts.get(accountId)));
  };
}

export function directCompose(account) {
  return (dispatch, getState) => {
    dispatch({
      type: COMPOSE_DIRECT,
      account: account,
    });

    ensureComposeIsVisible(getState);
  };
}

export function submitCompose() {
  return function (dispatch, getState) {
    const status   = getState().getIn(['compose', 'text'], '');
    const media    = getState().getIn(['compose', 'media_attachments']);
    const statusId = getState().getIn(['compose', 'id'], null);

    if ((!status || !status.length) && media.size === 0) {
      return;
    }

    dispatch(submitComposeRequest());

    // If we're editing a post with media attachments, those have not
    // necessarily been changed on the server. Do it now in the same
    // API call.
    let media_attributes;
    if (statusId !== null) {
      media_attributes = media.map(item => {
        let focus;

        if (item.getIn(['meta', 'focus'])) {
          focus = `${item.getIn(['meta', 'focus', 'x']).toFixed(2)},${item.getIn(['meta', 'focus', 'y']).toFixed(2)}`;
        }

        return {
          id: item.get('id'),
          description: item.get('description'),
          focus,
        };
      });
    }

    api().request({
      url: statusId === null ? '/api/v1/statuses' : `/api/v1/statuses/${statusId}`,
      method: statusId === null ? 'post' : 'put',
      data: {
        status,
        in_reply_to_id: getState().getIn(['compose', 'in_reply_to'], null),
        media_ids: media.map(item => item.get('id')),
        media_attributes,
        sensitive: getState().getIn(['compose', 'sensitive']),
        spoiler_text: getState().getIn(['compose', 'spoiler']) ? getState().getIn(['compose', 'spoiler_text'], '') : '',
        visibility: getState().getIn(['compose', 'privacy']),
        poll: getState().getIn(['compose', 'poll'], null),
        language: getState().getIn(['compose', 'language']),
      },
      headers: {
        'Idempotency-Key': getState().getIn(['compose', 'idempotencyKey']),
      },
    }).then(function (response) {
      if ((browserHistory.location.pathname === '/publish' || browserHistory.location.pathname === '/statuses/new') && window.history.state) {
        browserHistory.goBack();
      }

      dispatch(insertIntoTagHistory(response.data.tags, status));
      dispatch(submitComposeSuccess({ ...response.data }));

      // To make the app more responsive, immediately push the status
      // into the columns
      const insertIfOnline = timelineId => {
        const timeline = getState().getIn(['timelines', timelineId]);

        if (timeline && timeline.get('items').size > 0 && timeline.getIn(['items', 0]) !== null && timeline.get('online')) {
          dispatch(updateTimeline(timelineId, { ...response.data }));
        }
      };

      if (statusId) {
        dispatch(importFetchedStatus({ ...response.data }));
      }

      if (statusId === null && response.data.visibility !== 'direct') {
        insertIfOnline('home');
      }

      if (statusId === null && response.data.in_reply_to_id === null && response.data.visibility === 'public') {
        insertIfOnline('community');
        insertIfOnline('public');
        insertIfOnline(`account:${response.data.account.id}`);
      }

      dispatch(showAlert({
        message: statusId === null ? messages.published : messages.saved,
        action: messages.open,
        dismissAfter: 10000,
        onClick: () => browserHistory.push(`/@${response.data.account.username}/${response.data.id}`),
      }));
    }).catch(function (error) {
      dispatch(submitComposeFail(error));
    });
  };
}

export function submitComposeRequest() {
  return {
    type: COMPOSE_SUBMIT_REQUEST,
  };
}

export function submitComposeSuccess(status) {
  return {
    type: COMPOSE_SUBMIT_SUCCESS,
    status: status,
  };
}

export function submitComposeFail(error) {
  return {
    type: COMPOSE_SUBMIT_FAIL,
    error: error,
  };
}

export function uploadCompose(files) {
  return function (dispatch, getState) {
    const uploadLimit = getState().getIn(['server', 'server', 'configuration', 'statuses', 'max_media_attachments']);
    const media = getState().getIn(['compose', 'media_attachments']);
    const pending = getState().getIn(['compose', 'pending_media_attachments']);
    const progress = new Array(files.length).fill(0);

    let total = Array.from(files).reduce((a, v) => a + v.size, 0);

    if (files.length + media.size + pending > uploadLimit) {
      dispatch(showAlert({ message: messages.uploadErrorLimit }));
      return;
    }

    if (getState().getIn(['compose', 'poll'])) {
      dispatch(showAlert({ message: messages.uploadErrorPoll }));
      return;
    }

    dispatch(uploadComposeRequest());

    for (const [i, file] of Array.from(files).entries()) {
      if (media.size + i > (uploadLimit - 1)) break;

      const data = new FormData();
      data.append('file', file);

      api().post('/api/v2/media', data, {
        onUploadProgress: function({ loaded }){
          progress[i] = loaded;
          dispatch(uploadComposeProgress(progress.reduce((a, v) => a + v, 0), total));
        },
      }).then(({ status, data }) => {
        // If server-side processing of the media attachment has not completed yet,
        // poll the server until it is, before showing the media attachment as uploaded

        if (status === 200) {
          dispatch(uploadComposeSuccess(data, file));
        } else if (status === 202) {
          dispatch(uploadComposeProcessing());

          let tryCount = 1;

          const poll = () => {
            api().get(`/api/v1/media/${data.id}`).then(response => {
              if (response.status === 200) {
                dispatch(uploadComposeSuccess(response.data, file));
              } else if (response.status === 206) {
                const retryAfter = (Math.log2(tryCount) || 1) * 1000;
                tryCount += 1;
                setTimeout(() => poll(), retryAfter);
              }
            }).catch(error => dispatch(uploadComposeFail(error)));
          };

          poll();
        }
      }).catch(error => dispatch(uploadComposeFail(error)));
    }
  };
}

export const uploadComposeProcessing = () => ({
  type: COMPOSE_UPLOAD_PROCESSING,
});

export const uploadThumbnail = (id, file) => (dispatch) => {
  dispatch(uploadThumbnailRequest());

  const total = file.size;
  const data = new FormData();

  data.append('thumbnail', file);

  api().put(`/api/v1/media/${id}`, data, {
    onUploadProgress: ({ loaded }) => {
      dispatch(uploadThumbnailProgress(loaded, total));
    },
  }).then(({ data }) => {
    dispatch(uploadThumbnailSuccess(data));
  }).catch(error => {
    dispatch(uploadThumbnailFail(id, error));
  });
};

export const uploadThumbnailRequest = () => ({
  type: THUMBNAIL_UPLOAD_REQUEST,
  skipLoading: true,
});

export const uploadThumbnailProgress = (loaded, total) => ({
  type: THUMBNAIL_UPLOAD_PROGRESS,
  loaded,
  total,
  skipLoading: true,
});

export const uploadThumbnailSuccess = media => ({
  type: THUMBNAIL_UPLOAD_SUCCESS,
  media,
  skipLoading: true,
});

export const uploadThumbnailFail = error => ({
  type: THUMBNAIL_UPLOAD_FAIL,
  error,
  skipLoading: true,
});

export function initMediaEditModal(id) {
  return dispatch => {
    dispatch({
      type: INIT_MEDIA_EDIT_MODAL,
      id,
    });

    dispatch(openModal({
      modalType: 'FOCAL_POINT',
      modalProps: { id },
    }));
  };
}

export function onChangeMediaDescription(description) {
  return {
    type: COMPOSE_CHANGE_MEDIA_DESCRIPTION,
    description,
  };
}

export function onChangeMediaFocus(focusX, focusY) {
  return {
    type: COMPOSE_CHANGE_MEDIA_FOCUS,
    focusX,
    focusY,
  };
}

export function changeUploadCompose(id, params) {
  return (dispatch, getState) => {
    dispatch(changeUploadComposeRequest());

    let media = getState().getIn(['compose', 'media_attachments']).find((item) => item.get('id') === id);

    // Editing already-attached media is deferred to editing the post itself.
    // For simplicity's sake, fake an API reply.
    if (media && !media.get('unattached')) {
      const { focus, ...other } = params;
      const data = { ...media.toJS(), ...other };

      if (focus) {
        const [x, y] = focus.split(',');
        data.meta = { focus: { x: parseFloat(x), y: parseFloat(y) } };
      }

      dispatch(changeUploadComposeSuccess(data, true));
    } else {
      api().put(`/api/v1/media/${id}`, params).then(response => {
        dispatch(changeUploadComposeSuccess(response.data, false));
      }).catch(error => {
        dispatch(changeUploadComposeFail(id, error));
      });
    }
  };
}

export function changeUploadComposeRequest() {
  return {
    type: COMPOSE_UPLOAD_CHANGE_REQUEST,
    skipLoading: true,
  };
}

export function changeUploadComposeSuccess(media, attached) {
  return {
    type: COMPOSE_UPLOAD_CHANGE_SUCCESS,
    media: media,
    attached: attached,
    skipLoading: true,
  };
}

export function changeUploadComposeFail(error) {
  return {
    type: COMPOSE_UPLOAD_CHANGE_FAIL,
    error: error,
    skipLoading: true,
  };
}

export function uploadComposeRequest() {
  return {
    type: COMPOSE_UPLOAD_REQUEST,
    skipLoading: true,
  };
}

export function uploadComposeProgress(loaded, total) {
  return {
    type: COMPOSE_UPLOAD_PROGRESS,
    loaded: loaded,
    total: total,
  };
}

export function uploadComposeSuccess(media, file) {
  return {
    type: COMPOSE_UPLOAD_SUCCESS,
    media: media,
    file: file,
    skipLoading: true,
  };
}

export function uploadComposeFail(error) {
  return {
    type: COMPOSE_UPLOAD_FAIL,
    error: error,
    skipLoading: true,
  };
}

export function undoUploadCompose(media_id) {
  return {
    type: COMPOSE_UPLOAD_UNDO,
    media_id: media_id,
  };
}

export function clearComposeSuggestions() {
  if (fetchComposeSuggestionsAccountsController) {
    fetchComposeSuggestionsAccountsController.abort();
  }
  return {
    type: COMPOSE_SUGGESTIONS_CLEAR,
  };
}

const fetchComposeSuggestionsAccounts = throttle((dispatch, getState, token) => {
  if (fetchComposeSuggestionsAccountsController) {
    fetchComposeSuggestionsAccountsController.abort();
  }

  fetchComposeSuggestionsAccountsController = new AbortController();

  api().get('/api/v1/accounts/search', {
    signal: fetchComposeSuggestionsAccountsController.signal,

    params: {
      q: token.slice(1),
      resolve: false,
      limit: 4,
    },
  }).then(response => {
    dispatch(importFetchedAccounts(response.data));
    dispatch(readyComposeSuggestionsAccounts(token, response.data));
  }).catch(error => {
    if (!axios.isCancel(error)) {
      dispatch(showAlertForError(error));
    }
  }).finally(() => {
    fetchComposeSuggestionsAccountsController = undefined;
  });
}, 200, { leading: true, trailing: true });

const fetchComposeSuggestionsEmojis = (dispatch, getState, token) => {
  const results = emojiSearch(token.replace(':', ''), { maxResults: 5 });
  dispatch(readyComposeSuggestionsEmojis(token, results));
};

const fetchComposeSuggestionsTags = throttle((dispatch, getState, token) => {
  if (fetchComposeSuggestionsTagsController) {
    fetchComposeSuggestionsTagsController.abort();
  }

  dispatch(updateSuggestionTags(token));

  fetchComposeSuggestionsTagsController = new AbortController();

  api().get('/api/v2/search', {
    signal: fetchComposeSuggestionsTagsController.signal,

    params: {
      type: 'hashtags',
      q: token.slice(1),
      resolve: false,
      limit: 4,
      exclude_unreviewed: true,
    },
  }).then(({ data }) => {
    dispatch(readyComposeSuggestionsTags(token, data.hashtags));
  }).catch(error => {
    if (!axios.isCancel(error)) {
      dispatch(showAlertForError(error));
    }
  }).finally(() => {
    fetchComposeSuggestionsTagsController = undefined;
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
}

export function readyComposeSuggestionsEmojis(token, emojis) {
  return {
    type: COMPOSE_SUGGESTIONS_READY,
    token,
    emojis,
  };
}

export function readyComposeSuggestionsAccounts(token, accounts) {
  return {
    type: COMPOSE_SUGGESTIONS_READY,
    token,
    accounts,
  };
}

export const readyComposeSuggestionsTags = (token, tags) => ({
  type: COMPOSE_SUGGESTIONS_READY,
  token,
  tags,
});

export function selectComposeSuggestion(position, token, suggestion, path) {
  return (dispatch, getState) => {
    let completion, startPosition;

    if (suggestion.type === 'emoji') {
      completion    = suggestion.native || suggestion.colons;
      startPosition = position - 1;

      dispatch(useEmoji(suggestion));
    } else if (suggestion.type === 'hashtag') {
      completion    = `#${suggestion.name}`;
      startPosition = position - 1;
    } else if (suggestion.type === 'account') {
      completion    = getState().getIn(['accounts', suggestion.id, 'acct']);
      startPosition = position;
    }

    // We don't want to replace hashtags that vary only in case due to accessibility, but we need to fire off an event so that
    // the suggestions are dismissed and the cursor moves forward.
    if (suggestion.type !== 'hashtag' || token.slice(1).localeCompare(suggestion.name, undefined, { sensitivity: 'accent' }) !== 0) {
      dispatch({
        type: COMPOSE_SUGGESTION_SELECT,
        position: startPosition,
        token,
        completion,
        path,
      });
    } else {
      dispatch({
        type: COMPOSE_SUGGESTION_IGNORE,
        position: startPosition,
        token,
        completion,
        path,
      });
    }
  };
}

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

    // FIXME: Matching input hashtags with recognized hashtags has become more
    // complicated because of new normalization rules, it's no longer just
    // a case sensitivity issue
    const names = recognizedTags.map(tag => {
      const matches = text.match(new RegExp(`#${tag.name}`, 'i'));

      if (matches && matches.length > 0) {
        return matches[0].slice(1);
      } else {
        return tag.name;
      }
    });

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
}

export function unmountCompose() {
  return {
    type: COMPOSE_UNMOUNT,
  };
}

export function changeComposeSensitivity() {
  return {
    type: COMPOSE_SENSITIVITY_CHANGE,
  };
}

export const changeComposeLanguage = language => ({
  type: COMPOSE_LANGUAGE_CHANGE,
  language,
});

export function changeComposeSpoilerness() {
  return {
    type: COMPOSE_SPOILERNESS_CHANGE,
  };
}

export function changeComposeSpoilerText(text) {
  return {
    type: COMPOSE_SPOILER_TEXT_CHANGE,
    text,
  };
}

export function changeComposeVisibility(value) {
  return {
    type: COMPOSE_VISIBILITY_CHANGE,
    value,
  };
}

export function insertEmojiCompose(position, emoji, needsSpace) {
  return {
    type: COMPOSE_EMOJI_INSERT,
    position,
    emoji,
    needsSpace,
  };
}

export function changeComposing(value) {
  return {
    type: COMPOSE_COMPOSING_CHANGE,
    value,
  };
}

export function addPoll() {
  return {
    type: COMPOSE_POLL_ADD,
  };
}

export function removePoll() {
  return {
    type: COMPOSE_POLL_REMOVE,
  };
}

export function addPollOption(title) {
  return {
    type: COMPOSE_POLL_OPTION_ADD,
    title,
  };
}

export function changePollOption(index, title, maxOptions) {
  return {
    type: COMPOSE_POLL_OPTION_CHANGE,
    index,
    title,
    maxOptions,
  };
}

export function removePollOption(index) {
  return {
    type: COMPOSE_POLL_OPTION_REMOVE,
    index,
  };
}

export function changePollSettings(expiresIn, isMultiple) {
  return {
    type: COMPOSE_POLL_SETTINGS_CHANGE,
    expiresIn,
    isMultiple,
  };
}

export const changeMediaOrder = (a, b) => ({
  type: COMPOSE_CHANGE_MEDIA_ORDER,
  a,
  b,
});

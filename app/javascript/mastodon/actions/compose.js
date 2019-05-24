import api from '../api';
import { CancelToken, isCancel } from 'axios';
import { throttle } from 'lodash';
import { search as emojiSearch } from '../features/emoji/emoji_mart_search_light';
import { tagHistory, tagTemplate } from '../settings';
import { useEmoji } from './emojis';
import resizeImage from '../utils/resize_image';
import { importFetchedAccounts } from './importer';
import { updateTimeline } from './timelines';
import { showAlertForError } from './alerts';
import { showAlert } from './alerts';
import { defineMessages } from 'react-intl';
import { fromJS } from 'immutable';

let cancelFetchComposeSuggestionsAccounts;

import { extractHashtags } from 'twitter-text';

export const COMPOSE_CHANGE          = 'COMPOSE_CHANGE';
export const COMPOSE_SUBMIT_REQUEST  = 'COMPOSE_SUBMIT_REQUEST';
export const COMPOSE_SUBMIT_SUCCESS  = 'COMPOSE_SUBMIT_SUCCESS';
export const COMPOSE_SUBMIT_FAIL     = 'COMPOSE_SUBMIT_FAIL';
export const COMPOSE_REPLY           = 'COMPOSE_REPLY';
export const COMPOSE_REPLY_CANCEL    = 'COMPOSE_REPLY_CANCEL';
export const COMPOSE_DIRECT          = 'COMPOSE_DIRECT';
export const COMPOSE_QUOTE           = 'COMPOSE_QUOTE';
export const COMPOSE_QUOTE_CANCEL    = 'COMPOSE_QUOTE_CANCEL';
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

export const COMPOSE_TAG_TEMPLATE_UPDATE = 'COMPOSE_TAG_TEMPLATE_UPDATE';

export const COMPOSE_MOUNT   = 'COMPOSE_MOUNT';
export const COMPOSE_UNMOUNT = 'COMPOSE_UNMOUNT';

export const COMPOSE_SENSITIVITY_CHANGE = 'COMPOSE_SENSITIVITY_CHANGE';
export const COMPOSE_SPOILERNESS_CHANGE = 'COMPOSE_SPOILERNESS_CHANGE';
export const COMPOSE_SPOILER_TEXT_CHANGE = 'COMPOSE_SPOILER_TEXT_CHANGE';
export const COMPOSE_VISIBILITY_CHANGE  = 'COMPOSE_VISIBILITY_CHANGE';
export const COMPOSE_LISTABILITY_CHANGE = 'COMPOSE_LISTABILITY_CHANGE';
export const COMPOSE_COMPOSING_CHANGE = 'COMPOSE_COMPOSING_CHANGE';

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

const messages = defineMessages({
  uploadErrorLimit: { id: 'upload_error.limit', defaultMessage: 'File upload limit exceeded.' },
  uploadErrorPoll:  { id: 'upload_error.poll', defaultMessage: 'File upload not allowed with polls.' },
});

export function changeCompose(text) {
  return {
    type: COMPOSE_CHANGE,
    text: text,
  };
};

export function replyCompose(status, routerHistory) {
  return (dispatch, getState) => {
    dispatch({
      type: COMPOSE_REPLY,
      status: status,
    });

    if (!getState().getIn(['compose', 'mounted'])) {
      routerHistory.push('/statuses/new');
    }
  };
};

export function cancelReplyCompose() {
  return {
    type: COMPOSE_REPLY_CANCEL,
  };
};

export function quoteCompose(status, router) {
  return (dispatch, getState) => {
    dispatch({
      type: COMPOSE_QUOTE,
      status: status,
    });

    if (!getState().getIn(['compose', 'mounted'])) {
      router.push('/statuses/new');
    }
  };
};

export function cancelQuoteCompose() {
  return {
    type: COMPOSE_QUOTE_CANCEL,
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

    if (!getState().getIn(['compose', 'mounted'])) {
      routerHistory.push('/statuses/new');
    }
  };
};

export function directCompose(account, routerHistory) {
  return (dispatch, getState) => {
    dispatch({
      type: COMPOSE_DIRECT,
      account: account,
    });

    if (!getState().getIn(['compose', 'mounted'])) {
      routerHistory.push('/statuses/new');
    }
  };
};

export function submitCompose(routerHistory, withCommunity) {
  return function (dispatch, getState) {
    let status = getState().getIn(['compose', 'text'], '');
    const media  = getState().getIn(['compose', 'media_attachments']);

    if ((!status || !status.length) && media.size === 0) {
      return;
    }

    const hashtag = getState().getIn(['compose', 'tagTemplate']);

    hashtag.map(tag => {
      if (tag && tag.get('active') && (tag.get('text') || '').length) {
        status = [status, ` #${tag.get('text')}`].join('')
      }
    });

    const { newStatus, visibility, hasDefaultHashtag } = handleDefaultTag(
      withCommunity,
      status,
      getState().getIn(['compose', 'privacy'])
    );

    dispatch(submitComposeRequest());

    api(getState).post('/api/v1/statuses', {
      status: newStatus,
      in_reply_to_id: getState().getIn(['compose', 'in_reply_to'], null),
      media_ids: media.map(item => item.get('id')),
      sensitive: getState().getIn(['compose', 'sensitive']),
      spoiler_text: getState().getIn(['compose', 'spoiler_text'], ''),
      visibility,
      quote_id: getState().getIn(['compose', 'quote_from'], null),
      poll: getState().getIn(['compose', 'poll'], null),
      quote_id: getState().getIn(['compose', 'quote_from'], null),
    }, {
      headers: {
        'Idempotency-Key': getState().getIn(['compose', 'idempotencyKey']),
      },
    }).then(function (response) {
      if (response.data.visibility === 'direct' && getState().getIn(['conversations', 'mounted']) <= 0 && routerHistory) {
        routerHistory.push('/timelines/direct');
      } else if (routerHistory && routerHistory.location.pathname === '/statuses/new' && window.history.state) {
        routerHistory.goBack();
      }

      dispatch(insertIntoTagHistory(response.data.tags, newStatus));
      dispatch(submitComposeSuccess({ ...response.data }));

      // To make the app more responsive, immediately push the status
      // into the columns

      const insertIfOnline = timelineId => {
        const timeline = getState().getIn(['timelines', timelineId]);

        if (timeline && timeline.get('items').size > 0 && timeline.getIn(['items', 0]) !== null && timeline.get('online')) {
          dispatch(updateTimeline(timelineId, { ...response.data }));
        }
      };

      if (response.data.visibility !== 'direct') {
        insertIfOnline('home');
      }
      
      if (response.data.visibility === 'public') {
        if (hasDefaultHashtag) {
          // Refresh the community timeline only if there is default hashtag
          insertIfOnline('community');
        }
        insertIfOnline('public');
      }
    }).catch(function (error) {
      dispatch(submitComposeFail(error));
    });
  };
};

const handleDefaultTag = (withCommunity, status, visibility) => {
  if (!status || !status.length) {
    return {};
  }

  const tags = extractHashtags(status);
  const hasHashtags = tags.length > 0;
  const hasDefaultHashtag = tags.some(tag => tag === process.env.DEFAULT_HASHTAG);
  const isPublic = visibility === 'public';

  if (withCommunity) {
    // toot with community:
    // if has default hashtag: keep
    // else if public: add default hashtag
    return hasDefaultHashtag ? {
      newStatus: status,
      visibility,
      hasDefaultHashtag: true,
    } : {
      newStatus: isPublic ? `${status} #${process.env.DEFAULT_HASHTAG}` : status,
      visibility,
      hasDefaultHashtag: true,
    };

  } else {
    // toot without community:
    // if has hashtag: keep
    // else if public: change visibility to unlisted
    return hasHashtags ? {
      newStatus: status,
      visibility,
      hasDefaultHashtag: false,
    } : {
      newStatus: status,
      visibility: isPublic ? 'unlisted' : visibility,
      hasDefaultHashtag: false,
    };

  }
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

export function uploadCompose(files) {
  return function (dispatch, getState) {
    const uploadLimit = 4;
    const media  = getState().getIn(['compose', 'media_attachments']);
    const progress = new Array(files.length).fill(0);
    let total = Array.from(files).reduce((a, v) => a + v.size, 0);

    if (files.length + media.size > uploadLimit) {
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

        return api(getState).post('/api/v1/media', data, {
          onUploadProgress: function({ loaded }){
            progress[i] = loaded;
            dispatch(uploadComposeProgress(progress.reduce((a, v) => a + v, 0), total));
          },
        }).then(({ data }) => dispatch(uploadComposeSuccess(data)));
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

const fetchComposeSuggestionsTags = (dispatch, getState, token) => {
  dispatch(updateSuggestionTags(token));
};

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

export function selectComposeSuggestion(position, token, suggestion, path) {
  return (dispatch, getState) => {
    let completion, startPosition;

    if (typeof suggestion === 'object' && suggestion.id) {
      completion    = suggestion.native || suggestion.colons;
      startPosition = position - 1;

      dispatch(useEmoji(suggestion));
    } else if (suggestion[0] === '#') {
      completion    = suggestion;
      startPosition = position - 1;
    } else {
      completion    = getState().getIn(['accounts', suggestion, 'acct']);
      startPosition = position;
    }

    dispatch({
      type: COMPOSE_SUGGESTION_SELECT,
      position: startPosition,
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

export function updateTextTagTemplate(text, index) {
  return (dispatch, getState) => {
    let active = getState().getIn(['compose', 'tagTemplate', index, 'active']) || true;

    if (text.length === 0) {
      active = false;
    }

    updateTagTemplate(text, active, index, dispatch, getState);
  };
}

export function addTagTemplate(index) {
  return (dispatch, getState) => {
    const oldTemplate = getState().getIn(['compose', 'tagTemplate']);
    const me = getState().getIn(['meta', 'me']);

    if (oldTemplate.size >= 4 || oldTemplate.getIn([index, 'text']).length === 0) {
      return;
    }

    const tags = oldTemplate.push(fromJS({text: '', active: false}));

    dispatch({
      type: COMPOSE_TAG_TEMPLATE_UPDATE,
      tags,
    });

    tagTemplate.set(me, tags);
  }
}

export function delTagTemplate(index) {
  return (dispatch, getState) => {
    if (index === 0) {
      return;
    }

    const oldTemplate = getState().getIn(['compose', 'tagTemplate']);
    const me = getState().getIn(['meta', 'me']);
    const tags = oldTemplate.delete(index);

    dispatch({
      type: COMPOSE_TAG_TEMPLATE_UPDATE,
      tags,
    });
  
    tagTemplate.set(me, tags);
  }
}

export function enableTagTemplate(index) {
  return (dispatch, getState) => {
    const text = getState().getIn(['compose', 'tagTemplate', index, 'text']);
    if (text.length > 0) {
      updateTagTemplate(text, true, index, dispatch, getState);
    }
  };
}

export function disableTagTemplate(index) {
  return (dispatch, getState) => {
    const text = getState().getIn(['compose', 'tagTemplate', index, 'text']);
    updateTagTemplate(text, false, index, dispatch, getState);
  };
}

function updateTagTemplate(text, active, index, dispatch, getState) {
    const oldTemplate = getState().getIn(['compose', 'tagTemplate']);
    const me = getState().getIn(['meta', 'me']);
    const tags = oldTemplate.setIn([index], fromJS({text: text, active: active}));

    dispatch({
      type: COMPOSE_TAG_TEMPLATE_UPDATE,
      tags,
    });

    tagTemplate.set(me, tags);
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
    const names = recognizedTags.map(tag => text.match(new RegExp(`#${tag.name}`, 'i'))[0].slice(1));
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

export function insertEmojiCompose(position, emoji, needsSpace) {
  return {
    type: COMPOSE_EMOJI_INSERT,
    position,
    emoji,
    needsSpace,
  };
};

export function changeComposing(value) {
  return {
    type: COMPOSE_COMPOSING_CHANGE,
    value,
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

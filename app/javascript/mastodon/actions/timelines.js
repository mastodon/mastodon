import api, { getLinks } from '../api';
import Immutable from 'immutable';

export const TIMELINE_UPDATE  = 'TIMELINE_UPDATE';
export const TIMELINE_DELETE  = 'TIMELINE_DELETE';

export const TIMELINE_REFRESH_REQUEST = 'TIMELINE_REFRESH_REQUEST';
export const TIMELINE_REFRESH_SUCCESS = 'TIMELINE_REFRESH_SUCCESS';
export const TIMELINE_REFRESH_FAIL    = 'TIMELINE_REFRESH_FAIL';

export const TIMELINE_EXPAND_REQUEST = 'TIMELINE_EXPAND_REQUEST';
export const TIMELINE_EXPAND_SUCCESS = 'TIMELINE_EXPAND_SUCCESS';
export const TIMELINE_EXPAND_FAIL    = 'TIMELINE_EXPAND_FAIL';

export const TIMELINE_SCROLL_TOP = 'TIMELINE_SCROLL_TOP';

export const TIMELINE_CONNECT    = 'TIMELINE_CONNECT';
export const TIMELINE_DISCONNECT = 'TIMELINE_DISCONNECT';

export function refreshTimelineSuccess(timeline, statuses, skipLoading, next) {
  return {
    type: TIMELINE_REFRESH_SUCCESS,
    timeline,
    statuses,
    skipLoading,
    next,
  };
};

export function updateTimeline(timeline, status) {
  return (dispatch, getState) => {
    const references = status.reblog ? getState().get('statuses').filter((item, itemId) => (itemId === status.reblog.id || item.get('reblog') === status.reblog.id)).map((_, itemId) => itemId) : [];

    dispatch({
      type: TIMELINE_UPDATE,
      timeline,
      status,
      references,
    });
  };
};

export function deleteFromTimelines(id) {
  return (dispatch, getState) => {
    const accountId  = getState().getIn(['statuses', id, 'account']);
    const references = getState().get('statuses').filter(status => status.get('reblog') === id).map(status => [status.get('id'), status.get('account')]);
    const reblogOf   = getState().getIn(['statuses', id, 'reblog'], null);

    dispatch({
      type: TIMELINE_DELETE,
      id,
      accountId,
      references,
      reblogOf,
    });
  };
};

export function refreshTimelineRequest(timeline, id, skipLoading) {
  return {
    type: TIMELINE_REFRESH_REQUEST,
    timeline,
    id,
    skipLoading,
  };
};

export function refreshTimeline(timeline, id = null) {
  return function (dispatch, getState) {
    if (getState().getIn(['timelines', timeline, 'isLoading'])) {
      return;
    }

    const ids      = getState().getIn(['timelines', timeline, 'items'], Immutable.List());
    const newestId = ids.size > 0 ? ids.first() : null;
    let params     = getState().getIn(['timelines', timeline, 'params'], {});
    const path     = getState().getIn(['timelines', timeline, 'path'])(id);

    let skipLoading = false;

    if (newestId !== null && getState().getIn(['timelines', timeline, 'loaded']) && (id === null || getState().getIn(['timelines', timeline, 'id']) === id)) {
      if (id === null && getState().getIn(['timelines', timeline, 'online'])) {
        // Skip refreshing when timeline is live anyway
        return;
      }

      params          = { ...params, since_id: newestId };
      skipLoading     = true;
    } else if (getState().getIn(['timelines', timeline, 'loaded'])) {
      skipLoading = true;
    }

    dispatch(refreshTimelineRequest(timeline, id, skipLoading));

    api(getState).get(path, { params }).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(refreshTimelineSuccess(timeline, response.data, skipLoading, next ? next.uri : null));
    }).catch(error => {
      dispatch(refreshTimelineFail(timeline, error, skipLoading));
    });
  };
};

export function refreshTimelineFail(timeline, error, skipLoading) {
  return {
    type: TIMELINE_REFRESH_FAIL,
    timeline,
    error,
    skipLoading,
  };
};

export function expandTimeline(timeline) {
  return (dispatch, getState) => {
    if (getState().getIn(['timelines', timeline, 'isLoading'])) {
      return;
    }

    if (getState().getIn(['timelines', timeline, 'items']).size === 0) {
      return;
    }

    const path   = getState().getIn(['timelines', timeline, 'path'])(getState().getIn(['timelines', timeline, 'id']));
    const params = getState().getIn(['timelines', timeline, 'params'], {});
    const lastId = getState().getIn(['timelines', timeline, 'items']).last();

    dispatch(expandTimelineRequest(timeline));

    api(getState).get(path, {
      params: {
        ...params,
        max_id: lastId,
        limit: 10,
      },
    }).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(expandTimelineSuccess(timeline, response.data, next ? next.uri : null));
    }).catch(error => {
      dispatch(expandTimelineFail(timeline, error));
    });
  };
};

export function expandTimelineRequest(timeline) {
  return {
    type: TIMELINE_EXPAND_REQUEST,
    timeline,
  };
};

export function expandTimelineSuccess(timeline, statuses, next) {
  return {
    type: TIMELINE_EXPAND_SUCCESS,
    timeline,
    statuses,
    next,
  };
};

export function expandTimelineFail(timeline, error) {
  return {
    type: TIMELINE_EXPAND_FAIL,
    timeline,
    error,
  };
};

export function scrollTopTimeline(timeline, top) {
  return {
    type: TIMELINE_SCROLL_TOP,
    timeline,
    top,
  };
};

export function connectTimeline(timeline) {
  return {
    type: TIMELINE_CONNECT,
    timeline,
  };
};

export function disconnectTimeline(timeline) {
  return {
    type: TIMELINE_DISCONNECT,
    timeline,
  };
};

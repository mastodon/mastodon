import { importFetchedStatus, importFetchedStatuses } from './importer';
import api, { getLinks } from '../api';
import { Map as ImmutableMap, List as ImmutableList } from 'immutable';

export const TIMELINE_UPDATE  = 'TIMELINE_UPDATE';
export const TIMELINE_DELETE  = 'TIMELINE_DELETE';

export const TIMELINE_EXPAND_REQUEST = 'TIMELINE_EXPAND_REQUEST';
export const TIMELINE_EXPAND_SUCCESS = 'TIMELINE_EXPAND_SUCCESS';
export const TIMELINE_EXPAND_FAIL    = 'TIMELINE_EXPAND_FAIL';

export const TIMELINE_SCROLL_TOP = 'TIMELINE_SCROLL_TOP';

export const TIMELINE_DISCONNECT = 'TIMELINE_DISCONNECT';

export const TIMELINE_CONTEXT_UPDATE = 'CONTEXT_UPDATE';

export function updateTimeline(timeline, status) {
  return (dispatch, getState) => {
    const references = status.reblog ? getState().get('statuses').filter((item, itemId) => (itemId === status.reblog.id || item.get('reblog') === status.reblog.id)).map((_, itemId) => itemId) : [];
    const parents = [];

    if (status.in_reply_to_id) {
      let parent = getState().getIn(['statuses', status.in_reply_to_id]);

      while (parent && parent.get('in_reply_to_id')) {
        parents.push(parent.get('id'));
        parent = getState().getIn(['statuses', parent.get('in_reply_to_id')]);
      }
    }

    dispatch(importFetchedStatus(status));

    dispatch({
      type: TIMELINE_UPDATE,
      timeline,
      status,
      references,
    });

    if (parents.length > 0) {
      dispatch({
        type: TIMELINE_CONTEXT_UPDATE,
        status,
        references: parents,
      });
    }
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

const noOp = () => {};

export function expandTimeline(timelineId, path, params = {}, done = noOp) {
  return (dispatch, getState) => {
    const timeline = getState().getIn(['timelines', timelineId], ImmutableMap());

    if (timeline.get('isLoading')) {
      done();
      return;
    }

    if (!params.max_id && timeline.get('items', ImmutableList()).size > 0) {
      params.since_id = timeline.getIn(['items', 0]);
    }

    dispatch(expandTimelineRequest(timelineId));

    api(getState).get(path, { params }).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(importFetchedStatuses(response.data));
      dispatch(expandTimelineSuccess(timelineId, response.data, next ? next.uri : null, response.code === 206));
      done();
    }).catch(error => {
      dispatch(expandTimelineFail(timelineId, error));
      done();
    });
  };
};

export const expandHomeTimeline            = ({ maxId } = {}, done = noOp) => expandTimeline('home', '/api/v1/timelines/home', { max_id: maxId }, done);
export const expandPublicTimeline          = ({ maxId, onlyMedia } = {}, done = noOp) => expandTimeline(`public${onlyMedia ? ':media' : ''}`, '/api/v1/timelines/public', { max_id: maxId, only_media: !!onlyMedia }, done);
export const expandCommunityTimeline       = ({ maxId, onlyMedia } = {}, done = noOp) => expandTimeline(`community${onlyMedia ? ':media' : ''}`, '/api/v1/timelines/public', { local: true, max_id: maxId, only_media: !!onlyMedia }, done);
export const expandDirectTimeline          = ({ maxId } = {}, done = noOp) => expandTimeline('direct', '/api/v1/timelines/direct', { max_id: maxId }, done);
export const expandAccountTimeline         = (accountId, { maxId, withReplies } = {}) => expandTimeline(`account:${accountId}${withReplies ? ':with_replies' : ''}`, `/api/v1/accounts/${accountId}/statuses`, { exclude_replies: !withReplies, max_id: maxId });
export const expandAccountFeaturedTimeline = accountId => expandTimeline(`account:${accountId}:pinned`, `/api/v1/accounts/${accountId}/statuses`, { pinned: true });
export const expandAccountMediaTimeline    = (accountId, { maxId } = {}) => expandTimeline(`account:${accountId}:media`, `/api/v1/accounts/${accountId}/statuses`, { max_id: maxId, only_media: true });
export const expandHashtagTimeline         = (hashtag, { maxId } = {}, done = noOp) => expandTimeline(`hashtag:${hashtag}`, `/api/v1/timelines/tag/${hashtag}`, { max_id: maxId }, done);
export const expandListTimeline            = (id, { maxId } = {}, done = noOp) => expandTimeline(`list:${id}`, `/api/v1/timelines/list/${id}`, { max_id: maxId }, done);

export function expandTimelineRequest(timeline) {
  return {
    type: TIMELINE_EXPAND_REQUEST,
    timeline,
  };
};

export function expandTimelineSuccess(timeline, statuses, next, partial) {
  return {
    type: TIMELINE_EXPAND_SUCCESS,
    timeline,
    statuses,
    next,
    partial,
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

export function disconnectTimeline(timeline) {
  return {
    type: TIMELINE_DISCONNECT,
    timeline,
  };
};

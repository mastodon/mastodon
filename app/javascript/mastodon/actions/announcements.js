import api from '../api';
import { normalizeAnnouncement } from './importer/normalizer';

export const ANNOUNCEMENTS_FETCH_REQUEST = 'ANNOUNCEMENTS_FETCH_REQUEST';
export const ANNOUNCEMENTS_FETCH_SUCCESS = 'ANNOUNCEMENTS_FETCH_SUCCESS';
export const ANNOUNCEMENTS_FETCH_FAIL    = 'ANNOUNCEMENTS_FETCH_FAIL';
export const ANNOUNCEMENTS_UPDATE        = 'ANNOUNCEMENTS_UPDATE';
export const ANNOUNCEMENTS_DISMISS       = 'ANNOUNCEMENTS_DISMISS';

export const ANNOUNCEMENTS_REACTION_ADD_REQUEST = 'ANNOUNCEMENTS_REACTION_ADD_REQUEST';
export const ANNOUNCEMENTS_REACTION_ADD_SUCCESS = 'ANNOUNCEMENTS_REACTION_ADD_SUCCESS';
export const ANNOUNCEMENTS_REACTION_ADD_FAIL    = 'ANNOUNCEMENTS_REACTION_ADD_FAIL';

export const ANNOUNCEMENTS_REACTION_REMOVE_REQUEST = 'ANNOUNCEMENTS_REACTION_REMOVE_REQUEST';
export const ANNOUNCEMENTS_REACTION_REMOVE_SUCCESS = 'ANNOUNCEMENTS_REACTION_REMOVE_SUCCESS';
export const ANNOUNCEMENTS_REACTION_REMOVE_FAIL    = 'ANNOUNCEMENTS_REACTION_REMOVE_FAIL';

export const ANNOUNCEMENTS_REACTION_UPDATE = 'ANNOUNCEMENTS_REACTION_UPDATE';

const noOp = () => {};

export const fetchAnnouncements = (done = noOp) => (dispatch, getState) => {
  dispatch(fetchAnnouncementsRequest());

  api(getState).get('/api/v1/announcements').then(response => {
    dispatch(fetchAnnouncementsSuccess(response.data.map(x => normalizeAnnouncement(x))));
  }).catch(error => {
    dispatch(fetchAnnouncementsFail(error));
  }).finally(() => {
    done();
  });
};

export const fetchAnnouncementsRequest = () => ({
  type: ANNOUNCEMENTS_FETCH_REQUEST,
  skipLoading: true,
});

export const fetchAnnouncementsSuccess = announcements => ({
  type: ANNOUNCEMENTS_FETCH_SUCCESS,
  announcements,
  skipLoading: true,
});

export const fetchAnnouncementsFail= error => ({
  type: ANNOUNCEMENTS_FETCH_FAIL,
  error,
  skipLoading: true,
  skipAlert: true,
});

export const updateAnnouncements = announcement => ({
  type: ANNOUNCEMENTS_UPDATE,
  announcement: normalizeAnnouncement(announcement),
});

export const dismissAnnouncement = announcementId => (dispatch, getState) => {
  dispatch({
    type: ANNOUNCEMENTS_DISMISS,
    id: announcementId,
  });

  api(getState).post(`/api/v1/announcements/${announcementId}/dismiss`);
};

export const addReaction = (announcementId, name) => (dispatch, getState) => {
  dispatch(addReactionRequest(announcementId, name));

  api(getState).put(`/api/v1/announcements/${announcementId}/reactions/${name}`).then(() => {
    dispatch(addReactionSuccess(announcementId, name));
  }).catch(err => {
    dispatch(addReactionFail(announcementId, name, err));
  });
};

export const addReactionRequest = (announcementId, name) => ({
  type: ANNOUNCEMENTS_REACTION_ADD_REQUEST,
  id: announcementId,
  name,
  skipLoading: true,
});

export const addReactionSuccess = (announcementId, name) => ({
  type: ANNOUNCEMENTS_REACTION_ADD_SUCCESS,
  id: announcementId,
  name,
  skipLoading: true,
});

export const addReactionFail = (announcementId, name, error) => ({
  type: ANNOUNCEMENTS_REACTION_ADD_FAIL,
  id: announcementId,
  name,
  error,
  skipLoading: true,
});

export const removeReaction = (announcementId, name) => (dispatch, getState) => {
  dispatch(removeReactionRequest(announcementId, name));

  api(getState).delete(`/api/v1/announcements/${announcementId}/reactions/${name}`).then(() => {
    dispatch(removeReactionSuccess(announcementId, name));
  }).catch(err => {
    dispatch(removeReactionFail(announcementId, name, err));
  });
};

export const removeReactionRequest = (announcementId, name) => ({
  type: ANNOUNCEMENTS_REACTION_REMOVE_REQUEST,
  id: announcementId,
  name,
  skipLoading: true,
});

export const removeReactionSuccess = (announcementId, name) => ({
  type: ANNOUNCEMENTS_REACTION_REMOVE_SUCCESS,
  id: announcementId,
  name,
  skipLoading: true,
});

export const removeReactionFail = (announcementId, name, error) => ({
  type: ANNOUNCEMENTS_REACTION_REMOVE_FAIL,
  id: announcementId,
  name,
  error,
  skipLoading: true,
});

export const updateReaction = reaction => ({
  type: ANNOUNCEMENTS_REACTION_UPDATE,
  reaction,
});

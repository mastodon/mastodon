import api from '../api';
import { normalizeAnnouncement } from './importer/normalizer';

export const ANNOUNCEMENTS_FETCH_REQUEST = 'ANNOUNCEMENTS_FETCH_REQUEST';
export const ANNOUNCEMENTS_FETCH_SUCCESS = 'ANNOUNCEMENTS_FETCH_SUCCESS';
export const ANNOUNCEMENTS_FETCH_FAIL    = 'ANNOUNCEMENTS_FETCH_FAIL';
export const ANNOUNCEMENTS_UPDATE        = 'ANNOUNCEMENTS_UPDATE';
export const ANNOUNCEMENTS_DISMISS       = 'ANNOUNCEMENTS_DISMISS';

export const fetchAnnouncements = () => (dispatch, getState) => {
  dispatch(fetchAnnouncementsRequest());

  api(getState).get('/api/v1/announcements').then(response => {
    dispatch(fetchAnnouncementsSuccess(response.data.map(x => normalizeAnnouncement(x))));
  }).catch(error => {
    dispatch(fetchAnnouncementsFail(error));
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

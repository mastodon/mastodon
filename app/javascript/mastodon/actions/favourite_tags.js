import api from '../api';

export const FAVOURITE_TAGS_SUCCESS = 'FAVOURITE_TAGS_SUCCESS';
export const COMPOSE_LOCK_TAG = 'LOCK_TAG';

export function refreshFavouriteTags() {
  return (dispatch, getState) => {
    api(getState).get('/api/v1/favourite_tags').then(response => {
      dispatch(refreshFavouriteTagsSuccess(response.data));
    });
  };
}

export function lockTagCompose(tag, visibility) {
  return {
    type: COMPOSE_LOCK_TAG,
    tag,
    visibility,
  };
}

export function refreshFavouriteTagsSuccess(tags) {
  return {
    type: FAVOURITE_TAGS_SUCCESS,
    tags,
  };
}

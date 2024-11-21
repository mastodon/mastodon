import api from '../api';

export const FEATURED_TAGS_FETCH_REQUEST = 'FEATURED_TAGS_FETCH_REQUEST';
export const FEATURED_TAGS_FETCH_SUCCESS = 'FEATURED_TAGS_FETCH_SUCCESS';
export const FEATURED_TAGS_FETCH_FAIL    = 'FEATURED_TAGS_FETCH_FAIL';

export const fetchFeaturedTags = (id) => (dispatch, getState) => {
  if (getState().getIn(['user_lists', 'featured_tags', id, 'items'])) {
    return;
  }

  dispatch(fetchFeaturedTagsRequest(id));

  api().get(`/api/v1/accounts/${id}/featured_tags`)
    .then(({ data }) => dispatch(fetchFeaturedTagsSuccess(id, data)))
    .catch(err => dispatch(fetchFeaturedTagsFail(id, err)));
};

export const fetchFeaturedTagsRequest = (id) => ({
  type: FEATURED_TAGS_FETCH_REQUEST,
  id,
});

export const fetchFeaturedTagsSuccess = (id, tags) => ({
  type: FEATURED_TAGS_FETCH_SUCCESS,
  id,
  tags,
});

export const fetchFeaturedTagsFail = (id, error) => ({
  type: FEATURED_TAGS_FETCH_FAIL,
  id,
  error,
});

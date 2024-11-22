import api from '../api';

export const CUSTOM_EMOJIS_FETCH_REQUEST = 'CUSTOM_EMOJIS_FETCH_REQUEST';
export const CUSTOM_EMOJIS_FETCH_SUCCESS = 'CUSTOM_EMOJIS_FETCH_SUCCESS';
export const CUSTOM_EMOJIS_FETCH_FAIL = 'CUSTOM_EMOJIS_FETCH_FAIL';

export function fetchCustomEmojis() {
  return (dispatch) => {
    dispatch(fetchCustomEmojisRequest());

    api().get('/api/v1/custom_emojis').then(response => {
      dispatch(fetchCustomEmojisSuccess(response.data));
    }).catch(error => {
      dispatch(fetchCustomEmojisFail(error));
    });
  };
}

export function fetchCustomEmojisRequest() {
  return {
    type: CUSTOM_EMOJIS_FETCH_REQUEST,
    skipLoading: true,
  };
}

export function fetchCustomEmojisSuccess(custom_emojis) {
  return {
    type: CUSTOM_EMOJIS_FETCH_SUCCESS,
    custom_emojis,
    skipLoading: true,
  };
}

export function fetchCustomEmojisFail(error) {
  return {
    type: CUSTOM_EMOJIS_FETCH_FAIL,
    error,
    skipLoading: true,
  };
}

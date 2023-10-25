export const NEXTID_SAVE_POST_REQUEST = 'NEXTID_SAVE_POST_REQUEST';
export const NEXTID_SAVE_POST_SUCCESS = 'NEXTID_SAVE_POST_SUCCESS';
export const NEXTID_SAVE_POST_FAIL = 'NEXTID_SAVE_POST_FAIL';

export function fetchSavePostRequest() {
  return {
    type: NEXTID_SAVE_POST_REQUEST,
  };
}

export function fetchSavePostSuccess() {
  return {
    type: NEXTID_SAVE_POST_SUCCESS,
  };
}

export function fetchSavePostFail(error) {
  return {
    type: NEXTID_SAVE_POST_FAIL,
    error
  };
}

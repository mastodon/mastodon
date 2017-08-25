export const BUNDLE_FETCH_REQUEST = 'BUNDLE_FETCH_REQUEST';
export const BUNDLE_FETCH_SUCCESS = 'BUNDLE_FETCH_SUCCESS';
export const BUNDLE_FETCH_FAIL = 'BUNDLE_FETCH_FAIL';

export function fetchBundleRequest(skipLoading) {
  return {
    type: BUNDLE_FETCH_REQUEST,
    skipLoading,
  };
}

export function fetchBundleSuccess(skipLoading) {
  return {
    type: BUNDLE_FETCH_SUCCESS,
    skipLoading,
  };
}

export function fetchBundleFail(error, skipLoading) {
  return {
    type: BUNDLE_FETCH_FAIL,
    error,
    skipLoading,
  };
}

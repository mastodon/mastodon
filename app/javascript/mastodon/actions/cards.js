import api from '../api';

export const STATUS_CARD_FETCH_REQUEST = 'STATUS_CARD_FETCH_REQUEST';
export const STATUS_CARD_FETCH_SUCCESS = 'STATUS_CARD_FETCH_SUCCESS';
export const STATUS_CARD_FETCH_FAIL    = 'STATUS_CARD_FETCH_FAIL';

export function fetchStatusCard(id) {
  return (dispatch, getState) => {
    if (getState().getIn(['cards', id], null) !== null) {
      return;
    }

    dispatch(fetchStatusCardRequest(id));

    api(getState).get(`/api/v1/statuses/${id}/card`).then(response => {
      if (!response.data.url) {
        return;
      }

      dispatch(fetchStatusCardSuccess(id, response.data));
    }).catch(error => {
      dispatch(fetchStatusCardFail(id, error));
    });
  };
};

export function fetchStatusCardRequest(id) {
  return {
    type: STATUS_CARD_FETCH_REQUEST,
    id,
    skipLoading: true,
  };
};

export function fetchStatusCardSuccess(id, card) {
  return {
    type: STATUS_CARD_FETCH_SUCCESS,
    id,
    card,
    skipLoading: true,
  };
};

export function fetchStatusCardFail(id, error) {
  return {
    type: STATUS_CARD_FETCH_FAIL,
    id,
    error,
    skipLoading: true,
    skipAlert: true,
  };
};

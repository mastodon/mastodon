import { changeCompose } from '../actions/compose';

export const UTILBTNS_FUKUMOKU = 'UTILBTNS_FUKUMOKU';

export function submitFukumoku (textarea) {
  return function (dispatch, getState) {
    let text = `${textarea.value} #ふくもく会`;

    dispatch(submitFukumokuRequest());
    dispatch(changeCompose(text));

    textarea.focus();
  }
}

export function submitFukumokuRequest () {
  return {
    type: UTILBTNS_FUKUMOKU
  }
}
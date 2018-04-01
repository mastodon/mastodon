import { changeCompose } from '../actions/compose';

export const UTILBTNS_FUKUMOKU = 'UTILBTNS_FUKUMOKU';
export const UTILBTNS_WARSHIPGIRLS = 'UTILBTNS_WARSHIPGIRLS';
export const UTILBTNS_KANCOLLE = 'UTILBTNS_KANCOLLE';

// fukumoku-kai hashtag insert button
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

// WarshipGirls hashtag insert button
export function submitWarshipgirls (textarea) {
  return function (dispatch, getState) {
    let text = `${textarea.value} #戦艦少女R`;

    dispatch(submitWarshipgirlsRequest());
    dispatch(changeCompose(text));

    textarea.focus();
  }
}

export function submitWarshipgirlsRequest () {
  return {
    type: UTILBTNS_WARSHIPGIRLS
  }
}

// KanColle hashtag insert button
export function submitKancolle (textarea) {
  return function (dispatch, getState) {
    let text = `${textarea.value} #艦これ`;

    dispatch(submitKancolleRequest());
    dispatch(changeCompose(text));

    textarea.focus();
  }
}

export function submitKancolleRequest () {
  return {
    type: UTILBTNS_KANCOLLE
  }
}

import api from '../api';

export const COMPOSE_ENQUETE_CHANGE = 'COMPOSE_ENQUETE_CHANGE';
export const COMPOSE_ENQUETE_TEXT_CHANGE = 'COMPOSE_ENQUETE_TEXT_CHANGE';
export const COMPOSE_ENQUETE_DURATION_CHANGE = 'COMPOSE_ENQUETE_DURATION_CHANGE';
export const ENQUETE_VOTE = 'ENQUETE_VOTE';
export const SET_ENQUETE_TIMEOUT = 'SET_ENQUETE_TIMEOUT';
export const VOTE_SUCCESS = 'VOTE_SUCCESS';

export function changeComposeEnquete() {
  return {
    type: COMPOSE_ENQUETE_CHANGE,
  };
};

export function changeComposeEnqueteText(text, item_index) {
  return {
    type: COMPOSE_ENQUETE_TEXT_CHANGE,
    text,
    item_index,
  };
};

export function changeConposeEnqueteDuration(duration){
  return {
    type: COMPOSE_ENQUETE_DURATION_CHANGE,
    duration,
  };
};


export function vote(status_id, item_index) {
  return (dispatch, getState) => {
    api(getState).post(`/api/v1/votes/${status_id}`, {
      item_index: item_index,
    }).then(response => {
      const data = response.data;
      if(data.valid === true){
        dispatch(voteSuccess(status_id, item_index));
      }
    }).catch(error => {
      console.error(error);
    });
  };
};

export function setEnqueteTimeout(status_id){
  return{
    type: SET_ENQUETE_TIMEOUT,
    status_id,
  };
};

export function voteSuccess(status_id, item_index){
  var str = 'vote_to_'+String(status_id) + '=' + String(item_index)+'; max-age=86400';
  document.cookie = str;
  return {
    type: VOTE_SUCCESS,
    status_id,
    item_index,
  };
};

export function voteLoad(status_id, item_index){
  return {
    type: VOTE_SUCCESS,
    status_id,
    item_index,
  };
};
import axios from 'axios';
import { openModal } from './modal';
import { FormattedMessage } from 'react-intl';

export const TWEXILE_SUBSCRIBE_CHANGE = 'TWEXILE_SUBSCRIBE_CHANGE';

function subscribe(getState) {
  reuturn axios.get(`https://twexile.nayukana.info/subscribe?token=${getState().getIn(['meta', 'access_token'])}`);
}


function unsubscribe(getState) {
  return axios.get(`https://twexile.nayukana.info/unsubscribe?token=${getState().getIn(['meta', 'access_token'])}`);
}

export function changeTwexileStatus(getState) {
  return (dispatch, getState) => {
    if (getState().getIn(['compose', 'twexile']) === true) {
      unsubscribe(getState).then(res => {
        dispatch({
          type: TWEXILE_SUBSCRIBE_CHANGE,
        });
      });
    } else {
      var authorized = axios
        .get(`https://twexile.nayukana.info/authorize?token=${getState().getIn(['meta', 'access_token'])}`)
        .then(response => {
          if (response.data === '') {
            
            return true;
          } else {
            return response.data;
          }
        }).catch(response => {
          return false;
        });
      authorized.then(authorized => {
        if (typeof authorized === 'string') {
          dispatch(openModal('CONFIRM', {
            message: <FormattedMessage id='confirmations.authorize.required.message' 
                                      defaultMessage='click this {link} and authorize with twitter'
                                      values={{ link: <a href={authorized} target="_blank">link</a> }} />,
          }));
        } else if (authorized === false) {
          dispatch(openModal('CONFIRM', {
            message: <FormattedMessage id='confirmations.authorize.failure.message' 
                                      defaultMessage='authorization failed' />,
          }));
        } else {
          subscribe(getState);
          dispatch({
            type: TWEXILE_SUBSCRIBE_CHANGE,
          });
        }
      });
      return {};
    }
  };
}
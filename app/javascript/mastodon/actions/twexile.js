import axios from 'axios';
import { openModal } from './modal.js';
import { FormattedMessage, injectIntl, defineMessages } from 'react-intl';

export const TWEXILE_SUBSCRIBE_CHANGE = "TWEXILE_SUBSCRIBE_CHANGE";

export function changeTwexileStatus(getState) {
  return (dispatch, getState) => {
    var authorized = axios
      .get(`https://twexile.nayukana.info/authorize?token=${getState().getIn(['meta', 'access_token'])}`)
      .then(response => {
        if (response.data === "")
          return true;
        else
          return response.data;
      }).catch(response => {
        return false;
      });
    authorized.then(authorized => {
      if (typeof authorized === "string") {
        dispatch(openModal('CONFIRM', {
          message: <FormattedMessage id='confirmations.authorize.required.message' 
                                     defaultMessage='click this {link} and authorize with twitter'
                                     values={{ link: <a href={authorized}>link</a> }} />,
        }));
      } else if (authorized == false) {
        dispatch(openModal('CONFIRM', {
          message: <FormattedMessage id='confirmations.authorize.failure.message' 
                                     defaultMessage='authorization failed' />,
        }));
      } else {
        dispatch(openModal('CONFIRM', {
          message: <FormattedMessage id='confirmations.authorize.success.message' 
                                     defaultMessage='authorization success' />,
        }));
      }
    })
    return {
      type: TWEXILE_SUBSCRIBE_CHANGE
    };
  };
}
import { openModal } from './modal';

export const BOOSTS_INIT_MODAL = 'BOOSTS_INIT_MODAL';
export const BOOSTS_CHANGE_PRIVACY = 'BOOSTS_CHANGE_PRIVACY';

export function initBoostModal(props) {
  return (dispatch, getState) => {
    const default_privacy = getState().getIn(['compose', 'default_privacy']);

    const privacy = props.status.get('visibility') === 'private' ? 'private' : default_privacy;

    dispatch({
      type: BOOSTS_INIT_MODAL,
      privacy
    });

    dispatch(openModal('BOOST', props));
  };
}


export function changeBoostPrivacy(privacy) {
  return dispatch => {
    dispatch({
      type: BOOSTS_CHANGE_PRIVACY,
      privacy,
    });
  };
}

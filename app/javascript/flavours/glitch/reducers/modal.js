import { MODAL_OPEN, MODAL_CLOSE } from 'flavours/glitch/actions/modal';

const initialState = {
  modalType: null,
  modalProps: {},
};

export default function modal(state = initialState, action) {
  switch(action.type) {
  case MODAL_OPEN:
    return { modalType: action.modalType, modalProps: action.modalProps };
  case MODAL_CLOSE:
    return (action.modalType === undefined || action.modalType === state.modalType) ? initialState : state;
  default:
    return state;
  }
};

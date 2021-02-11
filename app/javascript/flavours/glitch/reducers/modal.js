import { MODAL_OPEN, MODAL_CLOSE } from 'flavours/glitch/actions/modal';
import { TIMELINE_DELETE } from 'flavours/glitch/actions/timelines';

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
  case TIMELINE_DELETE:
    return (state.modalProps.statusId === action.id) ? initialState : state;
  default:
    return state;
  }
};

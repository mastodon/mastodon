import { MODAL_OPEN, MODAL_CLOSE } from '../actions/modal';
import { TIMELINE_DELETE } from '../actions/timelines';
import { Stack as ImmutableStack, Map as ImmutableMap } from 'immutable';

export default function modal(state = ImmutableStack(), action) {
  switch(action.type) {
  case MODAL_OPEN:
        return state.unshift(ImmutableMap({ modalType: action.modalType, modalProps: action.modalProps }));
  case MODAL_CLOSE:
    return (action.modalType === undefined || action.modalType === state.getIn([0, 'modalType'])) ? state.shift() : state;
  case TIMELINE_DELETE:
        return state.filterNot((modal) => modal.get('modalProps').statusId === action.id);
  default:
    return state;
  }
};

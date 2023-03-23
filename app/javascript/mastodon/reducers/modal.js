import { MODAL_OPEN, MODAL_CLOSE } from '../actions/modal';
import { TIMELINE_DELETE } from '../actions/timelines';
import { COMPOSE_UPLOAD_CHANGE_SUCCESS } from '../actions/compose';
import { Stack as ImmutableStack, Map as ImmutableMap } from 'immutable';

const initialState = ImmutableMap({
  ignoreFocus: false,
  stack: ImmutableStack(),
});

const popModal = (state, { modalType, ignoreFocus }) => {
  if (modalType === undefined || modalType === state.getIn(['stack', 0, 'modalType'])) {
    return state.set('ignoreFocus', !!ignoreFocus).update('stack', stack => stack.shift());
  } else {
    return state;
  }
};

const pushModal = (state, modalType, modalProps) => {
  return state.withMutations(map => {
    map.set('ignoreFocus', false);
    map.update('stack', stack => stack.unshift(ImmutableMap({ modalType, modalProps })));
  });
};

export default function modal(state = initialState, action) {
  switch(action.type) {
  case MODAL_OPEN:
    return pushModal(state, action.modalType, action.modalProps);
  case MODAL_CLOSE:
    return popModal(state, action);
  case COMPOSE_UPLOAD_CHANGE_SUCCESS:
    return popModal(state, { modalType: 'FOCAL_POINT', ignoreFocus: false });
  case TIMELINE_DELETE:
    return state.update('stack', stack => stack.filterNot((modal) => modal.get('modalProps').statusId === action.id));
  default:
    return state;
  }
}

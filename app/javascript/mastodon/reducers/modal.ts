import { Record as ImmutableRecord, Stack } from 'immutable';

import type { PayloadAction } from '@reduxjs/toolkit';

import { COMPOSE_UPLOAD_CHANGE_SUCCESS } from '../actions/compose';
import type { ModalType } from '../actions/modal';
import { openModal, closeModal } from '../actions/modal';
import { TIMELINE_DELETE } from '../actions/timelines';

type ModalProps = Record<string, unknown>;
interface Modal {
  modalType: ModalType;
  modalProps: ModalProps;
}

const Modal = ImmutableRecord<Modal>({
  modalType: 'ACTIONS',
  modalProps: ImmutableRecord({})(),
});

interface ModalState {
  ignoreFocus: boolean;
  stack: Stack<ImmutableRecord<Modal>>;
}

const initialState = ImmutableRecord<ModalState>({
  ignoreFocus: false,
  stack: Stack(),
})();
type State = typeof initialState;

interface PopModalOption {
  modalType: ModalType | undefined;
  ignoreFocus: boolean;
}
const popModal = (
  state: State,
  { modalType, ignoreFocus }: PopModalOption,
): State => {
  if (
    modalType === undefined ||
    modalType === state.get('stack').get(0)?.get('modalType')
  ) {
    return state
      .set('ignoreFocus', !!ignoreFocus)
      .update('stack', (stack) => stack.shift());
  } else {
    return state;
  }
};

const pushModal = (
  state: State,
  modalType: ModalType,
  modalProps: ModalProps,
): State => {
  return state.withMutations((record) => {
    record.set('ignoreFocus', false);
    record.update('stack', (stack) =>
      stack.unshift(Modal({ modalType, modalProps })),
    );
  });
};

export function modalReducer(
  state: State = initialState,
  action: PayloadAction<{
    modalType: ModalType;
    ignoreFocus: boolean;
    modalProps: Record<string, unknown>;
  }>,
) {
  switch (action.type) {
    case openModal.type:
      return pushModal(
        state,
        action.payload.modalType,
        action.payload.modalProps,
      );
    case closeModal.type:
      return popModal(state, action.payload);
    case COMPOSE_UPLOAD_CHANGE_SUCCESS:
      return popModal(state, { modalType: 'FOCAL_POINT', ignoreFocus: false });
    case TIMELINE_DELETE:
      return state.update('stack', (stack) =>
        stack.filterNot(
          // @ts-expect-error TIMELINE_DELETE action is not typed yet.
          (modal) => modal.get('modalProps').statusId === action.id,
        ),
      );
    default:
      return state;
  }
}

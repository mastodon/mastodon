import type { Reducer } from '@reduxjs/toolkit';
import { Record as ImmutableRecord, Stack } from 'immutable';

import { timelineDelete } from 'mastodon/actions/timelines_typed';

import type { ModalType } from '../actions/modal';
import { openModal, closeModal } from '../actions/modal';

export type ModalProps = Record<string, unknown>;
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
      .set('ignoreFocus', ignoreFocus)
      .update('stack', (stack) => stack.shift());
  } else {
    return state;
  }
};

const pushModal = (
  state: State,
  modalType: ModalType,
  modalProps: ModalProps,
  previousModalProps?: ModalProps,
): State => {
  return state.withMutations((record) => {
    record.set('ignoreFocus', false);
    record.update('stack', (stack) => {
      let tmp = stack;

      // With this option, we update the previously opened modal, so that when the
      // current (new) modal is closed, the previous modal is re-opened with different
      // props. Specifically, this is useful for the confirmation modal.
      if (previousModalProps) {
        const previousModal = tmp.first() as Modal | undefined;

        if (previousModal) {
          tmp = tmp.shift().unshift(
            Modal({
              modalType: previousModal.modalType,
              modalProps: {
                ...previousModal.modalProps,
                ...previousModalProps,
              },
            }),
          );
        }
      }

      tmp = tmp.unshift(Modal({ modalType, modalProps }));

      return tmp;
    });
  });
};

export const modalReducer: Reducer<State> = (state = initialState, action) => {
  if (openModal.match(action))
    return pushModal(
      state,
      action.payload.modalType,
      action.payload.modalProps,
      action.payload.previousModalProps,
    );
  else if (closeModal.match(action)) return popModal(state, action.payload);
  // TODO: type those actions
  else if (timelineDelete.match(action))
    return state.update('stack', (stack) =>
      stack.filterNot(
        (modal) => modal.get('modalProps').statusId === action.payload.statusId,
      ),
    );
  else return state;
};

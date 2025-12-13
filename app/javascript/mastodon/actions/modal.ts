import { createAction } from '@reduxjs/toolkit';

import type { ModalProps } from 'mastodon/reducers/modal';

import type { MODAL_COMPONENTS } from '../features/ui/components/modal_root';

export type ModalType = keyof typeof MODAL_COMPONENTS;

interface OpenModalPayload {
  modalType: ModalType;
  modalProps: ModalProps;
  previousModalProps?: ModalProps;
}
export const openModal = createAction<OpenModalPayload>('MODAL_OPEN');

interface CloseModalPayload {
  modalType: ModalType | undefined;
  ignoreFocus: boolean;
}
export const closeModal = createAction<CloseModalPayload>('MODAL_CLOSE');

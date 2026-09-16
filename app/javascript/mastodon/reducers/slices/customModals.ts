import type { PayloadAction } from '@reduxjs/toolkit';
import { createSlice } from '@reduxjs/toolkit';

/**
 * This state tracks the open/closed state of modal dialogs that were not opened
 * via our existing `openModal` actions, for example the `BottomSheet` component
 * that can be rendered 'standalone'.
 *
 * Modals rendered like this should add an id to this state and remove it when
 * they're closed. The presence of any id in this state is used by the
 * `BodyScrollLock` component to prevent the page from scrolling behind modals.
 */
interface CustomModalsState {
  stack: string[];
}

const initialState: CustomModalsState = {
  stack: [],
};

const customModalsSlice = createSlice({
  name: 'customModals',
  initialState,
  reducers: {
    addCustomModal(state, action: PayloadAction<string>) {
      if (!state.stack.includes(action.payload)) {
        state.stack.push(action.payload);
      }
    },
    removeCustomModal(state, action: PayloadAction<string>) {
      state.stack = state.stack.filter((id) => id !== action.payload);
    },
  },
});

export const customModals = customModalsSlice.reducer;
export const { addCustomModal, removeCustomModal } = customModalsSlice.actions;

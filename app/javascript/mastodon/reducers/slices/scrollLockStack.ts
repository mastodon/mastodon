import type { PayloadAction } from '@reduxjs/toolkit';
import { createSlice } from '@reduxjs/toolkit';

/**
 * This state tracks the open/closed state of modal dialogs that were not opened
 * via our existing `openModal` actions, for example the `BottomSheet` component
 * that can be rendered standalone.
 *
 * Modals rendered like this should add an id to this state and remove it when
 * they're closed. The presence of any id in this state is used by the
 * `BodyScrollLock` component to prevent the page from scrolling behind modals.
 */
interface ScrollLockStackState {
  stack: string[];
}

const initialState: ScrollLockStackState = {
  stack: [],
};

const scrollLockStackSlice = createSlice({
  name: 'scrollLockStack',
  initialState,
  reducers: {
    addToScrollLockStack(state, action: PayloadAction<string>) {
      if (!state.stack.includes(action.payload)) {
        state.stack.push(action.payload);
      }
    },
    removeFromScrollLockStack(state, action: PayloadAction<string>) {
      state.stack = state.stack.filter((id) => id !== action.payload);
    },
  },
});

export const scrollLockStack = scrollLockStackSlice.reducer;
export const { addToScrollLockStack, removeFromScrollLockStack } =
  scrollLockStackSlice.actions;

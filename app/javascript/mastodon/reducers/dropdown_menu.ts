import { createReducer } from '@reduxjs/toolkit';

import { closeDropdownMenu, openDropdownMenu } from '../actions/dropdown_menu';

interface DropdownMenuState {
  openId: number | null;
  keyboard: boolean;
  scrollKey: string | undefined;
}

const initialState: DropdownMenuState = {
  openId: null,
  keyboard: false,
  scrollKey: undefined,
};

export const dropdownMenuReducer = createReducer(initialState, (builder) => {
  builder
    .addCase(
      openDropdownMenu,
      (state, { payload: { id, keyboard, scrollKey } }) => {
        state.openId = id;
        state.keyboard = keyboard;
        state.scrollKey = scrollKey;
      },
    )
    .addCase(closeDropdownMenu, (state, { payload: { id } }) => {
      if (state.openId === id) {
        state.openId = null;
        state.scrollKey = undefined;
      }
    });
});

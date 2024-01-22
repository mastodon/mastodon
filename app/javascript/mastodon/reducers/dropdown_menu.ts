import { createReducer } from '@reduxjs/toolkit';

import { closeDropdownMenu, openDropdownMenu } from '../actions/dropdown_menu';

interface DropdownMenuState {
  openId: string | null;
  keyboard: boolean;
  scrollKey: string | null;
}

const initialState: DropdownMenuState = {
  openId: null,
  keyboard: false,
  scrollKey: null,
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
        state.scrollKey = null;
      }
    });
});

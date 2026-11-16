import { createReducer } from '@reduxjs/toolkit';

import {
  openNavigation,
  closeNavigation,
  toggleNavigation,
  openInlineSearch,
  closeInlineSearch,
  toggleInlineSearch,
} from 'mastodon/actions/navigation';

interface State {
  open: boolean;
  searchOpen: boolean;
}

const initialState: State = {
  open: false,
  searchOpen: false,
};

export const navigationReducer = createReducer(initialState, (builder) => {
  builder
    .addCase(openNavigation, (state) => {
      state.open = true;
    })
    .addCase(closeNavigation, (state) => {
      state.open = false;
    })
    .addCase(toggleNavigation, (state) => {
      state.open = !state.open;
    })
    .addCase(openInlineSearch, (state) => {
      state.searchOpen = true;
    })
    .addCase(closeInlineSearch, (state) => {
      state.searchOpen = false;
    })
    .addCase(toggleInlineSearch, (state) => {
      state.searchOpen = !state.searchOpen;
    });
});

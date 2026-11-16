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
  mobileMenuOpen: boolean;
  searchOpen: boolean;
}

const initialState: State = {
  mobileMenuOpen: false,
  searchOpen: false,
};

export const navigationReducer = createReducer(initialState, (builder) => {
  builder
    .addCase(openNavigation, (state) => {
      state.mobileMenuOpen = true;
    })
    .addCase(closeNavigation, (state) => {
      state.mobileMenuOpen = false;
    })
    .addCase(toggleNavigation, (state) => {
      state.mobileMenuOpen = !state.mobileMenuOpen;
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

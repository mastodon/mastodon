import { createSlice } from '@reduxjs/toolkit';

import { forceSingleColumn } from '../../initial_state';

interface State {
  isMobileMenuOpen: boolean;
  isInlineSearchOpen: boolean;
  isMenuCollapsed: boolean;
}

const initialState: State = {
  isMobileMenuOpen: false,
  isInlineSearchOpen: false,
  isMenuCollapsed: !forceSingleColumn,
};

const navigationSlice = createSlice({
  name: 'navigation',
  initialState,
  reducers: {
    // Mobile menu
    openMobileMenu(state) {
      state.isMobileMenuOpen = true;
    },
    closeMobileMenu(state) {
      state.isMobileMenuOpen = false;
    },
    toggleMobileMenu(state) {
      state.isMobileMenuOpen = !state.isMobileMenuOpen;
    },
    // MiniNav inline search
    openInlineSearch(state) {
      state.isInlineSearchOpen = true;
    },
    closeInlineSearch(state) {
      state.isInlineSearchOpen = false;
    },
    toggleInlineSearch(state) {
      state.isInlineSearchOpen = !state.isInlineSearchOpen;
    },
    // Collapsible main nav
    openCollapsibleMenu(state) {
      state.isMenuCollapsed = false;
    },
    closeCollapsibleMenu(state) {
      state.isMenuCollapsed = true;
    },
    toggleCollapsibleMenu(state) {
      state.isMenuCollapsed = !state.isMenuCollapsed;
    },
  },
});

export const navigationReducer = navigationSlice.reducer;

export const {
  openMobileMenu,
  closeMobileMenu,
  toggleMobileMenu,
  openInlineSearch,
  closeInlineSearch,
  toggleInlineSearch,
  openCollapsibleMenu,
  closeCollapsibleMenu,
  toggleCollapsibleMenu,
} = navigationSlice.actions;

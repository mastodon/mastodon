import { createSlice } from '@reduxjs/toolkit';

import { forceSingleColumn } from '../../initial_state';

interface State {
  isMobileMenuOpen: boolean;
  isInlineSearchOpen: boolean;
  isSidebarCollapsed: boolean;
}

const initialState: State = {
  isMobileMenuOpen: false,
  isInlineSearchOpen: false,
  isSidebarCollapsed: !forceSingleColumn,
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
    openCollapsibleSidebar(state) {
      state.isSidebarCollapsed = false;
    },
    closeCollapsibleSidebar(state) {
      state.isSidebarCollapsed = true;
    },
    toggleCollapsibleSidebar(state) {
      state.isSidebarCollapsed = !state.isSidebarCollapsed;
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
  openCollapsibleSidebar,
  closeCollapsibleSidebar,
  toggleCollapsibleSidebar,
} = navigationSlice.actions;

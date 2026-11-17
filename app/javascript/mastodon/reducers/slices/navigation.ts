import { createSlice } from '@reduxjs/toolkit';

interface State {
  isMobileMenuOpen: boolean;
  isInlineSearchOpen: boolean;
}

const initialState: State = {
  isMobileMenuOpen: false,
  isInlineSearchOpen: false,
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
} = navigationSlice.actions;

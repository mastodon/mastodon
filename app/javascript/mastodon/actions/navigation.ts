import { createAction } from '@reduxjs/toolkit';

export const openNavigation = createAction('navigation/open');

export const closeNavigation = createAction('navigation/close');

export const toggleNavigation = createAction('navigation/toggle');

export const openInlineSearch = createAction('navigation/openSearch');

export const closeInlineSearch = createAction('navigation/closeSearch');

export const toggleInlineSearch = createAction('navigation/toggleSearch');

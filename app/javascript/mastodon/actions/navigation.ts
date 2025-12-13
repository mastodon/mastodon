import { createAction } from '@reduxjs/toolkit';

export const openNavigation = createAction('navigation/open');

export const closeNavigation = createAction('navigation/close');

export const toggleNavigation = createAction('navigation/toggle');

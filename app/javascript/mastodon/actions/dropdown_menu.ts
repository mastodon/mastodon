import { createAction } from '@reduxjs/toolkit';

export const openDropdownMenu = createAction<{
  id: number;
  keyboard: boolean;
  scrollKey?: string;
}>('dropdownMenu/open');

export const closeDropdownMenu = createAction<{ id: number }>(
  'dropdownMenu/close',
);

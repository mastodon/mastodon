import { createAction } from '@reduxjs/toolkit';

export const openDropdownMenu = createAction<{
  id: string;
  keyboard: boolean;
  scrollKey: string;
}>('dropdownMenu/open');

export const closeDropdownMenu = createAction<{ id: string }>(
  'dropdownMenu/close',
);

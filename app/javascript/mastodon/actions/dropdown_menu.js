export const DROPDOWN_MENU_OPEN = 'DROPDOWN_MENU_OPEN';
export const DROPDOWN_MENU_CLOSE = 'DROPDOWN_MENU_CLOSE';

export function openDropdownMenu(id, keyboard, scroll_key) {
  return { type: DROPDOWN_MENU_OPEN, id, keyboard, scroll_key };
}

export function closeDropdownMenu(id) {
  return { type: DROPDOWN_MENU_CLOSE, id };
}

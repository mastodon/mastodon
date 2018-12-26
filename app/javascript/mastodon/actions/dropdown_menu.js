export const DROPDOWN_MENU_OPEN = 'DROPDOWN_MENU_OPEN';
export const DROPDOWN_MENU_CLOSE = 'DROPDOWN_MENU_CLOSE';

export function openDropdownMenu(id, placement, keyboard) {
  return { type: DROPDOWN_MENU_OPEN, id, placement, keyboard };
}

export function closeDropdownMenu(id) {
  return { type: DROPDOWN_MENU_CLOSE, id };
}

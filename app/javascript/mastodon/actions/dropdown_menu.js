export const DROPDOWN_MENU_OPEN = 'DROPDOWN_MENU_OPEN';
export const DROPDOWN_MENU_CLOSE = 'DROPDOWN_MENU_CLOSE';

export function openDropdownMenu(id, placement) {
  return { type: DROPDOWN_MENU_OPEN, id, placement };
}

export function closeDropdownMenu(id) {
  return { type: DROPDOWN_MENU_CLOSE, id };
}

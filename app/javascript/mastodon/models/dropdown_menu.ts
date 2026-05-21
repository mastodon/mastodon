import type { KeyboardEvent, MouseEvent, TouchEvent } from 'react';

import type { IconProp } from '../components/icon';

interface BaseMenuItem {
  text: string;
  description?: string;
  icon?: IconProp;
  iconId?: string;
  highlighted?: boolean;
  disabled?: boolean;
  dangerous?: boolean;
}

export interface ActionMenuItem extends BaseMenuItem {
  action: (event: MouseEvent | KeyboardEvent | TouchEvent) => void;
}

export interface LinkMenuItem extends BaseMenuItem {
  to: string;
}

export interface ExternalLinkMenuItem extends BaseMenuItem {
  href: string;
  target?: string;
  method?: 'post' | 'put' | 'delete';
}

export type MenuItem =
  | ActionMenuItem
  | LinkMenuItem
  | ExternalLinkMenuItem
  | null;

export const isMenuItem = (item: unknown): item is MenuItem => {
  if (item === null) {
    return true;
  }

  return typeof item === 'object' && 'text' in item;
};

export const isActionItem = (item: unknown): item is ActionMenuItem => {
  if (!item || !isMenuItem(item)) {
    return false;
  }

  return 'action' in item;
};

export const isExternalLinkItem = (
  item: unknown,
): item is ExternalLinkMenuItem => {
  if (!item || !isMenuItem(item)) {
    return false;
  }

  return 'href' in item;
};

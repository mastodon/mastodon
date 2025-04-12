interface BaseMenuItem {
  text: string;
  dangerous?: boolean;
}

export interface ActionMenuItem extends BaseMenuItem {
  action: () => void;
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

interface BaseMenuItem {
  text: string;
  dangerous?: boolean;
}

interface ActionMenuItem extends BaseMenuItem {
  action: () => void;
}

interface LinkMenuItem extends BaseMenuItem {
  to: string;
}

interface ExternalLinkMenuItem extends BaseMenuItem {
  href: string;
}

export type MenuItem =
  | ActionMenuItem
  | LinkMenuItem
  | ExternalLinkMenuItem
  | null;

export type DropdownMenu = MenuItem[];

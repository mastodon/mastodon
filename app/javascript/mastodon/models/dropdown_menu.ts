interface MenuItem {
  text: string;
  action?: () => void;
  to?: string;
  dangerous?: boolean;
}

export type MenuItems = (MenuItem | null)[];

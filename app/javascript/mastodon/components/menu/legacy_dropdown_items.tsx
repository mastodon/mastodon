import type { MenuItem as LegacyDropdownMenuItem } from '@/mastodon/models/dropdown_menu';

import { MenuItem, MenuItemLink, MenuItemDivider } from './items';

export const LegacyDropdownMenuItems: React.FC<{
  items: LegacyDropdownMenuItem[];
}> = ({ items }) => {
  return items.map((item, index) => {
    if (item === null) {
      return <MenuItemDivider key={`divider-${index}`} />;
    }

    const commonProps = {
      destructive: item.dangerous,
      disabled: item.disabled,
      description: item.description,
      icon: item.icon,
    } as const;

    if ('action' in item) {
      return (
        <MenuItem key={item.text} onClick={item.action} {...commonProps}>
          {item.text}
        </MenuItem>
      );
    }
    if ('to' in item) {
      return (
        <MenuItemLink key={item.text} to={item.to} {...commonProps}>
          {item.text}
        </MenuItemLink>
      );
    }
    if ('href' in item) {
      return (
        <MenuItemLink as='a' key={item.text} href={item.href} {...commonProps}>
          {item.text}
        </MenuItemLink>
      );
    }
    return null;
  });
};

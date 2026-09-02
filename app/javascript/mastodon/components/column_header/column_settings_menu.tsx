import { DotsThreeIcon } from '@phosphor-icons/react';

import { ColumnHeaderButton } from '@/mastodon/components/column_header';
import { Menu, MenuList, MenuTrigger } from '@/mastodon/components/menu';

import type { IconButtonProps } from '../button/redesign';

interface ColumnSettingsMenuProps {
  icon?: IconButtonProps['icon'];
  label: React.ReactNode;
  children: React.ReactNode;
}

export const ColumnSettingsMenu: React.FC<ColumnSettingsMenuProps> = ({
  label,
  icon = DotsThreeIcon,
  children,
}) => {
  return (
    <Menu>
      <MenuTrigger as={ColumnHeaderButton} icon={icon}>
        {label}
      </MenuTrigger>
      <MenuList placement='bottom-end' strategy='absolute'>
        {children}
      </MenuList>
    </Menu>
  );
};

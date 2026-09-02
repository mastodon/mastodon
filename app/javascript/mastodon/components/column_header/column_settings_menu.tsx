import { FormattedMessage } from 'react-intl';

import { DotsThreeIcon } from '@phosphor-icons/react';

import { ColumnHeaderButton } from '@/mastodon/components/column_header';
import { Menu, MenuList, MenuTrigger } from '@/mastodon/components/menu';

import type { IconButtonProps } from '../button/redesign';

type ColumnSettingsMenuProps = {
  icon?: IconButtonProps['icon'];
  children: React.ReactNode;
} & (
  | {
      labelPrefix?: never;
      label: React.ReactNode;
    }
  | {
      labelPrefix: React.ReactNode;
      label?: never;
    }
);

export const ColumnSettingsMenu: React.FC<ColumnSettingsMenuProps> = ({
  label,
  labelPrefix,
  icon = DotsThreeIcon,
  children,
}) => {
  return (
    <Menu>
      <MenuTrigger as={ColumnHeaderButton} icon={icon}>
        {labelPrefix}
        {label ?? (
          <FormattedMessage
            id='column.settings'
            defaultMessage='Column Settings'
          />
        )}
      </MenuTrigger>
      <MenuList placement='bottom-end' strategy='absolute'>
        {children}
      </MenuList>
    </Menu>
  );
};

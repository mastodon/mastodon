import {
  MoonIcon,
  NumberCircleOneIcon,
  NumberCircleTwoIcon,
  SunIcon,
} from '@phosphor-icons/react';
import type { Meta, StoryObj } from '@storybook/react-vite';
import { action } from 'storybook/actions';

import { useToggle } from '@/mastodon/hooks/useToggle';

import { ToggleField } from '../form_fields/redesign';

import { Menu, MenuButton, MenuList, MenuItemBase, MenuItem } from '.';
import type { MenuCardProps } from './card';
import { MenuCard } from './card';

const meta = {
  title: 'Redesign/Menu',
  args: {
    elevation: 1,
  },
  argTypes: {
    elevation: {
      control: 'inline-radio',
      options: [1, 2],
    },
  },
} satisfies Meta<Omit<MenuCardProps<'div'>, 'children'>>;

export default meta;

type Story = StoryObj<typeof meta>;

const handleMenuItemClick = action('menu item click');

export const Simple: Story = {
  render(args) {
    return (
      <MenuCard {...args}>
        <MenuItem
          leadingIcon={NumberCircleOneIcon}
          onClick={handleMenuItemClick}
        >
          First item
        </MenuItem>
        <MenuItem
          leadingIcon={NumberCircleTwoIcon}
          onClick={handleMenuItemClick}
        >
          Second item
        </MenuItem>
      </MenuCard>
    );
  },
};

export const Popover: Story = {
  render(args) {
    return (
      <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
        <Menu>
          <MenuButton>Click to show dropdown</MenuButton>

          <MenuList {...args}>
            <MenuItem
              leadingIcon={NumberCircleOneIcon}
              onClick={handleMenuItemClick}
            >
              First item
            </MenuItem>
            <MenuItem
              leadingIcon={NumberCircleTwoIcon}
              onClick={handleMenuItemClick}
            >
              Second item
            </MenuItem>
          </MenuList>
        </Menu>
      </div>
    );
  },
};

export const Controls: Story = {
  render(args) {
    const [sun, { onToggle }] = useToggle();
    return (
      <MenuCard {...args}>
        <MenuItem onClick={handleMenuItemClick}>First item</MenuItem>

        <hr />

        <MenuItemBase leadingIcon={sun ? SunIcon : MoonIcon}>
          <ToggleField label='Daytime toggle' size='sm' onChange={onToggle} />
        </MenuItemBase>
      </MenuCard>
    );
  },
};

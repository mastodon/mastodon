import { useCallback, useState } from 'react';

import {
  MoonIcon,
  NumberCircleOneIcon,
  NumberCircleTwoIcon,
  SunIcon,
} from '@phosphor-icons/react';
import type { Meta, StoryObj } from '@storybook/react-vite';
import { action } from 'storybook/actions';

import { useToggle } from '@/mastodon/hooks/useToggle';

import {
  Menu,
  MenuButton,
  MenuList,
  MenuItem,
  MenuItemDivider,
  MenuItemCheckbox,
  MenuItemGroup,
  MenuItemRadio,
} from '.';
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
        <MenuItem icon={NumberCircleOneIcon} onClick={handleMenuItemClick}>
          First item
        </MenuItem>
        <MenuItem icon={NumberCircleTwoIcon} onClick={handleMenuItemClick}>
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
            <MenuItem icon={NumberCircleOneIcon} onClick={handleMenuItemClick}>
              First item
            </MenuItem>
            <MenuItem icon={NumberCircleTwoIcon} onClick={handleMenuItemClick}>
              Second item
            </MenuItem>
          </MenuList>
        </Menu>
      </div>
    );
  },
};

export const Complex: Story = {
  render(args) {
    const [sun, { onToggle }] = useToggle();
    const [precip, setPrecip] = useState('none');

    const handlePrecipChange = useCallback(({ value }: { value: string }) => {
      setPrecip(value);
    }, []);

    return (
      <MenuCard {...args}>
        <MenuItem onClick={handleMenuItemClick}>First item</MenuItem>

        <MenuItemDivider />

        <MenuItemCheckbox
          icon={sun ? SunIcon : MoonIcon}
          checked={sun}
          onChange={onToggle}
          value='daytime'
        >
          Daytime toggle
        </MenuItemCheckbox>
        <MenuItemDivider />
        <MenuItemGroup label='Precipitation'>
          <MenuItemRadio
            value='none'
            checked={precip === 'none'}
            onChange={handlePrecipChange}
          >
            None
          </MenuItemRadio>
          <MenuItemRadio
            value='rain'
            checked={precip === 'rain'}
            onChange={handlePrecipChange}
          >
            Rain
          </MenuItemRadio>
          <MenuItemRadio
            value='snow'
            checked={precip === 'snow'}
            onChange={handlePrecipChange}
          >
            Snow
          </MenuItemRadio>
        </MenuItemGroup>
      </MenuCard>
    );
  },
};

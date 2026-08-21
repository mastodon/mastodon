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
  MenuTrigger,
  MenuList,
  MenuItem,
  MenuItemDivider,
  MenuItemCheckbox,
  MenuItemGroup,
  MenuItemRadio,
  MenuItemLink,
} from '.';
import type { MenuCardProps } from './card';

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

export const Default: Story = {
  render(args) {
    return (
      <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
        <Menu>
          <MenuTrigger>Show actions</MenuTrigger>

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
      <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
        <Menu>
          <MenuTrigger>World settings</MenuTrigger>

          <MenuList {...args}>
            <MenuItem onClick={handleMenuItemClick} keepMenuOpenOnClick>
              First item
            </MenuItem>

            <MenuItemDivider />

            <MenuItemCheckbox
              icon={sun ? SunIcon : MoonIcon}
              checked={sun}
              onChange={onToggle}
              value='daytime'
              keepMenuOpenOnClick
            >
              Daytime toggle
            </MenuItemCheckbox>
            <MenuItemDivider />
            <MenuItemGroup label='Precipitation'>
              <MenuItemRadio
                value='none'
                checked={precip === 'none'}
                onChange={handlePrecipChange}
                keepMenuOpenOnClick
              >
                None
              </MenuItemRadio>
              <MenuItemRadio
                value='rain'
                checked={precip === 'rain'}
                onChange={handlePrecipChange}
                keepMenuOpenOnClick
              >
                Rain
              </MenuItemRadio>
              <MenuItemRadio
                value='snow'
                checked={precip === 'snow'}
                onChange={handlePrecipChange}
                keepMenuOpenOnClick
              >
                Snow
              </MenuItemRadio>
            </MenuItemGroup>
          </MenuList>
        </Menu>
      </div>
    );
  },
};

export const Navigation: Story = {
  render(args) {
    return (
      <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
        <Menu type='navigation'>
          <MenuTrigger>More links</MenuTrigger>

          <MenuList {...args}>
            <MenuItemLink to='/about'>About</MenuItemLink>
            <MenuItemLink to='/privacy'>Terms & Conditions</MenuItemLink>
            <MenuItemLink href='/terms' as='a'>
              Privacy
            </MenuItemLink>
          </MenuList>
        </Menu>
      </div>
    );
  },
};

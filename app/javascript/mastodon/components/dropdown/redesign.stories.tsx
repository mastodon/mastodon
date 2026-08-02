import { useState } from 'react';

import {
  MoonIcon,
  NumberCircleOneIcon,
  NumberCircleTwoIcon,
  SunIcon,
} from '@phosphor-icons/react';
import type { Meta, StoryObj } from '@storybook/react-vite';
import { action } from 'storybook/actions';

import { useToggle } from '@/mastodon/hooks/useToggle';

import { Button } from '../button/redesign';
import { ToggleField } from '../form_fields/redesign';
import { Icon } from '../icon';

import type { DropdownProps } from './redesign';
import {
  Dropdown,
  DropdownItem,
  DropdownItemButton,
  DropdownPopover,
} from './redesign';

const meta = {
  title: 'Redesign/Dropdown',
  args: {
    elevation: 1,
  },
  argTypes: {
    elevation: {
      control: 'inline-radio',
      options: [1, 2],
    },
  },
} satisfies Meta<Omit<DropdownProps<'div'>, 'children'>>;

export default meta;

type Story = StoryObj<typeof meta>;

const handleMenuItemClick = action('menu item click');

export const Simple: Story = {
  render(args) {
    return (
      <Dropdown {...args}>
        <DropdownItemButton
          icon={NumberCircleOneIcon}
          onClick={handleMenuItemClick}
        >
          First item
        </DropdownItemButton>
        <DropdownItemButton
          icon={NumberCircleTwoIcon}
          onClick={handleMenuItemClick}
        >
          Second item
        </DropdownItemButton>
      </Dropdown>
    );
  },
};

export const Popover: Story = {
  render(args) {
    const [ref, setRef] = useState<HTMLButtonElement | null>(null);
    const [open, { onToggle, onFalse }] = useToggle();

    return (
      <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
        <Button ref={setRef} onClick={onToggle}>
          Click to show dropdown
        </Button>

        <DropdownPopover
          reference={ref}
          isOpen={open}
          onClose={onFalse}
          {...args}
        >
          <DropdownItemButton
            icon={NumberCircleOneIcon}
            onClick={handleMenuItemClick}
          >
            First item
          </DropdownItemButton>
          <DropdownItemButton
            icon={NumberCircleTwoIcon}
            onClick={handleMenuItemClick}
          >
            Second item
          </DropdownItemButton>
        </DropdownPopover>
      </div>
    );
  },
};

export const Controls: Story = {
  render(args) {
    const [sun, { onToggle }] = useToggle();
    return (
      <Dropdown {...args}>
        <DropdownItemButton onClick={handleMenuItemClick}>
          First item
        </DropdownItemButton>

        <hr />

        <DropdownItem>
          {sun ? (
            <Icon id='sun' icon={SunIcon} />
          ) : (
            <Icon id='moon' icon={MoonIcon} />
          )}
          <ToggleField label='Daytime toggle' size='sm' onChange={onToggle} />
        </DropdownItem>
      </Dropdown>
    );
  },
};

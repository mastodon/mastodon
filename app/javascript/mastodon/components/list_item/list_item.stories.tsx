import type { Meta, StoryObj } from '@storybook/react-vite';

import ChevronRightIcon from '@/material-icons/400-24px/chevron_right.svg?react';
import KeyboardArrowDownIcon from '@/material-icons/400-24px/keyboard_arrow_down.svg?react';
import VisibilityIcon from '@/material-icons/400-24px/visibility.svg?react';
import VisibilityOffIcon from '@/material-icons/400-24px/visibility_off.svg?react';

import { Icon } from '../icon';

import { ListItemWrapper, ListItemButton, ListItemLink } from './index';

const meta = {
  title: 'Components/ListItem',
  component: ListItemWrapper,
  subcomponents: { ListItemButton, ListItemLink },
} satisfies Meta<typeof ListItemWrapper>;

export default meta;

type Story = StoryObj<typeof meta>;

export const WithButton: Story = {
  render: () => (
    <ListItemWrapper
      icon={<Icon icon={VisibilityOffIcon} id='visibility' />}
      iconEnd={<Icon icon={KeyboardArrowDownIcon} id='down' />}
    >
      <ListItemButton subtitle='You’ve blocked or muted these users'>
        3 hidden accounts
      </ListItemButton>
    </ListItemWrapper>
  ),
};

export const WithLink: Story = {
  render: () => (
    <ListItemWrapper
      icon={<Icon icon={VisibilityIcon} id='visibility' />}
      iconEnd={<Icon icon={ChevronRightIcon} id='right' />}
    >
      <ListItemLink to='/'>View more</ListItemLink>
    </ListItemWrapper>
  ),
};

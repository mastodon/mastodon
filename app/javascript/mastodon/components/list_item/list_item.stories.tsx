import type { Meta, StoryObj } from '@storybook/react-vite';

import ChevronRightIcon from '@/material-icons/400-24px/chevron_right.svg?react';
import KeyboardArrowDownIcon from '@/material-icons/400-24px/keyboard_arrow_down.svg?react';
import VisibilityIcon from '@/material-icons/400-24px/visibility.svg?react';
import VisibilityOffIcon from '@/material-icons/400-24px/visibility_off.svg?react';

import { AvatarById } from '../avatar';
import { Button } from '../button';
import { Icon } from '../icon';

import {
  ListItemWrapper,
  ListItemContent,
  ListItemButton,
  ListItemLink,
} from './index';

const meta = {
  title: 'Components/ListItem',
  component: ListItemWrapper,
  subcomponents: { ListItemContent, ListItemButton, ListItemLink },
} satisfies Meta<typeof ListItemWrapper>;

export default meta;

type Story = StoryObj<typeof meta>;

export const NonInteractive: Story = {
  render: () => (
    <ListItemWrapper icon={<Icon icon={VisibilityIcon} id='visibility' />}>
      <ListItemContent>View more</ListItemContent>
    </ListItemWrapper>
  ),
};

export const WithButton: Story = {
  render: () => (
    <ListItemWrapper
      icon={<Icon icon={VisibilityOffIcon} id='visibility' />}
      sideContent={<Icon icon={KeyboardArrowDownIcon} id='down' />}
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
      sideContent={<Icon icon={ChevronRightIcon} id='right' />}
    >
      <ListItemLink to='/'>View more</ListItemLink>
    </ListItemWrapper>
  ),
};

export const WithInteractiveSideContent: Story = {
  render: () => (
    <ListItemWrapper
      icon={<AvatarById accountId='1' size={40} />}
      sideContent={<Button compact>Follow</Button>}
    >
      <ListItemLink to='/' subtitle='@test@example.com'>
        Test account
      </ListItemLink>
    </ListItemWrapper>
  ),
};

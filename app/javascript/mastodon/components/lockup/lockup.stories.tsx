import type { Meta, StoryObj } from '@storybook/react-vite';

import ChevronRightIcon from '@/material-icons/400-24px/chevron_right.svg?react';
import KeyboardArrowDownIcon from '@/material-icons/400-24px/keyboard_arrow_down.svg?react';
import VisibilityIcon from '@/material-icons/400-24px/visibility.svg?react';
import VisibilityOffIcon from '@/material-icons/400-24px/visibility_off.svg?react';

import { AvatarById } from '../avatar';
import { Button } from '../button';
import { Icon } from '../icon';

import {
  LockupWrapper,
  LockupContent,
  LockupButton,
  LockupLink,
} from './index';

const meta = {
  title: 'Components/Lockup',
  component: LockupWrapper,
  subcomponents: { LockupContent, LockupButton, LockupLink },
} satisfies Meta<typeof LockupWrapper>;

export default meta;

type Story = StoryObj<typeof meta>;

export const NonInteractive: Story = {
  render: () => (
    <LockupWrapper icon={<Icon icon={VisibilityIcon} id='visibility' />}>
      <LockupContent>View more</LockupContent>
    </LockupWrapper>
  ),
};

export const WithButton: Story = {
  render: () => (
    <LockupWrapper
      icon={<Icon icon={VisibilityOffIcon} id='visibility' />}
      sideContent={<Icon icon={KeyboardArrowDownIcon} id='down' />}
    >
      <LockupButton subtitle='You’ve blocked or muted these users'>
        3 hidden accounts
      </LockupButton>
    </LockupWrapper>
  ),
};

export const WithLink: Story = {
  render: () => (
    <LockupWrapper
      icon={<Icon icon={VisibilityIcon} id='visibility' />}
      sideContent={<Icon icon={ChevronRightIcon} id='right' />}
    >
      <LockupLink to='/'>View more</LockupLink>
    </LockupWrapper>
  ),
};

export const WithInteractiveSideContent: Story = {
  render: () => (
    <LockupWrapper
      icon={<AvatarById accountId='1' size={40} />}
      sideContent={<Button compact>Follow</Button>}
    >
      <LockupLink to='/' subtitle='@test@example.com'>
        Test account
      </LockupLink>
    </LockupWrapper>
  ),
};

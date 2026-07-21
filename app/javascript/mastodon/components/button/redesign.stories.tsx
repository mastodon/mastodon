import type { Meta, StoryObj } from '@storybook/react-vite';

import ChatIcon from '@/material-icons/400-24px/chat.svg?react';
import DownloadIcon from '@/material-icons/400-24px/download.svg?react';
import HeadphonesIcon from '@/material-icons/400-24px/headphones.svg?react';

import { Button, IconButton } from './redesign';

const iconArgType = {
  control: 'select',
  options: ['chat', 'download', 'audio'],
  mapping: {
    chat: ChatIcon,
    download: DownloadIcon,
    audio: HeadphonesIcon,
  },
} as const;

const meta = {
  title: 'Redesign/Button',
  component: Button,
  args: {
    label: 'Action',
    size: 'md',
    variant: 'solid',
    color: 'neutral',
    loading: false,
    as: 'button',
  },
  argTypes: {
    as: {
      control: 'select',
      options: ['button', 'a'],
    },
    leadingIcon: iconArgType,
    trailingIcon: iconArgType,
  },
} satisfies Meta<typeof Button>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};

export const IconLeading: Story = {
  args: {
    leadingIcon: ChatIcon,
  },
};

export const IconTrailing: Story = {
  args: {
    trailingIcon: HeadphonesIcon,
  },
};

export const IconOnly: Story = {
  render(args) {
    return <IconButton {...args} icon={args.leadingIcon ?? ChatIcon} />;
  },
  args: {
    label: undefined,
    leadingIcon: ChatIcon,
  },
};

import type { Meta, StoryObj } from '@storybook/react-vite';
import { fn } from 'storybook/test';

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
    children: 'Action',
    size: 'md',
    variant: 'solid',
    color: 'neutral',
    disabled: false,
    loading: false,
    as: 'button',
    onClick: fn(),
  },
  argTypes: {
    children: {
      control: 'text',
    },
    as: {
      control: 'inline-radio',
      options: ['button', 'a', 'link'],
    },
    size: {
      control: 'inline-radio',
      options: ['xs', 'sm', 'md', 'lg'],
    },
    variant: {
      control: 'inline-radio',
      options: ['solid', 'text'],
    },
    color: {
      control: 'inline-radio',
      options: ['neutral', 'accent', 'tonal', 'destructive'],
    },
    leadingIcon: iconArgType,
    trailingIcon: iconArgType,
    onClick: {
      table: {
        disable: true,
      },
    },
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
    leadingIcon: ChatIcon,
  },
};

export const Link: Story = {
  render(args) {
    if (args.as === 'link') {
      return <Button {...args} to='/example' />;
    }
    return <Button {...args} />;
  },
  args: {
    as: 'link',
  },
};

import type { Meta, StoryObj } from '@storybook/react-vite';

import LinkIcon from '@/material-icons/400-24px/link_2.svg?react';

import { MiniCardList } from './list';

const meta = {
  title: 'Components/MiniCard',
  component: MiniCardList,
} satisfies Meta<typeof MiniCardList>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {
    cards: [
      { label: 'Pronouns', value: 'they/them' },
      {
        label: 'Website',
        value: <a href='https://example.com'>bowie-the-db.meow</a>,
        icon: LinkIcon,
      },
      {
        label: 'Free playlists',
        value: <a href='https://soundcloud.com/bowie-the-dj'>soundcloud.com</a>,
        icon: LinkIcon,
      },
      { label: 'Location', value: 'Purris, France' },
    ],
  },
};

export const LongValue: Story = {
  args: {
    cards: [
      {
        label: 'Username',
        value: 'bowie-the-dj',
        style: { maxWidth: '250px' },
      },
      {
        label: 'Bio',
        value:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        style: { maxWidth: '250px' },
      },
    ],
  },
};

export const OneCard: Story = {
  args: {
    cards: [{ label: 'Pronouns', value: 'they/them' }],
  },
};

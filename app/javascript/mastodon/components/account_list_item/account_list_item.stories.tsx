import type { Meta, StoryObj } from '@storybook/react-vite';

import { accountFactoryState, relationshipsFactory } from '@/testing/factories';

import { PendingBadge } from '../badge';

import { AccountListItem } from './index';

const meta = {
  title: 'Components/AccountListItem',
  component: AccountListItem,
  args: {
    accountId: '1',
    withBorder: false,
  },
  parameters: {
    state: {
      accounts: {
        '1': accountFactoryState(),
      },
    },
  },
} satisfies Meta<typeof AccountListItem>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};

export const FollowsYou: Story = {
  parameters: {
    state: {
      relationships: {
        '1': relationshipsFactory({
          followed_by: true,
        }),
      },
    },
  },
};

export const WithCustomStats: Story = {
  args: {
    stats: ['posts', 'last-active'],
  },
};

export const WithCustomBadge: Story = {
  args: {
    badge: <PendingBadge />,
  },
};

export const WithBorder: Story = {
  args: {
    withBorder: true,
  },
};

export const WithoutButton: Story = {
  args: {
    renderButton: () => null,
  },
};

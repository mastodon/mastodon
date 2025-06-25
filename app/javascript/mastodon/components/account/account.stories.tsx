import type { Meta, StoryObj } from '@storybook/react-vite';

import { accountFactoryState, relationshipsFactory } from '@/testing/factories';

import { Account } from './index';

const meta = {
  title: 'Components/Account',
  component: Account,
  argTypes: {
    id: {
      type: 'string',
      description: 'ID of the account to display',
    },
    size: {
      type: 'number',
      description: 'Size of the avatar in pixels',
    },
    hidden: {
      type: 'boolean',
      description: 'Whether the account is hidden or not',
    },
    minimal: {
      type: 'boolean',
      description: 'Whether to display a minimal version of the account',
    },
    defaultAction: {
      type: 'string',
      control: 'select',
      options: ['block', 'mute'],
      description: 'Default action to take on the account',
    },
    withBio: {
      type: 'boolean',
      description: 'Whether to display the account bio or not',
    },
    withMenu: {
      type: 'boolean',
      description: 'Whether to display the account menu or not',
    },
  },
  args: {
    id: '1',
    size: 46,
    hidden: false,
    minimal: false,
    defaultAction: 'mute',
    withBio: false,
    withMenu: true,
  },
  parameters: {
    state: {
      accounts: {
        '1': accountFactoryState(),
      },
    },
  },
} satisfies Meta<typeof Account>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Primary: Story = {
  args: {
    id: '1',
  },
};

export const Hidden: Story = {
  args: {
    hidden: true,
  },
};

export const Minimal: Story = {
  args: {
    minimal: true,
  },
};

export const WithBio: Story = {
  args: {
    withBio: true,
  },
};

export const NoMenu: Story = {
  args: {
    withMenu: false,
  },
};

export const Blocked: Story = {
  args: {
    defaultAction: 'block',
  },
  parameters: {
    state: {
      relationships: {
        '1': relationshipsFactory({
          blocking: true,
        }),
      },
    },
  },
};

export const Muted: Story = {
  args: {},
  parameters: {
    state: {
      relationships: {
        '1': relationshipsFactory({
          muting: true,
        }),
      },
    },
  },
};

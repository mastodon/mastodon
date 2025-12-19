import type { ComponentProps } from 'react';

import type { Meta, StoryObj } from '@storybook/react-vite';

import { accountFactoryState, relationshipsFactory } from '@/testing/factories';

import { Account } from './index';

type Props = Omit<ComponentProps<typeof Account>, 'id'> & {
  name: string;
  username: string;
};

const meta = {
  title: 'Components/Account',
  argTypes: {
    name: {
      type: 'string',
      description: 'The display name of the account',
      reduxPath: 'accounts.1.display_name_html',
    },
    username: {
      type: 'string',
      description: 'The username of the account',
      reduxPath: 'accounts.1.acct',
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
    name: 'Test User',
    username: 'testuser',
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
  render(args) {
    return <Account id='1' {...args} />;
  },
} satisfies Meta<Props>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Primary: Story = {};

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

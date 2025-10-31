import type { ComponentProps } from 'react';

import type { Meta, StoryObj } from '@storybook/react-vite';

import { accountFactoryState } from '@/testing/factories';

import { DisplayName, LinkedDisplayName } from './index';

type PageProps = Omit<ComponentProps<typeof DisplayName>, 'account'> & {
  name: string;
  username: string;
  loading: boolean;
};

const meta = {
  title: 'Components/DisplayName',
  args: {
    username: 'mastodon@mastodon.social',
    name: 'Test User 🧪',
    loading: false,
    localDomain: 'mastodon.social',
  },
  tags: [],
  render({ name, username, loading, ...args }) {
    const account = !loading
      ? accountFactoryState({
          display_name: name,
          acct: username,
        })
      : undefined;
    return <DisplayName {...args} account={account} />;
  },
} satisfies Meta<PageProps>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Primary: Story = {
  args: {},
};

export const Loading: Story = {
  args: {
    loading: true,
  },
};

export const NoDomain: Story = {
  args: {
    variant: 'noDomain',
  },
};

export const Simple: Story = {
  args: {
    variant: 'simple',
  },
};

export const LocalUser: Story = {
  args: {
    username: 'localuser',
    name: 'Local User',
    localDomain: '',
  },
};

export const Linked: Story = {
  render({ name, username, loading, ...args }) {
    const account = !loading
      ? accountFactoryState({
          display_name: name,
          acct: username,
        })
      : undefined;
    return <LinkedDisplayName displayProps={{ account, ...args }} />;
  },
};

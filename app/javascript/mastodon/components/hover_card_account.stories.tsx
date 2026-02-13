import { Map as ImmutableMap } from 'immutable';

import type { Meta, StoryObj } from '@storybook/react-vite';

import { accountFactory, accountFactoryState } from '@/testing/factories';

import { HoverCardAccount } from './hover_card_account';

const meta = {
  title: 'Components/HoverCardAccount',
  component: HoverCardAccount,
  argTypes: {
    accountId: {
      type: 'string',
      description: 'ID of the account to display in the hover card',
    },
  },
  args: {
    accountId: '1',
  },
  decorators: [
    (Story) => (
      <div
        style={{
          padding: '20px',
          backgroundColor: '#f5f5f5',
          minHeight: '300px',
        }}
      >
        <p style={{ marginBottom: '20px', color: '#666' }}>
          Hover card examples - demonstrating Issue #35623 fix for moved
          accounts
        </p>
        <Story />
      </div>
    ),
  ],
} satisfies Meta<typeof HoverCardAccount>;

export default meta;

type Story = StoryObj<typeof meta>;

// Mock data for different account states
const regularAccount = accountFactoryState({
  id: '1',
  username: 'alice',
  acct: 'alice@mastodon.social',
  display_name: 'Alice Johnson',
  note: 'Frontend developer who loves building amazing user interfaces. Coffee enthusiast ☕',
  followers_count: 1250,
  following_count: 342,
  statuses_count: 1840,
  avatar: 'https://picsum.photos/200/200?random=1',
  header: 'https://picsum.photos/600/200?random=1',
  fields: [
    { name: 'Website', value: 'https://alice.dev', verified_at: null },
    { name: 'Location', value: 'San Francisco, CA', verified_at: null },
  ],
});

const movedAccount = accountFactoryState({
  id: '2',
  username: 'bob_old',
  acct: 'bob_old@mastodon.social',
  display_name: 'Bob Smith (Moved)',
  note: 'I have moved to a new account. Please follow me there!',
  followers_count: 890,
  following_count: 156,
  statuses_count: 420,
  avatar: 'https://picsum.photos/200/200?random=2',
  header: 'https://picsum.photos/600/200?random=2',
  moved: accountFactory({
    id: '3',
    username: 'bob_new',
    acct: 'bob_new@social.example',
    display_name: 'Bob Smith',
    followers_count: 950,
    following_count: 180,
    statuses_count: 45,
    avatar: 'https://picsum.photos/200/200?random=3',
    header: 'https://picsum.photos/600/200?random=3',
  }),
});

const newAccount = accountFactoryState({
  id: '3',
  username: 'bob_new',
  acct: 'bob_new@social.example',
  display_name: 'Bob Smith',
  note: 'This is my new account! Thanks for following me here.',
  followers_count: 950,
  following_count: 180,
  statuses_count: 45,
  avatar: 'https://picsum.photos/200/200?random=3',
  header: 'https://picsum.photos/600/200?random=3',
});

export const RegularAccount: Story = {
  args: {
    accountId: '1',
  },
  parameters: {
    state: {
      accounts: ImmutableMap({
        '1': regularAccount,
      }),
      relationships: ImmutableMap(),
      meta: ImmutableMap({
        locale: 'en',
        emoji_style: 'unicode',
      }),
    },
  },
};

export const MovedAccount: Story = {
  args: {
    accountId: '2',
  },
  parameters: {
    state: {
      accounts: ImmutableMap({
        '2': movedAccount,
        '3': newAccount,
      }),
      relationships: ImmutableMap(),
      meta: ImmutableMap({
        locale: 'en',
        emoji_style: 'unicode',
      }),
    },
  },
};

export const LoadingState: Story = {
  args: {
    accountId: '999',
  },
  parameters: {
    state: {
      accounts: ImmutableMap(),
      relationships: ImmutableMap(),
      meta: ImmutableMap({
        locale: 'en',
        emoji_style: 'unicode',
      }),
    },
  },
};

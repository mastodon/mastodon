import type { Meta, StoryObj } from '@storybook/react-vite';

import type { StatusVisibility } from '@/mastodon/api_types/statuses';
import { statusFactoryState } from '@/testing/factories';

import { LegacyReblogButton, StatusReblogButton } from './reblog_button';

interface StoryProps {
  visibility: StatusVisibility;
  quoteAllowed: boolean;
  alreadyBoosted: boolean;
  reblogCount: number;
}

const meta = {
  title: 'Components/Status/ReblogButton',
  args: {
    visibility: 'public',
    quoteAllowed: true,
    alreadyBoosted: false,
    reblogCount: 0,
  },
  argTypes: {
    visibility: {
      name: 'Visibility',
      control: { type: 'select' },
      options: ['public', 'unlisted', 'private', 'direct'],
    },
    reblogCount: {
      name: 'Boost Count',
      description: 'More than 0 will show the counter',
    },
    quoteAllowed: {
      name: 'Quotes allowed',
    },
    alreadyBoosted: {
      name: 'Already boosted',
    },
  },
  render: (args) => (
    <StatusReblogButton
      status={argsToStatus(args)}
      counters={args.reblogCount > 0}
    />
  ),
} satisfies Meta<StoryProps>;

export default meta;

function argsToStatus({
  reblogCount,
  visibility,
  quoteAllowed,
  alreadyBoosted,
}: StoryProps) {
  return statusFactoryState({
    reblogs_count: reblogCount,
    visibility,
    reblogged: alreadyBoosted,
    quote_approval: {
      automatic: [],
      manual: [],
      current_user: quoteAllowed ? 'automatic' : 'denied',
    },
  });
}

type Story = StoryObj<typeof meta>;

export const Default: Story = {};

export const Mine: Story = {
  parameters: {
    state: {
      meta: {
        me: '1',
      },
    },
  },
};

export const Legacy: Story = {
  render: (args) => (
    <LegacyReblogButton
      status={argsToStatus(args)}
      counters={args.reblogCount > 0}
    />
  ),
};

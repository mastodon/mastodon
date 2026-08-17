import type { Meta, StoryObj } from '@storybook/react-vite';

import { DAY } from '@/mastodon/utils/time';

import { RelativeTimestamp } from './index';

const meta = {
  title: 'Components/RelativeTimestamp',
  component: RelativeTimestamp,
  args: {
    timestamp: new Date(Date.now() - DAY * 3).toISOString(),
    long: false,
    noTime: false,
    hasFuture: false,
  },
  argTypes: {
    timestamp: {
      control: 'date',
    },
  },
  render(props) {
    const { timestamp } = props;
    const dateString = toDateString(timestamp);

    return <RelativeTimestamp {...props} timestamp={dateString} />;
  },
} satisfies Meta<typeof RelativeTimestamp>;

export default meta;

type Story = StoryObj<typeof RelativeTimestamp>;

export const Plain: Story = {};

export const Long: Story = {
  args: {
    long: true,
  },
};

export const DateOnly: Story = {
  args: {
    noTime: true,
  },
};

export const HasFuture: Story = {
  args: {
    timestamp: new Date(Date.now() + DAY * 3).toISOString(),
    hasFuture: true,
  },
};

// Storybook has a known bug with changing a date control from a string to number.
function toDateString(timestamp?: number | string) {
  if (!timestamp) {
    return new Date().toISOString();
  }

  if (typeof timestamp === 'number') {
    return new Date(timestamp).toISOString();
  }

  return timestamp;
}

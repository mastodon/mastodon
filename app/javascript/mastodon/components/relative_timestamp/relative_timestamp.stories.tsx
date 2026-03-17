import type { Meta, StoryObj } from '@storybook/react-vite';

import { DAY } from '@/mastodon/utils/time';

import { RelativeTimestamp as LegacyRelativeTimestamp } from '../relative_timestamp';

import { RelativeTimestamp } from './index';

const meta = {
  title: 'Components/RelativeTimestamp',
  component: RelativeTimestamp,
  args: {
    timestamp: new Date(Date.now() - DAY * 3).toISOString(),
    long: false,
    noTime: false,
    noFuture: false,
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

export const NoFuture: Story = {
  args: {
    timestamp: new Date(Date.now() + DAY * 3).toISOString(),
    noFuture: true,
  },
};

export const Legacy: Story = {
  render(props) {
    const { timestamp } = props;
    const dateString = toDateString(timestamp);
    const isFuture = new Date(dateString).getTime() > Date.now();

    return (
      <LegacyRelativeTimestamp
        {...props}
        timestamp={dateString}
        futureDate={isFuture}
      />
    );
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

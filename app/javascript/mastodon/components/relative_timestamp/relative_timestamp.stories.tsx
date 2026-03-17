import type { Meta, StoryObj } from '@storybook/react-vite';

import { RelativeTimestamp as LegacyRelativeTimestamp } from '../relative_timestamp';

import { RelativeTimestamp } from './index';

const defaultTimestamp = new Date(1772449618000).toISOString();

const meta = {
  title: 'Components/RelativeTimestamp',
  component: RelativeTimestamp,
  args: {
    timestamp: defaultTimestamp,
    short: true,
  },
  argTypes: {
    timestamp: {
      control: 'date',
    },
  },
  render(props) {
    const { timestamp } = props;
    if (!timestamp) {
      return <span>Invalid timestamp</span>;
    }
    const dateString = toDateString(timestamp);

    return <RelativeTimestamp {...props} timestamp={dateString} />;
  },
} satisfies Meta<typeof RelativeTimestamp>;

export default meta;

type Story = StoryObj<typeof RelativeTimestamp>;

export const Plain: Story = {};

export const DateOnly: Story = {
  render(props) {
    const { timestamp } = props;
    if (!timestamp) {
      return <span>Invalid timestamp</span>;
    }
    const dateTimeString = toDateString(timestamp);

    const dateString = dateTimeString.split('T')[0];
    if (!dateString) {
      return <span>Invalid timestamp</span>;
    }

    return <RelativeTimestamp {...props} timestamp={dateString} />;
  },
};

export const Legacy: Story = {
  render(props) {
    const { timestamp } = props;
    if (!timestamp) {
      return <span>Invalid timestamp</span>;
    }
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
function toDateString(timestamp: number | string) {
  if (typeof timestamp === 'number') {
    return new Date(timestamp).toISOString();
  }
  return timestamp;
}

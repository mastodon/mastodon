import type { Meta, StoryObj } from '@storybook/react-vite';

import { A11yLiveRegion } from '.';

const meta = {
  title: 'Components/A11yLiveRegion',
  component: A11yLiveRegion,
} satisfies Meta<typeof A11yLiveRegion>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Polite: Story = {
  args: {
    children: "This field can't be empty.",
  },
};

export const Assertive: Story = {
  args: {
    ...Polite.args,
    role: 'alert',
  },
};

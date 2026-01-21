import type { Meta, StoryObj } from '@storybook/react-vite';

import { Callout } from '.';

const meta = {
  title: 'Components/Callout',
  args: {
    children: 'Contents here',
  },
  component: Callout,
} satisfies Meta<typeof Callout>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};

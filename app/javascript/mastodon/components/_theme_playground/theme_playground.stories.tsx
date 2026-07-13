import type { Meta, StoryObj } from '@storybook/react-vite';

import { ThemePlayground } from './index';

const meta = {
  title: 'Components/ThemePlayground',
  component: ThemePlayground,
  parameters: {
    layout: 'fullscreen',
  },
} satisfies Meta<typeof ThemePlayground>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};

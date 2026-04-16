import type { Meta, StoryObj } from '@storybook/react-vite';
import { action } from 'storybook/actions';

import { Button } from '../button';

import { EmptyState } from '.';

const meta = {
  title: 'Components/EmptyState',
  component: EmptyState,
  argTypes: {
    title: {
      control: 'text',
      type: 'string',
      table: {
        type: { summary: 'string' },
      },
    },
  },
} satisfies Meta<typeof EmptyState>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {
    message: 'Try clearing filters or refreshing the page.',
  },
};

export const WithAction: Story = {
  args: {
    ...Default.args,
    // eslint-disable-next-line react/jsx-no-bind
    children: <Button onClick={() => action('Refresh')}>Refresh</Button>,
  },
};

export const WithoutImage: Story = {
  args: {
    ...Default.args,
    image: null,
  },
};

export const WithoutMessage: Story = {
  args: {
    ...Default.args,
    message: undefined,
  },
};

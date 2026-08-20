import type { Meta, StoryObj } from '@storybook/react-vite';

import { CalloutInline } from '.';

const meta = {
  title: 'Components/CalloutInline',
  args: {
    children: 'Contents here',
  },
  component: CalloutInline,
} satisfies Meta<typeof CalloutInline>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Error: Story = {
  args: {
    variant: 'error',
  },
};

export const Warning: Story = {
  args: {
    variant: 'warning',
  },
};

export const Success: Story = {
  args: {
    variant: 'success',
  },
};

export const Info: Story = {
  args: {
    variant: 'info',
  },
};

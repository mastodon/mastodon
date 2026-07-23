import type { Meta, StoryObj } from '@storybook/react-vite';

import { RedesignComposeForm } from '.';

const meta = {
  title: 'Redesign/Compose',
  component: RedesignComposeForm,
  render() {
    return (
      <div style={{ width: '40vw' }}>
        <RedesignComposeForm />
      </div>
    );
  },
  parameters: {
    redesign: true,
  },
} satisfies Meta<typeof RedesignComposeForm>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Post: Story = {};

export const Reply: Story = {
  parameters: {
    state: {
      compose: {
        in_reply_to: '1',
      },
    },
  },
};

export const Message: Story = {
  parameters: {
    state: {
      compose: {
        privacy: 'direct',
      },
    },
  },
};

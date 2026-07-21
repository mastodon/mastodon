import type { Meta, StoryObj } from '@storybook/react-vite';

import { RedesignComposeForm } from '.';

const meta = {
  title: 'Compose/Redesign',
  component: RedesignComposeForm,
  render() {
    return (
      <div style={{ width: '40vw' }}>
        <RedesignComposeForm />
      </div>
    );
  },
} satisfies Meta<typeof RedesignComposeForm>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};

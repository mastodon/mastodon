import type { Meta, StoryObj } from '@storybook/react-vite';

import { Details } from './index';

const meta = {
  component: Details,
  title: 'Components/Details',
  args: {
    summary: 'Here is the summary title',
    children: (
      <p>
        And here are the details that are hidden until you click the summary.
      </p>
    ),
  },
  render(props) {
    return (
      <div style={{ width: '400px' }}>
        <Details {...props} />
      </div>
    );
  },
} satisfies Meta<typeof Details>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Plain: Story = {};

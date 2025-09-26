import type { Meta, StoryObj } from '@storybook/react-vite';
import { expect } from 'storybook/test';

import { HTMLBlock } from './index';

const meta = {
  title: 'Components/HTMLBlock',
  component: HTMLBlock,
  args: {
    contents:
      '<p>Hello, world!</p>\n<p><a href="#">A link</a></p>\n<p>This should be filtered out: <button>Bye!</button></p>',
  },
  render(args) {
    return (
      // Just for visual clarity in Storybook.
      <div
        style={{
          border: '1px solid black',
          padding: '1rem',
          minWidth: '300px',
        }}
      >
        <HTMLBlock {...args} />
      </div>
    );
  },
} satisfies Meta<typeof HTMLBlock>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {
  async play({ canvas }) {
    const link = canvas.queryByRole('link');
    await expect(link).toBeInTheDocument();
    const button = canvas.queryByRole('button');
    await expect(button).not.toBeInTheDocument();
  },
};

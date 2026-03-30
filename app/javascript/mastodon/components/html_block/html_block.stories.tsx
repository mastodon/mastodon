import type { Meta, StoryObj } from '@storybook/react-vite';
import { expect } from 'storybook/test';

import { HTMLBlock } from './index';

const meta = {
  title: 'Components/HTMLBlock',
  component: HTMLBlock,
  args: {
    htmlString: `<p>Hello, world!</p>
<p><a href="#">A link</a></p>
<p>This should be filtered out: <button>Bye!</button></p>
<p>This also has emoji: 🖤</p>`,
  },
  argTypes: {
    extraEmojis: {
      table: {
        disable: true,
      },
    },
    onElement: {
      table: {
        disable: true,
      },
    },
    onAttribute: {
      table: {
        disable: true,
      },
    },
  },
  render(args) {
    return (
      // Just for visual clarity in Storybook.
      <HTMLBlock
        {...args}
        style={{
          border: '1px solid black',
          padding: '1rem',
          minWidth: '300px',
        }}
      />
    );
  },
  // Force Twemoji to demonstrate emoji rendering.
  parameters: {
    state: {
      meta: {
        emoji_style: 'twemoji',
      },
    },
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

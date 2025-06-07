import type { Meta, StoryObj } from '@storybook/react-vite';
import { fn, expect } from 'storybook/test';

import { Button } from '.';

const meta = {
  title: 'Components/Button',
  component: Button,
  args: {
    secondary: false,
    compact: false,
    dangerous: false,
    disabled: false,
    onClick: fn(),
  },
  argTypes: {
    text: {
      control: 'text',
      type: 'string',
      description:
        'Alternative way of specifying the button label. Will override `children` if provided.',
    },
    type: {
      type: 'string',
      control: 'text',
      table: {
        type: { summary: 'string' },
      },
    },
  },
  tags: ['test'],
} satisfies Meta<typeof Button>;

export default meta;

type Story = StoryObj<typeof meta>;

const buttonTest: Story['play'] = async ({ args, canvas, userEvent }) => {
  await userEvent.click(canvas.getByRole('button'));
  await expect(args.onClick).toHaveBeenCalled();
};

const disabledButtonTest: Story['play'] = async ({
  args,
  canvas,
  userEvent,
}) => {
  await userEvent.click(canvas.getByRole('button'));
  await expect(args.onClick).not.toHaveBeenCalled();
};

export const Primary: Story = {
  args: {
    children: 'Primary button',
  },
  play: buttonTest,
};

export const Secondary: Story = {
  args: {
    secondary: true,
    children: 'Secondary button',
  },
  play: buttonTest,
};

export const Compact: Story = {
  args: {
    compact: true,
    children: 'Compact button',
  },
  play: buttonTest,
};

export const Dangerous: Story = {
  args: {
    dangerous: true,
    children: 'Dangerous button',
  },
  play: buttonTest,
};

export const PrimaryDisabled: Story = {
  args: {
    ...Primary.args,
    disabled: true,
  },
  play: disabledButtonTest,
};

export const SecondaryDisabled: Story = {
  args: {
    ...Secondary.args,
    disabled: true,
  },
  play: disabledButtonTest,
};

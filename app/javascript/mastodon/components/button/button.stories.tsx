import type { Meta, StoryObj } from '@storybook/react-vite';
import { fn } from 'storybook/test';

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
} satisfies Meta<typeof Button>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Primary: Story = {
  args: {
    children: 'Button',
  },
};

export const Secondary: Story = {
  args: {
    secondary: true,
    children: 'Button',
  },
};

export const Compact: Story = {
  args: {
    compact: true,
    children: 'Button',
  },
};

export const Dangerous: Story = {
  args: {
    dangerous: true,
    children: 'Button',
  },
};

export const PrimaryDisabled: Story = {
  args: {
    ...Primary.args,
    disabled: true,
  },
};

export const SecondaryDisabled: Story = {
  args: {
    ...Secondary.args,
    disabled: true,
  },
};

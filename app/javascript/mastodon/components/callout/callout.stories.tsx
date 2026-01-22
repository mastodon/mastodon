import type { Meta, StoryObj } from '@storybook/react-vite';
import { action } from 'storybook/actions';

import { Callout } from '.';

const meta = {
  title: 'Components/Callout',
  args: {
    children: 'Contents here',
    title: 'Title',
    primaryAction: action('Primary Action Clicked'),
    primaryLabel: 'Primary Action',
    secondaryAction: action('Secondary Action Clicked'),
    secondaryLabel: 'Secondary Action',
    noClose: false,
  },
  component: Callout,
} satisfies Meta<typeof Callout>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {
    variant: 'default',
  },
};

export const NoIcon: Story = {
  args: {
    icon: false,
  },
};

export const NoActions: Story = {
  args: {
    primaryAction: undefined,
    secondaryAction: undefined,
  },
};

export const Subtle: Story = {
  args: {
    variant: 'subtle',
  },
};

export const Feature: Story = {
  args: {
    variant: 'feature',
  },
};

export const Inverted: Story = {
  args: {
    variant: 'inverted',
  },
};

export const Success: Story = {
  args: {
    variant: 'success',
  },
};

export const Warning: Story = {
  args: {
    variant: 'warning',
  },
};

export const Error: Story = {
  args: {
    variant: 'error',
  },
};

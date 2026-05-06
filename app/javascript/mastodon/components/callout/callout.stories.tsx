import type { Meta, StoryObj } from '@storybook/react-vite';
import { action } from 'storybook/actions';

import { Callout } from '.';

const meta = {
  title: 'Components/Callout',
  args: {
    children: 'Contents here',
    title: 'Title',
    onPrimary: action('Primary action clicked'),
    primaryLabel: 'Primary',
    onSecondary: action('Secondary action clicked'),
    secondaryLabel: 'Secondary',
    onClose: action('Close clicked'),
  },
  component: Callout,
  render(args) {
    return (
      <div style={{ minWidth: 'min(400px, calc(100vw - 2rem))' }}>
        <Callout {...args} />
      </div>
    );
  },
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
    onPrimary: undefined,
    onSecondary: undefined,
  },
};

export const OnlyText: Story = {
  args: {
    onClose: undefined,
    onPrimary: undefined,
    onSecondary: undefined,
    icon: false,
  },
};

// export const Subtle: Story = {
//   args: {
//     variant: 'subtle',
//   },
// };

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

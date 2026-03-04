import type { Meta, StoryObj } from '@storybook/react-vite';

import { CharacterCounter } from './index';

const meta = {
  component: CharacterCounter,
  title: 'Components/CharacterCounter',
} satisfies Meta<typeof CharacterCounter>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Required: Story = {
  args: {
    currentLength: 50,
    maxLength: 100,
  },
};

export const ExceedingLimit: Story = {
  args: {
    currentLength: 120,
    maxLength: 100,
  },
};

export const Recommended: Story = {
  args: {
    currentLength: 100,
    maxLength: 80,
    recommended: true,
  },
};

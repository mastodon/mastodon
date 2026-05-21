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
    currentString: 'Hello, world!',
    maxLength: 100,
  },
};

export const ExceedingLimit: Story = {
  args: {
    currentString: 'Hello, world!',
    maxLength: 10,
  },
};

export const Recommended: Story = {
  args: {
    currentString: 'Hello, world!',
    maxLength: 10,
    recommended: true,
  },
};

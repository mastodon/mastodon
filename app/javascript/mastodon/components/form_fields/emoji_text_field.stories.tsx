import { useState } from 'react';

import type { Meta, StoryObj } from '@storybook/react-vite';

import type { EmojiInputProps } from './emoji_text_field';
import { EmojiTextAreaField, EmojiTextInputField } from './emoji_text_field';

const meta = {
  title: 'Components/Form Fields/EmojiTextInputField',
  args: {
    label: 'Label',
    hint: 'Hint text',
    value: 'Insert text with emoji',
  },
  render({ value: initialValue = '', ...args }) {
    const [value, setValue] = useState(initialValue);
    return <EmojiTextInputField {...args} value={value} onChange={setValue} />;
  },
} satisfies Meta<EmojiInputProps & { disabled?: boolean }>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Simple: Story = {};

export const WithMaxLength: Story = {
  args: {
    maxLength: 20,
  },
};

export const WithRecommended: Story = {
  args: {
    maxLength: 20,
    recommended: true,
  },
};

export const Disabled: Story = {
  args: {
    disabled: true,
  },
};

export const TextArea: Story = {
  render(args) {
    const [value, setValue] = useState('Insert text with emoji');
    return (
      <EmojiTextAreaField
        {...args}
        value={value}
        onChange={setValue}
        label='Label'
        maxLength={100}
      />
    );
  },
};

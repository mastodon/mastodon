import type { Meta, StoryObj } from '@storybook/react-vite';

import { TextInputField, TextInput } from './text_input_field';

const meta = {
  title: 'Components/Form Fields/TextInputField',
  component: TextInputField,
  args: {
    label: 'Label',
    hint: 'This is a description of this form field',
  },
} satisfies Meta<typeof TextInputField>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Simple: Story = {};

export const WithoutHint: Story = {
  args: {
    hint: undefined,
  },
};

export const Required: Story = {
  args: {
    required: true,
  },
};

export const Optional: Story = {
  args: {
    required: false,
  },
};

export const WithError: Story = {
  args: {
    required: false,
    hasError: true,
  },
};

export const Plain: Story = {
  render(args) {
    return <TextInput {...args} />;
  },
};

export const Disabled: Story = {
  ...Plain,
  args: {
    disabled: true,
    defaultValue: "This value can't be changed",
  },
};

import type { Meta, StoryObj } from '@storybook/react-vite';

import { TextAreaField, TextArea } from './text_area_field';

const meta = {
  title: 'Components/Form Fields/TextAreaField',
  component: TextAreaField,
  args: {
    label: 'Label',
    hint: 'This is a description of this form field',
  },
} satisfies Meta<typeof TextAreaField>;

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

export const AutoSize: Story = {
  args: {
    autoSize: true,
    defaultValue: 'This textarea will grow as you type more lines.',
  },
};

export const Plain: Story = {
  render(args) {
    return <TextArea {...args} />;
  },
};

export const Disabled: Story = {
  ...Plain,
  args: {
    disabled: true,
    defaultValue: "This value can't be changed",
  },
};

import type { Meta, StoryObj } from '@storybook/react-vite';

import { Toggle, ToggleField } from './toggle_field';

const meta = {
  title: 'Components/Form Fields/ToggleField',
  component: ToggleField,
  args: {
    label: 'Label',
    hint: 'This is a description of this form field',
    disabled: false,
    size: 'lg',
  },
  argTypes: {
    size: {
      control: { type: 'radio' },
      options: ['sm', 'lg'],
    },
  },
} satisfies Meta<typeof ToggleField>;

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
    status: 'error',
  },
};

export const Disabled: Story = {
  args: {
    disabled: true,
    checked: true,
  },
};

export const Plain: Story = {
  render(props) {
    return <Toggle {...props} />;
  },
};

export const Small: Story = {
  args: {
    size: 'sm',
  },
};

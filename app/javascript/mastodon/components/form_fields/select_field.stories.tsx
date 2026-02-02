import type { Meta, StoryObj } from '@storybook/react-vite';

import { SelectField, Select } from './select_field';

const meta = {
  title: 'Components/Form Fields/SelectField',
  component: SelectField,
  args: {
    label: 'Fruit preference',
    hint: 'Select your favourite fruit or not. Up to you.',
    children: (
      <>
        <option>Apple</option>
        <option>Banana</option>
        <option>Kiwi</option>
        <option>Lemon</option>
        <option>Mango</option>
        <option>Orange</option>
        <option>Pomelo</option>
        <option>Strawberries</option>
        <option>Something else</option>
      </>
    ),
  },
} satisfies Meta<typeof SelectField>;

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
    return <Select {...args} />;
  },
};

export const Disabled: Story = {
  ...Plain,
  args: {
    disabled: true,
  },
};

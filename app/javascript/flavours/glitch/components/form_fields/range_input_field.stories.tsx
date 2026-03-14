import type { Meta, StoryObj } from '@storybook/react-vite';

import { RangeInputField } from './range_input_field';

const meta = {
  title: 'Components/Form Fields/RangeInputField',
  component: RangeInputField,
  args: {
    label: 'Label',
    hint: 'This is a description of this form field',
    checked: false,
    disabled: false,
  },
} satisfies Meta<typeof RangeInputField>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Simple: Story = {};

export const Markers: Story = {
  args: {
    markers: [
      { value: 0, label: 'None' },
      { value: 25, label: 'Some' },
      { value: 50, label: 'Half' },
      { value: 75, label: 'Most' },
      { value: 100, label: 'All' },
    ],
  },
};

import type { Meta, StoryObj } from '@storybook/react-vite';

import { SelectField } from './select_field';

const meta = {
  title: 'Components/Form Fields/SelectField',
  component: SelectField,
  args: {
    label: 'Fruit preference',
    hint: 'Select your favourite fruit or not. Up to you.',
  },
  render(args) {
    // Component styles require a wrapper class at the moment
    return (
      <div className='simple_form'>
        <SelectField {...args}>
          <option>Apple</option>
          <option>Banana</option>
          <option>Kiwi</option>
          <option>Lemon</option>
          <option>Mango</option>
          <option>Orange</option>
          <option>Pomelo</option>
          <option>Strawberries</option>
          <option>Something else</option>
        </SelectField>
      </div>
    );
  },
} satisfies Meta<typeof SelectField>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Simple: Story = {};

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

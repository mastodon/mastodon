import type { Meta, StoryObj } from '@storybook/react-vite';

import { TextInputField } from './text_input_field';

const meta = {
  title: 'Components/Form Fields/TextInputField',
  component: TextInputField,
  render(args) {
    // Component styles require a wrapper class at the moment
    return (
      <div className='simple_form'>
        <TextInputField {...args} />
      </div>
    );
  },
} satisfies Meta<typeof TextInputField>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Simple: Story = {
  args: {
    label: 'Label',
    hint: 'This is a description of this form field',
  },
};

export const Required: Story = {
  args: {
    label: 'Label',
    hint: 'This is a description of this form field',
    required: true,
  },
};

export const Optional: Story = {
  args: {
    label: 'Label',
    hint: 'This is a description of this form field',
    required: false,
  },
};

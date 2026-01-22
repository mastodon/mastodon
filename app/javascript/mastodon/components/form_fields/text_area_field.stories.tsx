import type { Meta, StoryObj } from '@storybook/react-vite';

import { TextAreaField } from './text_area_field';

const meta = {
  title: 'Components/Form Fields/TextAreaField',
  component: TextAreaField,
  render(args) {
    // Component styles require a wrapper class at the moment
    return (
      <div className='simple_form'>
        <TextAreaField {...args} />
      </div>
    );
  },
} satisfies Meta<typeof TextAreaField>;

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

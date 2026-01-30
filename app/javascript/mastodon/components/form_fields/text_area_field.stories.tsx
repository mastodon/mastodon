import type { Meta, StoryObj } from '@storybook/react-vite';

import { TextAreaField } from './text_area_field';

const meta = {
  title: 'Components/Form Fields/TextAreaField',
  component: TextAreaField,
  args: {
    label: 'Label',
    hint: 'This is a description of this form field',
  },
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

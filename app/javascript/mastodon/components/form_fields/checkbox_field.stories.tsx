import type { Meta, StoryObj } from '@storybook/react-vite';

import { Checkbox, CheckboxField } from './checkbox_field';
import { Fieldset } from './fieldset';

const meta = {
  title: 'Components/Form Fields/CheckboxField',
  component: CheckboxField,
  args: {
    label: 'Label',
    hint: 'This is a description of this form field',
    disabled: false,
  },
  argTypes: {
    size: {
      control: { type: 'range', min: 10, max: 64, step: 1 },
    },
  },
} satisfies Meta<typeof CheckboxField>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Simple: Story = {};

export const WithoutHint: Story = {
  args: {
    hint: undefined,
  },
};

export const InFieldset: Story = {
  render() {
    return (
      <Fieldset
        legend='Choose your options'
        hint='This is a description of this set of options'
      >
        <CheckboxField label='Option 1' />
        <CheckboxField label='Option 2' />
        <CheckboxField label='Option 3' defaultChecked />
      </Fieldset>
    );
  },
};

export const InFieldsetHorizontal: Story = {
  render() {
    return (
      <Fieldset
        legend='Choose your options'
        hint='This is a description of this set of options'
        layout='horizontal'
      >
        <CheckboxField label='Option 1' />
        <CheckboxField label='Option 2' />
        <CheckboxField label='Option 3' defaultChecked />
      </Fieldset>
    );
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

export const DisabledChecked: Story = {
  args: {
    disabled: true,
    checked: true,
  },
};

export const DisabledUnchecked: Story = {
  args: {
    disabled: true,
    checked: false,
  },
};

export const Indeterminate: Story = {
  args: {
    indeterminate: true,
  },
};

export const Plain: Story = {
  render(props) {
    return <Checkbox {...props} />;
  },
};

export const Small: Story = {
  args: {
    size: 14,
  },
};

export const Large: Story = {
  args: {
    size: 36,
  },
};

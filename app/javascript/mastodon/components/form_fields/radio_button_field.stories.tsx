import type { Meta, StoryObj } from '@storybook/react-vite';

import { Fieldset } from './fieldset';
import { RadioButton, RadioButtonField } from './radio_button_field';

const meta = {
  title: 'Components/Form Fields/RadioButtonField',
  component: RadioButtonField,
  args: {
    label: 'Label',
    hint: 'This is a description of this form field',
    checked: false,
    disabled: false,
  },
  argTypes: {
    size: {
      control: { type: 'range', min: 10, max: 64, step: 1 },
    },
  },
} satisfies Meta<typeof RadioButtonField>;

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
        legend='Choose one option'
        hint='This is a description of this set of options'
      >
        <RadioButtonField label='Option 1' defaultChecked />
        <RadioButtonField label='Option 2' />
        <RadioButtonField label='Option 3' />
      </Fieldset>
    );
  },
};

export const InFieldsetHorizontal: Story = {
  render() {
    return (
      <Fieldset
        legend='Choose one option'
        hint='This is a description of this set of options'
        layout='horizontal'
      >
        <RadioButtonField label='Option 1' defaultChecked />
        <RadioButtonField label='Option 2' />
        <RadioButtonField label='Option 3' />
      </Fieldset>
    );
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

export const Plain: Story = {
  render(props) {
    return <RadioButton {...props} />;
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

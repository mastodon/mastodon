import type { Meta, StoryObj } from '@storybook/react-vite';

import CheckIcon from '@/material-icons/400-24px/check.svg?react';

import { Fieldset } from './fieldset';
import { RadioButtonField, TextInputField, ToggleField } from './redesign';

interface FieldProps {
  label: string;
  hint?: string;
  disabled?: boolean;
}

const meta = {
  title: 'Redesign/Form Fields',
  // eslint-disable-next-line @typescript-eslint/no-unused-vars -- We need to add args or TS doesn't see it in other render functions.
  render(args) {
    return <>Empty</>; // Override elsewhere
  },
  args: {
    label: 'Label',
    hint: 'This is a description of this form field',
    disabled: false,
  },
  parameters: {
    redesign: true,
  },
} satisfies Meta<FieldProps>;

export default meta;

type Story = StoryObj<typeof meta>;

export const RadioButton: Story = {
  render(args) {
    return (
      <Fieldset name='test' legend='Test radio'>
        <RadioButtonField {...args} icon={CheckIcon} defaultChecked />
        <RadioButtonField {...args} icon={CheckIcon} />
      </Fieldset>
    );
  },
};

export const TextInput: Story = {
  render(args) {
    return <TextInputField {...args} />;
  },
};

export const Toggle: Story = {
  render(args) {
    return <ToggleField {...args} />;
  },
};

export const ToggleSmall: Story = {
  render(args) {
    return <ToggleField {...args} size='sm' />;
  },
};

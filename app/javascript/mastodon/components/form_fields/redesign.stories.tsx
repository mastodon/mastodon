import type { Meta, StoryObj } from '@storybook/react-vite';

import { ToggleField } from './redesign';

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
} satisfies Meta<FieldProps>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Toggle: Story = {
  render(args) {
    return <ToggleField {...args} />;
  },
};

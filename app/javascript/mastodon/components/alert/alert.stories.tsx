import type { Meta, StoryObj } from '@storybook/react-vite';
import { fn, expect } from 'storybook/test';

import { Alert } from '.';

const meta = {
  title: 'Components/Alert',
  component: Alert,
  args: {
    isActive: true,
    isLoading: false,
    animateFrom: 'side',
    title: '',
    message: '',
    action: '',
    onActionClick: fn(),
  },
  argTypes: {
    isActive: {
      control: 'boolean',
      type: 'boolean',
      description: 'Animate to the active (displayed) state of the alert',
    },
    isLoading: {
      control: 'boolean',
      type: 'boolean',
      description:
        'Display a loading indicator in the alert, replacing the dismiss button if present',
    },
    animateFrom: {
      control: 'radio',
      type: 'string',
      options: ['side', 'below'],
      description:
        'Direction that the alert animates in from when activated. `side` is dependent on reading direction, defaulting to left in ltr languages.',
    },
    title: {
      control: 'text',
      type: 'string',
      description: '(Optional) title of the alert',
    },
    message: {
      control: 'text',
      type: 'string',
      description: 'Main alert text',
    },
    action: {
      control: 'text',
      type: 'string',
      description:
        'Label of the alert action (requires `onActionClick` handler)',
    },
  },
  tags: ['test'],
} satisfies Meta<typeof Alert>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Simple: Story = {
  args: {
    message: 'Post published.',
  },
  render: (args) => (
    <div style={{ overflow: 'clip', padding: '1rem' }}>
      <Alert {...args} />
    </div>
  ),
};

export const WithAction: Story = {
  args: {
    ...Simple.args,
    action: 'Open',
  },
  render: Simple.render,
  play: async ({ args, canvas, userEvent }) => {
    const button = await canvas.findByRole('button', { name: 'Open' });
    await userEvent.click(button);
    await expect(args.onActionClick).toHaveBeenCalled();
  },
};

export const WithTitle: Story = {
  args: {
    title: 'Warning:',
    message: 'This is an alert',
  },
  render: Simple.render,
};

export const WithDismissButton: Story = {
  args: {
    message: 'More replies found',
    action: 'Show',
    onDismiss: fn(),
  },
  render: Simple.render,
};

export const InSizedContainer: Story = {
  args: WithDismissButton.args,
  render: (args) => (
    <div
      style={{
        overflow: 'clip',
        padding: '1rem',
        width: '380px',
        maxWidth: '100%',
        boxSizing: 'border-box',
      }}
    >
      <Alert {...args} />
    </div>
  ),
};

export const WithLoadingIndicator: Story = {
  args: {
    ...WithDismissButton.args,
    isLoading: true,
  },
  render: InSizedContainer.render,
};

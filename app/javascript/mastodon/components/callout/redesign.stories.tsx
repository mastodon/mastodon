import { InfoIcon } from '@phosphor-icons/react';
import type { Meta, StoryObj } from '@storybook/react-vite';
import { fn } from 'storybook/test';

import type { CalloutProps } from './redesign';
import { Callout } from './redesign';

const meta = {
  title: 'Redesign/Callout',
  render(props) {
    const actionProps = props.actionText
      ? fn().mockName('actionClick')
      : undefined;
    const secondaryActionProps = props.secondaryActionText
      ? fn().mockName('secondaryActionClick')
      : undefined;
    return (
      <Callout
        {...props}
        {...actionProps}
        {...secondaryActionProps}
        icon={props.hasIcon ? InfoIcon : undefined}
      />
    );
  },
  args: {
    children: 'Main text goes here',
    actionText: 'Action 1',
    secondaryActionText: 'Action 2',
    hasIcon: false,
  },
  argTypes: {
    children: { control: 'text' },
    size: { control: 'inline-radio', options: ['sm', 'lg'] },
    actionText: { control: 'text' },
    secondaryActionText: { control: 'text', if: { arg: 'size', neq: 'sm' } },
    hasIcon: { control: 'boolean', if: { arg: 'size', neq: 'sm' } },
  },
} satisfies Meta<
  CalloutProps<React.ElementType> & {
    as?: never;
    hasIcon?: boolean;
    children: string;
  }
>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Large: Story = {
  args: {
    size: 'lg',
    hasIcon: true,
  },
};

export const Small: Story = { args: { size: 'sm' } };

import type { Meta, StoryObj } from '@storybook/react-vite';

import { Button } from '../button/redesign';

import type { ModalShellProps } from './redesign';
import { ModalShell, ModalActions, ModalTitle } from './redesign';

const meta = {
  title: 'Redesign/Modal',
  args: {
    actionAlign: 'stretch',
    children: 'This is a modal.',
    elevation: 2,
    maxWidth: 0,
  },
  argTypes: {
    actionAlign: {
      control: 'inline-radio',
      options: ['left', 'right', 'stretch'],
    },
    elevation: {
      control: 'inline-radio',
      options: [1, 2],
    },
  },
  render({ actionAlign, children, ...props }) {
    return (
      <ModalShell {...props}>
        <ModalTitle>Modal Example</ModalTitle>

        {children
          .split('\n')
          .filter((line) => !!line.trim())
          .map((line, index) => (
            <p key={index}>{line}</p>
          ))}

        <ModalActions align={actionAlign}>
          <Button>Cancel</Button>

          <Button variant='solid'>Save</Button>
        </ModalActions>
      </ModalShell>
    );
  },
} satisfies Meta<
  Pick<ModalShellProps, 'elevation' | 'maxWidth'> & {
    children: string;
    actionAlign?: 'left' | 'right' | 'stretch';
  }
>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};

import { UserPlusIcon, DotsThreeIcon } from '@phosphor-icons/react';
import type { Meta, StoryObj } from '@storybook/react-vite';

import type { ColumnHeaderProps } from './index';
import { ColumnHeader, ColumnHeaderButton } from './index';

const meta = {
  title: 'Redesign/ColumnHeader',
  component: ColumnHeader,
  args: {
    title: 'Page title',
  },
  decorators: [
    (Story) => (
      <div style={{ maxWidth: 600, margin: 'auto', padding: 20 }}>
        <Story />
      </div>
    ),
  ],
  parameters: {
    layout: 'fullscreen',
    redesign: true,
  },
} satisfies Meta<ColumnHeaderProps>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};

export const WithBackButton: Story = {
  args: {
    withBackButton: true,
  },
};

export const WithButtons: Story = {
  args: {
    withBackButton: true,
    extraButtons: (
      <>
        <ColumnHeaderButton icon={DotsThreeIcon}>Options</ColumnHeaderButton>
        <ColumnHeaderButton
          showTextOnDesktop
          icon={UserPlusIcon}
          variant='solid'
        >
          Follow
        </ColumnHeaderButton>
      </>
    ),
  },
};

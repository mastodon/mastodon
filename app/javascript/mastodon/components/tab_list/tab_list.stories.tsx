import type { Meta, StoryObj } from '@storybook/react-vite';

import { TabList, TabLink } from './index';

const meta = {
  title: 'Components/TabList',
  component: TabList,
  subcomponents: { TabLink },
} satisfies Meta<typeof TabList>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {
  render: () => (
    <TabList>
      <TabLink to='/'>Activity</TabLink>
      <TabLink to='/media'>Media</TabLink>
      <TabLink to='/featured'>Featured</TabLink>
    </TabList>
  ),
};

export const Plain: Story = {
  render: () => (
    <TabList plain>
      <TabLink to='/'>Activity</TabLink>
      <TabLink to='/media'>Media</TabLink>
      <TabLink to='/featured'>Featured</TabLink>
    </TabList>
  ),
};

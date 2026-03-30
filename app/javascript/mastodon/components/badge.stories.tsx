import type { Meta, StoryObj } from '@storybook/react-vite';

import CelebrationIcon from '@/material-icons/400-24px/celebration-fill.svg?react';

import * as badges from './badge';

const meta = {
  component: badges.Badge,
  title: 'Components/Badge',
  args: {
    label: undefined,
  },
} satisfies Meta<typeof badges.Badge>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {
    label: 'Example',
  },
};

export const Domain: Story = {
  args: {
    ...Default.args,
    domain: 'example.com',
  },
};

export const CustomIcon: Story = {
  args: {
    ...Default.args,
    icon: <CelebrationIcon />,
  },
};

export const Admin: Story = {
  args: {
    roleId: '1',
  },
  render(args) {
    return <badges.AdminBadge {...args} />;
  },
};

export const Group: Story = {
  render(args) {
    return <badges.GroupBadge {...args} />;
  },
};

export const Automated: Story = {
  render(args) {
    return <badges.AutomatedBadge {...args} />;
  },
};

export const Muted: Story = {
  render(args) {
    return <badges.MutedBadge {...args} />;
  },
};

export const MutedWithDate: Story = {
  render(args) {
    const futureDate = new Date(new Date().getFullYear(), 11, 31).toISOString();
    return <badges.MutedBadge {...args} expiresAt={futureDate} />;
  },
};

export const Blocked: Story = {
  render(args) {
    return <badges.BlockedBadge {...args} />;
  },
};

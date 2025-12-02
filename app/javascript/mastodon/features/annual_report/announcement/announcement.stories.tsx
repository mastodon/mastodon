import type { Meta, StoryObj } from '@storybook/react-vite';
import { fn } from 'storybook/test';

import { AnnualReportAnnouncement } from '.';

const meta = {
  title: 'Components/AnnualReportAnnouncement',
  component: AnnualReportAnnouncement,
  args: {
    hasData: false,
    isLoading: false,
    year: '2025',
    onRequestBuild: fn(),
    onOpen: fn(),
  },
} satisfies Meta<typeof AnnualReportAnnouncement>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {
  render: (args) => <AnnualReportAnnouncement {...args} />,
};

export const Loading: Story = {
  args: {
    isLoading: true,
  },
  render: Default.render,
};

export const WithData: Story = {
  args: {
    hasData: true,
  },
  render: Default.render,
};

import type { Meta, StoryObj } from '@storybook/react-vite';

import { accountFactoryState, statusFactoryState } from '@/testing/factories';

import { AnnualReport } from '.';

const meta = {
  title: 'Components/AnnualReport',
  component: AnnualReport,
  args: {
    context: 'standalone',
  },
  parameters: {
    state: {
      accounts: {
        '1': accountFactoryState(),
      },
      statuses: {
        '1': statusFactoryState(),
      },
      annualReport: {
        state: 'available',
        report: {
          schema_version: 2,
          share_url: '#',
          account_id: '1',
          year: 2025,
          data: {
            archetype: 'lurker',
            time_series: [
              {
                month: 1,
                statuses: 0,
                followers: 0,
                following: 0,
              },
              {
                month: 2,
                statuses: 0,
                followers: 0,
                following: 0,
              },
              {
                month: 3,
                statuses: 0,
                followers: 0,
                following: 0,
              },
              {
                month: 4,
                statuses: 0,
                followers: 0,
                following: 0,
              },
              {
                month: 5,
                statuses: 1,
                followers: 1,
                following: 3,
              },
              {
                month: 6,
                statuses: 7,
                followers: 1,
                following: 0,
              },
              {
                month: 7,
                statuses: 2,
                followers: 0,
                following: 0,
              },
              {
                month: 8,
                statuses: 2,
                followers: 0,
                following: 0,
              },
              {
                month: 9,
                statuses: 11,
                followers: 0,
                following: 1,
              },
              {
                month: 10,
                statuses: 12,
                followers: 0,
                following: 1,
              },
              {
                month: 11,
                statuses: 6,
                followers: 0,
                following: 1,
              },
              {
                month: 12,
                statuses: 4,
                followers: 0,
                following: 0,
              },
            ],
            top_hashtags: [
              {
                name: 'Mastodon',
                count: 14,
              },
            ],
            top_statuses: {
              by_reblogs: '1',
              by_replies: '1',
              by_favourites: '1',
            },
          },
        },
      },
    },
  },
} satisfies Meta<typeof AnnualReport>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {
  render: (args) => <AnnualReport {...args} />,
};

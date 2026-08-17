import type { Meta, StoryObj } from '@storybook/react-vite';

import {
  accountFactoryState,
  annualReportFactory,
  statusFactoryState,
} from '@/testing/factories';

import { AnnualReport } from '.';

const SAMPLE_HASHTAG = {
  name: 'Mastodon',
  count: 14,
};

const meta = {
  title: 'Components/AnnualReport',
  component: AnnualReport,
  args: {
    context: 'standalone',
  },
  parameters: {
    state: {
      accounts: {
        '1': accountFactoryState({ display_name: 'Freddie Fruitbat' }),
      },
      statuses: {
        '1': statusFactoryState(),
      },
      annualReport: annualReportFactory({
        top_hashtag: SAMPLE_HASHTAG,
      }),
    },
  },
} satisfies Meta<typeof AnnualReport>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Standalone: Story = {
  args: {
    context: 'standalone',
  },
};

export const InModal: Story = {
  args: {
    context: 'modal',
  },
};

export const ArchetypeOracle: Story = {
  ...InModal,
  parameters: {
    state: {
      annualReport: annualReportFactory({
        archetype: 'oracle',
        top_hashtag: SAMPLE_HASHTAG,
      }),
    },
  },
};

export const NoHashtag: Story = {
  ...InModal,
  parameters: {
    state: {
      annualReport: annualReportFactory({
        archetype: 'booster',
      }),
    },
  },
};

export const NoNewPosts: Story = {
  ...InModal,
  parameters: {
    state: {
      annualReport: annualReportFactory({
        archetype: 'pollster',
        top_hashtag: SAMPLE_HASHTAG,
        without_posts: true,
      }),
    },
  },
};

export const NoNewPostsNoHashtag: Story = {
  ...InModal,
  parameters: {
    state: {
      annualReport: annualReportFactory({
        archetype: 'replier',
        without_posts: true,
      }),
    },
  },
};

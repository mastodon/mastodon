import type { Meta, StoryObj } from '@storybook/react-vite';

import {
  accountFactoryImmutable,
  statusFactoryImmutable,
  statusQuotedFactoryAPI,
} from '@/testing/factories';

import type { StatusQuoteManagerProps } from './status_quoted';
import { StatusQuoteManager } from './status_quoted';

const meta = {
  title: 'Components/Status/StatusQuoteManager',
  render(args) {
    return <StatusQuoteManager {...args} />;
  },
  parameters: {
    state: {
      accounts: {
        '1': accountFactoryImmutable({ id: '1', acct: 'hashtaguser' }),
      },
      statuses: {
        '1': statusFactoryImmutable({
          id: '1',
          language: 'en',
          text: 'Hello world!',
        }),
        '2': statusFactoryImmutable({
          id: '2',
          language: 'en',
          text: 'Quote!',
          quote: {
            state: 'accepted',
            quoted_status: statusQuotedFactoryAPI({ id: '1' }),
          },
        }),
        '1001': statusFactoryImmutable({
          id: '1001',
          language: 'mn-Mong',
          // meaning: Mongolia
          text: 'ᠮᠤᠩᠭᠤᠯ',
        }),
        '1002': statusFactoryImmutable({
          id: '1002',
          language: 'mn-Mong',
          // meaning: All human beings are born free and equal in dignity and rights.
          text: 'ᠬᠦᠮᠦᠨ ᠪᠦᠷ ᠲᠥᠷᠥᠵᠦ ᠮᠡᠨᠳᠡᠯᠡᠬᠦ ᠡᠷᠬᠡ ᠴᠢᠯᠥᠭᠡ ᠲᠡᠢ᠂ ᠠᠳᠠᠯᠢᠬᠠᠨ ᠨᠡᠷ᠎ᠡ ᠲᠥᠷᠥ ᠲᠡᠢ᠂ ᠢᠵᠢᠯ ᠡᠷᠬᠡ ᠲᠡᠢ ᠪᠠᠢᠠᠭ᠃',
        }),
        '1003': statusFactoryImmutable({
          id: '1003',
          language: 'mn-Mong',
          // meaning: Mongolia
          text: 'ᠮᠤᠩᠭᠤᠯ',
          quote: {
            state: 'accepted',
            quoted_status: statusQuotedFactoryAPI({ id: '1002' }),
          },
        }),
      },
    },
  },
} satisfies Meta<StatusQuoteManagerProps>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {
    id: '1',
  },
};

export const Quote: Story = {
  args: {
    id: '2',
  },
};

export const TraditionalMongolian: Story = {
  args: {
    id: '1001',
  },
};

export const LongTraditionalMongolian: Story = {
  args: {
    id: '1002',
  },
};

// TODO: fix quoted rotated Mongolian script text
// https://github.com/mastodon/mastodon/pull/37204#issuecomment-3661767226
export const QuotedTraditionalMongolian: Story = {
  args: {
    id: '1003',
  },
};

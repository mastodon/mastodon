import type { Meta, StoryObj } from '@storybook/react-vite';

import { accountFactoryState, statusFactoryState } from '@/testing/factories';

import type { StatusQuoteManagerProps } from './status_quoted';
import { StatusQuoteManager } from './status_quoted';

const meta = {
  title: 'Components/Status/StatusQuoteManager',
  render(args) {
    return <StatusQuoteManager {...args} />;
  },
  args: {
    id: '1',
  },
  parameters: {
    state: {
      accounts: {
        '1': accountFactoryState({ id: '1', acct: 'hashtaguser' }),
      },
      statuses: {
        '1': statusFactoryState({
          id: '1',
          text: 'Hello world!',
        }),
      },
    },
  },
} satisfies Meta<StatusQuoteManagerProps>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};

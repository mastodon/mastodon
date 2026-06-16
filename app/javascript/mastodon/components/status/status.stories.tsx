import { Map as ImmutableMap } from 'immutable';

import type { Meta, StoryObj } from '@storybook/react-vite';
import { fn } from 'storybook/test';

import { accountFactoryState, statusFactoryState } from '@/testing/factories';

import Status from './index';
import type { StatusComponent, StatusProps } from './types';

const meta = {
  title: 'Components/Status/Status',
  args: {
    status: statusFactoryState(),
    account: accountFactoryState(),
    onReply: fn(),
    onFavourite: fn(),
    onMention: fn(),
    onOpenMedia: fn(),
    onOpenVideo: fn(),
    onQuote: fn(),
    onReblog: fn(),
    onToggleCollapsed: fn(),
    onToggleHidden: fn(),
    onTranslate: fn(),
    onAddFilter: fn(),
    onBlock: fn(),
    onClick: fn(),
    onDelete: fn(),
    onDirect: fn(),
    onEmbed: fn(),
    onHeightChange: fn(),
    onInteractionModal: fn(),
    onPin: fn(),
    deployPictureInPicture: fn(),
    // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
    pictureInPicture: ImmutableMap<'inUse' | 'available', boolean>({
      inUse: false,
      available: true,
      // eslint-disable-next-line @typescript-eslint/no-explicit-any -- Casting to solves infinite recursion errors.
    }) as any,
  } satisfies StatusProps,
  render({ status, account, ...rest }) {
    return (
      <Status
        {...rest}
        status={status.set('account', account)}
        account={account}
      />
    );
  },
} satisfies Meta<StatusComponent>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};

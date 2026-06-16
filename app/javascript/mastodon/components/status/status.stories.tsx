import type { FC } from 'react';
import { useMemo } from 'react';

import { Map as ImmutableMap } from 'immutable';

import type { Meta, StoryObj } from '@storybook/react-vite';
import { fn } from 'storybook/test';

import type { StatusVisibility } from '@/mastodon/api_types/statuses';
import {
  accountFactoryState,
  pollFactory,
  statusFactory,
  statusFactoryState,
} from '@/testing/factories';

import { TypedStatus } from './types';

interface StatusStoryProps {
  visibility: StatusVisibility;
  isFavourited?: boolean;
  isReblogged?: boolean;
  isReply?: boolean;
  isQuote?: boolean;
  isPoll?: boolean;

  attachments?: 'image-1' | 'image-2' | 'image-3' | 'video';
  favouriteCount?: number;
  reblogCount?: number;
  replyCount?: number;

  hasNextReply?: boolean;
  disableActions?: boolean;
}

const StatusStoryComponent: FC<StatusStoryProps> = ({
  visibility,
  isReply,
  isReblogged,
  isFavourited,
  isQuote,
  isPoll,
  hasNextReply,
  favouriteCount = 0,
  replyCount = 0,
  reblogCount = 0,
  disableActions = false,
}) => {
  const { account, status } = useMemo(() => {
    const account = accountFactoryState();
    return {
      account,
      status: statusFactoryState({
        reblogged: isReblogged,
        favourited: isFavourited,
        visibility,
        in_reply_to_account_id: isReply ? '2' : undefined,
        in_reply_to_id: isReply ? '2' : undefined,
        quote: isQuote
          ? {
              state: 'accepted',
              quoted_status: { ...statusFactory(), quote: undefined },
            }
          : undefined,
        favourites_count: favouriteCount,
        reblogs_count: reblogCount,
        replies_count: replyCount,
      }).withMutations((status) => {
        status.set('account', account);
        if (isPoll) {
          status.set('poll', '1');
        }
      }),
    };
  }, [
    favouriteCount,
    isFavourited,
    isPoll,
    isQuote,
    isReblogged,
    isReply,
    reblogCount,
    replyCount,
    visibility,
  ]);

  return (
    <TypedStatus
      {...staticProps}
      status={status}
      account={account}
      previousId={isReply ? '2' : undefined}
      isQuotedPost={isQuote}
      nextInReplyToId={hasNextReply ? '1' : undefined}
      showActions={!disableActions}
      showThread={isReply}
    />
  );
};

const staticProps = {
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
} as const;

const meta = {
  title: 'Components/Status/Status',
  component: StatusStoryComponent,
  argTypes: {
    visibility: {
      text: {
        control: 'text',
      },
      control: 'inline-radio',
      options: [
        'direct',
        'private',
        'public',
        'unlisted',
      ] satisfies StatusVisibility[],
    },
  },
  args: {
    visibility: 'public',
    isQuote: false,
    isReply: false,
    isFavourited: false,
    isPoll: false,
    isReblogged: false,
    hasNextReply: false,
    favouriteCount: 0,
    reblogCount: 0,
    replyCount: 0,
    disableActions: false,
  } satisfies StatusStoryProps,
  parameters: {
    state: {
      polls: {
        '1': pollFactory(),
      },
    },
  },
} satisfies Meta<typeof StatusStoryComponent>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};

export const Reply: Story = {
  args: {
    isReply: true,
  },
};

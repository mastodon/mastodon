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

type ContextTypes =
  | 'account'
  | 'bookmarks'
  | 'detailed'
  | 'favourites'
  | 'home'
  | 'notifications'
  | 'public'
  | 'search'
  | 'thread';

type AttachmentTypes = 'image-1' | 'image-2' | 'image-3' | 'video' | 'audio';

interface StatusStoryProps {
  // Contents
  text: string;
  visibility: StatusVisibility;
  isReply?: boolean;
  isQuote?: boolean;
  isPoll?: boolean;
  attachments?: AttachmentTypes;

  // Interactions
  hasFavourited?: boolean;
  hasReblogged?: boolean;
  hasVoted?: boolean;
  favouriteCount?: number;
  reblogCount?: number;
  replyCount?: number;

  // Display
  hasNextReply?: boolean;
  contextType?: ContextTypes;
  disableActions?: boolean;
}

const StatusStoryComponent: FC<StatusStoryProps> = ({
  text,
  visibility,
  isReply,
  hasReblogged: isReblogged,
  hasFavourited: isFavourited,
  isQuote,
  isPoll,
  hasVoted,
  hasNextReply,
  contextType,
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
        text,
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
          status.set('poll', hasVoted ? '2' : '1');
        }
      }),
    };
  }, [
    favouriteCount,
    hasVoted,
    isFavourited,
    isPoll,
    isQuote,
    isReblogged,
    isReply,
    reblogCount,
    replyCount,
    text,
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
      contextType={contextType}
    />
  );
};

// eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
const staticProps = Object.fromEntries(
  // As Storybook auto-names from args only,
  // we need to manually name these for proper action tracking.
  Object.entries({
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
  } as const)
    .map(([key, value]) => [key, value.mockName(key)])
    .concat([
      [
        'pictureInPicture',
        ImmutableMap<'inUse' | 'available', boolean>({
          inUse: false,
          available: true,
          // eslint-disable-next-line @typescript-eslint/no-explicit-any -- Casting to solves infinite recursion errors.
        }) as any,
      ],
    ]),
);

const categoryContents = {
  table: {
    category: 'contents',
  },
} as const;
const categoryInteraction = {
  table: {
    category: 'interactions',
  },
} as const;
const displayInteraction = {
  table: {
    category: 'display',
  },
} as const;

const meta = {
  title: 'Components/Status/Status',
  component: StatusStoryComponent,
  argTypes: {
    visibility: {
      ...categoryContents,
      control: 'inline-radio',
      options: [
        'direct',
        'private',
        'public',
        'unlisted',
      ] satisfies StatusVisibility[],
    },
    isPoll: categoryContents,
    isQuote: categoryContents,
    isReply: categoryContents,
    text: categoryContents,
    contextType: {
      ...displayInteraction,
      control: 'select',
      options: [
        'account',
        'bookmarks',
        'detailed',
        'favourites',
        'home',
        'notifications',
        'public',
        'search',
        'thread',
      ] satisfies ContextTypes[],
    },
    hasFavourited: categoryInteraction,
    hasReblogged: categoryInteraction,
    hasVoted: {
      ...categoryInteraction,
      if: {
        arg: 'isPoll',
        truthy: true,
      },
    },
    favouriteCount: categoryInteraction,
    reblogCount: categoryInteraction,
    replyCount: categoryInteraction,
    disableActions: displayInteraction,
    hasNextReply: displayInteraction,
  },
  args: {
    text: 'This is a status',
    visibility: 'public',
    contextType: 'home',
    isQuote: false,
    isReply: false,
    hasFavourited: false,
    isPoll: false,
    hasVoted: false,
    hasReblogged: false,
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
        '2': pollFactory({
          voted: true,
          voters_count: 1,
          votes_count: 1,
          own_votes: [0],
        }),
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

export const LongText: Story = {
  args: {
    text: [
      'This is a long-form piece of text that wraps multiple lines.',
      'It is here to test what a longer status looks like.',
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    ].join('\n'),
  },
};

export const Poll: Story = {
  args: {
    isPoll: true,
  },
};

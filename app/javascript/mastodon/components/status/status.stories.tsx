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
  isReblog?: boolean;
  isReply?: boolean;
  isPoll?: boolean;
  isQuote?: boolean;
  attachments?: AttachmentTypes;
  contentWarning?: string;

  // Interactions
  hasFavourited?: boolean;
  hasReblogged?: boolean;
  hasBookmarked?: boolean;
  hasReplied?: boolean;
  hasFilter?: boolean;
  hasVoted?: boolean;
  disableActions?: boolean;
  showTranslate?: boolean;

  // Display
  showThread?: boolean;
  contextType?: ContextTypes;
  showCounters?: boolean;
  favouriteCount?: number;
  reblogCount?: number;
  replyCount?: number;
  hidden?: boolean;
  muted?: boolean;
}

const otherAccount = accountFactoryState({
  id: '2',
  display_name: 'Another user',
});

const StatusStoryComponent: FC<StatusStoryProps> = (props) => {
  const {
    text,
    visibility,
    isReblog,
    isReply,
    isPoll,
    isQuote,
    contentWarning,

    hasFavourited,
    hasReblogged,
    hasBookmarked,
    hasFilter,
    hasVoted,
    showTranslate,
    disableActions = false,

    contextType,
    showThread,
    showCounters,
    favouriteCount = 0,
    replyCount = 0,
    reblogCount = 0,
    hidden,
    muted,
  } = props;
  const { account, status } = useMemo(() => {
    const account = accountFactoryState();
    return {
      account,
      status: statusFactoryState({
        text,
        reblogged: hasReblogged,
        favourited: hasFavourited,
        bookmarked: hasBookmarked,
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
        language: showTranslate ? 'xx' : undefined,
        spoiler_text: contentWarning,
      }).withMutations((status) => {
        status.set('account', account);
        status.set('matched_filters', hasFilter ? ['test'] : false);
        status.set('matched_media_filters', hasFilter ? ['test'] : false);
        status.set('hidden', hidden);

        // StatusActionBar checks specifically for null so undefined doesn't work.
        if (!status.get('in_reply_to_id')) {
          status.set('in_reply_to_id', null);
        }

        if (isReblog) {
          status.set(
            'reblog',
            statusFactoryState({ id: '2' }).set('account', otherAccount),
          );
        }
        if (isPoll) {
          status.set('poll', hasVoted ? '2' : '1');
        }
      }),
    };
  }, [
    text,
    hasReblogged,
    hasFavourited,
    hasBookmarked,
    visibility,
    isReply,
    isQuote,
    favouriteCount,
    reblogCount,
    replyCount,
    showTranslate,
    contentWarning,
    hasFilter,
    hidden,
    isReblog,
    isPoll,
    hasVoted,
  ]);

  return (
    <div style={{ width: 'min(600px, 80vw)' }}>
      <TypedStatus
        {...staticProps}
        key={JSON.stringify(props)} // Update on any props change. Required because Status has updateOnProps set.
        status={status}
        account={isReblog ? account : undefined}
        isQuotedPost={isQuote}
        showActions={!disableActions}
        contextType={contextType}
        withCounters={showCounters}
        // Either we are showing a thread (in a timeline) or it's a full reply chain view.
        showThread={isReply && showThread}
        previousId={isReply && !showThread ? '2' : undefined}
        rootId={isReply && !showThread ? '2' : undefined}
        nextInReplyToId={isReply && !showThread ? '1' : undefined}
        muted={muted}
        hidden={hidden && !contentWarning && !hasFilter}
      />
    </div>
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
const categoryDisplay = {
  table: {
    category: 'display',
  },
} as const;

const meta = {
  title: 'Components/Status/Status',
  component: StatusStoryComponent,
  argTypes: {
    // Contents
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
    isReblog: categoryContents,
    isReply: categoryContents,
    isPoll: categoryContents,
    isQuote: categoryContents,
    text: categoryContents,
    contentWarning: categoryContents,

    // Interactions
    hasFavourited: categoryInteraction,
    hasReblogged: categoryInteraction,
    hasBookmarked: categoryInteraction,
    hasFilter: categoryInteraction,
    hasVoted: {
      ...categoryInteraction,
      if: {
        arg: 'isPoll',
        truthy: true,
      },
    },
    disableActions: categoryInteraction,
    showTranslate: categoryInteraction,

    // Display
    showCounters: categoryDisplay,
    favouriteCount: categoryDisplay,
    reblogCount: categoryDisplay,
    replyCount: categoryDisplay,
    showThread: categoryDisplay,
    contextType: {
      ...categoryDisplay,
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
    hidden: categoryDisplay,
    muted: categoryDisplay,
  },
  args: {
    text: 'This is a status',
    visibility: 'public',
    isReblog: false,
    isReply: false,
    isPoll: false,
    isQuote: false,
    contentWarning: '',

    hasFavourited: false,
    hasReblogged: false,
    hasBookmarked: false,
    hasFilter: false,
    hasVoted: false,
    disableActions: false,
    showTranslate: false,

    favouriteCount: 0,
    reblogCount: 0,
    replyCount: 0,
    showCounters: true,
    contextType: 'home',
    showThread: false,
    hidden: false,
    muted: false,
  } satisfies StatusStoryProps,
  parameters: {
    state: {
      accounts: {
        '2': otherAccount,
      },
      polls: {
        '1': pollFactory(),
        '2': pollFactory({
          voted: true,
          voters_count: 1,
          votes_count: 1,
          own_votes: [0],
        }),
      },
      server: {
        translationLanguages: {
          item: {
            xx: ['en', 'de', 'fr'],
          },
        },
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

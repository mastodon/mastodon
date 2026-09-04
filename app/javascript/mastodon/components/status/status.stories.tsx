import type { FC } from 'react';

import { Map as ImmutableMap } from 'immutable';

import type { Meta, StoryObj } from '@storybook/react-vite';
import { fn } from 'storybook/test';

import type { StatusVisibility } from '@/mastodon/api_types/statuses';
import {
  accountFactoryImmutable,
  pollFactoryImmutable,
  statusFactoryAPI,
  statusFactoryImmutable,
} from '@/testing/factories';

import { StatusRedesign } from './status';
import type { AttachmentArgs } from './testing';
import { attachmentArgTypes, attachmentFactory } from './testing';
import type { StatusContextType } from './types';

interface StatusStoryProps extends AttachmentArgs {
  // Contents
  text: string;
  visibility: StatusVisibility;
  isReblog?: boolean;
  isReply?: boolean;
  isPoll?: boolean;
  isQuote?: boolean;
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
  contextType?: StatusContextType;
  showCounters?: boolean;
  favouriteCount?: number;
  reblogCount?: number;
  replyCount?: number;
  hidden?: boolean;
  muted?: boolean;
  showPrepend?: boolean;
}

const otherAccount = accountFactoryImmutable({
  id: '2',
  display_name: 'Another user',
});

const StatusStoryComponent: FC<StatusStoryProps> = (props) => {
  const {
    isReblog,
    isReply,
    isQuote,
    contentWarning,

    hasFilter,
    disableActions = false,

    contextType,
    showThread,
    showCounters,
    hidden,
    muted,
    showPrepend = true,
  } = props;
  return (
    <StatusRedesign
      {...staticProps}
      id='1'
      accountId={isReblog ? '1' : undefined}
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
      skipPrepend={!showPrepend}
      withDismiss={contextType === 'notifications'}
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
const categoryDisplay = {
  table: {
    category: 'display',
  },
} as const;

const meta = {
  title: 'Redesign/Status',
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
    attachment1: {
      ...categoryContents,
      ...attachmentArgTypes.attachment1,
    },
    attachment2: {
      ...categoryContents,
      ...attachmentArgTypes.attachment2,
    },
    attachment3: {
      ...categoryContents,
      ...attachmentArgTypes.attachment3,
    },
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
    showPrepend: categoryDisplay,
    showThread: {
      ...categoryDisplay,
      if: {
        arg: 'showPrepend',
        truthy: true,
      },
    },
    contextType: {
      ...categoryDisplay,
      control: 'select',
      options: [
        'account',
        'bookmarks',
        'composer',
        'detailed',
        'favourites',
        'home',
        'notifications',
        'public',
        'search',
        'thread',
      ] satisfies StatusContextType[],
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
    attachment1: undefined,
    attachment2: undefined,
    attachment3: undefined,

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
    showPrepend: true,
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
        '1': pollFactoryImmutable(),
        '2': pollFactoryImmutable({
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
    stateFn({
      text,
      contentWarning,
      visibility,
      attachment1,
      attachment2,
      attachment3,
      hasBookmarked,
      hasFavourited,
      hasReblogged,
      isQuote,
      isReply,
      favouriteCount,
      reblogCount,
      replyCount,
      showTranslate,
    }: StatusStoryProps) {
      const account = accountFactoryImmutable();

      const status = statusFactoryImmutable({
        text,
        spoiler_text: contentWarning,
        visibility,
        media_attachments: attachmentFactory(
          attachment1,
          attachment2,
          attachment3,
        ),
        reblogged: hasReblogged,
        favourited: hasFavourited,
        bookmarked: hasBookmarked,
        in_reply_to_account_id: isReply ? '2' : undefined,
        in_reply_to_id: isReply ? '2' : undefined,
        quote: isQuote
          ? {
              state: 'accepted',
              quoted_status: { ...statusFactoryAPI(), quote: undefined },
            }
          : undefined,
        favourites_count: favouriteCount,
        reblogs_count: reblogCount,
        replies_count: replyCount,
        language: showTranslate ? 'xx' : undefined,
      });

      return {
        statuses: {
          '1': status,
        },
        accounts: {
          '1': account,
        },
      };
    },
    controls: {
      disableSaveFromUI: true,
    },
    redesign: true,
  },
  decorators: [
    (Story) => (
      <div style={{ width: 'min(600px, 80vw)' }}>
        <Story />
      </div>
    ),
  ],
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
      'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
      'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
      'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
      'Curabitur pretium tincidunt lacus, nulla gravida orci a odio.',
      'Nullam varius, turpis et commodo pharetra, est eros bibendum elit, nec luctus magna felis sollicitudin mauris.',
      'Integer in mauris eu nibh euismod gravida, duis ac tellus et risus vulputate vehicula.',
      'Donec lobortis risus a elit, etiam tempor.',
      'Vestibulum commodo volutpat a, convallis ac, laoreet enim.',
      'Phasellus fermentum in, dolor pellentesque facilisis.',
      'Integer rutrum, orci vestibulum ullamcorper ultricies, lacus quam ultricies odio, vitae placerat pede sem sit amet enim.',
      'Morbi purus libero, faucibus adipiscing, commodo quis, gravida id, est.',
      'Sed lectus, suspendisse varius enim in eros elementum tristique.',
      'Duis cursus, mi quis viverra ornare, eros dolor interdum nulla, ut commodo diam libero vitae erat.',
      'Aenean faucibus nibh et justo cursus id rutrum lorem imperdiet.',
      'Nunc ut sem vitae risus tristique posuere.',
    ].join('\n'),
  },
};

export const Images: Story = {
  args: {
    attachment1: 'image',
    attachment2: 'image',
    attachment3: 'image',
  },
};

export const Video: Story = {
  args: {
    attachment1: 'video',
  },
};

export const Audio: Story = {
  args: {
    attachment1: 'audio',
  },
};

export const Poll: Story = {
  args: {
    isPoll: true,
    hasVoted: true,
  },
};

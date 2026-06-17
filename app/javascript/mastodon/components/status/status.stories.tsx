import type { FC } from 'react';
import { useMemo } from 'react';

import { Map as ImmutableMap } from 'immutable';

import type { Meta, StoryObj } from '@storybook/react-vite';
import { fn } from 'storybook/test';

import type { ApiMediaAttachmentJSON } from '@/mastodon/api_types/media_attachments';
import type { StatusVisibility } from '@/mastodon/api_types/statuses';
import {
  accountFactoryState,
  mediaAttachmentFactory,
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

type AttachmentTypes =
  | 'image-1'
  | 'image-2'
  | 'image-3'
  | 'video'
  | 'audio'
  | 'gifv'
  | 'unknown';

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
  showPrepend?: boolean;
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
    attachments,
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
    showPrepend = true,
  } = props;
  const { account, status } = useMemo(() => {
    const account = accountFactoryState();

    const media_attachments: ApiMediaAttachmentJSON[] = [];
    switch (attachments) {
      // Use fall through add attachments depending on count.
      case 'image-3':
        media_attachments.push(
          mediaAttachmentFactory({
            id: '2',
            url: 'https://cataas.com/cat/EbVq9zMc4Xxv7s73',
            meta: {
              original: {
                width: 960,
                height: 1280,
                size: '960x1280',
                aspect: 0.75,
              },
            },
          }),
        );
      // eslint-disable-next-line no-fallthrough
      case 'image-2':
        media_attachments.push(
          mediaAttachmentFactory({
            id: '3',
            url: 'https://cataas.com/cat/YFaQ4xWYoWURSz37',
            meta: {
              original: {
                width: 964,
                height: 1280,
                size: '964x1280',
                aspect: 0.753125,
              },
            },
          }),
        );
      // eslint-disable-next-line no-fallthrough
      case 'image-1':
        media_attachments.push(
          mediaAttachmentFactory({
            id: '4',
            url: 'https://cataas.com/cat/bYBTjiFUqjUPIBUD',
            meta: {
              original: {
                width: 1280,
                height: 964,
                size: '1280x964',
                aspect: 1.32780083,
              },
            },
          }),
        );
        break;
      case 'video':
        media_attachments.push(
          mediaAttachmentFactory({
            type: 'video',
            url: 'https://www.pexels.com/download/video/11760787/',
            meta: {
              original: {
                width: 2160,
                height: 4096,
              },
            },
          }),
        );
        break;
      case 'audio':
        media_attachments.push(
          mediaAttachmentFactory({
            type: 'audio',
            url: 'https://upload.wikimedia.org/wikipedia/commons/4/40/Elephant_voice_-_trumpeting.ogg',
          }),
        );
        break;
      case 'gifv':
        media_attachments.push(
          mediaAttachmentFactory({
            type: 'gifv',
            url: 'https://www.pexels.com/download/video/11760787/',
            meta: {
              original: {
                width: 2160,
                height: 4096,
              },
            },
          }),
        );
        break;
      case 'unknown':
        media_attachments.push(mediaAttachmentFactory({ type: attachments }));
        break;
    }

    return {
      account,
      status: statusFactoryState({
        text,
        spoiler_text: contentWarning,
        visibility,
        media_attachments,
        reblogged: hasReblogged,
        favourited: hasFavourited,
        bookmarked: hasBookmarked,
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
    attachments,
    text,
    contentWarning,
    visibility,
    hasReblogged,
    hasFavourited,
    hasBookmarked,
    isReply,
    isQuote,
    favouriteCount,
    reblogCount,
    replyCount,
    showTranslate,
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
        skipPrepend={!showPrepend}
        withDismiss={contextType === 'notifications'}
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
    attachments: {
      ...categoryContents,
      control: 'select',
      options: [
        'One image',
        'Two images',
        'Three images',
        'Video',
        'Audio',
        'GIF',
        'Other',
      ],
      mapping: {
        'One image': 'image-1',
        'Two images': 'image-2',
        'Three images': 'image-3',
        Video: 'video',
        Audio: 'audio',
        GIF: 'gifv',
        Other: 'unknown',
      } satisfies Record<string, AttachmentTypes>,
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
    attachments: undefined,

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
    controls: {
      disableSaveFromUI: true,
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

export const Images: Story = {
  args: {
    attachments: 'image-3',
  },
};

export const Video: Story = {
  args: {
    attachments: 'video',
  },
};

export const Audio: Story = {
  args: {
    attachments: 'audio',
  },
};

export const Poll: Story = {
  args: {
    isPoll: true,
    hasVoted: true,
  },
};

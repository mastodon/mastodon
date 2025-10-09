import type { Meta, StoryObj } from '@storybook/react-vite';

import { HashtagMenuController } from '@/mastodon/features/ui/components/hashtag_menu_controller';

import { HoverCardController } from '../hover_card_controller';

import type { HandledLinkProps } from './handled_link';
import { HandledLink } from './handled_link';

type HandledLinkStoryProps = Pick<HandledLinkProps, 'href' | 'text'> & {
  mentionAccount: 'local' | 'remote' | 'none';
};

const meta = {
  title: 'Components/Status/HandledLink',
  render({ mentionAccount, ...args }) {
    let mention: HandledLinkProps['mention'] | undefined;
    if (mentionAccount === 'local') {
      mention = { id: '1', acct: 'testuser' };
    } else if (mentionAccount === 'remote') {
      mention = { id: '2', acct: 'remoteuser@mastodon.social' };
    }
    return (
      <>
        <HandledLink {...args} mention={mention} hashtagAccountId='1' />
        <HashtagMenuController />
        <HoverCardController />
      </>
    );
  },
  args: {
    href: 'https://example.com/path/subpath?query=1#hash',
    text: 'https://example.com',
    mentionAccount: 'none',
  },
  argTypes: {
    mentionAccount: {
      control: { type: 'select' },
      options: ['local', 'remote', 'none'],
      defaultValue: 'none',
    },
  },
} satisfies Meta<HandledLinkStoryProps>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};

export const Simple: Story = {
  args: {
    href: 'https://example.com/test',
  },
};

export const Hashtag: Story = {
  args: {
    text: '#example',
  },
};

export const Mention: Story = {
  args: {
    text: '@user',
    mentionAccount: 'local',
  },
};

export const InternalLink: Story = {
  args: {
    href: '/about',
    text: 'About',
  },
};

export const InvalidURL: Story = {
  args: {
    href: 'ht!tp://invalid-url',
    text: 'ht!tp://invalid-url -- invalid!',
  },
};
